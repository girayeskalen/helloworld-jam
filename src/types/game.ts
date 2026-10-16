/** Sözleşme v0.2: Matter nesneleri dışarı sızmaz; koordinatlar piksel, açılar radyan. */
export type Vec2 = { x: number; y: number };
export type Rect = Vec2 & { width: number; height: number };
export type Phase = 'FORESIGHT' | 'REWIND' | 'PLANNING' | 'EXECUTION';
export type ExecutionStage = 'SHAKING' | 'EVACUATION' | 'REPORT';
export type InterventionId = 'anchor-cabinet' | 'coach-npc' | 'gas-sensor' | 'anchor-bookcase' | 'anchor-fridge' | 'reinforce-table' | 'reinforce-column';

export type PhysicsObjectType = 'floor' | 'wall' | 'column' | 'cabinet' | 'bookcase' | 'fridge' | 'table' | 'lamp' | 'ceiling' | 'debris' | 'gas' | 'npc';
export interface DangerArc { origin: Vec2; radius: number; startAngle: number; endAngle: number }
export interface PhysicsBodyState {
  id: string;
  type: PhysicsObjectType;
  label: string;
  /** Dünya kütle merkezi. Compound gövdeleri doğru çizmek için parts kullanılır. */
  x: number; y: number; width: number; height: number; angle: number;
  velocity: Vec2; angularVelocity: number;
  mass: number; friction: number;
  isStatic: boolean; isSecured: boolean;
  integrity: number; maxIntegrity: number;
  broken: boolean; grounded: boolean;
  dangerArc: DangerArc | null;
  parts: Vec2[][];
}
export interface PhysicsObjectDefinition {
  id: string; type: PhysicsObjectType; label: string;
  x: number; y: number; width: number; height: number;
  mass: number; friction: number; integrity: number;
  isStatic?: boolean;
  /** Gövdeye göre değil, dünya koordinatlarında compound dikdörtgenleri. */
  parts?: Rect[];
  centreOffset?: Vec2;
}
export interface ShelterDefinition { id: string; label: string; supportId: string; position: Vec2 }
export interface PhysicsLevelData { objects: PhysicsObjectDefinition[]; shelters: ShelterDefinition[]; seed: number }
export interface SafeTriangle {
  id: string; supportId: string; label: string;
  polygon: Vec2[]; position: Vec2;
  isClear: boolean; supported: boolean; occupied: boolean; blockedBy: string[];
}
export interface GripState {
  balance: number; velocity: number; target: number; greenHalfWidth: number;
  stamina: number; stableTime: number; exposureTime: number;
  slips: number; holding: boolean; slipCooldown: number;
}
export interface SeismicState { x: number; y: number; pWave: number; sWave: number; intensity: number }
export interface PhysicsConstraintState {
  id: string; bodyA: string | null; bodyB: string;
  pointA: Vec2; pointB: Vec2; length: number; stiffness: number; damping: number;
  breakingStrain: number; kind: 'anchor' | 'support' | 'suspension' | 'grip';
}
export interface PhysicsBodySnapshot {
  id: string; definition: PhysicsObjectDefinition; position: Vec2; velocity: Vec2; angle: number; angularVelocity: number;
  isStatic: boolean; isSensor: boolean; collisionMask: number;
  integrity: number; maxIntegrity: number; broken: boolean; isSecured: boolean; lastImpactTick: number;
}
export interface PhysicsSnapshot {
  bodies: PhysicsBodySnapshot[]; constraints: PhysicsConstraintState[];
  motion: SeismicState; tick: number; jumpHeld: boolean; coyoteTime: number;
  gasLeaking: boolean; ignited: boolean; lampReleased: boolean;
}

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
  grounded?: boolean;
  velocity?: Vec2;
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
  physics?: PhysicsLevelData;
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
  physicsBodies: PhysicsBodyState[];
  constraints: PhysicsConstraintState[];
  safeTriangles: SafeTriangle[];
  selectedShelterId: string;
  grip: GripState;
  seismic: SeismicState;
  physicsTick: number;
}

export interface InputState { left: boolean; right: boolean; up: boolean; down: boolean; jump?: boolean; grip?: boolean }
export type DeepReadonly<T> = T extends object ? { readonly [K in keyof T]: DeepReadonly<T[K]> } : T;
export interface GameController {
  getState(): DeepReadonly<GameState>;
  intervene(id: InterventionId): boolean;
  execute(): void;
  restart(): void;
  undoPlanning(): void;
  selectShelter(id: string): boolean;
}
export interface GamePresentation {
  render(state: DeepReadonly<GameState>, delta: number): void;
  reset(): void;
}
