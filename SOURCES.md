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

## 17 Ekim 2026 — Adım 4.8 farkındalık metinleri ve teknik başvurular

Kart notları aşağıdaki resmî/meslek kuruluşu içeriklerinden kısa Türkçe özetlerdir; başlıklar ve fantastik etkiler kullanıcı tasarımı/AI destekli oyun yazımıdır. Web arama sonuçlarındaki kurum içerikleri kontrol edildi; bazı AFAD sayfalarının tam sayfa isteği 500, USGS tam sayfa isteği zaman aşımı verdi. Tam metin/PDF bütünlüğü doğrulanmış gibi raporlanmaz; doğrulanabilen kısa kapsam esas alındı.

| Kaynak / sağlayıcı | Oyunda kullanım |
| --- | --- |
| [AFAD Şırnak — Afet Çantanı Hazırla](https://sirnak.afad.gov.tr/afet-cantani-hazirla-ki-canin-sag-olsun) | 72 saatlik çantada su, dayanıklı gıda, ilk yardım, fener, pil ve düdük; çanta kartı, medikal loot ve erişilebilir çanta notu |
| [AFAD Bursa — Afete Hazır Aile](https://bursa.afad.gov.tr/afete-hazir-aile) | Ağır eşyaların sabitlenmesi, çıkışların açık tutulması, kesicilerin önceden tanınması; sabitleme, halat, gaz, sprinkler, türbin notları |
| [AFAD Muğla — Şiddetli Yağış ve Sel](https://mugla.afad.gov.tr/siddetli-yagis-sel) | Yüksek güvenli yere çıkma, sel suyuna yürüyerek/araçla girmeme, uyarıları izleme; taşkın/drenaj kartları |
| [USGS — Triangle of Life](https://www.usgs.gov/faqs/what-triangle-life-and-it-legitimate) | “Yaşam üçgeni standardı” önerisi yerine Çök-Kapan-Tutun; eşya sabitleme bu davranışla aynı teknik olarak sunulmaz |
| [AFAD İstanbul — Güçlendirme](https://istanbul.afad.gov.tr/kurumlar/istanbul.afad/9562/files/GUCLENDIRME.pdf) ve [İMO — Güçlendirme İzni Genelgesi (2020)](https://www.imo.org.tr/TR%2C59074/cevre-sehircilik-bakanligi-tarafindan-24092020-tarihinde-guclendirme-izni-genelgesi-yayinlandi.html) | FRP/kolon/epoksi kartında uzman incelemesi ve proje gereği; güncel mevzuat ya da kendin yap güçlendirme tarifi verilmez |
| [AFAD İstanbul — Hafif Arama ve Kurtarma Eğitmen Eğitimi](https://istanbul.afad.gov.tr/kurumlar/istanbul.afad/PDF-Dosyalar/Ek_2_Hafif_Arama_ve_Kurtarma_Egitmen_Egitimi_02082022.pdf) | Bot/eldiven gibi koruyucu ekipmanın hatırlatılması |
| [AFAD — KBRN 2024 Kongre Kitabı](https://cbrn2024.afad.gov.tr/upload/Node/36846/files/Kongre_Kitabi_Congress_Book.pdf) | Drone/robotların tehlikeyi uzaktan tespitte kullanılması; drone kartında dar kapsamlı bir not |
| [İPKB — Afet ve Engelli Bireyler Rehberi](https://www.ipkb.gov.tr/wp-content/uploads/2023/03/AFET-ENGELLI-BIREYLER-REHBER.pdf) | Otomatik gaz kesme ve önceden hazırlık bağlamı; oyun vanasına gerçek dünyada yangını kesin önleme gücü atfedilmez |
| [Godot — Viewport](https://docs.godotengine.org/en/stable/classes/class_viewport.html) | `get_final_transform` ve `push_input(event,false)` ile küçük pencerede gerçek ölçek dönüşümü üzerinden fare test girdisi |

Notların etkilendiği ana dosya `scripts/combat/SiegeUpgrades.gd`; loot kısa etiketleri `scripts/loot/LootSystem.gd`, ayrım/açıklamalar README ve bu dosyadadır. Kaynak sayfalarından resim, font, PDF veya ham belge repoya alınmadı. Bilgi özetlerinin yeniden kullanım lisansı açıkça doğrulanmadı; birebir metin kopyalanmadı. Kaynak göstermek kullanım izni yerine geçmez. Oyun yüzdeleri, anlık onarım, kalkan, robot ve süreler kurgu olarak açıkça ayrılır.


## 17 Ekim 2026 — Git teslimi aracı

- [GitHub CLI v2.102.0](https://github.com/cli/cli/releases/tag/v2.102.0), GitHub ve katkıcıları; [MIT lisansı](https://github.com/cli/cli/blob/v2.102.0/LICENSE). Resmî yayın SHA256 listesiyle doğrulandı. Push/oturum açma geliştirme aracı; oyun bağımlılığı veya dağıtılan oyun asseti değildir.
- [GitHub CLI tarayıcı girişi](https://cli.github.com/manual/gh_auth_login) ve [GitHub noreply commit adresi](https://docs.github.com/en/account-and-profile/reference/email-addresses-reference): yetkili hesabın giriş ve repo kimliği kurulumu. Token veya şifre repo/belgelere alınmadı.

## 17 Ekim 2026 — Adım 4.9

Yeni dış kaynak, asset veya belge kullanılmadı. HUD ikonları, Titan çizimi ve yetenekler proje içinde prosedürel GDScript ile yazıldı; mevcut Godot `CanvasItem` çizim API'leri (draw_rect, draw_string_outline, draw_polyline) ve zaten kaydedilmiş 4.3 belgeleri yeterli oldu. Yeni afet bilgisi metni eklenmedi; final boss mekanikleri kurgusaldır.

## 17 Ekim 2026 — Adım 5 teknik başvuruları

- [AudioStreamWAV — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_audiostreamwav.html): 16-bit PCM veri, örnekleme hızı ve döngü (loop_mode/loop_end).
- [AudioServer — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_audioserver.html) ve [Audio buses](https://docs.godotengine.org/en/4.3/tutorials/audio/audio_buses.html): Music/SFX/UI bus'ları, sessiz/seviye, bus efektleri (alçak geçiren filtre, sınırlayıcı).
- [Pausing games and process mode — Godot 4.3](https://docs.godotengine.org/en/4.3/tutorials/scripting/pausing_games.html): `get_tree().paused`, `PROCESS_MODE_ALWAYS` ile çalışan panel.
- [Thread](https://docs.godotengine.org/en/4.3/classes/class_thread.html) / [Mutex](https://docs.godotengine.org/en/4.3/classes/class_mutex.html) ve [thread-safe API notları](https://docs.godotengine.org/en/4.3/tutorials/performance/thread_safe_apis.html): sahneye dokunmayan saf sentezin arka planda pişirilmesi.
- DSP yöntemleri: Hal Chamberlin, *Musical Applications of Microprocessors* (1985) durum-değişkenli filtre; Paul Kellet'in yaygın olarak paylaşılan "economy" pembe gürültü katsayıları. Formüller bilgi düzeyinde kullanıldı; kod kopyalanmadı.

Yeni ses/müzik dosyası veya hazır asset yok.

## 17 Ekim 2026 — Adım 5.5 (OpenAI Codex)

Claude'un Adım 4.9/5 değişiklikleri ve mevcut SFX/oyuncu/4×4 bina/loot/onarım temel alınarak kullanıcı tasarımı uygulandı. Kampanya FIRTINA → DEPREM → SEL → DEPREM • SEL • FIRTINA olarak dört faza indirildi; yangın bossu ve çifte faz kaldırıldı. Birleşik saldırı/sanat yalnız rüzgâr, kaya ve su kullanır; eski ateş jetleri köpüklü su jetlerine dönüştürüldü. BossCinematic ile ayrı 2,5/2,8 sn giriş, hafif kamera odağı, şimşek/kaya/su sahnelemesi ve letterbox; GameHUD'da alt boss barı eklendi.

Özgün BGM bestesi ve sentez kodu AI yardımıyla MusicScore.gd içinde üretildi: 16 ölçü Re minör, sıcak bas, stereo akor pedleri, yumuşak davul/hat ve arpej, hazırlık/kuşatma/final düzenlemeleri. Ses dosyası veya dış müzik/asset indirilmedi; örnekler çalışma anında AudioStreamGenerator'a üretilir. Mevcut SoundRecipes/SoundSynth efektleri korunur. Test için geçici WAV/PNG çıktıları Git dışındadır. Müzik kalitesi ölçüm ve gerçek sürücüyle çalıştırmayla incelendi; kulakla öznel dinleme yapılmadı. Lisans veya insan bestesi iddiası eklenmedi.

Step55Smoke eklendi; önceki paketlerde kaldırılan dalga/ateşli final/üst HUD beklentileri yeni tasarıma uyarlandı. Motor sürümleri ve gerçek sonuçlar STATUS.md içindedir.

## 17 Ekim 2026 — Adım 6 (OpenAI Codex)

Kullanıcının FPS/BGM/final zorluğu talebi doğrultusunda AI yardımıyla mevcut GDScript değiştirildi: statik oda/mobilya/AO/güçlendirme/arka plan doku önbellekleri; sabit hava parçacıkları, dört noktalı mermi izi, savaş öncesi hazırlanan ortak mermi siluetleri, daha az boss mikro geometrisi ve toplu telgraf çizgileri. Oyuncu hareketi, 16 oda kimliği, loot/onarım/kartlar ve mevcut SFX korunur.

MusicScore artık çalışma karesinde canlı sentez yapmaz; açılışta özgün Re minör bas/davul/melodi/akor katmanlarından 22.050 Hz 16-bit mono AudioStreamWAV üretir. Ayrı Master/−5 dB/ALWAYS oynatıcı, örnek adedine göre ileri döngü ve mute'a saygılı watchdog eklendi. 120 BPM'de sekiz 4/4 ölçü 16 sn olduğundan, çelişen 12,8 sn yerine bu müzikal uzunluk kullanıldı. Dış müzik, ses örneği, servis, asset veya bağımlılık indirilmedi; önbellekler mevcut prosedürel çizimlerin çalışma anındaki kopyalarıdır.

Yalnız finalde cooldown×1,3, adet round(×0,7), hız×0,8, oyuncu/bina hasarı×0,7 ve uyarı+0,20 sn uygulandı. Bu mekanik katsayılar ölçülür; insanın algıladığı toplam zorluğun tam %30 değiştiği iddia edilmez. Step6Smoke ve PerformanceBench eklendi, eski test beklentileri güncellendi. Gerçek test/FPS/ses çıkışı ölçümleri ve sınırlar STATUS.md'dedir; insan kulakla dinleme veya bütün bilgisayarlarda FPS garantisi iddiası yoktur.


## 17 Ekim 2026 — Adım 7 teknik başvuruları (Claude)

- [AudioStreamPlayer.pitch_scale — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_audiostreamplayer.html): doruk sırasında aynı BGM döngüsünün 1,05× oynatılması (hız ve perde birlikte değişir; WAV yeniden üretilmez).
- [CanvasItem.self_modulate — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_canvasitem.html): önbellekli mobilyayı yeniden render etmeden kuşatmada karartma.
- [Geometry2D.get_closest_points_between_segments — Godot 4.3](https://docs.godotengine.org/en/4.3/classes/class_geometry2d.html): mevcut kapsül/segment çarpışmasıyla aynı testten sıyrılma mesafesi.

Tempo eğrisi, koreografi geometrisi ve sıyrılma kuralı proje içinde yazıldı; hazır bullet-hell paketi veya başka oyundan kod alınmadı. Bu adımda yeni afet bilgisi metni eklenmedi; mevcut AFAD/USGS kaynaklı kart notları değişmedi.

## 18 Ekim 2026 — Adım 8 kaynak eşleştirmesi

Araç: OpenAI Codex; mevcut Claude Adım 7 kodu üzerinde GDScript, özgün kod tabanlı piksel ikon/efektler ve metin desteği. Harici görsel/ses/kod paketi eklenmedi. Kart metinleri özgün kısa özetlerdir, kurumsal metinlerin uzun alıntısı yoktur. Kalkan, zaman bükme, mermi temizleme ve uzaktan anlık onarım bu kaynaklarda tanımlanan gerçek uygulamalar değildir.

| Kart / veri anahtarı | Kaynak ve doğrulanan kapsam |
| --- | --- |
| Çök-Kapan-Tutun, oda sabitleme, tahliye yolu, baş-boyun koruma, merdivene koşmama, hasarlı binaya girmeme (`afad_quake`) | [AFAD: Deprem öncesi, anı ve sonrası](https://afad.gov.tr/deprem-oncesi-ani-ve-sonrasi-alabileceginiz-onlemleri-biliyor-musunuz), [AFAD: Önlemini al, güvende kal](https://afad.gov.tr/deprem-oncesi-ani-ve-sonrasi-onlemini-al-guvende-kal). 18 Ekim 2026 resmî arama sonuçlarında davranışlar ve sabitleme bilgileri doğrulandı. Yapı onarım/güçlendirmesi için garanti veya uygulama reçetesi verilmez. |
| 72 saatlik afet çantası (`afad_bag`) | [AFAD Gümüşhane: Afet ve acil durum çantasında neler bulunmalı?](https://gumushane.afad.gov.tr/afet-ve-acil-durum-cantasinda-neler-bulunmali). İlk 72 saat ve ihtiyaç malzemeleri resmî kaynak taramasıyla kontrol edildi. Çantanın oyun içi iyileştirmesi/bullet temizliği kurgudur. |
| Sismograf (`usgs_warning`) | [USGS: Earthquake Early Warning — Overview](https://www.usgs.gov/programs/earthquake-hazards/science/earthquake-early-warning-overview?items_per_page=6&page=1). Resmî arama sonucu, uyarının başlamış depremi algıladığı ve deprem tahmini olmadığı ayrımını destekler; kesin tepki süresi vaadi yoktur. |
| Swept collision / iki segment arası yakınlık | [Godot 4.3 Geometry2D](https://docs.godotengine.org/en/4.3/classes/class_geometry2d.html). Resmî API sayfası açılarak get_closest_points_between_segments ve segment_intersects_segment işlevleri incelendi; kaynak kod kopyalanmadı. |

Bu taramada `www.afad.gov.tr/afet-ve-acil-durum-cantasi-nasil-hazirlanmali` ve `www.usgs.gov/programs/earthquake-hazards/science/early-warning` doğrudan açılışları hata döndürdü; bu iki başarısız bağlantı doğrulanmış kaynak sayılmadı. Yukarıdaki resmî arama sonuçları ve açılabilen Godot sayfası kullanıldı.

## 18 Ekim 2026 — Adım 9 hikâye / kurgu ayrımı

- [USGS: Can you predict earthquakes?](https://www.usgs.gov/faqs/can-you-predict-earthquakes): resmî sayfa açılıp incelendi. Belirli gün/saat, konum ve büyüklüğü önceden bilme iddiasını desteklemez. Bu nedenle TV'nin “3 gün” başlığı kurgusal bülten olarak gösterilir; deprem gününün önceden bilinemediği belirtilir.
- [NOAA/NHC: Saffir-Simpson Hurricane Wind Scale](https://www.nhc.noaa.gov/aboutsshws.php?lv=true): resmî arama sonucu ölçeğin 1–5 olduğunu doğrular; düz sayfanın doğrudan açılışı hata verdi. “Kategori 6 Hiper-Kasırga” resmî bir sınıf gibi sunulmaz; kurgusal boss ultisi etiketlidir.

Diploma, salon, kuşanma, ulti/kalkan/çöküş/gündüz görüntüleri ve üç yeni PCM ses tarifi proje için AI yardımıyla yazılmış özgün prosedürel içeriktir. Dış görsel, oyun kodu, kurum logosu, hazır diploma veya müzik eseri kopyalanmadı. Ekrandaki diploma bir oyun dekorudur; gerçek diploma olduğu iddia edilmez. Final kalkanı gerçek yapının sıfır kayıpla dayanacağına ilişkin mühendislik garantisi değildir.

## 18 Ekim 2026 — video intro ve piksel font

- [Godot 4.3: Playing videos](https://docs.godotengine.org/en/4.3/tutorials/animation/playing_videos.html) ve [VideoStreamPlayer API](https://docs.godotengine.org/en/4.3/classes/class_videostreamplayer.html): resmî rehber arama sonucu + API sayfası açılarak doğrulandı. Yerleşik format Ogg Theora/OGV; diğer formatlar GDExtension çözücüsü gerektirir. VideoStreamPlayer.finished, paused, expand, stream_position ve ses bus'ı kullanıldı. Theora uzunluğunun API'de 0 dönebilmesi nedeniyle sabit süre tahmini yapılmaz; gerçek bitiş sinyali izlenir.
- **Press Start 2P**, The Press Start 2P Project Authors (2012), Reserved Font Name Press Start 2P; [TTF orijinali](https://raw.githubusercontent.com/google/fonts/main/ofl/pressstart2p/PressStart2P-Regular.ttf), [SIL OFL 1.1 orijinali](https://raw.githubusercontent.com/google/fonts/main/ofl/pressstart2p/OFL.txt). İki dosya HTTPS üzerinden Google Fonts resmî deposundan indirilip assets/fonts içine kaydedildi; değiştirilmedi. GitHub klasör sayfasının browser açılışı hata verdi, ham dosyalar başarıyla alındı. Türkçe harfler ve bullet glyph'i gerçek font kaynağıyla test edildi.

Minimal bültendeki tahliye planı/afet çantası notları yukarıdaki AFAD hazırlık kaynaklarının kısa özgün özetidir. Kesin afet tarihi, gerçek yapı dayanımı veya kurum onayı iddiası yoktur. Gerçek video henüz sağlanmadı; testte kullanılan FFmpeg test deseni geçici klasördedir, teslim içeriği değildir. Önceki Adım 9'un çizimleri ve ilgili üretim kodları bu kullanıcı isteğiyle kaldırılmıştır; yukarıdaki kayıt tarihçedir.
