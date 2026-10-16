import type { GameState } from '../types/game';

/** Her sabit fizik adımının tam kopyası: dönüşüm, NPC, olaylar ve AP birlikte geri sarılır. */
export class TimelineRewind {
  private frames: GameState[] = [];

  record(state: GameState): void {
    this.frames.push(structuredClone(state));
  }

  sample(progress: number): GameState {
    if (this.frames.length === 0) throw new Error('Geri sarılacak zaman çizelgesi yok.');
    const index = Math.round((this.frames.length - 1) * (1 - Math.max(0, Math.min(1, progress))));
    return structuredClone(this.frames[index]);
  }

  reset(): void { this.frames = []; }
}
