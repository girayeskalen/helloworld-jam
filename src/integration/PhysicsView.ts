import type { DeepReadonly, GameController, GamePresentation, GameState, LevelData, PhysicsBodyState, Vec2 } from '../types/game';
import { ParticleSystem } from '../ui_vfx/ParticleSystem';
import { SoundSynth } from '../ui_vfx/SoundSynth';
import './physics.css';

const colors = { cyan: '#89e6c6', danger: '#ff8b70', gold: '#efc580', dim: '#547483' };
/** Fizik sözleşmesinin referans entegrasyonu. ui_vfx/ ve levels/ dosyalarına dokunmaz. */
export class PhysicsView implements GamePresentation {
  private readonly ctx: CanvasRenderingContext2D;
  private readonly particles = new ParticleSystem();
  readonly sound = new SoundSynth();
  private phase = '';
  private time = 0;
  private readonly actions: HTMLButtonElement[];
  private readonly elements: Record<string, HTMLElement> = {};

  constructor(canvas: HTMLCanvasElement, private readonly root: HTMLElement, private readonly level: LevelData, controller: GameController) {
    this.ctx = canvas.getContext('2d')!;
    root.innerHTML = `
      <header class="p-header"><h1>ARTÇI</h1><div class="p-sub">AFTERSHOCK<br>TACTICAL REWIND</div><div class="p-version">YÜK YOLU / 01<br>TAKTİK SİMÜLASYON · v0.2</div><button id="sound" class="p-sound">SESİ AÇ</button></header>
      <nav class="p-phases">${['FORESIGHT', 'REWIND', 'PLANNING', 'EXECUTION'].map((phase, i) => `<span data-phase="${phase}">0${i + 1} ${['ÖNGÖRÜ', 'GERİ SARMA', 'HAZIRLIK', 'HAYATTA KAL'][i]}</span>`).join('')}</nav>
      <aside class="p-panel"><div class="p-kicker">ÖNCE YÜK YOLUNU OKU.</div><h2 id="phase-label"></h2><div class="p-budget">HAZIRLIK BÜTÇESİ <b id="ap"></b></div>
      <div class="p-actions">${level.interventions.map((action, i) => `<button class="p-action" data-action="${action.id}" title="${action.description}"><span><kbd>${i + 1}</kbd> ${action.label}<b>${action.cost} AP</b></span></button>`).join('')}</div>
      <div class="p-shelters">${level.physics!.shelters.map(shelter => `<button data-shelter="${shelter.id}">${shelter.label}</button>`).join('')}</div>
      <button class="p-start" id="start">SARSINTIYI BAŞLAT [SPACE]</button><button class="p-undo" id="undo">PLANI SIFIRLA [R]</button>
      <section class="p-grip" id="grip-panel" hidden><strong>TUTUNMA DENGESİ</strong><p>A / D: sola–sağa dengele.<br>SPACE: kısa süreli tutuş.<br>Yeşil bölgede kal; enerjini yenile.</p><meter id="stamina" min="0" max="1" value="1" aria-label="Tutunma enerjisi"></meter><p class="p-grip-status" id="grip-status" role="meter" aria-label="Tutunma dengesi" aria-valuemin="-120" aria-valuemax="120"></p></section>
      <div class="p-timer" id="evac-clock" role="timer" hidden></div><div class="p-keys">TAHLİYE: A/D veya ←/→<br>ZIPLA: SPACE / W / ↑<br>HIZLI İNİŞ: S / ↓ · SES: M</div></aside>
      <div class="p-event" id="event-log"></div><div class="p-status" id="status-message" role="status" aria-live="polite"></div>
      <section class="p-report" id="report" hidden><strong id="rank"></strong><h2>Yük. Denge.<br>Doğru karar.</h2><p id="report-reason"></p><div id="score-breakdown"></div><p id="report-grip"></p><button class="p-start" id="restart">GELECEĞİ YENİDEN YAZ [R]</button></section>
      <div id="pause-notice" class="pause-notice" hidden>DURAKLATILDI<br><small>Oyuna dönünce süre devam eder.</small></div>`;
    for (const element of root.querySelectorAll<HTMLElement>('[id]')) this.elements[element.id] = element;
    this.actions = [...root.querySelectorAll<HTMLButtonElement>('[data-action]')];
    this.actions.forEach((button, i) => button.addEventListener('click', () => { if (controller.intervene(level.interventions[i].id)) this.sound.confirm(); }));
    root.querySelectorAll<HTMLButtonElement>('[data-shelter]').forEach(button => button.addEventListener('click', () => { if (controller.selectShelter(button.dataset.shelter!)) this.sound.confirm(); }));
    this.elements.start.addEventListener('click', () => { controller.execute(); canvas.focus(); });
    this.elements.undo.addEventListener('click', () => controller.undoPlanning());
    this.elements.restart.addEventListener('click', () => controller.restart());
    this.elements.sound.addEventListener('click', () => { if (this.sound.isUnlocked) this.sound.toggle(); void this.sound.unlock(); });
  }

  render(state: DeepReadonly<GameState>, delta: number): void {
    if (state.phase === 'FORESIGHT' && (this.phase !== state.phase || state.time < this.time)) this.reset();
    if (state.phase === 'EXECUTION' && this.phase === 'PLANNING') this.reset();
    this.phase = state.phase; this.time = state.time;
    this.particles.update(state, delta); this.sound.update(state);
    this.draw(state); this.hud(state);
  }
  reset(): void { this.particles.reset(); this.sound.reset(); }

  private hud(state: DeepReadonly<GameState>): void {
    const planning = state.phase === 'PLANNING';
    const shaking = state.phase === 'EXECUTION' && state.executionStage === 'SHAKING';
    const evacuating = state.phase === 'EXECUTION' && state.executionStage === 'EVACUATION';
    const put = (id: string, text: string) => { if (this.elements[id].textContent !== text) this.elements[id].textContent = text; };
    put('phase-label', planning ? '5 puan. Zor seçimler.' : state.phase === 'FORESIGHT' ? 'Yapıyı dinle.' : state.phase === 'REWIND' ? 'Her şeyi geri al.' : shaking ? 'Tutun. Dengele.' : evacuating ? 'Şimdi hareket et.' : 'Bir sonraki gelecek.');
    put('ap', `${state.ap} / ${this.level.actionPoints} AP`);
    this.elements.ap.setAttribute('aria-label', `${state.ap} aksiyon puanı kaldı`);
    this.root.querySelectorAll<HTMLElement>('[data-phase]').forEach(element => element.classList.toggle('active', element.dataset.phase === state.phase));
    this.actions.forEach((button, i) => {
      const action = this.level.interventions[i];
      const applied = state.appliedInterventions.includes(action.id);
      button.disabled = !planning || applied || state.ap < action.cost;
      button.classList.toggle('applied', applied); button.setAttribute('aria-pressed', String(applied));
      button.querySelector('b')!.textContent = applied ? '✓' : `${action.cost} AP`;
    });
    this.root.querySelectorAll<HTMLButtonElement>('[data-shelter]').forEach(button => { button.disabled = !planning; button.classList.toggle('selected', button.dataset.shelter === state.selectedShelterId); });
    this.elements.start.hidden = !planning; this.elements.undo.hidden = !planning;
    this.root.querySelector<HTMLElement>('.p-actions')!.hidden = state.phase === 'EXECUTION';
    this.root.querySelector<HTMLElement>('.p-shelters')!.hidden = state.phase === 'EXECUTION';
    this.elements['grip-panel'].hidden = !shaking;
    (this.elements.stamina as HTMLMeterElement).value = state.grip.stamina;
    put('grip-status', `TUTUNUŞ ${state.grip.holding ? 'KORUNUYOR' : 'KAYIYOR'} · ${state.grip.slips} kopma`);
    this.elements['grip-status'].setAttribute('aria-valuenow', String(Math.round(state.grip.balance * 100)));
    this.elements['grip-status'].setAttribute('aria-valuetext', state.grip.holding ? 'Yeşil bölgede' : 'Yeşil bölge dışında');
    this.elements['grip-status'].dataset.target = String(state.grip.target);
    this.elements['grip-status'].dataset.velocity = String(state.grip.velocity);
    this.elements['evac-clock'].hidden = !evacuating;
    this.elements['evac-clock'].classList.toggle('urgent', state.aftershockRemaining < 4);
    put('evac-clock', `${state.aftershockRemaining.toFixed(1)} sn`);
    put('status-message', state.message);
    put('sound', !this.sound.isUnlocked ? 'SESİ AÇ' : this.sound.isMuted ? 'SES KAPALI [M]' : 'SES AÇIK [M]');
    put('event-log', state.events.at(-1)?.message ?? 'Sarı bağlar: yük aktarımı · Turkuaz: güçlendirme · Kırmızı yay: devrilme alanı');
    this.elements.report.hidden = !state.score;
    if (state.score) {
      put('rank', state.score.rank); put('report-reason', state.score.reason);
      put('score-breakdown', `MÜHENDİSLİK ${state.score.engineering}/40 · FARKINDALIK ${state.score.awareness}/30 · TAHLİYE ${state.score.evacuation}/30 = ${state.score.total}/100`);
      put('report-grip', `Dengede ${state.grip.stableTime.toFixed(1)} sn · ${state.grip.slips} tutunuş kaybı · Sağlık ${Math.round(state.npcs[0].health)}`);
    }
  }

  private draw(state: DeepReadonly<GameState>): void {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, 1280, 720); ctx.fillStyle = '#081a25'; ctx.fillRect(0, 0, 1280, 720);
    for (let x = 0; x < 1280; x += 24) this.line(x, 120, x, 720, '#14303e', 0.5);
    for (let y = 120; y < 720; y += 24) this.line(0, y, 1280, y, '#14303e', 0.5);
    this.line(40, 118, 1240, 118, '#355364');
    this.text('01 / YÜK YOLU', 64, 172, 13, '#c4d9df');
    this.text(`T ${state.phase === 'REWIND' ? '≪' : '+'} ${state.time.toFixed(2)} s`, 798, 172, 14, colors.cyan);
    ctx.fillStyle = '#102a36'; ctx.fillRect(112, 204, 840, 348);
    ctx.fillStyle = '#0a202c'; ctx.fillRect(128, 325, 808, 212);
    for (let x = 185; x < 900; x += 180) { ctx.strokeStyle = '#315363'; ctx.strokeRect(x, 230, 76, 54); this.line(x + 38, 230, x + 38, 284, '#315363'); }
    const exit = this.level.exit;
    ctx.fillStyle = '#163f3b'; ctx.fillRect(exit.x, exit.y, exit.width, exit.height);
    ctx.strokeStyle = colors.cyan; ctx.strokeRect(exit.x, exit.y, exit.width, exit.height);
    this.text('ÇIKIŞ', exit.x + 7, exit.y + 24, 12, colors.cyan); this.text('→', exit.x + 17, exit.y + 49, 26, colors.cyan);
    for (const zone of state.safeTriangles) {
      const color = zone.isClear ? colors.cyan : colors.danger;
      ctx.fillStyle = zone.isClear ? '#89e6c61a' : '#ff8b701a'; ctx.strokeStyle = color;
      this.polygon(zone.polygon); ctx.fill(); ctx.setLineDash([4, 4]); ctx.stroke(); ctx.setLineDash([]);
      if (state.phase === 'PLANNING') this.text(`${state.selectedShelterId === zone.id ? '◉' : '○'} ${zone.label.toUpperCase()}`, zone.position.x - 34, 568, 9, color);
    }
    for (const body of state.physicsBodies.filter(body => body.type !== 'npc')) this.body(body, state.phase === 'PLANNING');
    const lookup = new Map(state.physicsBodies.map(body => [body.id, body]));
    for (const link of state.constraints) {
      const a = link.bodyA ? lookup.get(link.bodyA) : null;
      const b = lookup.get(link.bodyB)!;
      if (!b) continue;
      this.line((a?.x ?? 0) + link.pointA.x, (a?.y ?? 0) + link.pointA.y, b.x + link.pointB.x, b.y + link.pointB.y, link.kind === 'anchor' || link.kind === 'grip' ? colors.cyan : '#b69c70', link.kind === 'anchor' ? 2 : 1);
    }
    for (const npc of state.npcs) {
      const physical = lookup.get(npc.id)!;
      const x = npc.position.x, y = npc.position.y;
      ctx.strokeStyle = npc.health > 0 ? colors.cyan : colors.danger; ctx.lineWidth = 2;
      ctx.beginPath(); ctx.arc(x, y - 10, 5, 0, Math.PI * 2); ctx.stroke();
      this.line(x, y - 4, x, y + 6, ctx.strokeStyle as string, 2);
      this.line(x - 8, y, x + 8, y - 2, ctx.strokeStyle as string, 2);
      this.line(x, y + 6, x - 7, y + 16, ctx.strokeStyle as string, 2);
      this.line(x, y + 6, x + 7, y + 16, ctx.strokeStyle as string, 2);
      this.text(`${Math.round(npc.health)} HP`, x - 17, physical.y - 28, 9, npc.health > 40 ? colors.cyan : colors.danger);
    }
    this.particles.draw(ctx);
    const shaking = state.phase === 'EXECUTION' && state.executionStage === 'SHAKING';
    if (shaking) this.grip(state);
    else this.seismograph(state);
    if (state.phase === 'REWIND') {
      for (let y = 206; y < 554; y += 5) { ctx.fillStyle = '#a3e9ec0d'; ctx.fillRect(112, y, 840, 1); }
      const y = 212 + state.phaseElapsed * 310 % 320;
      ctx.fillStyle = '#b4e4e426'; ctx.fillRect(112, y, 840, 16);
      ctx.fillStyle = '#091b25ee'; ctx.fillRect(323, 362, 384, 55);
      this.text('≪ TAKTİKSEL GERİ SARMA', 350, 396, 22, colors.gold);
    }
  }

  private body(body: DeepReadonly<PhysicsBodyState>, planning: boolean): void {
    if (body.broken) return;
    const ctx = this.ctx;
    const structural = ['wall', 'floor'].includes(body.type) || body.isStatic && body.type === 'column';
    const color = body.isSecured ? colors.cyan : structural ? '#557d90' : body.integrity < body.maxIntegrity * 0.4 ? colors.danger : '#a0bac6';
    ctx.fillStyle = structural ? '#284552' : body.type === 'debris' ? '#50493f' : '#1c3543'; ctx.strokeStyle = color; ctx.lineWidth = structural ? 1 : 1.6;
    for (const part of body.parts) { this.polygon(part); ctx.fill(); ctx.stroke(); }
    if (['cabinet', 'bookcase', 'fridge'].includes(body.type)) {
      ctx.save(); ctx.translate(body.x, body.y); ctx.rotate(body.angle);
      for (let y = -body.height / 3; y < body.height / 2; y += body.height / 3) this.line(-body.width / 2 + 5, y, body.width / 2 - 5, y, color);
      if (body.type === 'fridge') this.line(body.width / 2 - 9, -25, body.width / 2 - 9, 10, color, 3);
      ctx.restore();
    }
    if (body.type === 'gas') { ctx.beginPath(); ctx.arc(body.x, body.y - 26, 11, 0, Math.PI * 2); ctx.stroke(); }
    if (!structural && planning) {
      this.text(body.label, body.x - Math.min(body.width / 2, 40), Math.max(345, body.y - body.height / 2 - 10), 9, color);
      if (body.dangerArc) {
        const arc = body.dangerArc;
        ctx.strokeStyle = '#ff8b7060'; ctx.setLineDash([5, 5]); ctx.beginPath(); ctx.arc(arc.origin.x, arc.origin.y, arc.radius, arc.startAngle, arc.endAngle); ctx.stroke(); ctx.setLineDash([]);
      }
    }
    if (body.type === 'table' || body.type === 'column' && !body.isStatic) {
      const width = Math.max(30, body.width);
      ctx.fillStyle = '#263c45'; ctx.fillRect(body.x - width / 2, body.y + body.height / 2 + 5, width, 3);
      ctx.fillStyle = color; ctx.fillRect(body.x - width / 2, body.y + body.height / 2 + 5, width * body.integrity / body.maxIntegrity, 3);
    }
  }

  private grip(state: DeepReadonly<GameState>): void {
    const ctx = this.ctx;
    const x = 230, y = 626, width = 560;
    this.text('TUTUNMA DENGESİ', x, y - 19, 11, '#c4d9df');
    ctx.fillStyle = '#162e39'; ctx.fillRect(x, y, width, 16);
    const grip = state.grip;
    const centre = x + (grip.target + 1.2) / 2.4 * width;
    const half = grip.greenHalfWidth / 2.4 * width;
    ctx.fillStyle = '#357f65'; ctx.fillRect(centre - half, y, half * 2, 16);
    const marker = x + (grip.balance + 1.2) / 2.4 * width;
    ctx.fillStyle = grip.holding ? colors.cyan : colors.danger; ctx.fillRect(marker - 3, y - 4, 6, 24);
    this.text('A ←     KISA SPACE TUTUŞLARI     → D', 310, y + 39, 11, colors.gold);
  }

  private seismograph(state: DeepReadonly<GameState>): void {
    const ctx = this.ctx;
    const x = 64, y = 627;
    this.text(state.phase === 'PLANNING' ? 'T = 0 / AYNI DÜNYA. FARKLI KARARLAR.' : 'SİSMİK İZ / P + S', x, y - 20, 10, colors.dim);
    this.line(x, y, 925, y, '#375968');
    ctx.beginPath(); ctx.strokeStyle = state.phase === 'REWIND' ? colors.gold : colors.cyan;
    for (let i = 0; i <= 860; i += 3) {
      const envelope = state.phase === 'PLANNING' ? 0 : 1;
      const v = Math.sin(i * 0.13 + state.time * 10) * Math.sin(i * 0.041) * 9 * envelope;
      if (i === 0) ctx.moveTo(x + i, y + v); else ctx.lineTo(x + i, y + v);
    }
    ctx.stroke();
  }

  private polygon(points: readonly DeepReadonly<Vec2>[]): void {
    this.ctx.beginPath(); points.forEach((point, i) => i === 0 ? this.ctx.moveTo(point.x, point.y) : this.ctx.lineTo(point.x, point.y)); this.ctx.closePath();
  }
  private line(x: number, y: number, bx: number, by: number, color: string, width = 1): void {
    const ctx = this.ctx; ctx.strokeStyle = color; ctx.lineWidth = width; ctx.beginPath(); ctx.moveTo(x, y); ctx.lineTo(bx, by); ctx.stroke();
  }
  private text(value: string, x: number, y: number, size: number, color: string): void {
    this.ctx.fillStyle = color; this.ctx.font = `${size}px ui-monospace, Consolas, monospace`; this.ctx.fillText(value, x, y);
  }
}
