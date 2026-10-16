import type { DeepReadonly, GameState } from '../types/game';

/** AudioContext yalnızca kullanıcı jestinden sonra açılır; bütün sesler burada sentezlenir. */
export class SoundSynth {
  private context: AudioContext | null = null;
  private master: GainNode | null = null;
  private seen = new Set<string>();
  private previousPhase = '';
  private muted = false;
  private available = true;

  get isMuted(): boolean { return this.muted; }
  get isAvailable(): boolean { return this.available; }
  get isUnlocked(): boolean { return this.context?.state === 'running'; }

  async unlock(): Promise<void> {
    if (!this.available) return;
    try {
      if (!this.context) {
        this.context = new AudioContext();
        this.master = this.context.createGain();
        this.master.gain.value = this.muted ? 0 : 1;
        this.master.connect(this.context.destination);
      }
      if (this.context.state === 'suspended') await this.context.resume();
    } catch { this.available = false; }
  }

  toggle(): void {
    this.muted = !this.muted;
    if (this.master) this.master.gain.value = this.muted ? 0 : 1;
  }

  confirm(): void { this.tone(720, 0.11, 'sine', 0.045, 1100); }

  update(state: DeepReadonly<GameState>): void {
    if (state.phase !== this.previousPhase) {
      if (state.phase === 'REWIND') this.tone(1100, 1.2, 'sawtooth', 0.025, 80);
      if (state.phase === 'PLANNING') this.seen.clear();
      this.previousPhase = state.phase;
    }
    if (state.phase === 'REWIND') return;
    for (const event of state.events) {
      if (this.seen.has(event.id)) continue;
      this.seen.add(event.id);
      if (event.kind === 'quake' || event.kind === 'aftershock') this.noise(0.7, 160, 0.09);
      if (event.kind === 'impact' || event.kind === 'collapse') this.noise(0.2, 450, 0.07);
      if (event.kind === 'explosion') this.noise(0.5, 220, 0.12);
      if (event.kind === 'leak') this.noise(0.6, 2400, 0.025);
      if (event.kind === 'evacuation') this.tone(520, 0.4, 'sine', 0.06, 1040);
    }
  }

  reset(): void { this.seen.clear(); this.previousPhase = ''; }

  private tone(frequency: number, duration: number, type: OscillatorType, volume: number, end: number): void {
    const ctx = this.context;
    if (!ctx || ctx.state !== 'running' || this.muted) return;
    const oscillator = ctx.createOscillator();
    const gain = ctx.createGain();
    oscillator.type = type;
    oscillator.frequency.setValueAtTime(frequency, ctx.currentTime);
    oscillator.frequency.exponentialRampToValueAtTime(end, ctx.currentTime + duration);
    gain.gain.setValueAtTime(volume, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + duration);
    oscillator.connect(gain).connect(this.master!);
    oscillator.start();
    oscillator.stop(ctx.currentTime + duration);
    oscillator.onended = () => { oscillator.disconnect(); gain.disconnect(); };
  }

  private noise(duration: number, cutoff: number, volume: number): void {
    const ctx = this.context;
    if (!ctx || ctx.state !== 'running' || this.muted) return;
    const buffer = ctx.createBuffer(1, Math.ceil(ctx.sampleRate * duration), ctx.sampleRate);
    const samples = buffer.getChannelData(0);
    for (let i = 0; i < samples.length; i++) samples[i] = Math.random() * 2 - 1;
    const source = ctx.createBufferSource();
    const filter = ctx.createBiquadFilter();
    const gain = ctx.createGain();
    source.buffer = buffer;
    filter.type = 'lowpass';
    filter.frequency.value = cutoff;
    gain.gain.setValueAtTime(volume, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + duration);
    source.connect(filter).connect(gain).connect(this.master!);
    source.start();
    source.onended = () => { source.disconnect(); filter.disconnect(); gain.disconnect(); };
  }
}
