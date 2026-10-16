import type { GameState, PhysicsSnapshot } from '../types/game';

export interface TimelineFrame { state: GameState; physics: PhysicsSnapshot }
const lerp = (a: number, b: number, t: number) => a + (b - a) * t;

/** 60 Hz simülasyonun her ikinci adımı kaydedilir; oynatma 60 Hz interpolasyonludur. */
export class TimelineRewind {
  private frames: TimelineFrame[] = [];
  get length(): number { return this.frames.length; }

  record(state: GameState, physics: PhysicsSnapshot, force = false): void {
    if (!force && physics.tick % 2 !== 0) return;
    if (this.frames.at(-1)?.physics.tick === physics.tick) return;
    this.frames.push(structuredClone({ state, physics }));
  }

  sample(progress: number): TimelineFrame {
    if (!this.frames.length) throw new Error('Geri sarılacak fizik kaydı yok.');
    const p = Math.max(0, Math.min(1, progress));
    const reel = p + Math.sin(p * Math.PI * 2) * 0.035;
    const index = (this.frames.length - 1) * (1 - reel);
    const low = Math.floor(index), high = Math.min(this.frames.length - 1, Math.ceil(index));
    const frame = structuredClone(this.frames[low]);
    const next = this.frames[high];
    const alpha = index - low;
    const byId = new Map(next.physics.bodies.map(body => [body.id, body]));
    for (const body of frame.physics.bodies) {
      const end = byId.get(body.id);
      if (!end || body.broken !== end.broken) continue;
      body.position.x = lerp(body.position.x, end.position.x, alpha);
      body.position.y = lerp(body.position.y, end.position.y, alpha);
      body.angle = lerp(body.angle, end.angle, alpha);
      body.velocity.x = lerp(body.velocity.x, end.velocity.x, alpha);
      body.velocity.y = lerp(body.velocity.y, end.velocity.y, alpha);
      body.angularVelocity = lerp(body.angularVelocity, end.angularVelocity, alpha);
    }
    frame.physics.motion.x = lerp(frame.physics.motion.x, next.physics.motion.x, alpha);
    frame.physics.motion.y = lerp(frame.physics.motion.y, next.physics.motion.y, alpha);
    frame.state.time = lerp(frame.state.time, next.state.time, alpha);
    return frame;
  }

  reset(): void { this.frames = []; }
}
