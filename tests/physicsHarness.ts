import { SimulationManager } from '../src/core/SimulationManager';
import { prototypeLevel } from '../src/levels/levels';
import type { InputState, InterventionId } from '../src/types/game';

export const idle: InputState = { left: false, right: false, up: false, down: false, jump: false, grip: false };
export const tablePlan: InterventionId[] = ['reinforce-table', 'gas-sensor', 'anchor-fridge', 'coach-npc'];
export const columnPlan: InterventionId[] = ['reinforce-column', 'gas-sensor', 'anchor-cabinet', 'coach-npc'];
export function create() { return new SimulationManager(prototypeLevel); }
export function advance(sim: SimulationManager, seconds: number, input = idle): void {
  for (let i = 0; i < Math.ceil(seconds * 60 - 1e-8); i++) sim.update(1 / 60, input);
}
export function prepare(sim: SimulationManager, actions: InterventionId[], shelter = 'table'): void {
  advance(sim, 10);
  for (const action of actions) if (!sim.intervene(action)) throw new Error(`Müdahale reddedildi: ${action}`);
  if (actions.includes('coach-npc')) sim.selectShelter(shelter);
}
export function quake(sim: SimulationManager, active: boolean): Record<string, number> {
  const maxima: Record<string, number> = {};
  sim.execute();
  for (let i = 0; i < 480; i++) {
    const g = sim.getState().grip;
    const prediction = g.balance + g.velocity * 0.38 - g.target;
    const input = active ? { ...idle, left: prediction > 0.025, right: prediction < -0.025, grip: Math.abs(g.balance - g.target) > 0.18 && g.stamina > 0.15 } : idle;
    sim.update(1 / 60, input);
    for (const body of sim.getState().physicsBodies) maxima[body.id] = Math.max(maxima[body.id] ?? 0, Math.abs(body.angle));
  }
  return maxima;
}
export function evacuate(sim: SimulationManager): void {
  for (let i = 0; i < 720 && !sim.getState().score; i++) sim.update(1 / 60, { ...idle, right: true, jump: i % 43 < 4 });
}
