import type { LevelData } from '../types/game';

const afad = 'https://afad.gov.tr/deprem-oncesi-ani-ve-sonrasi-alabileceginiz-onlemleri-biliyor-musunuz';

export const prototypeLevel: LevelData = {
  id: '01',
  title: 'KIRILGAN DENGE',
  subtitle: 'Zemin kat / konut + atölye',
  width: 1280,
  height: 720,
  floorY: 536,
  walkBounds: { x: 140, y: 477, width: 786, height: 59 },
  exit: { x: 860, y: 468, width: 64, height: 68 },
  shelter: { x: 483, y: 523 },
  quakeDuration: 4,
  rewindDuration: 1.5,
  evacuationDuration: 10,
  actionPoints: 3,
  hazards: [
    { id: 'cabinet', kind: 'cabinet', bounds: { x: 238, y: 408, width: 65, height: 128 }, active: false, mitigated: false, angle: 0, offsetY: 0, velocityY: 0 },
    { id: 'lamp', kind: 'lamp', bounds: { x: 590, y: 338, width: 36, height: 18 }, active: false, mitigated: false, angle: 0, offsetY: 0, velocityY: 0 },
    { id: 'gas', kind: 'gas', bounds: { x: 392, y: 390, width: 28, height: 128 }, active: false, mitigated: false, angle: 0, offsetY: 0, velocityY: 0 },
    { id: 'stairs', kind: 'stairs', bounds: { x: 716, y: 430, width: 104, height: 106 }, active: false, mitigated: false, angle: 0, offsetY: 0, velocityY: 0 },
  ],
  npcs: [{ id: 'deniz', name: 'Deniz', position: { x: 528, y: 523 }, health: 100, coached: false, status: 'idle' }],
  tiles: [
    { id: 'ground', kind: 'floor', bounds: { x: 124, y: 536, width: 816, height: 16 }, solid: true },
    { id: 'upper-floor', kind: 'floor', bounds: { x: 124, y: 318, width: 816, height: 14 }, solid: true },
    { id: 'wall-left', kind: 'wall', bounds: { x: 124, y: 200, width: 12, height: 336 }, solid: true },
    { id: 'wall-right', kind: 'wall', bounds: { x: 928, y: 200, width: 12, height: 268 }, solid: true },
    { id: 'desk', kind: 'desk', bounds: { x: 454, y: 492, width: 88, height: 44 }, solid: false },
    { id: 'exit', kind: 'exit', bounds: { x: 860, y: 468, width: 64, height: 68 }, solid: false },
    // Plan görünümündeki dar koridor: oyuncu merdiven enkazının altından geçer.
    { id: 'landing-debris', kind: 'obstacle', bounds: { x: 716, y: 477, width: 96, height: 22 }, solid: true },
  ],
  interventions: [
    { id: 'anchor-cabinet', targetId: 'cabinet', label: 'Dolabı sabitle', description: 'L-demir bağlantı · devrilmeyi ve boruya darbeyi önle.', cost: 1, hitbox: { x: 225, y: 395, width: 95, height: 148 }, ruleId: 'furniture' },
    { id: 'coach-npc', targetId: 'deniz', label: 'Çök · Kapan · Tutun', description: 'Deniz’i sağlam masa altına yönlendir; merdivene koşmasın.', cost: 1, hitbox: { x: 504, y: 474, width: 62, height: 62 }, ruleId: 'shelter' },
    { id: 'gas-sensor', targetId: 'gas', label: 'Gaz sensörü tak', description: 'Sarsıntıda otomatik kesme · sızıntı zincirini durdur.', cost: 1, hitbox: { x: 375, y: 380, width: 62, height: 94 }, ruleId: 'gas' },
  ],
  awarenessRules: [
    { id: 'furniture', title: 'Sabitlemek önlemektir.', explanation: 'Dolap ve rafları önceden sabitle; devrilebilecek eşyalardan uzak dur.', sourceUrl: afad },
    { id: 'shelter', title: 'Sarsıntıda merdivene koşma.', explanation: 'Sağlam masa altında başını ve enseni koru. Çök, kapan, tutun; sarsıntı geçene kadar bekle.', sourceUrl: afad },
    { id: 'gas', title: 'İkincil tehlikeleri düşün.', explanation: 'Gaz sızıntısında ateş ve elektrik düğmelerinden uzak dur. Bu oyundaki otomatik kesici bir hazırlık müdahalesidir.', sourceUrl: afad },
  ],
};
