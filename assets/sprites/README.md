# El yapımı sprite klasörü

Bu klasöre aşağıdaki adlarla PNG koyarsan oyun bir sonraki çalıştırmada prosedürel çizim yerine onları kullanır (`scripts/art/AssetRegistry.gd`). Dosya yoksa karanlık prosedürel çizim çalışır.

| Dosya | Nerede kullanılır | Öneri |
| --- | --- | --- |
| `player.png` | Oyuncu karakteri | Sağa bakan, ayaklar alt ortada. Oyun 64×88 dünya birimine ölçekler; squash/stretch, eğilme ve takla dönüşü uygulanır. |
| `boss_storm.png` | Sol fırtına bossu | Ayakları alt ortada; 292×550 dünya birimine ölçeklenir. Uyarıda büzülme, atışta öne doğru genişleme uygulanır. |
| `boss_quake.png` | Sağ sismik golem | Aynı ölçü; uyarıda geri çekilme, vuruşta öne çarpma uygulanır. |
| `tileset.png` | Her odanın arka duvarı | Döşenebilir (tile) doku; odanın duvar rengiyle tonlanır. |

Pixel-art için Godot'ta Import panelinde filtreyi kapalı (Nearest) tut. Kendi çizdiğin veya lisansını bildiğin dosyaları koy; kaynağını `SOURCES.md` ve `BEYAN.md` içine yaz.
