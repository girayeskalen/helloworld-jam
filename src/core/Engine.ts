import type { GamePresentation, InputState } from '../types/game';
import { SimulationManager } from './SimulationManager';

export class Engine {
  private frame = 0;
  private lastTime = 0;
  private accumulator = 0;
  private running = false;
  private readonly step = 1 / 60;

  constructor(
    private readonly simulation: SimulationManager,
    private readonly presentation: GamePresentation,
    private readonly readInput: () => InputState,
  ) {}

  start(): void {
    if (this.running) return;
    this.running = true;
    this.lastTime = performance.now();
    this.frame = requestAnimationFrame(this.tick);
  }

  stop(): void {
    this.running = false;
    cancelAnimationFrame(this.frame);
    this.accumulator = 0;
  }

  private readonly tick = (now: number): void => {
    if (!this.running) return;
    const delta = Math.min((now - this.lastTime) / 1000, 0.1);
    this.lastTime = now;
    this.accumulator += delta;
    while (this.accumulator >= this.step) {
      this.simulation.update(this.step, this.readInput());
      this.accumulator -= this.step;
    }
    this.presentation.render(this.simulation.getState(), delta);
    this.frame = requestAnimationFrame(this.tick);
  };
}
