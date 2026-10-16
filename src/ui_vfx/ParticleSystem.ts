import type { DeepReadonly, GameState } from '../types/game';

interface Particle { x: number; y: number; vx: number; vy: number; life: number; color: string }

export class ParticleSystem {
  private particles: Particle[] = [];
  private seen = new Set<string>();

  update(state: DeepReadonly<GameState>, delta: number): void {
    if (state.phase === 'REWIND' || state.phase === 'PLANNING') { this.reset(); return; }
    for (const event of state.events) {
      if (this.seen.has(event.id)) continue;
      this.seen.add(event.id);
      if (!['impact', 'explosion', 'collapse', 'leak', 'aftershock'].includes(event.kind)) continue;
      const count = event.kind === 'explosion' ? 65 : 18;
      for (let i = 0; i < count; i++) {
        const angle = Math.random() * Math.PI * 2;
        const speed = 30 + Math.random() * 110;
        this.particles.push({ x: event.position.x, y: event.position.y, vx: Math.cos(angle) * speed, vy: Math.sin(angle) * speed - 40, life: 0.4 + Math.random(), color: event.kind === 'leak' ? '#e9c46a' : event.kind === 'explosion' ? '#ff896b' : '#8fa8b5' });
      }
    }
    for (const particle of this.particles) {
      particle.x += particle.vx * delta;
      particle.y += particle.vy * delta;
      particle.vy += 90 * delta;
      particle.life -= delta;
    }
    this.particles = this.particles.filter(p => p.life > 0).slice(-300);
  }

  draw(ctx: CanvasRenderingContext2D): void {
    for (const p of this.particles) {
      ctx.globalAlpha = Math.min(1, p.life);
      ctx.fillStyle = p.color;
      ctx.fillRect(p.x, p.y, 2.5, 2.5);
    }
    ctx.globalAlpha = 1;
  }

  reset(): void { this.particles = []; this.seen.clear(); }
}
