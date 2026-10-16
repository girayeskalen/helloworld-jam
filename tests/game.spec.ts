import { expect, test } from '@playwright/test';
import type { Page } from '@playwright/test';

async function planning(page: Page): Promise<void> {
  await page.clock.runFor(6100);
  await expect(page.locator('[data-phase="PLANNING"]')).toHaveClass('active');
}

test.beforeEach(async ({ page }) => {
  await page.clock.install();
  await page.goto('/');
});

test('otomatik öngörü, görünür geri sarma ve müdahalesiz yaralanma', async ({ page }) => {
  const errors: string[] = [];
  page.on('pageerror', error => errors.push(error.message));
  await expect(page.locator('canvas')).toHaveAttribute('width', '1280');
  await expect(page.locator('[data-phase="FORESIGHT"]')).toHaveClass('active');
  await page.clock.runFor(4200);
  await expect(page.locator('[data-phase="REWIND"]')).toHaveClass('active');
  await page.clock.runFor(1800);
  await expect(page.locator('#ap')).toHaveAttribute('aria-label', '3 aksiyon puanı kaldı');
  await page.keyboard.press('Space');
  await page.clock.runFor(4200);
  await expect(page.locator('#report')).toBeVisible();
  await expect(page.locator('#rank')).toHaveText('C');
  await expect(page.locator('#report-reason')).toContainText('yaralandı');
  expect(errors).toEqual([]);
});

test('ölçeklenmiş canvas tıklaması, AP koruması, aktif tahliye ve S karnesi', async ({ page }) => {
  await page.setViewportSize({ width: 1100, height: 780 });
  await planning(page);
  const canvas = page.locator('canvas');
  const bounds = (await canvas.boundingBox())!;
  const click = async (x: number, y: number) => page.mouse.click(bounds.x + x / 1280 * bounds.width, bounds.y + y / 720 * bounds.height);
  await click(270, 450);
  await click(270, 450);
  await expect(page.locator('#ap')).toHaveAttribute('aria-label', '2 aksiyon puanı kaldı');
  await click(530, 507);
  await click(405, 415);
  await expect(page.locator('#ap')).toHaveAttribute('aria-label', '0 aksiyon puanı kaldı');
  await expect(page.locator('.action.applied')).toHaveCount(3);
  await page.keyboard.press('Space');
  await page.clock.runFor(4200);
  await expect(page.locator('#evac-clock')).toBeVisible();
  await page.keyboard.down('ArrowRight');
  await page.clock.runFor(2900);
  await page.keyboard.up('ArrowRight');
  await expect(page.locator('#rank')).toHaveText('S');
  await expect(page.locator('#score-breakdown')).toContainText('100/100');
  await page.locator('#restart').click();
  await page.clock.runFor(50);
  await expect(page.locator('#report')).toBeHidden();
  await expect(page.locator('[data-phase="FORESIGHT"]')).toHaveClass('active');
});

test('klavye müdahalesi, planı sıfırlama ve artçı süresi dolması', async ({ page }) => {
  await planning(page);
  await page.keyboard.press('Digit1');
  await page.keyboard.press('KeyR');
  await expect(page.locator('#ap')).toHaveAttribute('aria-label', '3 aksiyon puanı kaldı');
  for (const code of ['Digit1', 'Digit2', 'Digit3']) await page.keyboard.press(code);
  await page.keyboard.press('Space');
  await page.clock.runFor(14_500);
  await expect(page.locator('#report-reason')).toContainText('ulaşamadın');
  await expect(page.locator('#score-breakdown')).toContainText('70/100');
  await expect(page.locator('#rank')).toHaveText('B');
});

test('DOM müdahale butonları ve Space ile yerel buton erişilebilirliği', async ({ page }) => {
  await planning(page);
  await page.locator('[data-action="coach-npc"]').focus();
  await page.keyboard.press('Space');
  await expect(page.locator('.action.applied')).toHaveCount(1);
  await expect(page.locator('[data-phase="PLANNING"]')).toHaveClass('active');
  await page.locator('[data-action="anchor-cabinet"]').click();
  await page.locator('[data-action="gas-sensor"]').click();
  await page.locator('#start').click();
  await page.clock.runFor(4200);
  await page.keyboard.down('KeyD');
  await page.clock.runFor(2900);
  await page.keyboard.up('KeyD');
  await expect(page.locator('#rank')).toHaveText('S');
});

test('ses kullanıcı jestiyle açılır ve gizli sekmede simülasyon durur', async ({ page }) => {
  const errors: string[] = [];
  page.on('pageerror', error => errors.push(error.message));
  await expect(page.locator('#sound')).toHaveText('SESİ AÇ');
  await page.locator('#sound').click();
  await page.clock.runFor(100);
  await expect(page.locator('#sound')).toHaveText('SES AÇIK [M]');
  await page.keyboard.press('KeyM');
  await page.clock.runFor(50);
  await expect(page.locator('#sound')).toHaveText('SES KAPALI [M]');
  await page.evaluate(() => {
    Object.defineProperty(document, 'hidden', { configurable: true, value: true });
    document.dispatchEvent(new Event('visibilitychange'));
  });
  await page.clock.runFor(12_000);
  await expect(page.locator('#pause-notice')).toBeVisible();
  await expect(page.locator('[data-phase="FORESIGHT"]')).toHaveClass('active');
  await page.evaluate(() => {
    Object.defineProperty(document, 'hidden', { configurable: true, value: false });
    document.dispatchEvent(new Event('visibilitychange'));
  });
  await page.clock.runFor(6100);
  await expect(page.locator('#pause-notice')).toBeHidden();
  await expect(page.locator('[data-phase="PLANNING"]')).toHaveClass('active');
  const layoutFits = await page.evaluate(() => document.querySelector('.key-guide')!.getBoundingClientRect().bottom < document.querySelector('.status-bar')!.getBoundingClientRect().top);
  expect(layoutFits).toBe(true);
  expect(errors).toEqual([]);
});

test('olay zinciri, tam geri sarma, başlangıç verisinin korunması ve alternatif sonuçlar', async ({ page }) => {
  const result = await page.evaluate(async () => {
    const corePath = '/src/core/SimulationManager.ts';
    const levelPath = '/src/levels/levels.ts';
    const { SimulationManager } = await import(corePath);
    const { prototypeLevel } = await import(levelPath);
    const original = JSON.stringify(prototypeLevel);
    const simulation = new SimulationManager(prototypeLevel);
    const idle = { left: false, right: false, up: false, down: false };
    const advance = (seconds: number, input = idle) => {
      for (let i = 0; i < Math.ceil(seconds * 60); i++) simulation.update(1 / 60, input);
    };
    advance(4.05);
    const disaster = structuredClone(simulation.getState());
    advance(0.7);
    const rewindingTime = simulation.getState().time;
    advance(1);
    const reset = structuredClone(simulation.getState());
    simulation.intervene('coach-npc');
    simulation.execute();
    advance(4.1);
    const partial = structuredClone(simulation.getState());
    simulation.restart();
    advance(5.7);
    for (const id of ['anchor-cabinet', 'coach-npc', 'gas-sensor']) simulation.intervene(id);
    simulation.execute();
    advance(4.1);
    const protectedState = structuredClone(simulation.getState());
    // Enkaz çarpışması: yukarıdan geçmeye çalışınca x konumu engelde kalır.
    advance(0.7, { ...idle, up: true });
    advance(2, { ...idle, right: true });
    const blockedX = simulation.getState().npcs[0].position.x;
    return { disaster, rewindingTime, reset, partial, protectedState, blockedX, originalUnchanged: original === JSON.stringify(prototypeLevel) };
  });
  expect(result.disaster.events.map((event: { id: string }) => event.id)).toEqual(expect.arrayContaining(['cabinet-impact', 'lamp-impact', 'gas-leak', 'gas-explosion', 'stairs-collapse', 'stairs-injury-deniz']));
  expect(result.disaster.npcs[0].health).toBe(0);
  expect(result.rewindingTime).toBeGreaterThan(0);
  expect(result.rewindingTime).toBeLessThan(4);
  expect(result.reset.time).toBe(0);
  expect(result.reset.events).toHaveLength(0);
  expect(result.reset.hazards.every((hazard: { active: boolean }) => !hazard.active)).toBe(true);
  expect(result.reset.npcs[0].health).toBe(100);
  expect(result.partial.npcs[0].health).toBe(55);
  expect(result.protectedState.npcs[0].health).toBe(100);
  expect(result.protectedState.events.some((event: { id: string }) => event.id === 'gas-explosion')).toBe(false);
  expect(result.blockedX).toBeLessThan(716);
  expect(result.originalUnchanged).toBe(true);
});
