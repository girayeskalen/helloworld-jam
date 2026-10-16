import Matter from 'matter-js';
import type {
  GameState, InputState, LevelData, PhysicsConstraintState, PhysicsObjectDefinition,
  PhysicsSnapshot, SeismicState, Vec2,
} from '../types/game';

const { Bodies, Body, Composite, Constraint, Engine, Events, Query, Vector } = Matter;
const clamp = (value: number, min: number, max: number) => Math.max(min, Math.min(max, value));
interface Entity {
  definition: PhysicsObjectDefinition; body: Matter.Body;
  integrity: number; maxIntegrity: number; broken: boolean; secured: boolean;
  grounded: boolean; lastImpactTick: number;
  restPosition: Vec2; restAngle: number;
}
interface Link { constraint: Matter.Constraint; spec: PhysicsConstraintState }

/** Matter dünyasının tek sahibi. Kütle/hasar birimleri oyun içindir, yapı analizi değildir. */
export class PhysicsHazardSystem {
  private engine = Engine.create({ positionIterations: 10, velocityIterations: 8, constraintIterations: 6, enableSleeping: false });
  private entities = new Map<string, Entity>();
  private links = new Map<string, Link>();
  private state: GameState | null = null;
  private tick = 0;
  private coyoteTime = 0;
  private jumpHeld = false;
  private gasLeaking = false;
  private ignited = false;
  private lampReleased = false;
  private motion: SeismicState = { x: 0, y: 0, pWave: 0, sWave: 0, intensity: 0 };

  constructor(private readonly level: LevelData) {
    this.engine.gravity.y = 1.12;
    Events.on(this.engine, 'collisionStart', event => this.collisions(event.pairs));
    this.reset();
  }

  reset(): void {
    Composite.clear(this.engine.world, false);
    Engine.clear(this.engine);
    this.engine.world.isModified = true;
    this.engine.timing.timestamp = 0;
    this.entities.clear(); this.links.clear();
    this.tick = 0; this.coyoteTime = 0; this.jumpHeld = false;
    this.gasLeaking = false; this.ignited = false; this.lampReleased = false;
    this.motion = { x: 0, y: 0, pWave: 0, sWave: 0, intensity: 0 };
    for (const definition of this.level.physics!.objects) this.add(definition);
    for (const npc of this.level.npcs) {
      const player = this.add({ id: npc.id, type: 'npc', label: npc.name, x: npc.position.x, y: npc.position.y, width: 20, height: 32, mass: 8, friction: 0.08, integrity: 100 });
      Body.setInertia(player.body, Infinity);
    }
    this.link('column-base', 'ground', 'column', { x: 223, y: -12 }, { x: 0, y: 103 }, 1, 0.95, 3, 'support');
    this.link('column-beam', 'column', 'ceiling-beam', { x: 0, y: -103 }, { x: 0, y: 0 }, 17, 0.9, 0.7, 'support');
    this.link('beam-hanger', 'upper-floor', 'ceiling-beam', { x: 305, y: 9 }, { x: 78, y: 0 }, 21, 0.8, 0.7, 'support');
    for (const id of ['ceiling-a', 'ceiling-b', 'lamp']) {
      const item = this.entities.get(id)!;
      const gap = item.body.position.y - item.definition.height / 2 - 325;
      this.link(`hanger-${id}`, 'upper-floor', id, { x: item.definition.x - 532, y: 9 }, { x: 0, y: -item.definition.height / 2 }, gap, 0.65, id === 'lamp' ? 0.075 : 0.09, 'suspension');
    }
    // Yerçekimiyle başlangıç oturması. Olay ve hasar işlenmez; kayıt bu dengeli konumdan başlar.
    for (let i = 0; i < 90; i++) Engine.update(this.engine, 1000 / 120);
    for (const entity of this.entities.values()) {
      Body.setVelocity(entity.body, { x: 0, y: 0 }); Body.setAngularVelocity(entity.body, 0);
      entity.restPosition = { ...entity.body.position }; entity.restAngle = entity.body.angle;
    }
    Engine.clear(this.engine);
    this.engine.world.isModified = true;
    this.engine.timing.timestamp = 0;
  }

  applyInterventions(state: GameState): void {
    for (const action of this.level.interventions) {
      if (!state.appliedInterventions.includes(action.id)) continue;
      const item = this.entities.get(action.targetId);
      if (action.id.startsWith('anchor-') && item && !item.secured) this.anchor(item);
      if (action.id.startsWith('reinforce-') && item && !item.secured) {
        item.secured = true;
        item.maxIntegrity = item.definition.integrity * 9;
        item.integrity = item.maxIntegrity;
        const ground = this.entities.get('ground')!.body;
        for (const side of [-1, 1]) {
          const point = { x: side * item.definition.width * 0.35, y: -item.definition.height * 0.35 };
          const anchor = { x: item.body.position.x - ground.position.x - side * 34, y: -12 };
          const end = Vector.add(item.body.position, point);
          const length = Vector.magnitude(Vector.sub(end, Vector.add(ground.position, anchor)));
          this.link(`brace-${action.targetId}-${side}`, 'ground', action.targetId, anchor, point, length, 0.92, 5, 'anchor');
        }
      }
      if (action.id === 'gas-sensor' && item) item.secured = true;
    }
  }

  placeInShelter(state: GameState): void {
    const shelter = this.level.physics!.shelters.find(item => item.id === state.selectedShelterId)!;
    for (const npc of state.npcs) {
      if (!npc.coached) continue;
      const player = this.entities.get(npc.id)!.body;
      Body.setPosition(player, shelter.position);
      Body.setVelocity(player, { x: 0, y: 0 });
    }
    this.sync(state);
  }

  update(state: GameState, input: InputState, dt: number): void {
    this.state = state;
    this.tick++;
    const shaking = state.phase === 'FORESIGHT' || state.executionStage === 'SHAKING';
    this.motion = this.wave(shaking ? state.time : this.level.quakeDuration);
    state.seismic = { ...this.motion };
    state.shake = this.motion.intensity * 2;
    for (const item of this.entities.values()) {
      if (item.definition.isStatic) {
        const d = item.definition;
        const position = { x: d.x + this.motion.x, y: d.y + this.motion.y };
        const velocity = Vector.sub(position, item.body.position);
        Body.setPosition(item.body, position);
        Body.setVelocity(item.body, velocity);
      }
    }
    if (shaking) {
      this.emit('quake', 'quake', { x: 532, y: 536 }, 'P dalgası → S dalgası. Yükler temaslar üzerinden aktarılıyor.');
      for (const item of this.entities.values()) {
        if (item.body.isStatic || item.broken || item.definition.type === 'npc') continue;
        const { body, definition } = item;
        // Hareketli temel + yükseklik boyunca göreli kat kesmesi. Kuvvet kütleyle ölçeklenir.
        Body.applyForce(body, { x: body.position.x, y: body.position.y - definition.height * 0.23 }, {
          x: body.mass * this.motion.sWave * 0.0023,
          y: body.mass * this.motion.pWave * 0.0006,
        });
      }
      const column = this.entities.get('column')!;
      const beam = this.entities.get('ceiling-beam')!;
      if (!column.broken && !beam.broken && this.links.has('column-beam')) {
        const cyclicLoad = Math.abs(this.motion.sWave) * beam.body.mass / 7;
        column.integrity = Math.max(0, column.integrity - cyclicLoad * dt);
        if (column.integrity <= 0) this.fracture(column);
      }
      this.checkLinks();
      this.controlDuringQuake(state, input, dt);
    } else {
      this.removeLink('player-grip');
      this.controlEvacuation(state, input, dt);
    }
    // İnce lambalar ve hızlı molozlar için 120 Hz alt adım; kayıt/oynanış 60 Hz.
    const forces = [...this.entities.values()].filter(item => !item.body.isStatic).map(({ body }) => {
      // Aynı toplam itki iki alt adıma yayılır; Matter her update sonunda kuvveti temizler.
      body.force.x *= 0.5; body.force.y *= 0.5; body.torque *= 0.5;
      return { body, force: { ...body.force }, torque: body.torque };
    });
    Engine.update(this.engine, dt * 500);
    for (const { body, force, torque } of forces) if (!body.isStatic) {
      body.force.x += force.x; body.force.y += force.y; body.torque += torque;
    }
    Engine.update(this.engine, dt * 500);
    if (!shaking) this.checkLinks();
    this.checkGrounding();
    if (shaking) this.secondaryHazards(state, dt);
    this.sync(state);
    this.state = null;
  }

  sync(state: GameState): void {
    state.physicsBodies = [...this.entities.values()].map(item => {
      const { body, definition: d } = item;
      const danger = ['cabinet', 'bookcase', 'fridge'].includes(d.type) && !item.secured && !item.broken;
      return {
        id: d.id, type: d.type, label: d.label, x: body.position.x, y: body.position.y,
        width: d.width, height: d.height, angle: body.angle,
        velocity: { ...body.velocity }, angularVelocity: body.angularVelocity,
        mass: body.isStatic ? 0 : body.mass, friction: body.friction,
        isStatic: body.isStatic, isSecured: item.secured, integrity: item.integrity, maxIntegrity: item.maxIntegrity,
        broken: item.broken, grounded: item.grounded,
        dangerArc: danger ? { origin: { x: body.position.x, y: this.level.floorY }, radius: d.height, startAngle: -Math.PI / 2, endAngle: 0 } : null,
        parts: (body.parts.length > 1 ? body.parts.slice(1) : [body]).map(part => part.vertices.map(v => ({ x: v.x, y: v.y }))),
      };
    });
    state.constraints = this.exportLinks();
    state.physicsTick = this.tick;
    state.seismic = { ...this.motion };
    for (const npc of state.npcs) {
      const item = this.entities.get(npc.id)!;
      npc.position = { ...item.body.position };
      npc.velocity = { ...item.body.velocity }; npc.grounded = item.grounded;
      if (npc.health <= 0) npc.status = 'injured';
    }
    state.safeTriangles = this.level.physics!.shelters.map(shelter => {
      const support = this.entities.get(shelter.supportId)!;
      const local = Vector.rotate(Vector.sub(shelter.position, support.restPosition), -support.restAngle);
      const p = Vector.add(support.body.position, Vector.rotate(local, support.body.angle));
      const probe = Bodies.rectangle(p.x, p.y, 18, 29);
      const blockedBy = [...this.entities.values()].filter(item => item !== support && !item.body.isSensor && !item.broken && !['npc', 'gas', 'floor', 'wall'].includes(item.definition.type) && Query.collides(probe, [item.body]).length > 0).map(item => item.definition.id);
      const loadBearing = support.definition.type !== 'column' || this.links.has('column-beam');
      const supported = loadBearing && !support.broken && Math.abs(support.body.angle) < 0.22 && support.integrity > 0;
      const occupied = state.npcs.some(npc => Math.hypot(npc.position.x - p.x, npc.position.y - p.y) < 23);
      return { id: shelter.id, label: shelter.label, supportId: shelter.supportId, position: p,
        polygon: [{ x: p.x - 25, y: p.y + 16 }, { x: p.x + 25, y: p.y + 16 }, { x: p.x + 25, y: p.y - 36 }],
        supported, isClear: supported && blockedBy.length === 0, occupied, blockedBy };
    });
    // Eski sunum sözleşmesi korunur; yeni çizici physicsBodies/parts okur.
    for (const hazard of state.hazards) {
      const item = this.entities.get(hazard.id === 'stairs' ? 'column' : hazard.id);
      if (!item) continue;
      hazard.angle = item.body.angle; hazard.offsetY = item.body.position.y - item.definition.y;
      hazard.velocityY = item.body.velocity.y; hazard.mitigated = item.secured;
      hazard.active = item.broken || Math.abs(item.body.angle) > 0.35 || (hazard.kind === 'gas' && this.gasLeaking);
    }
  }

  capture(): PhysicsSnapshot {
    return {
      bodies: [...this.entities.values()].map(item => ({ id: item.definition.id, definition: structuredClone(item.definition),
        position: { ...item.body.position }, velocity: { ...item.body.velocity }, angle: item.body.angle, angularVelocity: item.body.angularVelocity,
        isStatic: item.body.isStatic, isSensor: item.body.isSensor, collisionMask: item.body.collisionFilter.mask ?? 0xffffffff,
        integrity: item.integrity, maxIntegrity: item.maxIntegrity, broken: item.broken, isSecured: item.secured, lastImpactTick: item.lastImpactTick })),
      constraints: this.exportLinks(), motion: { ...this.motion }, tick: this.tick, jumpHeld: this.jumpHeld,
      coyoteTime: this.coyoteTime, gasLeaking: this.gasLeaking, ignited: this.ignited, lampReleased: this.lampReleased,
    };
  }

  restore(snapshot: PhysicsSnapshot): void {
    // Gövdeler, kırılıp oluşan parçalar ve bağların varlığı dahil geri yüklenir.
    const ids = new Set(snapshot.bodies.map(item => item.id));
    for (const [id, item] of this.entities) if (!ids.has(id)) { Composite.remove(this.engine.world, item.body); this.entities.delete(id); }
    for (const frame of snapshot.bodies) {
      const item = this.entities.get(frame.id) ?? this.add(frame.definition);
      const body = item.body;
      Body.setStatic(body, frame.isStatic);
      Body.setPosition(body, frame.position); Body.setAngle(body, frame.angle);
      Body.setVelocity(body, frame.velocity); Body.setAngularVelocity(body, frame.angularVelocity);
      body.isSensor = frame.isSensor; body.collisionFilter.mask = frame.collisionMask;
      body.force.x = 0; body.force.y = 0; body.torque = 0;
      item.integrity = frame.integrity; item.maxIntegrity = frame.maxIntegrity;
      item.broken = frame.broken; item.secured = frame.isSecured; item.lastImpactTick = frame.lastImpactTick;
    }
    for (const id of [...this.links.keys()]) this.removeLink(id);
    for (const spec of snapshot.constraints) this.link(spec.id, spec.bodyA, spec.bodyB, spec.pointA, spec.pointB, spec.length, spec.stiffness, spec.breakingStrain, spec.kind, spec.damping);
    this.motion = { ...snapshot.motion }; this.tick = snapshot.tick;
    this.jumpHeld = snapshot.jumpHeld; this.coyoteTime = snapshot.coyoteTime;
    this.gasLeaking = snapshot.gasLeaking; this.ignited = snapshot.ignited; this.lampReleased = snapshot.lampReleased;
    Engine.clear(this.engine);
    this.engine.world.isModified = true;
    this.engine.timing.timestamp = snapshot.tick * 1000 / 60;
    this.checkGrounding();
  }

  dispose(): void { Events.off(this.engine, 'collisionStart'); Composite.clear(this.engine.world, false); Engine.clear(this.engine); }

  private add(definition: PhysicsObjectDefinition): Entity {
    const d = structuredClone(definition);
    const options = { label: d.id, isStatic: d.isStatic ?? false, friction: d.friction, frictionStatic: 0.9, frictionAir: 0.012, restitution: 0.05, slop: 0.02 };
    const body = d.parts ? Body.create({ ...options, parts: d.parts.map(p => Bodies.rectangle(p.x + p.width / 2, p.y + p.height / 2, p.width, p.height)) }) : Bodies.rectangle(d.x, d.y, d.width, d.height, options);
    if (!body.isStatic) {
      Body.setMass(body, d.mass);
      if (d.centreOffset) {
        Body.setCentre(body, d.centreOffset, true);
        Body.setInertia(body, body.inertia + body.mass * Vector.magnitudeSquared(d.centreOffset));
      }
    }
    if (d.type === 'gas') body.isSensor = true;
    // Kesit kamera: karakter masa ayaklarının önünden/arkasından geçebilir.
    // Masa, diğer eşyalar ve molozlarla tam rijit cisim çarpışmasını korur.
    if (d.type === 'table' || d.type === 'npc') body.collisionFilter.group = -26016;
    const item = { definition: d, body, integrity: d.integrity, maxIntegrity: d.integrity, broken: false, secured: false, grounded: false, lastImpactTick: -100, restPosition: { ...body.position }, restAngle: body.angle };
    this.entities.set(d.id, item); Composite.add(this.engine.world, body);
    return item;
  }

  private wave(t: number): SeismicState {
    if (t >= this.level.quakeDuration) return { x: 0, y: 0, pWave: 0, sWave: 0, intensity: 0 };
    const attack = clamp(t / 0.65, 0, 1);
    const tail = clamp((this.level.quakeDuration - t) / 0.8, 0, 1);
    const seed = this.level.physics!.seed * 0.0001;
    const pWave = Math.sin(t * 28) * Math.exp(-t * 0.45) * attack;
    const pulse = 0.8 * Math.exp(-(((t - 1.2) / 0.38) ** 2));
    const sWave = attack * tail * (0.78 * Math.sin(t * 10) + 0.28 * Math.sin(t * 23.3 + seed) + 0.17 * Math.sin(t * 41.7) + pulse);
    return { x: sWave * 7, y: pWave * 3, pWave, sWave, intensity: Math.min(1, Math.abs(sWave) + Math.abs(pWave) * 0.3) };
  }

  private anchor(item: Entity): void {
    item.secured = true;
    const wall = this.entities.get('wall-left')!.body;
    for (const side of [-1, 1]) {
      const pointB = { x: side * item.definition.width * 0.35, y: -item.definition.height * 0.32 };
      const world = Vector.add(item.body.position, pointB);
      const pointA = { x: world.x - wall.position.x, y: world.y - wall.position.y };
      this.link(`anchor-${item.definition.id}-${side}`, 'wall-left', item.definition.id, pointA, pointB, 0, 0.98, 10, 'anchor');
    }
  }

  private link(id: string, a: string | null, b: string, pointA: Vec2, pointB: Vec2, length: number, stiffness: number, breakingStrain: number, kind: PhysicsConstraintState['kind'], damping = 0.1): void {
    const spec: PhysicsConstraintState = { id, bodyA: a, bodyB: b, pointA: { ...pointA }, pointB: { ...pointB }, length, stiffness, damping, breakingStrain, kind };
    const constraint = Constraint.create({ label: id, bodyA: a ? this.entities.get(a)!.body : undefined, bodyB: this.entities.get(b)!.body, pointA: { ...pointA }, pointB: { ...pointB }, length, stiffness, damping });
    this.links.set(id, { spec, constraint }); Composite.add(this.engine.world, constraint);
  }

  private removeLink(id: string): void {
    const link = this.links.get(id);
    if (link) { Composite.remove(this.engine.world, link.constraint); this.links.delete(id); }
  }

  private exportLinks(): PhysicsConstraintState[] {
    return [...this.links.values()].map(({ constraint: c, spec }) => ({ ...spec, pointA: { ...c.pointA }, pointB: { ...c.pointB } }));
  }

  private checkLinks(): void {
    for (const [id, link] of this.links) {
      if (link.spec.kind === 'anchor' || link.spec.kind === 'grip') continue;
      const c = link.constraint;
      const a = Vector.add(c.bodyA?.position ?? { x: 0, y: 0 }, c.pointA);
      const b = Vector.add(c.bodyB!.position, c.pointB);
      const strain = Math.abs(Vector.magnitude(Vector.sub(a, b)) - c.length) / Math.max(12, c.length);
      const lateralLoad = Math.abs(this.motion.sWave) * (link.spec.kind === 'suspension' ? 0.19 : 0.02);
      if (strain + lateralLoad > link.spec.breakingStrain) {
        this.removeLink(id);
        if (link.spec.bodyB === 'lamp') this.lampReleased = true;
        this.emit(`break-${id}`, 'collapse', b, `${this.entities.get(link.spec.bodyB)!.definition.label}: bağlantı yükü aşıldı.`);
      }
    }
  }

  private controlDuringQuake(state: GameState, input: InputState, dt: number): void {
    const npc = state.npcs[0];
    const item = this.entities.get(npc.id)!;
    if (npc.health <= 0) { state.grip.holding = false; this.removeLink('player-grip'); return; }
    const grip = state.grip;
    if (state.phase === 'EXECUTION') {
      grip.target = Math.sin(state.time * 2.1) * 0.22;
      const steer = Number(input.right) - Number(input.left);
      const resisting = Boolean(input.grip) && grip.stamina > 0.02;
      grip.stamina = clamp(grip.stamina + (resisting ? -0.24 : 0.2) * dt, 0, 1);
      grip.velocity += (this.motion.sWave * 2.3 + Math.sin(state.time * 3.7) * 1.5 + steer * 4.8) * dt;
      if (resisting) grip.velocity += ((grip.target - grip.balance) * 20 - grip.velocity * 7) * dt;
      grip.velocity *= Math.exp(-0.9 * dt);
      grip.balance = clamp(grip.balance + grip.velocity * dt, -1.15, 1.15);
      grip.exposureTime += dt;
      grip.slipCooldown = Math.max(0, grip.slipCooldown - dt);
      grip.holding = Math.abs(grip.balance - grip.target) <= grip.greenHalfWidth;
      if (grip.holding) grip.stableTime += dt;
      if (Math.abs(grip.balance - grip.target) > 0.55 && grip.slipCooldown === 0) {
        grip.slips++; grip.slipCooldown = 0.85; npc.health = Math.max(0, npc.health - 9);
        Body.applyForce(item.body, item.body.position, { x: Math.sign(grip.balance) * 0.055, y: -0.018 });
        this.emit(`slip-${this.tick}`, 'injury', item.body.position, 'Tutunuş koptu. Dengeyi yeşil bölgeye geri getir.');
      }
    } else state.grip.holding = false;
    if (!npc.coached) {
      // Planı atlayan oyuncunun da dengesi aktiftir; fakat sığınakta fiziksel tutuş bağı yoktur.
      npc.status = 'panicking';
      const speed = item.body.position.x < 747 ? (grip.holding ? 0.5 : 2.1) : 0;
      Body.applyForce(item.body, item.body.position, { x: clamp(speed - item.body.velocity.x, -3, 2) * 0.008, y: 0 });
      return;
    }
    npc.status = 'sheltering';
    const shelter = this.level.physics!.shelters.find(s => s.id === state.selectedShelterId)!;
    const support = this.entities.get(shelter.supportId)!;
    if (grip.holding && !support.broken && !this.links.has('player-grip')) {
      const pointA = Vector.sub(item.body.position, support.body.position);
      this.link('player-grip', shelter.supportId, npc.id, pointA, { x: 0, y: 0 }, 0, 0.24, 100, 'grip', 0.25);
    } else if (!grip.holding || support.broken) this.removeLink('player-grip');
    if (!grip.holding) Body.applyForce(item.body, item.body.position, { x: item.body.mass * this.motion.sWave * 0.001, y: 0 });
  }

  private controlEvacuation(state: GameState, input: InputState, dt: number): void {
    const npc = state.npcs[0];
    const player = this.entities.get(npc.id)!;
    if (npc.health <= 0) return;
    npc.status = 'evacuating';
    this.coyoteTime = player.grounded ? 0.1 : Math.max(0, this.coyoteTime - dt);
    const axis = Number(input.right) - Number(input.left);
    const maxSpeed = npc.health < 40 ? 2.7 : 3.8;
    const acceleration = player.grounded ? 0.7 : 0.24;
    Body.setVelocity(player.body, { x: player.body.velocity.x + clamp(axis * maxSpeed - player.body.velocity.x, -acceleration, acceleration), y: player.body.velocity.y });
    const jumping = Boolean(input.jump || input.up);
    if (jumping && !this.jumpHeld && this.coyoteTime > 0) {
      Body.setVelocity(player.body, { x: player.body.velocity.x, y: -12.5 });
      this.coyoteTime = 0; player.grounded = false;
    }
    // S / aşağı: havada hızlı iniş; yandan kesitte dikey serbest uçuş yoktur.
    if (input.down && !player.grounded) Body.applyForce(player.body, player.body.position, { x: 0, y: player.body.mass * 0.001 });
    this.jumpHeld = jumping;
  }

  private checkGrounding(): void {
    for (const npc of this.level.npcs) {
      const player = this.entities.get(npc.id)!;
      const bounds = player.body.bounds;
      const probe = Bodies.rectangle(player.body.position.x, bounds.max.y + 1.5, 14, 4);
      player.grounded = [...this.entities.values()].some(item => item !== player && !item.body.isSensor && !item.broken && Matter.Detector.canCollide(player.body.collisionFilter, item.body.collisionFilter) && Query.collides(probe, [item.body]).some(contact => Math.abs(contact.normal.y) > 0.55));
    }
  }

  private collisions(pairs: Matter.Pair[]): void {
    if (!this.state) return;
    for (const pair of pairs) {
      const a = this.entities.get(pair.bodyA.parent.label);
      const b = this.entities.get(pair.bodyB.parent.label);
      if (!a || !b || a === b) continue;
      const speed = Vector.magnitude(Vector.sub(a.body.velocity, b.body.velocity));
      if (speed < 1.5) continue;
      const reducedMass = a.body.isStatic ? b.body.mass : b.body.isStatic ? a.body.mass : a.body.mass * b.body.mass / (a.body.mass + b.body.mass);
      const load = speed * reducedMass;
      for (const [target, other] of [[a, b], [b, a]]) {
        if (target.broken) continue;
        if (['table', 'column'].includes(target.definition.type) && !other.body.isStatic && other.definition.type !== 'npc' && this.tick - target.lastImpactTick > 15) {
          const damage = clamp(load * 0.65 - 35, 0, 120);
          if (damage > 0) {
            target.integrity = Math.max(0, target.integrity - damage); target.lastImpactTick = this.tick;
            if (target.integrity <= 0) this.fracture(target);
          }
        }
        const movingHazard = other.body.velocity.y > 1.6 || Math.abs(other.body.angularVelocity) > 0.04 || Math.abs(other.body.velocity.x) > 2.5;
        if (target.definition.type === 'npc' && movingHazard && !['floor', 'wall', 'gas'].includes(other.definition.type) && this.tick - target.lastImpactTick > 24) {
          const npc = this.state.npcs.find(n => n.id === target.definition.id)!;
          const damage = clamp(load * 0.4, 4, 45);
          npc.health = Math.max(0, npc.health - damage); target.lastImpactTick = this.tick;
          this.emit(`injury-${this.tick}-${other.definition.id}`, 'injury', target.body.position, `${other.definition.label} çarpması: −${Math.round(damage)} sağlık.`);
        }
        if (target.definition.type === 'gas' && !target.secured && other.body.mass > 15) this.gasLeaking = true;
      }
      if (load > 100) this.emit(`impact-${a.definition.id}-${b.definition.id}`, 'impact', a.body.position, `${a.definition.label} ↔ ${b.definition.label}: yük aktarımı.`);
      if (a.definition.id === 'lamp' || b.definition.id === 'lamp') this.lampReleased = true;
    }
  }

  private fracture(item: Entity): void {
    if (item.broken) return;
    const inheritedVelocity = { ...item.body.velocity };
    const inheritedSpin = item.body.angularVelocity;
    item.broken = true; item.integrity = 0;
    item.body.isSensor = true; item.body.collisionFilter.mask = 0;
    Body.setStatic(item.body, true);
    for (const [id, link] of this.links) if (link.spec.bodyA === item.definition.id || link.spec.bodyB === item.definition.id) this.removeLink(id);
    this.emit(`fracture-${item.definition.id}`, 'collapse', item.body.position, `${item.definition.label}: taşıma kapasitesi aşıldı → fiziksel enkaz.`);
    for (let i = 0; i < 3; i++) {
      const d = item.definition;
      const horizontal = d.type === 'table';
      const x = item.body.position.x + (horizontal ? (i - 1) * 23 : (i - 1) * 6);
      const y = item.body.position.y + (horizontal ? -15 : (i - 1) * 55);
      const fragment = this.add({ id: `${d.id}-fragment-${i}`, type: 'debris', label: 'ENKAZ', x, y, width: horizontal ? 26 : 18, height: horizontal ? 12 : 62, mass: d.mass / 3, friction: 0.85, integrity: 100 });
      Body.setAngle(fragment.body, item.body.angle + (i - 1) * 0.12);
      Body.setVelocity(fragment.body, { x: inheritedVelocity.x + (horizontal ? 0 : (i - 1) * 0.7), y: inheritedVelocity.y });
      Body.setAngularVelocity(fragment.body, inheritedSpin + (horizontal ? 0 : (i - 1) * 0.035));
    }
  }

  private secondaryHazards(state: GameState, dt: number): void {
    const gas = this.entities.get('gas')!;
    if (!gas.secured && Math.abs(this.motion.sWave) > 0.95) this.gasLeaking = true;
    if (this.gasLeaking && !gas.secured) {
      this.emit('gas-leak', 'leak', gas.body.position, 'Boru hasarı → gaz kaçağı. Kıvılcım riski.');
      const lamp = this.entities.get('lamp')!;
      if (!this.ignited && this.lampReleased && lamp.body.position.y > 490) {
        this.ignited = true;
        this.emit('gas-explosion', 'explosion', { x: 480, y: 495 }, 'Düşen lamba + gaz kaçağı → ikincil patlama.');
        for (const item of this.entities.values()) if (!item.body.isStatic && !item.broken) {
          const delta = Vector.sub(item.body.position, { x: 480, y: 505 });
          const distance = Math.max(45, Vector.magnitude(delta));
          Body.applyForce(item.body, item.body.position, { x: delta.x / distance * item.body.mass * 0.015, y: -item.body.mass * 0.004 });
        }
        for (const npc of state.npcs) npc.health = Math.max(0, npc.health - 24);
      }
    }
    // Yaralanma, düşen cismin temasından gelir; yanan gazın yakınında kalmak ek maruziyettir.
    if (this.ignited) for (const npc of state.npcs) if (Math.abs(npc.position.x - 480) < 80) npc.health = Math.max(0, npc.health - dt * 3);
  }

  private emit(id: string, kind: GameState['events'][number]['kind'], position: Vec2, message: string): void {
    const state = this.state;
    if (state && !state.events.some(event => event.id === id)) state.events.push({ id, kind, position: { ...position }, time: state.time, message });
  }
}
