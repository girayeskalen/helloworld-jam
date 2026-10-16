import { Engine } from './core/Engine';
import { SimulationManager } from './core/SimulationManager';
import { PhysicsView } from './integration/PhysicsView';
import { prototypeLevel } from './levels/levels';
import type { InputState } from './types/game';
import './ui_vfx/styles.css';

const canvas = document.querySelector<HTMLCanvasElement>('#game')!;
const simulation = new SimulationManager(prototypeLevel);
const level = simulation.level;
const view = new PhysicsView(canvas, document.querySelector<HTMLElement>('#hud')!, level, simulation);
const keys = new Set<string>();
const listeners = new AbortController();
const options = { signal: listeners.signal };
const input = (): InputState => ({
  left: keys.has('ArrowLeft') || keys.has('KeyA'), right: keys.has('ArrowRight') || keys.has('KeyD'),
  up: keys.has('ArrowUp') || keys.has('KeyW'), down: keys.has('ArrowDown') || keys.has('KeyS'),
  jump: keys.has('Space'), grip: keys.has('Space'),
});
const engine = new Engine(simulation, view, input);
window.addEventListener('keydown', event => {
  const state = simulation.getState();
  const nativeButtonSpace = event.code === 'Space' && event.target instanceof HTMLButtonElement && (state.phase === 'PLANNING' || state.score);
  if (nativeButtonSpace) return;
  if (['Space', 'ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(event.code)) event.preventDefault();
  keys.add(event.code);
  if (event.repeat) return;
  if (event.code === 'KeyM') { document.querySelector<HTMLButtonElement>('#sound')!.click(); return; }
  void view.sound.unlock();
  if (event.code === 'Space' && state.phase === 'PLANNING') { simulation.execute(); canvas.focus(); }
  if (event.code === 'KeyR') {
    if (state.phase === 'PLANNING') simulation.undoPlanning(); else if (state.score) simulation.restart();
  }
  const digit = /^Digit([1-7])$/.exec(event.code);
  if (digit) {
    const action = level.interventions[Number(digit[1]) - 1];
    if (action && simulation.intervene(action.id)) view.sound.confirm();
  }
}, options);
window.addEventListener('keyup', event => keys.delete(event.code), options);
window.addEventListener('pointerdown', event => {
  if (!(event.target instanceof Element && event.target.closest('#sound'))) void view.sound.unlock();
}, options);
window.addEventListener('blur', () => keys.clear(), options);
document.addEventListener('visibilitychange', () => {
  keys.clear(); document.querySelector<HTMLElement>('#pause-notice')!.hidden = !document.hidden;
  if (document.hidden) engine.stop(); else engine.start();
}, options);

function actionAt(event: PointerEvent) {
  const bounds = canvas.getBoundingClientRect();
  const x = (event.clientX - bounds.left) * canvas.width / bounds.width;
  const y = (event.clientY - bounds.top) * canvas.height / bounds.height;
  const state = simulation.getState();
  return level.interventions.find(action => {
    const body = state.physicsBodies.find(body => body.id === action.targetId);
    if (!body) return false;
    return body.parts.some(part => {
      // Planlama gövdelerinin gerçek köşelerinden ölçek bağımsız seçim kutusu.
      const xs = part.map(p => p.x), ys = part.map(p => p.y);
      return x >= Math.min(...xs) - 6 && x <= Math.max(...xs) + 6 && y >= Math.min(...ys) - 6 && y <= Math.max(...ys) + 6;
    });
  });
}
canvas.addEventListener('pointerdown', event => {
  const action = actionAt(event);
  if (action && simulation.intervene(action.id)) view.sound.confirm();
  canvas.focus();
}, options);
canvas.addEventListener('pointermove', event => { canvas.style.cursor = simulation.getState().phase === 'PLANNING' && actionAt(event) ? 'pointer' : 'default'; }, options);

view.render(simulation.getState(), 0);
engine.start();
if (import.meta.hot) import.meta.hot.dispose(() => { listeners.abort(); engine.stop(); simulation.dispose(); });
