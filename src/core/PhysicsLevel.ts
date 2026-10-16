import type { Intervention, LevelData, PhysicsObjectDefinition } from '../types/game';

/** Kişi 1 fizik test sahnesi. Kişi 2'nin levels.ts verisi yerinde değiştirilmez. */
export function createPhysicsLevel(source: LevelData): LevelData {
  if (source.physics) return structuredClone(source);
  const object = (id: string, type: PhysicsObjectDefinition['type'], label: string, x: number, y: number, width: number, height: number, mass: number, friction = 0.55, integrity = 100, isStatic = false): PhysicsObjectDefinition => ({ id, type, label, x, y, width, height, mass, friction, integrity, isStatic });
  const objects: PhysicsObjectDefinition[] = [
    object('ground', 'floor', 'TEMEL', 532, 548, 840, 24, 0, 0.9, 1000, true),
    object('upper-floor', 'floor', 'KAT DÖŞEMESİ', 532, 316, 840, 18, 0, 0.7, 1000, true),
    object('wall-left', 'wall', 'PERDE', 120, 425, 16, 224, 0, 0.8, 1000, true),
    object('wall-right', 'wall', 'PERDE', 944, 363, 16, 126, 0, 0.8, 1000, true),
    object('column-left', 'column', 'SAĞLAM KOLON', 155, 431, 18, 210, 0, 0.8, 1000, true),
    { ...object('cabinet', 'cabinet', 'AĞIR GARDIROP', 266, 463, 52, 144, 95), centreOffset: { x: 0, y: -16 } },
    { ...object('bookcase', 'bookcase', 'KİTAPLIK', 365, 469, 42, 132, 65, 0.65), centreOffset: { x: 0, y: -20 } },
    object('fridge', 'fridge', 'BUZDOLABI', 654, 477, 48, 116, 110, 0.4),
    { ...object('desk', 'table', 'ZAYIF MASA', 490, 510, 84, 50, 35, 0.75, 28), parts: [
      { x: 448, y: 485, width: 84, height: 10 }, { x: 450, y: 495, width: 9, height: 40 }, { x: 521, y: 495, width: 9, height: 40 },
    ] },
    object('column', 'column', 'ZAYIF KOLON', 755, 432, 18, 206, 85, 0.85, 70),
    object('ceiling-beam', 'ceiling', 'TAVAN KİRİŞİ', 758, 346, 178, 18, 125, 0.65, 150),
    object('ceiling-a', 'ceiling', 'TAVAN BLOĞU', 470, 350, 62, 22, 48, 0.55, 100),
    object('ceiling-b', 'ceiling', 'TAVAN BLOĞU', 568, 349, 50, 20, 40, 0.55, 100),
    object('lamp', 'lamp', 'TAVAN LAMBASI', 607, 370, 32, 14, 8, 0.3),
    object('gas', 'gas', 'GAZ VANASI', 407, 464, 10, 100, 0, 0.5, 100, true),
  ];
  const action = (id: Intervention['id'], targetId: string, label: string, cost: number, description: string): Intervention => {
    const body = objects.find(item => item.id === targetId);
    return { id, targetId, label, cost, description, ruleId: targetId === 'gas' ? 'gas' : 'furniture', hitbox: body ? { x: body.x - body.width / 2 - 8, y: body.y - body.height / 2, width: body.width + 16, height: body.height } : { x: 540, y: 490, width: 36, height: 45 } };
  };
  return {
    ...structuredClone(source), title: 'YÜK YOLU', subtitle: 'Her temas, başka bir sonuç.',
    quakeDuration: 8, rewindDuration: 1.8, evacuationDuration: 12, actionPoints: 5,
    exit: { x: 881, y: 426, width: 53, height: 110 },
    npcs: [{ id: 'deniz', name: 'Deniz', position: { x: 555, y: 519 }, health: 100, coached: false, status: 'idle' }],
    interventions: [
      action('anchor-cabinet', 'cabinet', 'Gardırop · L-demir', 1, 'İki duvar bağıyla devrilmeyi durdur.'),
      action('anchor-bookcase', 'bookcase', 'Kitaplık · L-demir', 1, 'Üst yükü ve devrilme rotasını sabitle.'),
      action('anchor-fridge', 'fridge', 'Buzdolabı · Sabitle', 1, 'Tahliye koridorunun kapanmasını önle.'),
      action('reinforce-table', 'desk', 'Masa · Çelik çapraz', 2, 'Darbe kapasitesini artır; boşluğu koru.'),
      action('reinforce-column', 'column', 'Kolon · Çelik çapraz', 2, 'Kiriş yükünü taşıyan kolonu güçlendir.'),
      action('gas-sensor', 'gas', 'Gaz · Otomatik kesici', 1, 'Darbe ve kıvılcım zincirini kes.'),
      action('coach-npc', 'deniz', 'Sığınma planı', 1, 'Bir sığınak seç; sarsıntıda tutun.'),
    ],
    physics: { seed: 26016, objects, shelters: [
      { id: 'table', label: 'Masa altı', supportId: 'desk', position: { x: 490, y: 519 } },
      { id: 'column', label: 'Kolon yanı', supportId: 'column', position: { x: 787, y: 519 } },
    ] },
  };
}
