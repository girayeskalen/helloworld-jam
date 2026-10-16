/** Ortak sözleşme v0.1. Değişiklikler iki kişinin mutabakatıyla entegrasyon sorumlusunda. */
export type Vec2 = { x: number; y: number };
export type Rect = Vec2 & { width: number; height: number };
export type Phase = 'FORESIGHT' | 'REWIND' | 'PLANNING' | 'EXECUTION';
export type ExecutionStage = 'SHAKING' | 'EVACUATION' | 'REPORT';
export type InterventionId = 'anchor-cabinet' | 'coach-npc' | 'gas-sensor';

export interface Hazard {
  id: string;
  kind: 'cabinet' | 'lamp' | 'gas' | 'stairs';
  bounds: Rect;
  active: boolean;
  mitigated: boolean;
  angle: number;
  offsetY: number;
  velocityY: number;
}

export interface Intervention {
  id: InterventionId;
  targetId: string;
  label: string;
  description: string;
  cost: number;
  hitbox: Rect;
  ruleId: string;
}

export interface NPC {
  id: string;
  name: string;
  position: Vec2;
  health: number;
  coached: boolean;
  status: 'idle' | 'panicking' | 'sheltering' | 'injured' | 'evacuating' | 'safe';
}

export interface Tile {
  id: string;
  kind: 'floor' | 'wall' | 'desk' | 'exit' | 'obstacle';
  bounds: Rect;
  solid: boolean;
}

export interface AwarenessRule {
  id: string;
  title: string;
  explanation: string;
  sourceUrl: string;
}

export interface LevelData {
  id: string;
  title: string;
  subtitle: string;
  width: number;
  height: number;
  floorY: number;
  walkBounds: Rect;
  exit: Rect;
  shelter: Vec2;
  quakeDuration: number;
  rewindDuration: number;
  evacuationDuration: number;
  actionPoints: number;
  hazards: Hazard[];
  npcs: NPC[];
  tiles: Tile[];
  interventions: Intervention[];
  awarenessRules: AwarenessRule[];
}

export interface SimulationEvent {
  id: string;
  time: number;
  kind: 'quake' | 'impact' | 'collapse' | 'leak' | 'explosion' | 'injury' | 'protected' | 'evacuation' | 'aftershock';
  position: Vec2;
  message: string;
}

export interface ScoreCard {
  engineering: number;
  awareness: number;
  evacuation: number;
  total: number;
  rank: 'S' | 'A' | 'B' | 'C';
  evacuated: boolean;
  reason: string;
}

export interface GameState {
  phase: Phase;
  executionStage: ExecutionStage;
  time: number;
  phaseElapsed: number;
  ap: number;
  appliedInterventions: InterventionId[];
  hazards: Hazard[];
  npcs: NPC[];
  events: SimulationEvent[];
  aftershockRemaining: number;
  shake: number;
  score: ScoreCard | null;
  message: string;
}

export interface InputState { left: boolean; right: boolean; up: boolean; down: boolean }
export type DeepReadonly<T> = T extends object ? { readonly [K in keyof T]: DeepReadonly<T[K]> } : T;
export interface GameController {
  getState(): DeepReadonly<GameState>;
  intervene(id: InterventionId): boolean;
  execute(): void;
  restart(): void;
  undoPlanning(): void;
}
export interface GamePresentation {
  render(state: DeepReadonly<GameState>, delta: number): void;
  reset(): void;
}
