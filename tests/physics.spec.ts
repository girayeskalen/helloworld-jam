import { expect, test } from '@playwright/test';

test.beforeEach(async ({ page }) => {
  await page.route('**/physics-harness', route => route.fulfill({ contentType: 'text/html', body: '<html><body></body></html>' }));
  await page.goto('/physics-harness');
});

test('rijit cisimler devrilir, yük altında masa/kolon kırılır; 30 Hz kayıt bütün dünyayı geri alır', async ({ page }) => {
  const result = await page.evaluate(async () => {
    const path = '/tests/physicsHarness.ts';
    const h = await import(path); const sim = h.create();
    const initial = structuredClone(sim.getState());
    h.advance(sim, 8);
    const disaster = structuredClone(sim.getState()); const count = sim.recordedFrames;
    h.advance(sim, 0.8); const middle = structuredClone(sim.getState());
    h.advance(sim, 1.1); const restored = structuredClone(sim.getState());
    sim.restart(); h.advance(sim, 8); const repeated = structuredClone(sim.getState()); sim.dispose();
    return { initial, disaster, count, middle, restored, repeated };
  });
  expect(result.count).toBe(241);
  expect(result.disaster.physicsBodies.find(b => b.id === 'cabinet')!.angle).toBeGreaterThan(1);
  expect(result.disaster.events.map(e => e.id)).toEqual(expect.arrayContaining(['fracture-desk', 'fracture-column', 'gas-explosion']));
  expect(result.disaster.physicsBodies.some(b => b.type === 'debris')).toBe(true);
  expect(result.disaster.npcs[0].health).toBeLessThan(100);
  expect(result.disaster.npcs[0].position.y).toBeLessThan(550);
  expect(result.middle.phase).toBe('REWIND'); expect(result.middle.time).toBeGreaterThan(0); expect(result.middle.time).toBeLessThan(8);
  expect(result.restored.phase).toBe('PLANNING'); expect(result.restored.time).toBe(0);
  expect(result.restored.physicsBodies).toEqual(result.initial.physicsBodies);
  expect(result.restored.npcs[0].health).toBe(100);
  expect(result.restored.events).toEqual([]);
  expect(result.restored.constraints).toEqual(result.initial.constraints);
  expect(result.repeated.physicsBodies).toEqual(result.disaster.physicsBodies);
});

test('L-demir gerçek bağ oluşturur; aynı sarsıntıda güçlendirilmiş masa ayakta kalır', async ({ page }) => {
  const result = await page.evaluate(async () => {
    const path = '/tests/physicsHarness.ts'; const h = await import(path);
    const sim = h.create();
    h.prepare(sim, ['anchor-cabinet', 'reinforce-table', 'gas-sensor', 'coach-npc']);
    const plan = structuredClone(sim.getState());
    const maxima = h.quake(sim, true); const final = structuredClone(sim.getState()); sim.dispose();
    return { plan, maxima, final };
  });
  expect(result.plan.constraints.filter(c => c.id.startsWith('anchor-cabinet'))).toHaveLength(2);
  expect(result.maxima.cabinet).toBeLessThan(0.15);
  const desk = result.final.physicsBodies.find(b => b.id === 'desk')!;
  expect(desk.isSecured).toBe(true); expect(desk.broken).toBe(false); expect(desk.integrity).toBeGreaterThan(0);
  expect(desk.maxIntegrity).toBeGreaterThan(200);
  expect(result.final.safeTriangles.find(s => s.id === 'table')!.supported).toBe(true);
  expect(result.final.events.some(e => e.id === 'gas-explosion')).toBe(false);
});

test('maliyet, çift uygulama ve sığınak seçimleri bütçeyi aşamaz; sıfırlama fizik bağlarını da temizler', async ({ page }) => {
  const result = await page.evaluate(async () => {
    const path = '/tests/physicsHarness.ts'; const h = await import(path); const sim = h.create();
    h.advance(sim, 10);
    const first = sim.intervene('reinforce-table'); const duplicate = sim.intervene('reinforce-table');
    const afterTable = sim.getState().ap;
    const selected = sim.selectShelter('column'); const selectedAgain = sim.selectShelter('table');
    const afterShelter = sim.getState().ap;
    sim.intervene('reinforce-column'); const overBudget = sim.intervene('gas-sensor');
    const spent = sim.getState().ap;
    sim.undoPlanning(); const reset = structuredClone(sim.getState()); sim.dispose();
    return { first, duplicate, afterTable, selected, selectedAgain, afterShelter, overBudget, spent, reset };
  });
  expect(result.first).toBe(true); expect(result.duplicate).toBe(false); expect(result.afterTable).toBe(3);
  expect(result.selected).toBe(true); expect(result.selectedAgain).toBe(true); expect(result.afterShelter).toBe(2);
  expect(result.overBudget).toBe(false); expect(result.spent).toBe(0);
  expect(result.reset.ap).toBe(5); expect(result.reset.appliedInterventions).toEqual([]);
  expect(result.reset.physicsBodies.every(b => !b.isSecured)).toBe(true);
  expect(result.reset.constraints.some(c => c.kind === 'anchor')).toBe(false);
});

test('aktif dengeleme aynı planda savrulmayı ve sağlık kaybını azaltır; Space enerjisi sınırsız değildir', async ({ page }) => {
  const result = await page.evaluate(async () => {
    const path = '/tests/physicsHarness.ts'; const h = await import(path); const results = [];
    for (const active of [false, true]) {
      const sim = h.create(); h.prepare(sim, h.tablePlan); h.quake(sim, active);
      results.push(structuredClone(sim.getState())); sim.dispose();
    }
    const held = h.create(); h.prepare(held, h.tablePlan); held.execute(); h.advance(held, 6, { ...h.idle, grip: true });
    const exhausted = structuredClone(held.getState()); held.dispose();
    return { passive: results[0], active: results[1], exhausted };
  });
  expect(result.active.grip.stableTime).toBeGreaterThan(7);
  expect(result.passive.grip.slips).toBeGreaterThan(0);
  expect(result.active.grip.slips).toBe(0);
  expect(result.active.npcs[0].health).toBeGreaterThan(result.passive.npcs[0].health);
  expect(result.active.aftershockRemaining).toBe(12);
  expect(result.exhausted.grip.stamina).toBeLessThan(0.05);
});

test('yerçekimi ve zıplama, havada ikinci zıplama koruması, 12 sn timeout ve alternatif S rotası', async ({ page }) => {
  const result = await page.evaluate(async () => {
    const path = '/tests/physicsHarness.ts'; const h = await import(path);
    // Zıplama mekaniğini açık hacimde ölç; masa üzerindeki fiziksel yük bir tavan engelidir.
    const jump = h.create(); h.prepare(jump, h.columnPlan, 'column'); h.quake(jump, true);
    const initialY = jump.getState().npcs[0].position.y;
    jump.update(1 / 60, { ...h.idle, jump: true });
    const firstVelocity = jump.getState().npcs[0].velocity.y;
    h.advance(jump, 0.12); jump.update(1 / 60, { ...h.idle, jump: true });
    const secondVelocity = jump.getState().npcs[0].velocity.y;
    const airborneY = jump.getState().npcs[0].position.y; jump.dispose();
    const success = h.create(); h.prepare(success, h.columnPlan, 'column'); h.quake(success, true); h.evacuate(success);
    const win = structuredClone(success.getState()); success.dispose();
    const timeout = h.create(); h.prepare(timeout, h.columnPlan, 'column'); h.quake(timeout, true); h.advance(timeout, 12.05);
    const lose = structuredClone(timeout.getState()); timeout.dispose();
    return { initialY, firstVelocity, secondVelocity, airborneY, win, lose };
  });
  expect(result.firstVelocity).toBeLessThan(-10);
  expect(result.airborneY).toBeLessThan(result.initialY - 30);
  expect(result.secondVelocity).toBeGreaterThan(result.firstVelocity + 1);
  expect(result.win.score!.rank).toBe('S'); expect(result.win.score!.total).toBe(100);
  expect(result.win.physicsBodies.find(b => b.id === 'column')!.broken).toBe(false);
  expect(result.lose.score!.evacuated).toBe(false); expect(result.lose.aftershockRemaining).toBe(0);
  expect(result.lose.events.some(e => e.id === 'aftershock')).toBe(true);
});
