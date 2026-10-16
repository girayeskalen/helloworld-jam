import type { GameState, LevelData, SimulationEvent } from '../types/game';

/** Oynanış için deterministik zincir modeli; yapısal mühendislik çözücüsü değildir. */
export class PhysicsHazardSystem {
  update(state: GameState, level: LevelData, dt: number): void {
    const t = state.time;
    const cabinet = state.hazards.find(h => h.kind === 'cabinet')!;
    const lamp = state.hazards.find(h => h.kind === 'lamp')!;
    const gas = state.hazards.find(h => h.kind === 'gas')!;
    const stairs = state.hazards.find(h => h.kind === 'stairs')!;
    state.shake = Math.max(0, Math.sin(t * 42) * 3.5 + Math.sin(t * 67) * 2) * (1 - t / level.quakeDuration);
    this.emit(state, 'quake', 'quake', 0, { x: 520, y: 540 }, 'Sarsıntı başladı. Sabitlenmemiş eşyalar hareket ediyor.');

    if (t > 0.45 && !cabinet.mitigated) {
      cabinet.active = true;
      cabinet.angle = Math.min(Math.PI / 2, cabinet.angle + (t - 0.45) * 2.4 * dt);
      if (cabinet.angle >= Math.PI / 2) {
        this.emit(state, 'cabinet-impact', 'impact', t, { x: 393, y: 524 }, 'Dolap devrildi → gaz borusuna darbe.');
      }
    }
    if (t > 1.05) {
      lamp.active = true;
      lamp.velocityY += 980 * dt;
      const maxDrop = level.floorY - lamp.bounds.y - lamp.bounds.height;
      lamp.offsetY = Math.min(maxDrop, lamp.offsetY + lamp.velocityY * dt);
      lamp.angle = Math.sin(t * 12) * 0.2;
      if (lamp.offsetY >= maxDrop) {
        lamp.velocityY = 0;
        this.emit(state, 'lamp-impact', 'impact', t, { x: 608, y: 530 }, 'Tavan lambası düştü → elektrik kıvılcımı.');
      }
    }
    const pipeHit = state.events.some(e => e.id === 'cabinet-impact');
    if (!gas.mitigated && ((pipeHit && t > 1.65) || t > 2.05)) {
      gas.active = true;
      this.emit(state, 'gas-leak', 'leak', t, { x: 406, y: 480 }, pipeHit ? 'Darbe boruyu kırdı → gaz sızıntısı.' : 'Sarsıntı boru bağlantısını açtı → gaz sızıntısı.');
      if (t > 2.65 && state.events.some(e => e.id === 'lamp-impact')) {
        this.emit(state, 'gas-explosion', 'explosion', t, { x: 419, y: 486 }, 'Gaz + kıvılcım → ikincil patlama.');
      }
    }
    if (t > 2.35) {
      stairs.active = true;
      this.emit(state, 'stairs-collapse', 'collapse', t, { x: 765, y: 495 }, 'Merdiven sahanlığı çöktü.');
    }
    for (const npc of state.npcs) {
      if (npc.coached) {
        npc.status = 'sheltering';
        npc.position.x = Math.max(level.shelter.x, npc.position.x - 160 * dt);
        npc.position.y = level.shelter.y;
        this.emit(state, `shelter-${npc.id}`, 'protected', t, npc.position, 'Deniz: Çök · Kapan · Tutun. Sarsıntının bitmesini bekle.');
      } else if (npc.health > 0) {
        npc.status = 'panicking';
        npc.position.x = Math.min(764, npc.position.x + 88 * dt);
        if (stairs.active && npc.position.x >= 740) {
          npc.health = 0;
          npc.status = 'injured';
          this.emit(state, `stairs-injury-${npc.id}`, 'injury', t, npc.position, 'Panik rotası → çöken merdivende yaralanma.');
        }
      }
      if (state.events.some(e => e.id === 'gas-explosion') && npc.coached) {
        npc.health = Math.min(npc.health, 55);
        this.emit(state, `blast-injury-${npc.id}`, 'injury', t, npc.position, 'Masa doğrudan darbeyi azalttı; gaz patlaması yaralanmaya yol açtı.');
      }
    }
  }

  private emit(state: GameState, id: string, kind: SimulationEvent['kind'], time: number, position: { x: number; y: number }, message: string): void {
    if (!state.events.some(e => e.id === id)) state.events.push({ id, kind, time, position: { ...position }, message });
  }
}
