import type { DeepReadonly, GameState, Hazard, LevelData } from '../types/game';
import { ParticleSystem } from './ParticleSystem';
import { SceneArt, line, polygon, roundBox, shadow } from './SceneArt';

const ink = { muted: '#96998e', light: '#e1dacb', green: '#91b6a0', red: '#dc866c', gold: '#dbc18b' };

export class Renderer {
  private readonly ctx: CanvasRenderingContext2D;
  private readonly particles = new ParticleSystem();
  private readonly art: SceneArt;
  private clock = 0;
  private hovered = '';

  constructor(canvas: HTMLCanvasElement, private readonly level: LevelData) {
    const ctx = canvas.getContext('2d');
    if (!ctx) throw new Error('Canvas 2D bu tarayıcıda kullanılamıyor.');
    this.ctx = ctx;
    this.art = new SceneArt(ctx);
    canvas.addEventListener('pointermove', event => {
      const bounds = canvas.getBoundingClientRect();
      const x = (event.clientX - bounds.left) * canvas.width / bounds.width;
      const y = (event.clientY - bounds.top) * canvas.height / bounds.height;
      this.hovered = this.level.interventions.find(item => x >= item.hitbox.x && x <= item.hitbox.x + item.hitbox.width && y >= item.hitbox.y && y <= item.hitbox.y + item.hitbox.height)?.id ?? '';
    });
    canvas.addEventListener('pointerleave', () => { this.hovered = ''; });
  }

  reset(): void { this.particles.reset(); }

  render(state: DeepReadonly<GameState>, delta: number): void {
    this.clock += delta;
    this.particles.update(state, delta);
    const ctx = this.ctx;
    ctx.clearRect(0, 0, 1280, 720);
    // Architecture and material noise are rasterized once, not rebuilt every frame.
    ctx.drawImage(this.art.backdrop, 0, 0);
    ctx.save();
    if (state.shake && state.executionStage !== 'REPORT') {
      ctx.translate(Math.sin(this.clock * 75) * state.shake, Math.cos(this.clock * 90) * state.shake * .5);
    }
    // Move the cached section with the same shake as its objects.
    ctx.drawImage(this.art.backdrop, 105, 185, 850, 391, 105, 185, 850, 391);
    this.exit(state);
    this.damage(state);
    for (const hazard of state.hazards) this.hazard(hazard);
    this.desk();
    for (const npc of state.npcs) this.person(npc.position.x, npc.position.y, npc.status);
    this.particles.draw(ctx);
    if (state.phase === 'PLANNING') this.vectors(state);
    if (state.phase === 'EXECUTION' && state.executionStage === 'EVACUATION') {
      this.arrow(558, 565, 901, 565, ink.green, false);
    }
    ctx.restore();
    this.labels(state);
    this.timeline(state);
    if (state.phase === 'REWIND') this.rewind(state);
  }

  private exit(state: DeepReadonly<GameState>): void {
    const ctx = this.ctx, b = this.level.exit;
    const inside = ctx.createLinearGradient(b.x, b.y, b.x + b.width, b.y);
    inside.addColorStop(0, '#384c43'); inside.addColorStop(.7, '#94a98c'); inside.addColorStop(1, '#c7c6a0');
    ctx.fillStyle = '#54564a'; ctx.fillRect(b.x - 5, b.y - 6, b.width + 9, b.height + 6);
    ctx.fillStyle = inside; ctx.fillRect(b.x, b.y, b.width, b.height);
    polygon(ctx, [[b.x + 5, b.y + 7], [b.x + 36, b.y + 13], [b.x + 36, b.y + b.height - 3], [b.x + 5, b.y + b.height]], '#4d5d50');
    line(ctx, b.x + 34, b.y + 17, b.x + 34, b.y + b.height - 6, '#b1b79a', 1);
    ctx.fillStyle = '#d2ccad'; ctx.fillRect(b.x + 27, b.y + 35, 5, 2);
    ctx.fillStyle = '#3d6550'; ctx.fillRect(b.x + 2, b.y - 23, b.width - 3, 14);
    this.text('ÇIKIŞ  →', b.x + 8, b.y - 13, 9, '#e2ebd3');
    polygon(ctx, [[b.x + 25, 536], [b.x + b.width, 536], [b.x + 26, 550], [b.x - 18, 550]], '#e3db9b15');
    if (state.executionStage === 'EVACUATION') {
      ctx.save(); ctx.shadowColor = '#b3cd9c'; ctx.shadowBlur = 15;
      this.arrow(b.x + 11, b.y + 51, b.x + 51, b.y + 51, '#d8e3bc', false); ctx.restore();
    }
  }

  private damage(state: DeepReadonly<GameState>): void {
    const ctx = this.ctx;
    if (state.events.some(e => e.id === 'stairs-collapse')) {
      line(ctx, 773, 332, 767, 353, '#665e51');
      line(ctx, 767, 353, 781, 368, '#665e51');
      line(ctx, 781, 368, 775, 389, '#665e51');
      line(ctx, 767, 353, 750, 359, '#827867', .7);
    }
    const blast = state.events.find(e => e.id === 'gas-explosion');
    if (blast) {
      const age = Math.max(0, state.time - blast.time);
      const scorch = ctx.createRadialGradient(406, 486, 3, 406, 486, 59);
      scorch.addColorStop(0, '#211c19a0'); scorch.addColorStop(1, '#211c1900');
      ctx.fillStyle = scorch; ctx.fillRect(345, 426, 122, 110);
      if (age < .55) {
        const flare = ctx.createRadialGradient(406, 486, 0, 406, 486, 135);
        flare.addColorStop(0, '#fff1b3'); flare.addColorStop(.15, '#e9a352'); flare.addColorStop(.6, '#b8502320'); flare.addColorStop(1, '#e9a35200');
        ctx.globalAlpha = (1 - age / .55) * .72; ctx.fillStyle = flare; ctx.fillRect(271, 351, 270, 270); ctx.globalAlpha = 1;
      }
    }
  }

  private hazard(h: DeepReadonly<Hazard>): void {
    const ctx = this.ctx, b = h.bounds;
    if (h.kind === 'cabinet') {
      shadow(ctx, b.x + 38, 535, h.active ? 73 : 46, 6, .45);
      ctx.save(); ctx.translate(b.x + b.width, b.y + b.height); ctx.rotate(h.angle);
      ctx.fillStyle = '#30291e'; ctx.fillRect(-b.width - 3, -b.height - 3, b.width + 7, b.height + 3);
      ctx.fillStyle = this.art.wood; ctx.fillRect(-b.width, -b.height, b.width, b.height);
      polygon(ctx, [[0, -b.height], [5, -b.height - 3], [5, -3], [0, 0]], '#493d2a');
      const shade = ctx.createLinearGradient(-b.width, 0, 0, 0);
      shade.addColorStop(0, '#e4b97928'); shade.addColorStop(.7, '#22150600'); shade.addColorStop(1, '#22150644');
      ctx.fillStyle = shade; ctx.fillRect(-b.width, -b.height, b.width, b.height);
      for (let i = 0; i < 3; i++) {
        const y = -b.height + 5 + i * 40;
        ctx.fillStyle = '#4b352554'; ctx.fillRect(-b.width + 5, y + 1, b.width - 10, 33);
        ctx.fillStyle = this.art.wood; ctx.fillRect(-b.width + 6, y + 2, b.width - 12, 30);
        line(ctx, -b.width + 6, y + 2, -6, y + 2, '#e0b47e50');
        line(ctx, -b.width + 6, y + 33, -6, y + 33, '#352718aa');
        ctx.fillStyle = '#3a342b'; roundBox(ctx, -39, y + 16, 15, 4, 1);
        line(ctx, -38, y + 16, -25, y + 16, '#b6ac8c');
      }
      if (h.mitigated) {
        line(ctx, -b.width - 4, -b.height + 7, -b.width + 10, -b.height + 7, '#626b63', 4);
        line(ctx, -b.width - 4, -b.height + 7, -b.width - 4, -b.height - 8, '#626b63', 4);
        for (const [x, y] of [[-b.width + 6, -b.height + 7], [-b.width - 4, -b.height - 4]]) {
          ctx.fillStyle = '#c3c5b7'; ctx.beginPath(); ctx.arc(x, y, 1.7, 0, Math.PI * 2); ctx.fill();
        }
      }
      ctx.restore();
    } else if (h.kind === 'lamp') {
      if (!h.active) {
        line(ctx, b.x + 18, 332, b.x + 18, b.y + 3, '#474a43', 1.5);
        const light = ctx.createRadialGradient(b.x + 18, b.y + 20, 2, b.x + 18, b.y + 20, 95);
        light.addColorStop(0, '#ffe1a325'); light.addColorStop(1, '#ffe1a300');
        ctx.fillStyle = light; ctx.fillRect(b.x - 77, b.y - 75, 190, 190);
      } else shadow(ctx, b.x + 18, 534, 28, 4, .4);
      ctx.save(); ctx.translate(b.x + 18, b.y + h.offsetY); ctx.rotate(h.angle);
      const metal = ctx.createLinearGradient(-21, 0, 21, 0);
      metal.addColorStop(0, '#474e48'); metal.addColorStop(.45, '#a4a99b'); metal.addColorStop(1, '#444a43');
      polygon(ctx, [[-8, 0], [8, 0], [22, 15], [-22, 15]], metal);
      ctx.fillStyle = h.active ? '#928974' : '#e7d6a3'; ctx.beginPath(); ctx.ellipse(0, 15, 21, 3, 0, 0, Math.PI * 2); ctx.fill();
      line(ctx, -6, 1, 6, 1, '#d0d0b4', 1.5); ctx.restore();
    } else if (h.kind === 'gas') {
      shadow(ctx, 404, 534, 26, 4, .3);
      line(ctx, 407, 334, 407, 518, '#2d2c24', 7);
      line(ctx, 405, 334, 405, 515, '#9d9173', 5);
      line(ctx, 403, 335, 403, 514, '#d0c29b', 1);
      line(ctx, 405, 515, 372, 515, '#94856a', 5);
      for (const y of [355, 453, 496]) {
        ctx.fillStyle = '#555a51'; ctx.fillRect(398, y, 14, 4);
        ctx.fillStyle = '#c5c1a8'; ctx.fillRect(400, y, 2, 2);
      }
      ctx.fillStyle = '#695f4a'; ctx.fillRect(399, 400, 12, 23);
      ctx.fillStyle = '#74684d'; ctx.beginPath(); ctx.arc(405, 412, 10, 0, Math.PI * 2); ctx.fill();
      ctx.strokeStyle = '#bda677'; ctx.lineWidth = 2; ctx.stroke();
      line(ctx, 399, 405, 411, 419, '#d0b188', 3);
      if (h.mitigated) {
        ctx.fillStyle = '#424b43'; roundBox(ctx, 389, 365, 32, 23, 3);
        ctx.fillStyle = '#83927d'; ctx.fillRect(392, 369, 26, 9);
        this.text('AUTO', 395, 376, 7, '#202b23');
        ctx.fillStyle = '#99c397'; ctx.beginPath(); ctx.arc(414, 382, 1.8, 0, Math.PI * 2); ctx.fill();
      }
      if (h.active) {
        ctx.save(); ctx.globalAlpha = .3;
        for (let i = 0; i < 4; i++) {
          const drift = (this.clock * 13 + i * 19) % 65;
          const mist = ctx.createRadialGradient(423 + i * 7, 490 - drift, 0, 423 + i * 7, 490 - drift, 13 + i * 3);
          mist.addColorStop(0, '#d3c6a380'); mist.addColorStop(1, '#d3c6a300');
          ctx.fillStyle = mist; ctx.fillRect(400, 400, 90, 120);
        }
        ctx.restore();
      }
    } else {
      if (h.active) {
        shadow(ctx, 766, 532, 69, 7, .43);
        // The original passable corridor remains visible underneath the hanging debris.
        for (let i = 0; i < 7; i++) {
          const x = 724 + i * 13, y = 479 + (i % 3) * 5;
          ctx.save(); ctx.translate(x, y); ctx.rotate((i % 2 ? 1 : -1) * .2);
          ctx.fillStyle = this.art.concrete; ctx.fillRect(-10, -5, 23, 11);
          line(ctx, -10, -5, 13, -5, '#a7a797'); ctx.restore();
        }
        line(ctx, 735, 467, 770, 476, '#514936', 2);
        line(ctx, 758, 474, 793, 481, '#6b614a', 2);
      } else {
        shadow(ctx, 769, 535, 62, 6, .32);
        for (let i = 0; i < 7; i++) {
          const x = 716 + i * 15, y = 536 - (i + 1) * 15;
          ctx.fillStyle = this.art.concrete; ctx.fillRect(x, y, 15, 536 - y);
          ctx.fillStyle = '#c6c1ab'; ctx.fillRect(x, y, 17, 3);
          line(ctx, x, y + 4, x + 15, y + 4, '#4c5149');
        }
        line(ctx, 717, 498, 811, 404, '#4b514c', 3);
        line(ctx, 719, 497, 813, 403, '#c4c5b2');
        for (let i = 0; i < 4; i++) line(ctx, 727 + i * 25, 489 - i * 25, 727 + i * 25, 518 - i * 25, '#687168', 2);
      }
    }
  }

  private desk(): void {
    const ctx = this.ctx;
    shadow(ctx, 500, 535, 63, 6, .38);
    line(ctx, 461, 500, 460, 535, '#414a43', 5);
    line(ctx, 535, 500, 536, 535, '#414a43', 5);
    line(ctx, 460, 519, 536, 519, '#414a43', 3);
    line(ctx, 462, 501, 462, 533, '#899084');
    ctx.fillStyle = '#4b3726'; ctx.fillRect(452, 492, 93, 9);
    ctx.fillStyle = this.art.wood; ctx.fillRect(452, 490, 93, 7);
    line(ctx, 453, 490, 545, 490, '#d0ad7a', 1.5);
    ctx.fillStyle = '#d8cdb0'; polygon(ctx, [[473, 485], [492, 486], [490, 490], [471, 489]], '#c9c3ac');
    ctx.fillStyle = '#a38665'; ctx.fillRect(503, 484, 8, 6);
    line(ctx, 511, 485, 514, 485, '#a38665', 2);
  }

  private person(x: number, y: number, status: string): void {
    const ctx = this.ctx, crouching = status === 'sheltering', injured = status === 'injured';
    const moving = status === 'panicking' || status === 'evacuating';
    const stride = moving ? Math.sin(this.clock * 12) * 6 : 0;
    shadow(ctx, x + 3, y + 9, crouching ? 18 : 15, 3.5, .45);
    ctx.save(); ctx.translate(x, y + 8);
    if (injured) { ctx.translate(8, -4); ctx.rotate(-Math.PI / 2); }
    if (crouching) {
      line(ctx, 0, -13, 9, -7, '#384046', 7);
      line(ctx, 9, -7, 15, -1, '#343b40', 6);
      line(ctx, 15, -1, 8, 0, '#252a2d', 4);
      ctx.fillStyle = '#b07d55'; ctx.beginPath(); ctx.ellipse(0, -20, 8, 11, -.7, 0, Math.PI * 2); ctx.fill();
      ctx.fillStyle = '#c99b78'; ctx.beginPath(); ctx.ellipse(-6, -28, 4.3, 5.4, -.6, 0, Math.PI * 2); ctx.fill();
      ctx.fillStyle = '#40372f'; ctx.beginPath(); ctx.ellipse(-7, -31, 4.7, 3, -.7, 0, Math.PI * 2); ctx.fill();
      line(ctx, -2, -18, -11, -26, '#ca9d79', 3);
      line(ctx, -11, -26, -6, -30, '#ca9d79', 3);
    } else {
      line(ctx, -3, -16, -4 - stride, -2, '#303c42', 5);
      line(ctx, 3, -16, 5 + stride, -2, '#3d474b', 5);
      line(ctx, -5 - stride, -1, -1 - stride, -1, '#202629', 4);
      line(ctx, 4 + stride, -1, 9 + stride, -1, '#202629', 4);
      const shirt = ctx.createLinearGradient(-7, 0, 7, 0);
      shirt.addColorStop(0, '#8e6145'); shirt.addColorStop(.5, '#bc8d60'); shirt.addColorStop(1, '#9a704e');
      polygon(ctx, [[-5, -33], [5, -33], [8, -18], [-6, -17]], shirt);
      line(ctx, -5, -29, -9 + stride * .4, -17, '#a77b57', 4);
      line(ctx, 6, -29, 10 - stride * .4, -18, '#c09368', 4);
      ctx.fillStyle = '#c49a77'; ctx.fillRect(-10 + stride * .4, -18, 3, 4); ctx.fillRect(8 - stride * .4, -19, 3, 4);
      ctx.fillStyle = '#cba27f'; ctx.fillRect(-2, -37, 5, 6);
      ctx.beginPath(); ctx.ellipse(0, -40, 4.6, 6, 0, 0, Math.PI * 2); ctx.fill();
      ctx.fillStyle = '#38352f'; ctx.beginPath(); ctx.ellipse(-.5, -44, 5.1, 3.6, -.15, 0, Math.PI * 2); ctx.fill();
      ctx.fillStyle = '#332d28'; ctx.fillRect(2, -40, 1, 1);
      line(ctx, -2, -31, 1, -24, '#ddbb8a70');
    }
    ctx.restore();
    if (injured) this.pill('YARALI', x - 21, y + 19, ink.red);
    else if (status === 'safe') this.pill('GÜVENDE', x - 26, y + 19, ink.green);
    else this.pill('DENİZ', x - 20, y + 19, '#e0cfab');
  }

  private vectors(state: DeepReadonly<GameState>): void {
    const applied = state.appliedInterventions;
    if (!applied.includes('anchor-cabinet')) {
      this.arrow(306, 417, 362, 479, '#bd654e', true);
      this.pill('DEVRİLME RİSKİ', 236, 374, ink.red);
    }
    if (!applied.includes('coach-npc')) {
      this.arrow(560, 462, 756, 462, '#bd654e', true);
      this.pill('PANİK ROTASI', 590, 433, ink.red);
    }
    if (!applied.includes('gas-sensor')) {
      this.arrow(424, 422, 452, 403, '#bd654e', true);
    }
    for (let i = 0; i < this.level.interventions.length; i++) {
      const item = this.level.interventions[i], done = applied.includes(item.id);
      const b = item.hitbox, ctx = this.ctx, color = done ? ink.green : ink.gold;
      const hover = this.hovered === item.id;
      ctx.fillStyle = done ? '#91b6a00d' : hover ? '#efd3a21c' : '#efd3a206';
      ctx.fillRect(b.x, b.y, b.width, b.height);
      // Only corner brackets are drawn, keeping the actual object unobstructed.
      const length = hover ? 13 : 8;
      for (const [x, y, dx, dy] of [[b.x, b.y, 1, 1], [b.x + b.width, b.y, -1, 1], [b.x, b.y + b.height, 1, -1], [b.x + b.width, b.y + b.height, -1, -1]]) {
        line(ctx, x, y, x + dx * length, y, color, hover ? 2 : 1.2);
        line(ctx, x, y, x, y + dy * length, color, hover ? 2 : 1.2);
      }
      ctx.fillStyle = done ? '#365c49' : '#dac08d'; roundBox(ctx, b.x + 3, b.y + 3, 18, 18, 3);
      this.text(done ? '✓' : String(i + 1), b.x + 8, b.y + 16, 11, done ? '#edf1dc' : '#27271e', true);
    }
  }

  private labels(state: DeepReadonly<GameState>): void {
    this.text('BÖLÜM ' + this.level.id + '  /  ' + this.level.title, 64, 162, 12, ink.light, true);
    this.text(this.level.subtitle, 64, 181, 10, ink.muted);
    this.text('T ' + (state.phase === 'REWIND' ? '≪ ' : '+ ') + state.time.toFixed(2) + ' s', 804, 162, 12, state.phase === 'REWIND' ? ink.gold : ink.green);
    this.text('01  ÜST KAT', 77, 267, 9, ink.muted);
    this.text('00  ZEMİN', 77, 438, 9, ink.muted);
    line(this.ctx, 124, 574, 940, 574, '#b4ac8c24');
    this.text('KONUT + ATÖLYE', 135, 591, 9, ink.muted);
    this.text('KESİT GÖRÜNÜŞÜ  /  TEMSİLÎ SAHNE', 718, 591, 9, ink.muted);
  }

  private timeline(state: DeepReadonly<GameState>): void {
    const ctx = this.ctx, x = 64, y = 630, width = 860;
    this.text('OLASILIK KAYDI', x, y - 16, 9, ink.muted, true);
    this.text(state.phase === 'PLANNING' ? 'T = 0  /  GELECEĞİ DÜZENLE' : '04.00 SANİYELİK PENCERE', 694, y - 16, 9, ink.muted);
    line(ctx, x, y, x + width, y, '#ffffff16', 2);
    const progress = Math.min(1, state.time / this.level.quakeDuration);
    line(ctx, x, y, x + width * progress, y, state.phase === 'REWIND' ? ink.gold : ink.green, 2);
    for (let i = 0; i <= 4; i++) {
      line(ctx, x + i * width / 4, y - 4, x + i * width / 4, y + 4, '#a3a29160');
      this.text('0' + i, x + i * width / 4 - 6, y + 18, 9, ink.muted);
    }
    for (const event of state.events.filter(e => ['impact', 'explosion', 'collapse'].includes(e.kind))) {
      ctx.fillStyle = ink.red; ctx.fillRect(x + event.time / this.level.quakeDuration * width - 3, y - 3, 6, 6);
    }
  }

  private rewind(state: DeepReadonly<GameState>): void {
    const ctx = this.ctx;
    ctx.fillStyle = '#bac7b00b';
    for (let y = 200; y < 552; y += 4) ctx.fillRect(124, y, 816, 1);
    const sweep = 200 + (state.phaseElapsed * 260) % 340;
    ctx.fillStyle = '#e8d2a818'; ctx.fillRect(124, sweep, 816, 15);
    ctx.fillStyle = '#1a201ff2'; roundBox(ctx, 305, 349, 402, 70, 5);
    this.text('≪  TAKTİKSEL GERİ SARMA', 330, 380, 20, ink.gold, true);
    this.text('OLASI GELECEK / KAYIT GERİ ALINIYOR', 354, 402, 10, ink.light);
  }

  private arrow(x: number, y: number, ex: number, ey: number, color: string, dashed: boolean): void {
    const ctx = this.ctx;
    ctx.setLineDash(dashed ? [5, 5] : []);
    line(ctx, x, y, ex, ey, color, 1.7); ctx.setLineDash([]);
    const angle = Math.atan2(ey - y, ex - x);
    line(ctx, ex, ey, ex - Math.cos(angle - .45) * 8, ey - Math.sin(angle - .45) * 8, color, 1.7);
    line(ctx, ex, ey, ex - Math.cos(angle + .45) * 8, ey - Math.sin(angle + .45) * 8, color, 1.7);
  }

  private pill(value: string, x: number, y: number, color: string): void {
    const ctx = this.ctx;
    ctx.font = '600 9px system-ui, sans-serif';
    const width = ctx.measureText(value).width + 12;
    ctx.fillStyle = '#252a27ee'; roundBox(ctx, x, y - 10, width, 16, 3);
    this.text(value, x + 6, y + 1, 9, color, true);
  }

  private text(value: string, x: number, y: number, size: number, color: string, bold = false): void {
    const ctx = this.ctx;
    ctx.fillStyle = color;
    ctx.font = (bold ? '600 ' : '') + size + 'px system-ui, -apple-system, Segoe UI, sans-serif';
    ctx.fillText(value, x, y);
  }
}
