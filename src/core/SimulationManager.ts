import type { DeepReadonly, GameController, GameState, InputState, InterventionId, LevelData, Phase } from '../types/game';
import { PhysicsHazardSystem } from './PhysicsHazardSystem';
import { createPhysicsLevel } from './PhysicsLevel';
import { TimelineRewind } from './TimelineRewind';

export class SimulationManager implements GameController {
  readonly level: LevelData;
  private state: GameState;
  private readonly physics: PhysicsHazardSystem;
  private readonly timeline = new TimelineRewind();

  constructor(level: LevelData) {
    this.level = createPhysicsLevel(level);
    this.physics = new PhysicsHazardSystem(this.level);
    this.state = this.initialState('FORESIGHT');
    this.physics.sync(this.state);
    this.timeline.record(this.state, this.physics.capture(), true);
  }

  getState(): DeepReadonly<GameState> { return this.state; }
  get recordedFrames(): number { return this.timeline.length; }

  update(dt: number, input: InputState): void {
    if (!Number.isFinite(dt) || dt <= 0) return;
    // Dışarıdan gelen büyük deltalar da fizik adımına bölünür; sekme sıçraması oluşturmaz.
    let remaining = Math.min(dt, 0.1);
    while (remaining > 1e-8) {
      const step = Math.min(remaining, 1 / 60);
      this.step(step, input); remaining -= step;
    }
  }

  private step(dt: number, input: InputState): void {
    const state = this.state;
    if (state.score || state.phase === 'PLANNING') return;
    state.phaseElapsed += dt;
    if (state.phase === 'FORESIGHT' || (state.phase === 'EXECUTION' && state.executionStage === 'SHAKING')) {
      state.time = Math.min(this.level.quakeDuration, state.time + dt);
      this.physics.update(state, input, dt);
      const finished = state.time >= this.level.quakeDuration - 1e-7;
      if (state.phase === 'FORESIGHT') this.timeline.record(state, this.physics.capture(), finished);
      if (finished) {
        state.shake = 0; state.phaseElapsed = 0;
        if (state.phase === 'FORESIGHT') {
          state.phase = 'REWIND'; state.message = 'Yük yolu kaydedildi. Cisimler ve bağlar geri sarılıyor…';
        } else {
          state.executionStage = 'EVACUATION';
          state.aftershockRemaining = this.level.evacuationDuration;
          state.message = '12 saniye. Sağdaki çıkışa ilerle; SPACE ile enkazın üzerinden atla.';
          if (state.npcs.every(npc => npc.health <= 0)) this.finish(false, 'Karakter hareket edemeyecek kadar yaralandı. Önlemleri ve tutunuşu değiştir.');
        }
      }
    } else if (state.phase === 'REWIND') {
      const elapsed = state.phaseElapsed;
      const frame = this.timeline.sample(elapsed / this.level.rewindDuration);
      this.physics.restore(frame.physics);
      this.state = frame.state;
      this.physics.sync(this.state);
      this.state.phase = 'REWIND'; this.state.phaseElapsed = elapsed;
      this.state.message = '≪ Darbeler, kopan bağlar ve karakter hareketi geri sarılıyor.';
      if (elapsed >= this.level.rewindDuration - 1e-7) this.resetWorld('PLANNING');
    } else if (state.executionStage === 'EVACUATION') {
      state.aftershockRemaining = Math.max(0, state.aftershockRemaining - dt);
      this.physics.update(state, input, dt);
      const npc = state.npcs[0];
      const exit = this.level.exit;
      if (npc.health <= 0 || npc.position.y > this.level.floorY + 100) this.finish(false, 'Enkaz veya düşme tahliyeyi engelledi. Yeni bir hazırlık planı dene.');
      else if (npc.position.x >= exit.x && npc.position.x <= exit.x + exit.width + 20 && npc.position.y > exit.y && state.aftershockRemaining > 0) {
        npc.status = 'safe';
        state.events.push({ id: 'evacuated', kind: 'evacuation', time: state.time, position: { ...npc.position }, message: 'Deniz çıkışa ulaştı.' });
        this.finish(true, 'Hazırlık, tutunuş ve tahliye birlikte çalıştı.');
      } else if (state.aftershockRemaining <= 0) {
        state.seismic.intensity = 1;
        state.events.push({ id: 'aftershock', kind: 'aftershock', time: state.time, position: { ...npc.position }, message: 'Artçı başladı. Altın pencere kapandı.' });
        this.finish(false, '12 saniyelik tahliye penceresi doldu.');
      }
    }
  }

  intervene(id: InterventionId): boolean {
    const state = this.state;
    const action = this.level.interventions.find(item => item.id === id);
    if (state.phase !== 'PLANNING' || !action || state.ap < action.cost || state.appliedInterventions.includes(id)) return false;
    state.appliedInterventions.push(id); state.ap -= action.cost;
    if (id === 'coach-npc') state.npcs.forEach(npc => { npc.coached = true; });
    this.physics.applyInterventions(state);
    this.physics.placeInShelter(state);
    state.message = `${action.label}: ${action.description}`;
    return true;
  }

  selectShelter(id: string): boolean {
    const shelter = this.level.physics!.shelters.find(item => item.id === id);
    if (this.state.phase !== 'PLANNING' || !shelter) return false;
    if (!this.state.appliedInterventions.includes('coach-npc') && !this.intervene('coach-npc')) return false;
    this.state.selectedShelterId = id;
    this.physics.placeInShelter(this.state);
    this.state.message = `${shelter.label} seçildi. Taşıyıcıyı güçlendir; sarsıntıda dengeyi koru.`;
    return true;
  }

  execute(): void {
    if (this.state.phase !== 'PLANNING') return;
    // Aynı başlangıç dünyası + sadece seçilmiş müdahaleler: öngörü ile adil karşılaştırma.
    const planned = [...this.state.appliedInterventions];
    const selected = this.state.selectedShelterId;
    this.resetWorld('EXECUTION');
    this.state.appliedInterventions = planned;
    this.state.ap = this.level.actionPoints - this.level.interventions.filter(action => planned.includes(action.id)).reduce((sum, action) => sum + action.cost, 0);
    this.state.selectedShelterId = selected;
    this.state.npcs.forEach(npc => { npc.coached = planned.includes('coach-npc'); });
    this.physics.applyInterventions(this.state);
    this.physics.placeInShelter(this.state);
    this.state.message = 'A / D ile dengele. SPACE kısa tutuşlarla merkeze çeker; enerjini tüketme.';
  }

  undoPlanning(): void { if (this.state.phase === 'PLANNING') this.resetWorld('PLANNING'); }
  restart(): void {
    this.timeline.reset(); this.resetWorld('FORESIGHT');
    this.timeline.record(this.state, this.physics.capture(), true);
  }
  dispose(): void { this.physics.dispose(); }

  private resetWorld(phase: Phase): void {
    this.physics.reset(); this.state = this.initialState(phase); this.physics.sync(this.state);
  }

  private finish(evacuated: boolean, reason: string): void {
    const state = this.state;
    const applied = state.appliedInterventions;
    const upgraded = state.physicsBodies.some(body => (body.id === 'desk' || body.id === 'column') && body.isSecured && !body.broken && body.integrity > 0);
    const anchored = state.physicsBodies.some(body => ['cabinet', 'bookcase', 'fridge'].includes(body.type) && body.isSecured && Math.abs(body.angle) < 0.25);
    const engineering = (upgraded ? 12 : 0) + (applied.includes('gas-sensor') ? 12 : 0) + (anchored ? 12 : 0) + (!state.events.some(e => e.id === 'gas-explosion') ? 4 : 0);
    const stableFraction = state.grip.stableTime / Math.max(0.01, state.grip.exposureTime);
    const awareness = (applied.includes('coach-npc') ? 12 : 0) + Math.round(stableFraction * 18);
    const evacuation = evacuated ? 30 : 0;
    const total = engineering + awareness + evacuation;
    state.score = { engineering, awareness, evacuation, total, rank: total >= 90 && evacuated ? 'S' : total >= 75 && evacuated ? 'A' : total >= 50 ? 'B' : 'C', evacuated, reason };
    state.executionStage = 'REPORT'; state.message = reason;
  }

  private initialState(phase: Phase): GameState {
    return {
      phase, executionStage: 'SHAKING', time: 0, phaseElapsed: 0, ap: this.level.actionPoints,
      appliedInterventions: [], hazards: structuredClone(this.level.hazards), npcs: structuredClone(this.level.npcs),
      events: [], aftershockRemaining: this.level.evacuationDuration, shake: 0, score: null,
      message: phase === 'PLANNING' ? '5 AP. Önce yük yolunu oku; her şeyi güçlendiremezsin.' : 'Öngörü: hareketli temel, gerçek temaslar ve kırılabilen bağlantılar.',
      physicsBodies: [], constraints: [], safeTriangles: [], selectedShelterId: this.level.physics!.shelters[0].id,
      grip: { balance: 0, velocity: 0, target: 0, greenHalfWidth: 0.28, stamina: 1, stableTime: 0, exposureTime: 0, slips: 0, holding: false, slipCooldown: 0 },
      seismic: { x: 0, y: 0, pWave: 0, sWave: 0, intensity: 0 }, physicsTick: 0,
    };
  }
}
