import { Engine } from './core/Engine';
import { SimulationManager } from './core/SimulationManager';
import { prototypeLevel } from './levels/levels';
import type { GamePresentation, InputState } from './types/game';
import { Renderer } from './ui_vfx/Renderer';
import { SoundSynth } from './ui_vfx/SoundSynth';
import { TacticalHUD } from './ui_vfx/TacticalHUD';
import './ui_vfx/styles.css';

const canvas = document.querySelector<HTMLCanvasElement>('#game')!;
const simulation = new SimulationManager(prototypeLevel);
const renderer = new Renderer(canvas, prototypeLevel);
const sound = new SoundSynth();
const hud = new TacticalHUD(document.querySelector<HTMLElement>('#hud')!, simulation, prototypeLevel, sound);
const keys = new Set<string>();
let previousPhase = '';
let previousTime = 0;

const presentation: GamePresentation = {
  render(state, delta) {
    if ((state.phase === 'FORESIGHT' && (previousPhase !== state.phase || state.time < previousTime)) || (state.phase === 'EXECUTION' && previousPhase === 'PLANNING')) this.reset();
    renderer.render(state, delta);
    hud.render(state);
    sound.update(state);
    previousPhase = state.phase;
    previousTime = state.time;
  },
  reset() { renderer.reset(); hud.reset(); sound.reset(); },
};

const readInput = (): InputState => ({
  left: keys.has('ArrowLeft') || keys.has('KeyA'),
  right: keys.has('ArrowRight') || keys.has('KeyD'),
  up: keys.has('ArrowUp') || keys.has('KeyW'),
  down: keys.has('ArrowDown') || keys.has('KeyS'),
});

const engine = new Engine(simulation, presentation, readInput);
window.addEventListener('keydown', event => {
  const nativeButtonSpace = event.code === 'Space' && event.target instanceof HTMLButtonElement;
  if (nativeButtonSpace) return;
  if (['Space', 'ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(event.code)) event.preventDefault();
  keys.add(event.code);
  if (event.repeat) return;
  if (event.code === 'KeyM') {
    document.querySelector<HTMLButtonElement>('#sound')!.click();
    return;
  }
  void sound.unlock();
  if (event.code === 'Space') simulation.execute();
  if (event.code === 'KeyR') {
    if (simulation.getState().phase === 'PLANNING') simulation.undoPlanning();
    else if (simulation.getState().score) simulation.restart();
  }
  const action = { Digit1: 'anchor-cabinet', Digit2: 'coach-npc', Digit3: 'gas-sensor' } as const;
  const id = action[event.code as keyof typeof action];
  if (id && simulation.intervene(id)) sound.confirm();
});
window.addEventListener('keyup', event => keys.delete(event.code));
window.addEventListener('pointerdown', event => {
  if (!(event.target instanceof Element && event.target.closest('#sound'))) void sound.unlock();
});
window.addEventListener('blur', () => keys.clear());
document.addEventListener('visibilitychange', () => {
  keys.clear();
  document.querySelector<HTMLElement>('#pause-notice')!.hidden = !document.hidden;
  if (document.hidden) engine.stop(); else engine.start();
});
canvas.addEventListener('pointerdown', event => {
  const bounds = canvas.getBoundingClientRect();
  const x = (event.clientX - bounds.left) * canvas.width / bounds.width;
  const y = (event.clientY - bounds.top) * canvas.height / bounds.height;
  const action = prototypeLevel.interventions.find(item => x >= item.hitbox.x && x <= item.hitbox.x + item.hitbox.width && y >= item.hitbox.y && y <= item.hitbox.y + item.hitbox.height);
  if (action && simulation.intervene(action.id)) sound.confirm();
  canvas.focus();
});
canvas.addEventListener('pointermove', event => {
  const bounds = canvas.getBoundingClientRect();
  const x = (event.clientX - bounds.left) * canvas.width / bounds.width;
  const y = (event.clientY - bounds.top) * canvas.height / bounds.height;
  canvas.style.cursor = simulation.getState().phase === 'PLANNING' && prototypeLevel.interventions.some(item => x >= item.hitbox.x && x <= item.hitbox.x + item.hitbox.width && y >= item.hitbox.y && y <= item.hitbox.y + item.hitbox.height) ? 'pointer' : 'default';
});

presentation.render(simulation.getState(), 0);
engine.start();
if (import.meta.hot) import.meta.hot.dispose(() => engine.stop());
