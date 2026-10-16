import type { DeepReadonly, GameState, Hazard, LevelData } from '../types/game';
import { ParticleSystem } from './ParticleSystem';

const ink = { line: '#537481', muted: '#66838f', cyan: '#88e6dc', red: '#fa725f', gold: '#e4c27a' };

export class Renderer {
  private readonly ctx: CanvasRenderingContext2D;
  private readonly particles = new ParticleSystem();
  private clock = 0;

  constructor(canvas: HTMLCanvasElement, private readonly level: LevelData) {
    const ctx = canvas.getContext('2d');
    if (!ctx) throw new Error('Canvas 2D bu tarayıcıda kullanılamıyor.');
    this.ctx = ctx;
  }

  reset(): void { this.particles.reset(); }

  render(state: DeepReadonly<GameState>, delta: number): void {
    this.clock += delta;
    this.particles.update(state, delta);
    const ctx = this.ctx;
    ctx.clearRect(0, 0, 1280, 720);
    ctx.fillStyle = '#091821';
    ctx.fillRect(0, 0, 1280, 720);
    this.grid();
    this.line(40, 119, 1240, 119, '#29434f');
    ctx.save();
    if (state.shake && state.executionStage !== 'REPORT') ctx.translate(Math.sin(this.clock * 75) * state.shake, Math.cos(this.clock * 90) * state.shake * 0.5);
    this.building(state);
    for (const hazard of state.hazards) this.hazard(hazard);
    this.desk();
    for (const npc of state.npcs) this.person(npc.position.x, npc.position.y, npc.status);
    this.particles.draw(ctx);
    if (state.phase === 'PLANNING') this.vectors(state);
    if (state.phase === 'EXECUTION' && state.executionStage === 'EVACUATION') this.arrow(552, 566, 898, 566, ink.cyan, false);
    ctx.restore();
    this.labels(state);
    this.timeline(state);
    if (state.phase === 'REWIND') this.rewind(state);
  }

  private grid(): void {
    const ctx = this.ctx;
    ctx.lineWidth = 0.5;
    for (let x = 0; x <= 1280; x += 24) this.line(x, 120, x, 720, x % 120 === 0 ? '#16303b' : '#102630');
    for (let y = 144; y <= 720; y += 24) this.line(0, y, 1280, y, y % 120 === 0 ? '#16303b' : '#102630');
    for (const [x, y] of [[40, 150], [948, 150], [40, 594], [948, 594]]) {
      this.line(x - 5, y, x + 5, y, ink.muted);
      this.line(x, y - 5, x, y + 5, ink.muted);
    }
  }

  private building(state: DeepReadonly<GameState>): void {
    const ctx = this.ctx;
    ctx.fillStyle = '#10242d';
    ctx.fillRect(136, 209, 792, 327);
    ctx.fillStyle = '#0b1c25';
    ctx.fillRect(136, 332, 792, 204);
    this.line(112, 200, 948, 200, ink.line, 3);
    for (const tile of this.level.tiles) {
      const b = tile.bounds;
      if (tile.kind === 'wall' || tile.kind === 'floor') {
        ctx.fillStyle = '#233c47';
        ctx.fillRect(b.x, b.y, b.width, b.height);
        ctx.strokeStyle = ink.line;
        ctx.lineWidth = 1;
        ctx.strokeRect(b.x, b.y, b.width, b.height);
        ctx.save();
        ctx.beginPath(); ctx.rect(b.x, b.y, b.width, b.height); ctx.clip();
        for (let x = b.x - b.height; x < b.x + b.width; x += 12) this.line(x, b.y + b.height, x + b.height, b.y, '#3b5662');
        ctx.restore();
      }
    }
    for (const x of [175, 380, 590, 800]) {
      ctx.strokeStyle = '#294653';
      ctx.strokeRect(x, 226, 88, 65);
      this.line(x + 44, 226, x + 44, 291, '#294653');
      this.line(x, 259, x + 88, 259, '#294653');
    }
    this.text('01  /  ÜST KAT', 148, 307, 10, ink.muted);
    this.text('00  /  YAŞAM ALANI', 148, 355, 10, ink.muted);
    const exit = this.level.exit;
    ctx.fillStyle = '#143d39';
    ctx.fillRect(exit.x, exit.y, exit.width, exit.height);
    ctx.strokeStyle = ink.cyan;
    ctx.strokeRect(exit.x, exit.y, exit.width, exit.height);
    this.text('ÇIKIŞ', exit.x + 10, exit.y + 22, 12, ink.cyan);
    this.arrow(873, 508, 910, 508, ink.cyan, false);
    this.line(104, 570, 940, 570, '#3a5662');
    this.text('A', 100, 585, 10, ink.muted);
    this.text('B', 932, 585, 10, ink.muted);
    this.text('KESİT A—B   /   ŞEMATİK MODEL   /   ÖLÇEKSİZ', 348, 588, 10, ink.muted);
    if (state.events.some(e => e.id === 'gas-explosion')) {
      const event = state.events.find(e => e.id === 'gas-explosion')!;
      const flash = Math.max(0, 1 - (state.time - event.time) * 3);
      ctx.fillStyle = `rgba(255,137,89,${flash * 0.15})`;
      ctx.fillRect(136, 332, 576, 204);
      this.text('İKİNCİL HASAR', 360, 374, 11, ink.red);
    }
  }

  private hazard(h: DeepReadonly<Hazard>): void {
    const ctx = this.ctx;
    const b = h.bounds;
    const color = h.mitigated ? ink.cyan : h.active ? ink.red : '#a2b7bf';
    ctx.strokeStyle = color;
    ctx.lineWidth = 1.6;
    if (h.kind === 'cabinet') {
      ctx.save(); ctx.translate(b.x + b.width, b.y + b.height); ctx.rotate(h.angle);
      ctx.fillStyle = '#19303b';
      ctx.fillRect(-b.width, -b.height, b.width, b.height);
      ctx.strokeRect(-b.width, -b.height, b.width, b.height);
      this.line(-b.width + 8, -b.height + 42, -8, -b.height + 42, color);
      this.line(-b.width + 8, -b.height + 84, -8, -b.height + 84, color);
      for (const y of [-104, -64, -24]) ctx.strokeRect(-35, y, 8, 3);
      if (h.mitigated) {
        this.line(-b.width - 9, -b.height + 8, -b.width + 12, -b.height + 8, ink.cyan, 3);
        this.line(-b.width - 9, -b.height + 8, -b.width - 9, -b.height - 6, ink.cyan, 3);
      }
      ctx.restore();
    } else if (h.kind === 'lamp') {
      if (!h.active) this.line(b.x + 18, 332, b.x + 18, b.y, ink.line);
      ctx.save(); ctx.translate(b.x + 18, b.y + h.offsetY); ctx.rotate(h.angle);
      ctx.beginPath(); ctx.moveTo(-9, 0); ctx.lineTo(9, 0); ctx.lineTo(20, 14); ctx.lineTo(-20, 14); ctx.closePath();
      ctx.stroke(); ctx.restore();
    } else if (h.kind === 'gas') {
      this.line(405, 333, 405, 515, color, 5);
      this.line(405, 515, 372, 515, color, 5);
      ctx.beginPath(); ctx.arc(405, 412, 10, 0, Math.PI * 2); ctx.stroke();
      this.line(395, 402, 415, 422, color, 2);
      if (h.mitigated) {
        ctx.fillStyle = '#0d322f'; ctx.fillRect(389, 365, 32, 23);
        ctx.strokeRect(389, 365, 32, 23);
        this.text('AUTO', 392, 380, 9, ink.cyan);
      }
      if (h.active) {
        for (let i = 0; i < 4; i++) {
          ctx.beginPath(); ctx.ellipse(428 + i * 12, 483 - i * 13, 18 + Math.sin(this.clock * 4 + i) * 5, 10, -0.4, 0, Math.PI * 2); ctx.stroke();
        }
      }
    } else {
      if (h.active) {
        for (let i = 0; i < 6; i++) {
          ctx.save(); ctx.translate(728 + i * 15, 500 + (i % 2) * 19); ctx.rotate(i * 1.1); ctx.strokeRect(-9, -4, 19, 9); ctx.restore();
        }
        this.line(716, 445, 751, 469, ink.red, 2);
        this.line(751, 469, 741, 478, ink.red, 2);
      } else {
        ctx.beginPath(); ctx.moveTo(716, 536);
        for (let i = 0; i < 7; i++) { ctx.lineTo(716 + i * 15, 536 - (i + 1) * 15); ctx.lineTo(716 + (i + 1) * 15, 536 - (i + 1) * 15); }
        ctx.stroke();
        this.line(714, 502, 810, 406, ink.line);
      }
    }
  }

  private desk(): void {
    const ctx = this.ctx;
    ctx.fillStyle = '#173631';
    ctx.fillRect(454, 492, 88, 7);
    ctx.strokeStyle = ink.cyan;
    ctx.strokeRect(454, 492, 88, 7);
    this.line(459, 499, 459, 536, ink.cyan, 2);
    this.line(537, 499, 537, 536, ink.cyan, 2);
    this.text('SAĞLAM MASA', 453, 483, 9, ink.cyan);
  }

  private person(x: number, y: number, status: string): void {
    const ctx = this.ctx;
    const crouching = status === 'sheltering';
    const injured = status === 'injured';
    ctx.save(); ctx.translate(x, y);
    if (injured) ctx.rotate(-Math.PI / 2);
    const head = crouching ? -16 : -32;
    const color = injured ? ink.red : ink.cyan;
    ctx.strokeStyle = color;
    ctx.lineWidth = 2.4;
    ctx.beginPath(); ctx.arc(0, head, 5, 0, Math.PI * 2); ctx.stroke();
    this.line(0, head + 6, crouching ? 7 : 0, -8, color, 2.4);
    this.line(0, head + 10, -9, crouching ? -21 : -13, color, 2.4);
    this.line(0, head + 10, 10, crouching ? -22 : -14, color, 2.4);
    this.line(crouching ? 7 : 0, -8, -7, 8, color, 2.4);
    this.line(crouching ? 7 : 0, -8, 8, 8, color, 2.4);
    ctx.restore();
    this.text(injured ? 'YARALI' : status === 'safe' ? 'GÜVENDE' : 'DENİZ', x - 20, y + 27, 9, color);
  }

  private vectors(state: DeepReadonly<GameState>): void {
    const applied = state.appliedInterventions;
    if (!applied.includes('anchor-cabinet')) {
      this.arrow(303, 411, 366, 484, ink.red, true);
      this.text('DEVRİLME → DARBE', 270, 390, 10, ink.red);
    }
    if (!applied.includes('coach-npc')) {
      this.arrow(555, 458, 758, 458, ink.red, true);
      this.text('PANİK ROTASI / ÇÖKME', 595, 445, 10, ink.red);
    }
    if (!applied.includes('gas-sensor')) {
      this.arrow(424, 431, 459, 404, ink.red, true);
      this.text('SIZINTI', 442, 396, 10, ink.red);
    }
    for (let i = 0; i < this.level.interventions.length; i++) {
      const item = this.level.interventions[i];
      const done = applied.includes(item.id);
      const b = item.hitbox;
      const ctx = this.ctx;
      ctx.strokeStyle = done ? ink.cyan : '#e4c27a88';
      ctx.setLineDash([3, 5]); ctx.strokeRect(b.x, b.y, b.width, b.height); ctx.setLineDash([]);
      ctx.fillStyle = done ? ink.cyan : ink.gold;
      ctx.fillRect(b.x - 7, b.y - 8, 19, 19);
      this.text(done ? '✓' : String(i + 1), b.x - 2, b.y + 6, 12, '#091821');
    }
  }

  private labels(state: DeepReadonly<GameState>): void {
    this.text(`BÖLÜM ${this.level.id}  /  ${this.level.title}`, 64, 160, 12, '#b6ced5');
    this.text(this.level.subtitle.toUpperCase(), 64, 180, 10, ink.muted);
    const time = state.time.toFixed(2).padStart(5, '0');
    this.text(`T ${state.phase === 'REWIND' ? '≪' : '+'} ${time} s`, 794, 161, 13, state.phase === 'REWIND' ? ink.gold : ink.cyan);
    this.text('DOLAP', 243, 559, 9, ink.muted);
    this.text('GAZ HATTI', 370, 559, 9, ink.muted);
    this.text('MERDİVEN', 724, 559, 9, ink.muted);
  }

  private timeline(state: DeepReadonly<GameState>): void {
    const ctx = this.ctx;
    const x = 64, y = 628, width = 860;
    this.text('OLASILIK KAYDI', x, y - 17, 10, ink.muted);
    this.text(state.phase === 'PLANNING' ? 'T = 0  /  GELECEĞİ DÜZENLE' : '04.00 SANİYELİK PENCERE', 694, y - 17, 10, ink.muted);
    this.line(x, y, x + width, y, '#36505c', 2);
    this.line(x, y, x + width * state.time / this.level.quakeDuration, y, state.phase === 'REWIND' ? ink.gold : ink.cyan, 2);
    for (let i = 0; i <= 4; i++) {
      this.line(x + i * width / 4, y - 4, x + i * width / 4, y + 4, ink.line);
      this.text(`0${i}`, x + i * width / 4 - 7, y + 19, 10, ink.muted);
    }
    for (const event of state.events.filter(e => ['impact', 'explosion', 'collapse'].includes(e.kind))) {
      ctx.fillStyle = ink.red;
      ctx.fillRect(x + event.time / this.level.quakeDuration * width - 3, y - 3, 6, 6);
    }
  }

  private rewind(state: DeepReadonly<GameState>): void {
    const ctx = this.ctx;
    ctx.fillStyle = '#99d8db09';
    for (let y = 120; y < 656; y += 5) ctx.fillRect(40, y, 908, 1);
    const sweep = 180 + ((state.phaseElapsed * 350) % 370);
    ctx.fillStyle = '#b4e4e419'; ctx.fillRect(40, sweep, 908, 22);
    ctx.fillStyle = '#07141ee8'; ctx.fillRect(300, 339, 400, 74);
    this.text('≪  TAKTİKSEL GERİ SARMA', 322, 370, 21, ink.gold);
    this.text('OLASI GELECEK / KAYIT GERİ ALINIYOR', 350, 394, 10, '#afc9cf');
  }

  private arrow(x: number, y: number, endX: number, endY: number, color: string, dashed: boolean): void {
    const ctx = this.ctx;
    ctx.setLineDash(dashed ? [6, 5] : []);
    this.line(x, y, endX, endY, color, 1.5);
    ctx.setLineDash([]);
    const angle = Math.atan2(endY - y, endX - x);
    this.line(endX, endY, endX - Math.cos(angle - 0.45) * 10, endY - Math.sin(angle - 0.45) * 10, color, 1.5);
    this.line(endX, endY, endX - Math.cos(angle + 0.45) * 10, endY - Math.sin(angle + 0.45) * 10, color, 1.5);
  }

  private text(value: string, x: number, y: number, size: number, color: string): void {
    this.ctx.fillStyle = color;
    this.ctx.font = `${size}px ui-monospace, SFMono-Regular, Consolas, monospace`;
    this.ctx.fillText(value, x, y);
  }

  private line(x: number, y: number, endX: number, endY: number, color: string, width = 1): void {
    const ctx = this.ctx;
    ctx.strokeStyle = color; ctx.lineWidth = width;
    ctx.beginPath(); ctx.moveTo(x, y); ctx.lineTo(endX, endY); ctx.stroke();
  }
}
