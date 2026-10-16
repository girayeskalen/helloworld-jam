import type { DeepReadonly, GameState } from '../types/game';

interface Particle {
  x: number; y: number; vx: number; vy: number;
  life: number; duration: number; size: number;
  kind: 'dust' | 'smoke' | 'ember';
}

export class ParticleSystem {
  private particles: Particle[] = [];
  private seen = new Set<string>();
  private readonly brushes = {
    dust: this.brush('181,165,134'),
    smoke: this.brush('103,101,89'),
    ember: this.brush('240,167,83'),
  };

  update(state: DeepReadonly<GameState>, delta: number): void {
    if (state.phase === 'REWIND' || state.phase === 'PLANNING') { this.reset(); return; }
    for (const event of state.events) {
      if (this.seen.has(event.id)) continue;
      this.seen.add(event.id);
      if (!['impact', 'explosion', 'collapse', 'leak', 'aftershock'].includes(event.kind)) continue;
      const count = event.kind === 'explosion' ? 42 : event.kind === 'leak' ? 9 : 20;
      for (let i = 0; i < count; i++) {
        const angle = Math.random() * Math.PI * 2;
        const speed = 15 + Math.random() * 65;
        const kind = event.kind === 'explosion' ? (i % 3 === 0 ? 'ember' : 'smoke') : 'dust';
        const duration = kind === 'ember' ? .3 + Math.random() * .5 : .7 + Math.random() * 1.1;
        this.particles.push({
          x: event.position.x, y: event.position.y,
          vx: Math.cos(angle) * speed, vy: Math.sin(angle) * speed - 30,
          life: duration, duration, kind,
          size: kind === 'ember' ? 2 + Math.random() * 3 : 7 + Math.random() * 13,
        });
      }
    }
    for (const particle of this.particles) {
      particle.x += particle.vx * delta;
      particle.y += particle.vy * delta;
      particle.vy += (particle.kind === 'smoke' ? -16 : 45) * delta;
      particle.vx *= Math.exp(-.5 * delta);
      particle.life -= delta;
    }
    this.particles = this.particles.filter(p => p.life > 0).slice(-220);
  }

  draw(ctx: CanvasRenderingContext2D): void {
    for (const p of this.particles) {
      const age = 1 - p.life / p.duration;
      const size = p.size * (p.kind === 'ember' ? 1 : 1 + age * 1.5);
      ctx.globalAlpha = Math.min(1, age * 10) * Math.pow(1 - age, 1.5) * (p.kind === 'ember' ? .9 : .35);
      ctx.drawImage(this.brushes[p.kind], p.x - size, p.y - size, size * 2, size * 2);
    }
    ctx.globalAlpha = 1;
  }

  reset(): void { this.particles = []; this.seen.clear(); }

  private brush(rgb: string): HTMLCanvasElement {
    const canvas = document.createElement('canvas'); canvas.width = canvas.height = 48;
    const ctx = canvas.getContext('2d')!;
    const gradient = ctx.createRadialGradient(24, 24, 0, 24, 24, 24);
    gradient.addColorStop(0, 'rgba(' + rgb + ',.9)');
    gradient.addColorStop(.4, 'rgba(' + rgb + ',.4)');
    gradient.addColorStop(1, 'rgba(' + rgb + ',0)');
    ctx.fillStyle = gradient; ctx.fillRect(0, 0, 48, 48);
    return canvas;
  }
}
