import type { DeepReadonly, GameController, GameState, InputState, InterventionId, LevelData } from '../types/game';
import { PhysicsHazardSystem } from './PhysicsHazardSystem';
import { TimelineRewind } from './TimelineRewind';

export class SimulationManager implements GameController {
  private state: GameState;
  private readonly physics = new PhysicsHazardSystem();
  private readonly timeline = new TimelineRewind();

  constructor(private readonly level: LevelData) {
    this.state = this.initialState('FORESIGHT');
    this.timeline.record(this.state);
  }

  getState(): DeepReadonly<GameState> { return this.state; }

  update(dt: number, input: InputState): void {
    const state = this.state;
    state.phaseElapsed += dt;
    if (state.phase === 'FORESIGHT' || (state.phase === 'EXECUTION' && state.executionStage === 'SHAKING')) {
      state.time = Math.min(this.level.quakeDuration, state.time + dt);
      this.physics.update(state, this.level, dt);
      if (state.phase === 'FORESIGHT') this.timeline.record(state);
      if (state.time >= this.level.quakeDuration) {
        state.shake = 0;
        state.phaseElapsed = 0;
        if (state.phase === 'FORESIGHT') {
          state.phase = 'REWIND';
          state.message = 'Olası gelecek kaydedildi. T = 0 anına dönülüyor…';
        } else {
          state.executionStage = 'EVACUATION';
          state.message = 'Sarsıntı durdu. Sağdaki zemin çıkışına ilerle; merdiveni kullanma.';
          if (state.npcs.every(npc => npc.health <= 0)) this.finish(false, 'Deniz yaralandı; kendi başına tahliye olamıyor.');
        }
      }
    } else if (state.phase === 'REWIND') {
      const elapsed = state.phaseElapsed;
      this.state = this.timeline.sample(elapsed / this.level.rewindDuration);
      this.state.phase = 'REWIND';
      this.state.phaseElapsed = elapsed;
      this.state.message = 'Gelecek değiştirilebilir. Zaman geri sarılıyor…';
      if (elapsed >= this.level.rewindDuration) {
        this.state = this.initialState('PLANNING');
        this.state.message = 'Üç karar. Bir farklı gelecek. Nesnelere veya sağdaki müdahalelere tıkla.';
      }
    } else if (state.phase === 'EXECUTION' && state.executionStage === 'EVACUATION') {
      state.aftershockRemaining = Math.max(0, state.aftershockRemaining - dt);
      const npc = state.npcs.find(person => person.health > 0)!;
      npc.status = 'evacuating';
      const dx = Number(input.right) - Number(input.left);
      const dy = Number(input.down) - Number(input.up);
      const norm = Math.hypot(dx, dy) || 1;
      const speed = npc.health < 100 ? 115 : 155;
      const radius = 10;
      const bounds = this.level.walkBounds;
      const old = { ...npc.position };
      npc.position.x = Math.max(bounds.x + radius, Math.min(bounds.x + bounds.width - radius, old.x + dx / norm * speed * dt));
      if (this.collides(npc.position.x, npc.position.y, radius)) npc.position.x = old.x;
      npc.position.y = Math.max(bounds.y + radius, Math.min(bounds.y + bounds.height - radius, old.y + dy / norm * speed * dt));
      if (this.collides(npc.position.x, npc.position.y, radius)) npc.position.y = old.y;
      const exit = this.level.exit;
      if (npc.position.x >= exit.x && npc.position.y >= exit.y && state.aftershockRemaining > 0) {
        npc.status = 'safe';
        state.events.push({ id: 'evacuated', kind: 'evacuation', time: state.time, position: { ...npc.position }, message: 'Deniz güvenli çıkışa ulaştı.' });
        this.finish(true, 'Sarsıntıdan sonra güvenli zemin çıkışını kullandın.');
      } else if (state.aftershockRemaining <= 0) {
        state.shake = 9;
        state.events.push({ id: 'aftershock', kind: 'aftershock', time: state.time, position: { ...npc.position }, message: 'Artçı sarsıntı başladı. Tahliye süresi doldu.' });
        this.finish(false, 'Artçı sarsıntıdan önce çıkışa ulaşamadın.');
      }
    }
  }

  intervene(id: InterventionId): boolean {
    const state = this.state;
    const action = this.level.interventions.find(item => item.id === id);
    if (state.phase !== 'PLANNING' || !action || state.ap < action.cost || state.appliedInterventions.includes(id)) return false;
    state.appliedInterventions.push(id);
    state.ap -= action.cost;
    if (id === 'coach-npc') state.npcs.forEach(npc => { npc.coached = true; });
    else {
      const hazard = state.hazards.find(item => item.id === action.targetId);
      if (hazard) hazard.mitigated = true;
    }
    state.message = this.level.awarenessRules.find(rule => rule.id === action.ruleId)?.explanation ?? action.description;
    return true;
  }

  execute(): void {
    if (this.state.phase !== 'PLANNING') return;
    this.state.phase = 'EXECUTION';
    this.state.phaseElapsed = 0;
    this.state.time = 0;
    this.state.message = 'Müdahalelerin sınanıyor. Sarsıntı boyunca korun, sonra tahliye ol.';
  }

  undoPlanning(): void {
    if (this.state.phase === 'PLANNING') this.state = this.initialState('PLANNING');
  }

  restart(): void {
    this.timeline.reset();
    this.state = this.initialState('FORESIGHT');
    this.timeline.record(this.state);
  }

  private collides(x: number, y: number, radius: number): boolean {
    return this.level.tiles.some(tile => {
      if (!tile.solid || tile.kind !== 'obstacle') return false;
      const b = tile.bounds;
      return x + radius > b.x && x - radius < b.x + b.width && y + radius > b.y && y - radius < b.y + b.height;
    });
  }

  private finish(evacuated: boolean, reason: string): void {
    const state = this.state;
    const engineering = Number(state.appliedInterventions.includes('anchor-cabinet')) * 20 + Number(state.appliedInterventions.includes('gas-sensor')) * 20;
    const awareness = state.appliedInterventions.includes('coach-npc') ? 30 : 0;
    const evacuation = evacuated ? 30 : 0;
    const total = engineering + awareness + evacuation;
    state.score = { engineering, awareness, evacuation, total, rank: total === 100 ? 'S' : total >= 80 ? 'A' : total >= 50 ? 'B' : 'C', evacuated, reason };
    state.executionStage = 'REPORT';
    state.message = reason;
  }

  private initialState(phase: GameState['phase']): GameState {
    return {
      phase, executionStage: 'SHAKING', time: 0, phaseElapsed: 0,
      ap: this.level.actionPoints, appliedInterventions: [],
      hazards: structuredClone(this.level.hazards), npcs: structuredClone(this.level.npcs),
      events: [], aftershockRemaining: this.level.evacuationDuration, shake: 0, score: null,
      message: 'Önce olası felaketi izle. Dört saniye sonra zaman geri sarılacak.',
    };
  }
}
