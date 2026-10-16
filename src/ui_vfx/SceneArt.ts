/** Cached material surfaces and architectural detail; never part of the simulation. */
export class SceneArt {
  readonly backdrop: HTMLCanvasElement;
  readonly wood: CanvasPattern;
  readonly plaster: CanvasPattern;
  readonly concrete: CanvasPattern;
  readonly flooring: CanvasPattern;

  constructor(ctx: CanvasRenderingContext2D) {
    this.wood = ctx.createPattern(this.surface('wood'), 'repeat')!;
    this.plaster = ctx.createPattern(this.surface('plaster'), 'repeat')!;
    this.concrete = ctx.createPattern(this.surface('concrete'), 'repeat')!;
    this.flooring = ctx.createPattern(this.surface('floor'), 'repeat')!;
    this.backdrop = document.createElement('canvas');
    this.backdrop.width = 1280;
    this.backdrop.height = 720;
    this.drawInterior(this.backdrop.getContext('2d')!);
  }

  private surface(kind: 'wood' | 'plaster' | 'concrete' | 'floor'): HTMLCanvasElement {
    const canvas = document.createElement('canvas');
    canvas.width = canvas.height = 128;
    const ctx = canvas.getContext('2d')!;
    ctx.fillStyle = { wood: '#856242', plaster: '#c8c0ae', concrete: '#6f736d', floor: '#8d826e' }[kind];
    ctx.fillRect(0, 0, 128, 128);
    let seed = 4127;
    const random = () => ((seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0) / 4294967296);
    for (let i = 0; i < 3400; i++) {
      ctx.fillStyle = random() > .5 ? '#ffffff' : '#181712';
      ctx.globalAlpha = random() * (kind === 'concrete' ? .16 : .07);
      const x = random() * 128, y = random() * 128;
      ctx.fillRect(x, y, kind === 'wood' ? .5 + random() : 1, kind === 'wood' ? 3 + random() * 22 : 1);
    }
    ctx.globalAlpha = 1;
    if (kind === 'wood') {
      for (let i = 0; i < 18; i++) {
        const x = random() * 128;
        ctx.strokeStyle = `rgba(38,25,12,${.05 + random() * .1})`;
        ctx.lineWidth = .5;
        ctx.beginPath(); ctx.moveTo(x, 0);
        ctx.bezierCurveTo(x + 4, 42, x - 5, 88, x + 2, 128); ctx.stroke();
      }
    }
    if (kind === 'floor') {
      for (let y = 0; y < 128; y += 16) {
        line(ctx, 0, y + .5, 128, y + .5, '#4e483b80');
        line(ctx, (y % 32) * 3, y, (y % 32) * 3, y + 16, '#514a3e70');
        line(ctx, 0, y + 1.5, 128, y + 1.5, '#c4b39745');
      }
    }
    return canvas;
  }

  private drawInterior(ctx: CanvasRenderingContext2D): void {
    const background = ctx.createLinearGradient(0, 120, 0, 720);
    background.addColorStop(0, '#24292c'); background.addColorStop(1, '#141719');
    ctx.fillStyle = background; ctx.fillRect(0, 0, 1280, 720);
    ctx.fillStyle = '#1b2023'; ctx.fillRect(0, 0, 1280, 120);
    ctx.fillStyle = '#181d20'; ctx.fillRect(965, 120, 315, 535);
    line(ctx, 965, 146, 965, 655, '#ffffff0e');
    const ambient = ctx.createRadialGradient(523, 320, 70, 523, 320, 470);
    ambient.addColorStop(0, '#a4937040'); ambient.addColorStop(1, '#00000000');
    ctx.fillStyle = ambient; ctx.fillRect(40, 180, 920, 420);

    // The section's silhouette is solid, with depth on the exposed concrete faces.
    shadow(ctx, 533, 559, 439, 21, .5);
    ctx.save(); ctx.shadowColor = '#0009'; ctx.shadowBlur = 26; ctx.shadowOffsetY = 12;
    ctx.fillStyle = '#131718'; ctx.fillRect(115, 191, 834, 366); ctx.restore();
    ctx.fillStyle = this.plaster; ctx.fillRect(136, 209, 792, 327);
    const upper = ctx.createLinearGradient(0, 209, 0, 318);
    upper.addColorStop(0, '#ede2ca38'); upper.addColorStop(1, '#3b352e50');
    ctx.fillStyle = upper; ctx.fillRect(136, 209, 792, 109);
    ctx.fillStyle = '#c9c3b2'; ctx.fillRect(136, 332, 792, 145);
    ctx.fillStyle = this.plaster; ctx.globalAlpha = .54; ctx.fillRect(136, 332, 792, 145); ctx.globalAlpha = 1;
    const wallLight = ctx.createLinearGradient(136, 332, 928, 500);
    wallLight.addColorStop(0, '#f6ead531'); wallLight.addColorStop(.55, '#00000000'); wallLight.addColorStop(1, '#302a2a3b');
    ctx.fillStyle = wallLight; ctx.fillRect(136, 332, 792, 204);

    for (const [x, w] of [[163, 113], [365, 113], [571, 113], [779, 113]]) this.window(ctx, x, 226, w, 67);
    this.window(ctx, 155, 356, 66, 90);
    this.window(ctx, 553, 353, 126, 102);
    this.curtain(ctx, 549, 350, 20, 115);
    this.curtain(ctx, 666, 350, 19, 115);

    // Quiet upper-floor furniture gives the building a lived-in scale.
    shadow(ctx, 403, 315, 60, 4, .24);
    ctx.fillStyle = '#535f5a'; roundBox(ctx, 351, 294, 103, 21, 4);
    ctx.fillStyle = '#7b8580'; roundBox(ctx, 355, 289, 42, 19, 3); roundBox(ctx, 400, 289, 49, 19, 3);
    line(ctx, 358, 313, 358, 318, '#3d362c', 3); line(ctx, 446, 313, 446, 318, '#3d362c', 3);
    ctx.fillStyle = '#baa892'; ctx.fillRect(507, 302, 43, 5);
    line(ctx, 511, 307, 511, 318, '#786b5d', 2); line(ctx, 546, 307, 546, 318, '#786b5d', 2);
    this.plant(ctx, 829, 317, .6);
    ctx.fillStyle = '#e0d6c2'; ctx.fillRect(703, 248, 37, 42);
    ctx.fillStyle = '#938879'; ctx.fillRect(708, 253, 27, 32);
    polygon(ctx, [[709, 283], [719, 265], [728, 277], [734, 270], [734, 284]], '#b5b5a0');

    // Real floor boards and skirting replace the schematic grid.
    ctx.fillStyle = this.flooring; ctx.fillRect(136, 477, 792, 59);
    const floorShade = ctx.createLinearGradient(0, 477, 0, 536);
    floorShade.addColorStop(0, '#19130c60'); floorShade.addColorStop(.32, '#e4c29215'); floorShade.addColorStop(1, '#120f0b16');
    ctx.fillStyle = floorShade; ctx.fillRect(136, 477, 792, 59);
    ctx.fillStyle = '#8c8575'; ctx.fillRect(136, 470, 792, 7);
    line(ctx, 136, 470, 928, 470, '#eee3cc60'); line(ctx, 136, 477, 928, 477, '#423b3090');
    // Broad, translucent light from the same direction on both levels.
    ctx.save(); ctx.globalCompositeOperation = 'screen';
    polygon(ctx, [[558, 369], [608, 369], [725, 534], [608, 534]], '#f8db9920');
    polygon(ctx, [[162, 368], [194, 368], [275, 534], [208, 534]], '#f8db9915');
    ctx.restore();

    // A workbench corner, small fixtures and uneven plaster add believable detail.
    ctx.fillStyle = '#7c766b'; ctx.fillRect(328, 394, 45, 4);
    ctx.fillStyle = '#43554d'; ctx.fillRect(335, 374, 12, 20);
    ctx.fillStyle = '#c4b18a'; ctx.fillRect(350, 379, 15, 15);
    line(ctx, 338, 398, 338, 409, '#5e5a4f', 2); line(ctx, 364, 398, 364, 409, '#5e5a4f', 2);
    ctx.fillStyle = '#a9aaa0'; ctx.fillRect(159, 451, 47, 18);
    for (let x = 162; x < 204; x += 5) line(ctx, x, 453, x, 468, '#777e77', 1.2);
    ctx.fillStyle = '#827b6c'; ctx.fillRect(701, 364, 6, 21);
    ctx.fillStyle = '#ddd3bb'; ctx.fillRect(702, 365, 4, 7);
    ctx.fillStyle = '#ddd4be'; ctx.fillRect(445, 437, 7, 11);
    ctx.fillStyle = '#8f8a7d'; ctx.fillRect(447, 441, 1, 4);
    this.plant(ctx, 164, 532, .83);
    this.beam(ctx, 124, 200, 12, 336);
    this.beam(ctx, 928, 200, 12, 268);
    this.beam(ctx, 124, 318, 816, 14);
    this.beam(ctx, 124, 536, 816, 16);
    ctx.fillStyle = '#a5a396'; ctx.fillRect(120, 195, 824, 5);
    line(ctx, 120, 195, 944, 195, '#e1d9c180');
    for (const x of [175, 461, 816]) {
      line(ctx, x, 544, x + 54, 544, '#393e3c60', 1);
      line(ctx, x + 12, 547, x + 62, 547, '#393e3c40', 1);
    }
    const ao = ctx.createLinearGradient(0, 332, 0, 359);
    ao.addColorStop(0, '#1d1a1760'); ao.addColorStop(1, '#1d1a1700');
    ctx.fillStyle = ao; ctx.fillRect(136, 332, 792, 27);
    line(ctx, 136, 209, 136, 536, '#24221b60', 3);
    line(ctx, 927, 209, 927, 468, '#24221b70', 3);
  }

  private window(ctx: CanvasRenderingContext2D, x: number, y: number, w: number, h: number): void {
    ctx.fillStyle = '#3b3c36'; ctx.fillRect(x - 3, y - 3, w + 6, h + 8);
    const sky = ctx.createLinearGradient(0, y, 0, y + h);
    sky.addColorStop(0, '#8eabb3'); sky.addColorStop(.65, '#c0c7bc'); sky.addColorStop(1, '#e0ccb0');
    ctx.fillStyle = sky; ctx.fillRect(x, y, w, h);
    ctx.save(); ctx.beginPath(); ctx.rect(x, y, w, h); ctx.clip();
    for (let i = 0; i < 5; i++) {
      const height = 10 + ((i * 17 + x) % 28);
      ctx.fillStyle = i % 2 ? '#829393' : '#99a4a0';
      ctx.fillRect(x + i * 29 - 10, y + h - height, 25, height);
      ctx.fillStyle = '#d8d3b966';
      for (let j = 0; j < 3; j++) ctx.fillRect(x + i * 29 - 5, y + h - height + 5 + j * 8, 3, 3);
    }
    polygon(ctx, [[x, y], [x + w * .4, y], [x + w, y + h], [x + w * .76, y + h]], '#ffffff20');
    ctx.restore();
    ctx.strokeStyle = '#d7d3bf'; ctx.lineWidth = 3; ctx.strokeRect(x, y, w, h);
    line(ctx, x + w / 2, y, x + w / 2, y + h, '#b7b4a4', 3);
    line(ctx, x, y + h * .58, x + w, y + h * .58, '#b7b4a4', 2);
    ctx.fillStyle = '#e2d9c4'; ctx.fillRect(x - 5, y + h + 2, w + 10, 4);
    line(ctx, x - 4, y + h + 7, x + w + 6, y + h + 7, '#302d2740', 2);
  }

  private curtain(ctx: CanvasRenderingContext2D, x: number, y: number, w: number, h: number): void {
    const cloth = ctx.createLinearGradient(x, 0, x + w, 0);
    cloth.addColorStop(0, '#776e5c'); cloth.addColorStop(.3, '#d5c7aa'); cloth.addColorStop(.65, '#9d927b'); cloth.addColorStop(1, '#c6b89d');
    polygon(ctx, [[x, y], [x + w, y], [x + w - 4, y + h], [x - 3, y + h - 2]], cloth);
    line(ctx, x + 7, y + 3, x + 4, y + h - 3, '#f0e1bd40');
  }

  private plant(ctx: CanvasRenderingContext2D, x: number, y: number, scale: number): void {
    ctx.save(); ctx.translate(x, y); ctx.scale(scale, scale);
    shadow(ctx, 0, 0, 16, 3, .25);
    polygon(ctx, [[-12, -19], [12, -19], [9, 0], [-8, 0]], '#936e54');
    line(ctx, -12, -18, 12, -18, '#bca085', 3);
    for (let i = 0; i < 7; i++) {
      const endX = Math.sin(i * 2.4) * 19, endY = -33 - (i % 3) * 11;
      line(ctx, 0, -17, endX, endY, '#4d6250', 1.5);
      ctx.fillStyle = i % 2 ? '#637b5b' : '#7e8b64';
      ctx.beginPath(); ctx.ellipse(endX, endY, 6, 12, endX * .05, 0, Math.PI * 2); ctx.fill();
    }
    ctx.restore();
  }

  private beam(ctx: CanvasRenderingContext2D, x: number, y: number, w: number, h: number): void {
    ctx.fillStyle = this.concrete; ctx.fillRect(x, y, w, h);
    ctx.fillStyle = '#d3d2be38'; ctx.fillRect(x, y, w, 2); ctx.fillRect(x, y, 2, h);
    ctx.fillStyle = '#24292480'; ctx.fillRect(x, y + h - 3, w, 3); ctx.fillRect(x + w - 3, y, 3, h);
    if (w > 100) {
      line(ctx, x + 8, y + h - 5, x + w - 8, y + h - 5, '#4b4e47', 1);
      for (let i = x + 18; i < x + w - 8; i += 35) ctx.fillRect(i, y + 5, 2, 2);
    }
  }
}

export function line(ctx: CanvasRenderingContext2D, x: number, y: number, ex: number, ey: number, color: string, width = 1): void {
  ctx.strokeStyle = color; ctx.lineWidth = width; ctx.beginPath(); ctx.moveTo(x, y); ctx.lineTo(ex, ey); ctx.stroke();
}

export function polygon(ctx: CanvasRenderingContext2D, points: readonly (readonly number[])[], fill: string | CanvasGradient): void {
  ctx.beginPath(); points.forEach(([x, y], i) => i ? ctx.lineTo(x, y) : ctx.moveTo(x, y)); ctx.closePath(); ctx.fillStyle = fill; ctx.fill();
}

export function roundBox(ctx: CanvasRenderingContext2D, x: number, y: number, w: number, h: number, radius: number): void {
  ctx.beginPath(); ctx.roundRect(x, y, w, h, radius); ctx.fill();
}

export function shadow(ctx: CanvasRenderingContext2D, x: number, y: number, rx: number, ry: number, alpha = .3): void {
  ctx.save(); ctx.translate(x, y); ctx.scale(rx, ry);
  const g = ctx.createRadialGradient(0, 0, 0, 0, 0, 1);
  g.addColorStop(0, `rgba(12,10,8,${alpha})`); g.addColorStop(1, '#0c0a0800');
  ctx.fillStyle = g; ctx.fillRect(-1, -1, 2, 2); ctx.restore();
}
