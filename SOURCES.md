# AFET KUŞATMASI — kaynaklar

16 Ekim 2026. Teknik uygulamada Godot'un **4.3** belgeleri incelendi:

- [CharacterBody2D](https://docs.godotengine.org/en/4.3/classes/class_characterbody2d.html): velocity, çarpışma ve `move_and_slide`.
- [Custom drawing in 2D](https://docs.godotengine.org/en/4.3/tutorials/2d/custom_drawing_in_2d.html): `_draw`, çizim sırası ve redraw.
- [Command line tutorial](https://docs.godotengine.org/en/4.3/tutorials/editor/command_line_tutorial.html): import, headless, script ve proje çalıştırma.
- [Godot lisansı](https://godotengine.org/license/): motorun MIT bildirimi ve dağıtım koşulları; dağıtımda motor sürümünün kendi lisansları ayrıca korunmalı.
- [Godot 4.3 resmî sürümü](https://github.com/godotengine/godot-builds/releases/tag/4.3-stable): Windows x64 motoru, 4.3 uyumluluğunu gerçekten çalıştırarak doğrulamak için Temp klasörüne indirildi; ZIP'in SHA512 değeri aynı sürümün resmî `SHA512-SUMS.txt` kaydıyla eşleşti. Oyun asseti veya repo dosyası değildir.

Hazır oyun/asset indirilmedi. AI katkısının kategorileri ve kapsamı [BEYAN.md](BEYAN.md) içindedir.

## Adım 2 teknik başvuruları

- [Geometry2D — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_geometry2d.html): hareketli mermi/oyuncu için segmentler arasındaki en yakın noktalar; hızlı dash'te atlanan temasın önlenmesi.
- [Node — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_node.html): oyuncu, uyarı ve havuzun fizik işlem sırası.
- [CanvasItem — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_canvasitem.html): prosedürel boss/uyarı/mermi çizimi ve dönüşümler.
- [Window — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_window.html): ekranlı otomasyonda fiziksel kullanıcı girişini test penceresinden ayırma. Normal oyun penceresine bu test bayrakları uygulanmaz.

## Adım 2.5 teknik başvuruları

Adım 2.5 (17 Ekim 2026) teknik başvuruları:

- [CollisionShape2D — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_collisionshape2d.html): üst katların tek yönlü zemin çarpışması ve geçiş payı.
- [PhysicsBody2D — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_physicsbody2d.html): yalnız mevcut katı geçici dışlayan `add_collision_exception_with` ve iniş/reset sonrasında geri açma.

Coyote/jump yüksekliği ve patern matematiği proje içinde yazıldı; hazır karakter kontrolcüsü veya bullet-hell paketi alınmadı.

## Adım 3 teknik başvuruları

- [Camera2D — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_camera2d.html): `zoom` (1'den küçük değer daha geniş alan gösterir) ile 4×4 binanın ve bossların ekrana sığdırılması.
- Kat fazlaması, spiral (girdap) yolu, çapraz yaylım geometrisi ve rüzgâr itmesi proje içinde yazıldı. Bu davranışlar fantastik oyun mekaniğidir; gerçek fırtına/hortum davranışı veya güvenlik tavsiyesi değildir ve bu adımda afet bilgisi metni eklenmedi.

## Önceki projedeki kayıtlar

Kullanıcı ARTÇI'yı kaldırıp yeni projeyi istedi. Eski araştırma/AI kayıtlarının tamamı `2647179` commitindeki SOURCES ve BEYAN dosyalarında durur:

- [Önceki SOURCES.md](https://github.com/girayeskalen/helloworld-jam/blob/2647179121c4a57bdb90e236db6337d6afe61873/SOURCES.md)
- [Önceki BEYAN.md](https://github.com/girayeskalen/helloworld-jam/blob/2647179121c4a57bdb90e236db6337d6afe61873/BEYAN.md)

Bu kaynak geçmişi yeni oyunda eski oyun kodunun kullanıldığı anlamına gelmez. Jam tesliminde ekip gerçek kullanımını ve güncel resmî kuralları birlikte kontrol eder.

## Adım 2.7 teknik başvuruları

- [SubViewportContainer — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_subviewportcontainer.html): `stretch` ve `stretch_shrink` ile dünyanın düşük çözünürlükte çizilip büyütülmesi (pixel-art render).
- [CanvasItemMaterial — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_canvasitemmaterial.html): `BLEND_MODE_ADD` ile lamba konileri, baret feneri ve mermi ışıması.
- [CanvasItem — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_canvasitem.html): `draw_polygon` köşe renkleriyle gradyan ışık/gölge, `draw_string_outline` ile ekran etiketleri.
- [Image — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_image.html): içe aktarılmamış PNG'lerin `load_from_file` ile okunması (sprite yükleyici).
- [DisplayServer — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_displayserver.html): test görüntüleri için exclusive fullscreen.

Işık, dither, IK ve boss iskeletleri proje içinde yazıldı; hazır shader, ışık paketi veya animasyon eklentisi kullanılmadı. Şimşek/yağmur/fırtına görselleri kurgusal atmosferdir; gerçek afet davranışı veya güvenlik tavsiyesi değildir.

## Adım 3-B teknik başvuruları

- [PhysicsBody2D — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_physicsbody2d.html): üst kata zıplarken yalnız o katın döşemesini `add_collision_exception_with` ile geçici yok sayıp tepe noktasında geri açma.
- [CharacterBody2D — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_characterbody2d.html): yay sırasında `velocity` ve `move_and_slide` ile gerçek iniş.

Yay hızı (ayrık 60 Hz entegrasyon için düzeltilmiş), oda hasar tablosu, çöküş kuralı ve loot oda seçimi proje içinde yazıldı; hazır envanter/loot paketi kullanılmadı. Oda hasarı ve onarım kurgusaldır; deprem/fırtına güvenliği veya bina güçlendirme bilgisi olarak sunulmaz.

## Üç dalgalı kampanya ve afet hazırlığı ek kapsamı — 17 Ekim 2026

Araç: **OpenAI Codex**; kesin model etiketi bu çalışmada ayrıca doğrulanmadı. Kullanıcının verdiği tasarımla yalnız hasarlı odada kuşatma onarımı, 5 tip süreli loot, üç bileşenli inşaat ve %55 hasar azaltımı, 9 seçilebilir kartın gerçek oyun etkileri, 20 sn inşaat araları, koordineli çift boss finali ve zafer ekranı kodlandı. `SiegeUpgrades.gd`, `UpgradeOverlay.gd`, `CampaignSmoke.gd` eklendi; mevcut dalga/loot/oda/HUD ve uygun testler güncellendi. Claude'un 16 oda çizimleri, parabolik 2x W kat zıplaması ve çok parçalı boss rigleri korundu.

Görsel katkı: AI destekli GDScript çizimleriyle büyük çelik X-kiriş/perçin/şerit, kepenk, kum torbası, sabitleme kemeri, LED, 5 loot simgesi/ömrü ve üç kart arayüzü. Yeni harici sprite, font, ses, asset, eklenti veya resim üretim servisi kullanılmadı. Metin katkısı: kart açıklamaları, arayüz ve proje belgeleri. Doğrulama: motor içi testler ve gerçek Compatibility renderer görüntülerinin incelenmesi (sonuç STATUS'ta).

Kart adları, C40 etiketi ve oranları kullanıcı tasarımıdır; bu görevde gerçek afet veya mühendislik bilgisi doğrulaması yapılmadı. Anlık yapı onarımı, dokunulmaz takla, hidrolik bot ve manyetik drone gibi etkiler gerçek afet davranışı/teknik güvence olarak sunulmaz. Bu ek bir resmî kurum onayı veya bağımsız oyun teslimi değildir.

## 17 Ekim 2026 — Adım 4.5 / aktif mekanikler ve dalga dengesi

OpenAI Codex, kullanıcının ekli tasarımıyla 90 sn savaş / 15 sn inşaat, kilitli üç boss sırası, 1,5 sn giriş / 2,5 sn çıkış / kart fade-in, ortak üç odalık hasar sınırı, 10 sn onarım payı, görsel salınım/çatlak/toz ve dokuz yeni aktif kartı uyguladı. Eski pasif kart havuzu kaldırıldı. `SiegeMechanics.gd` dron/kule/türbin/iz/şok/ışın çizimlerini ve etkileri içerir; mevcut Claude oda çizimleri, gece atmosferi ve 2x W fizik yayı temel alınarak korundu. Boss rigine çıkış ayrışması eklendi. Yeni ses, harici görsel, font, paket veya servis kullanılmadı; görseller GDScript ile prosedüreldir. Kart isimleri/fantastik etkiler gerçek afet davranışı veya mühendislik uygulaması tavsiyesi değildir.

Testler yeni faz ve mekaniklere uyarlandı; `Step45Smoke.gd` eklendi. Gerçek test sonuçları ve native görsel kayıtların yeri `STATUS.md` içindedir. Commit/push veya dağıtım yapılmadı.
