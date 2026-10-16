import { expect, test } from '@playwright/test';
import type { Page } from '@playwright/test';

async function planning(page: Page): Promise<void> {
  await page.clock.runFor(10_100);
  await expect(page.locator('[data-phase="PLANNING"]')).toHaveClass('active');
}

test.beforeEach(async ({ page }) => { await page.clock.install(); await page.goto('/'); });

test('öngörü → geri sarma → planlama; ölçekli nesne seçimi, maliyet ve yeniden planlama', async ({ page }) => {
  const errors: string[] = []; page.on('pageerror', error => errors.push(error.message));
  await page.setViewportSize({ width: 1100, height: 780 });
  await expect(page.locator('canvas')).toHaveAttribute('width', '1280');
  await page.clock.runFor(8200);
  await expect(page.locator('[data-phase="REWIND"]')).toHaveClass('active');
  await page.clock.runFor(2000);
  const box = (await page.locator('canvas').boundingBox())!;
  await page.mouse.click(box.x + 266 / 1280 * box.width, box.y + 450 / 720 * box.height);
  await page.clock.runFor(20);
  await expect(page.locator('#ap')).toHaveAttribute('aria-label', '4 aksiyon puanı kaldı');
  await page.mouse.click(box.x + 266 / 1280 * box.width, box.y + 450 / 720 * box.height);
  await page.clock.runFor(20);
  await expect(page.locator('#ap')).toHaveAttribute('aria-label', '4 aksiyon puanı kaldı');
  await page.keyboard.press('KeyR'); await page.clock.runFor(20);
  await expect(page.locator('#ap')).toHaveAttribute('aria-label', '5 aksiyon puanı kaldı');
  await page.locator('[data-action="reinforce-table"]').focus(); await page.keyboard.press('Space');
  await page.clock.runFor(20);
  await expect(page.locator('#ap')).toHaveAttribute('aria-label', '3 aksiyon puanı kaldı');
  await expect(page.locator('[data-phase="PLANNING"]')).toHaveClass('active');
  expect(errors).toEqual([]);
});

test('gerçek klavye girişleriyle tutunma, 12 sn tahliye, S karnesi ve temiz yeniden başlatma', async ({ page }) => {
  const errors: string[] = []; page.on('pageerror', error => errors.push(error.message));
  await planning(page);
  for (const code of ['Digit1', 'Digit5', 'Digit6', 'Digit7']) await page.keyboard.press(code);
  await page.locator('[data-shelter="column"]').click();
  await page.locator('#start').click();
  await page.clock.runFor(20);
  await expect(page.locator('#grip-panel')).toBeVisible();
  for (let i = 0; i < 80; i++) {
    const feedback = await page.locator('#grip-status').evaluate(element => ({
      balance: Number(element.getAttribute('aria-valuenow')) / 100,
      velocity: Number((element as HTMLElement).dataset.velocity),
      target: Number((element as HTMLElement).dataset.target),
    }));
    const prediction = feedback.balance + feedback.velocity * 0.38 - feedback.target;
    if (prediction > 0.025) { await page.keyboard.down('KeyA'); await page.keyboard.up('KeyD'); }
    else if (prediction < -0.025) { await page.keyboard.down('KeyD'); await page.keyboard.up('KeyA'); }
    else { await page.keyboard.up('KeyA'); await page.keyboard.up('KeyD'); }
    await page.clock.runFor(100);
  }
  await page.keyboard.up('KeyA'); await page.keyboard.up('KeyD');
  await page.clock.runFor(30);
  await expect(page.locator('#evac-clock')).toBeVisible();
  await expect(page.locator('#evac-clock')).toContainText('11.');
  await page.keyboard.down('ArrowRight'); await page.clock.runFor(2200); await page.keyboard.up('ArrowRight');
  await expect(page.locator('#rank')).toHaveText('S');
  await page.locator('#restart').click(); await page.clock.runFor(20);
  await expect(page.locator('#report')).toBeHidden();
  await expect(page.locator('[data-phase="FORESIGHT"]')).toHaveClass('active');
  expect(errors).toEqual([]);
});

test('ses kontrolü, gizli sekmede duraklama ve panelin ekran içinde kalması', async ({ page }) => {
  await page.locator('#sound').click(); await page.clock.runFor(100);
  await expect(page.locator('#sound')).toHaveText('SES AÇIK [M]');
  await page.keyboard.press('KeyM'); await page.clock.runFor(20);
  await expect(page.locator('#sound')).toHaveText('SES KAPALI [M]');
  await page.evaluate(() => { Object.defineProperty(document, 'hidden', { configurable: true, value: true }); document.dispatchEvent(new Event('visibilitychange')); });
  await page.clock.runFor(14_000);
  await expect(page.locator('#pause-notice')).toBeVisible();
  await expect(page.locator('[data-phase="FORESIGHT"]')).toHaveClass('active');
  await page.evaluate(() => { Object.defineProperty(document, 'hidden', { configurable: true, value: false }); document.dispatchEvent(new Event('visibilitychange')); });
  await planning(page);
  const fits = await page.evaluate(() => document.querySelector('.p-keys')!.getBoundingClientRect().bottom < document.querySelector('.p-status')!.getBoundingClientRect().top);
  expect(fits).toBe(true);
});
