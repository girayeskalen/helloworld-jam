import type { DeepReadonly, GameController, GameState, InterventionId, LevelData } from '../types/game';
import { SoundSynth } from './SoundSynth';

const phaseNames = ['ÖNGÖRÜ', 'GERİ SARMA', 'PLANLAMA', 'UYGULAMA'];
const phaseOrder = ['FORESIGHT', 'REWIND', 'PLANNING', 'EXECUTION'];

export class TacticalHUD {
  private readonly phaseLabel: HTMLElement;
  private readonly message: HTMLElement;
  private readonly ap: HTMLElement;
  private readonly clock: HTMLElement;
  private readonly event: HTMLElement;
  private readonly start: HTMLButtonElement;
  private readonly undo: HTMLButtonElement;
  private readonly sound: HTMLButtonElement;
  private readonly report: HTMLElement;
  private readonly actions: HTMLButtonElement[];
  private readonly actionIds: InterventionId[];
  private lastScore = '';

  constructor(root: HTMLElement, controller: GameController, level: LevelData, private readonly audio: SoundSynth) {
    this.actionIds = level.interventions.map(action => action.id);
    const favicon = document.querySelector<HTMLLinkElement>('link[rel="icon"]') ?? document.createElement('link');
    favicon.rel = 'icon';
    favicon.href = 'data:image/svg+xml,' + encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 40 40"><rect width="40" height="40" rx="7" fill="#242c27"/><path d="M3 23h8l4-13 6 23 5-17 4 7h7" fill="none" stroke="#dbc18b" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/></svg>');
    if (!favicon.isConnected) document.head.append(favicon);
    root.innerHTML = `
      <header class="hud-header">
        <div class="brand"><svg class="brand-mark" viewBox="0 0 40 40" aria-hidden="true"><path d="M2 23h9l4-13 6 23 5-17 4 7h8" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg><h1>ARTÇI</h1><div class="brand-caption">AFTERSHOCK<br><span>TACTICAL REWIND</span></div></div>
        <div class="header-meta">FELAKETİ GÖR. GELECEĞİ DEĞİŞTİR.<br><span>AFET HAZIRLIĞI VE FARKINDALIK / v0.1</span></div>
        <button id="sound" class="sound-button" type="button">SESİ AÇ</button>
      </header>
      <nav class="phases" aria-label="Simülasyon fazları">${phaseNames.map((name, i) => `<span data-phase="${phaseOrder[i]}"><small>0${i + 1}</small> ${name}</span>`).join('')}</nav>
      <aside class="tactical-panel" aria-label="Taktik paneli">
        <div class="panel-kicker">TAKTİK KONSOLU <span>● CANLI</span></div>
        <h2 id="phase-label">ÖNGÖRÜ</h2>
        <div class="ap-row"><span>AKSİYON PUANI</span><strong id="ap">● ● ● / 3</strong></div>
        <div class="action-list">${level.interventions.map((action, i) => `<button type="button" data-action="${action.id}" class="action"><span class="action-title"><kbd>${i + 1}</kbd> ${action.label}<b>1 AP</b></span><span class="action-description">${action.description}</span></button>`).join('')}</div>
        <button id="start" class="start-button" type="button">DEPREMİ BAŞLAT <span>[SPACE]</span></button>
        <button id="undo" class="text-button" type="button">MÜDAHALELERİ SIFIRLA [R]</button>
        <div id="evac-clock" class="evac-clock" role="timer" aria-label="Artçı şok geri sayımı"></div>
        <div class="key-guide"><span>W A S D / ↑ ← ↓ →</span> Tahliye<br><span>1 · 2 · 3 / TIKLA</span> Müdahale</div>
      </aside>
      <div class="status-bar"><span id="status-message" role="status" aria-live="polite"></span><span class="status-index">SİMÜLASYON / 01</span></div>
      <div id="event-log" class="event-log" aria-label="Son simülasyon olayı"></div>
      <section id="report" class="report" aria-label="Mühendislik ve farkındalık karnesi" hidden>
        <div class="panel-kicker">SİMÜLASYON TAMAMLANDI / DEĞERLENDİRME</div>
        <div class="report-heading"><h2>Mühendislik &<br>Farkındalık Karnesi</h2><strong id="rank"></strong></div>
        <p id="report-reason"></p>
        <div id="score-breakdown" class="score-breakdown"></div>
        <p class="report-lesson">Önceden sabitle. Sarsıntıda çök, kapan, tutun. Sarsıntı durunca güvenli güzergâhtan çık.</p>
        <button id="restart" class="start-button" type="button">YENİDEN DENE <span>[R]</span></button>
      </section>
      <div id="pause-notice" class="pause-notice" hidden>SİMÜLASYON DURAKLATILDI<br><small>Devam etmek için oyun sekmesine dön.</small></div>`;
    const get = <T extends HTMLElement>(id: string): T => root.querySelector<T>(`#${id}`)!;
    this.phaseLabel = get('phase-label'); this.message = get('status-message');
    this.ap = get('ap'); this.clock = get('evac-clock'); this.event = get('event-log');
    this.start = get('start'); this.undo = get('undo'); this.sound = get('sound'); this.report = get('report');
    this.actions = [...root.querySelectorAll<HTMLButtonElement>('[data-action]')];
    this.actions.forEach((button, index) => button.addEventListener('click', () => {
      if (controller.intervene(level.interventions[index].id)) audio.confirm();
    }));
    this.start.addEventListener('click', () => controller.execute());
    this.undo.addEventListener('click', () => controller.undoPlanning());
    get('restart').addEventListener('click', () => controller.restart());
    this.sound.addEventListener('click', () => {
      if (audio.isUnlocked) audio.toggle();
      void audio.unlock();
    });
  }

  render(state: DeepReadonly<GameState>): void {
    const planning = state.phase === 'PLANNING';
    const evacuating = state.phase === 'EXECUTION' && state.executionStage === 'EVACUATION';
    const labels = { FORESIGHT: 'Felaketi izle.', REWIND: 'Zaman geri akıyor.', PLANNING: 'Geleceği düzenle.', EXECUTION: state.executionStage === 'SHAKING' ? 'Kararların sınanıyor.' : evacuating ? 'Şimdi tahliye et.' : 'Gelecek değişti mi?' };
    this.phaseLabel.textContent = labels[state.phase];
    if (this.message.textContent !== state.message) this.message.textContent = state.message;
    this.ap.textContent = `${'● '.repeat(state.ap)}${'○ '.repeat(3 - state.ap)} / 3`;
    this.ap.setAttribute('aria-label', `${state.ap} aksiyon puanı kaldı`);
    this.sound.textContent = !this.audio.isAvailable ? 'SES DESTEKLENMİYOR' : !this.audio.isUnlocked ? 'SESİ AÇ' : this.audio.isMuted ? 'SES KAPALI [M]' : 'SES AÇIK [M]';
    this.start.disabled = !planning;
    this.start.hidden = state.phase === 'EXECUTION';
    this.undo.disabled = !planning || state.appliedInterventions.length === 0;
    this.undo.hidden = !planning;
    this.actions.forEach((button, index) => {
      const done = state.appliedInterventions.includes(this.actionIds[index]);
      button.disabled = !planning || done || state.ap === 0;
      button.classList.toggle('applied', done);
      button.setAttribute('aria-pressed', String(done));
      button.querySelector('b')!.textContent = done ? '✓' : '1 AP';
    });
    document.querySelectorAll<HTMLElement>('[data-phase]').forEach((item, index) => {
      item.classList.toggle('active', item.dataset.phase === state.phase);
      item.classList.toggle('complete', index < phaseOrder.indexOf(state.phase));
    });
    this.clock.hidden = !evacuating;
    this.clock.textContent = `ARTÇIYA ${state.aftershockRemaining.toFixed(1)} sn`;
    this.clock.classList.toggle('urgent', state.aftershockRemaining < 4);
    this.event.textContent = state.events.at(-1)?.message ?? (planning ? 'Kesik oklar: öngörülen riskler · Yeşil işaret: önlem alındı' : 'Önce gözlemle. Her olay bir sonraki tehlikeyi tetikleyebilir.');
    this.report.hidden = !state.score;
    if (state.score && this.lastScore !== JSON.stringify(state.score)) {
      this.lastScore = JSON.stringify(state.score);
      this.report.querySelector('#rank')!.textContent = state.score.rank;
      this.report.querySelector('#report-reason')!.textContent = state.score.reason;
      this.report.querySelector('#score-breakdown')!.textContent = `MÜHENDİSLİK ${state.score.engineering}/40   ·   FARKINDALIK ${state.score.awareness}/30   ·   TAHLİYE ${state.score.evacuation}/30   =   ${state.score.total}/100`;
    }
  }

  reset(): void { this.lastScore = ''; }
}
