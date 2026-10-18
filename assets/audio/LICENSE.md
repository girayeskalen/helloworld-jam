# Ovani Sound — oyun içi işlenmiş sesler

Kaynak: **Sound FX Starter Pack Vol. 1**, Ovani Sound.
[Lisans koşulları](https://ovanisound.com/policies/terms-of-service).

`ambience/` ve `sfx/` dizinlerindeki WAV dosyaları oyunda kullanılan işlenmiş türevlerdir; ham Ovani paketini içermezler.
Ses hakları Ovani Sound'a aittir. Projenin kod lisansı bu sesleri kapsamaz.
Oyundan ayrı ses dağıtımı, soundboard ve AI eğitimi lisans kapsamında değildir.
Public kaynak deposunda WAV paylaşımı için sağlayıcının açık izni ayrıca
doğrulanmalıdır; kırpma veya dönüştürme bu izni kendiliğinden sağlamaz.

Kaynaklar/ölçümler: [manifest.json](manifest.json).
Yerel yeniden üretim: `python tools/audio/build_sfx.py --zip YOL`.

## Ayrı lisans: CC0 müzikler

`music/` altındaki beş MP3/OGG yukarıdaki Ovani kaynağından değildir:

- `menu_blackout.mp3` ve `bed_dark_place.ogg`: SkyleTheFrench — [Blackout](https://opengameart.org/content/blackout), [Dark Place](https://opengameart.org/node/159643).
- `prep_sector.ogg`, `final_urgent.ogg`, `victory_srg774.ogg`: SRG774 — [Dark Sci-Fi Audio Pack](https://opengameart.org/content/dark-sci-fi-audio-pack).

Bu beş dosya **[CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/)** kapsamındadır ve içerikleri değiştirilmeden kullanılır. SHA-256 ve boyut kayıtları [SOURCES.md](../../SOURCES.md) içindedir. CC0, Ovani efektlerine uygulanmaz.
