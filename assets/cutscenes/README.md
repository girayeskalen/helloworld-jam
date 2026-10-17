# Açılış videosu

Videonu bu klasöre **intro_cutscene.ogv** adıyla koy. Oyun ilk açılışta onu otomatik oynatır; başka sahne bağlantısı gerekmez. 1280×720 / 16:9 Ogg Theora video önerilir; video sesi varsa Master üzerinden M ve ses seviyesi ayarlarına uyar.

- Space veya Enter: videoyu/metin girişini geç; 0,45 saniyelik yumuşak geçişle apartmana dön.
- Video biterse aynı geçiş otomatik çalışır. Hazırlığın tam 8 saniyesi bundan sonra başlar.
- R: introyu tekrar oynatmadan yeni oyun.
- Video yoksa lisanslı piksel fontla isim kartı ve sakin acil durum bülteni gösterilir. Bu klasörde şu anda gerçek bir hikâye videosu yoktur.

**WebM:** Standart Godot 4 WebM çözücüsü içermez. Uygun VideoStream çözücüsü kurulmuşsa `intro_cutscene.webm` de otomatik algılanır; yoksa hataya düşmeden metin girişi gösterilir. Eklentisiz kullanım için dosyayı OGV'ye dönüştür. FFmpeg kuruluysa, kaynak videonun bulunduğu yerde:

```powershell
ffmpeg -i kaynak.webm -c:v libtheora -q:v 7 -c:a libvorbis -q:a 5 intro_cutscene.ogv
```

Oyun video süresini tahmin etmez; VideoStreamPlayer.finished sinyalini bekler. Editöre eklenen OGV normal bir Godot kaynağıdır; seçili dosyalarla export yaparsan videoyu da pakete dahil et.
