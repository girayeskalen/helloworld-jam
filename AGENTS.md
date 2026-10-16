# OYUN VİZYONU VE KALİTE STANDARTLARI (MASTER DESIGN DOC)

Bu bölüm ARTÇI'nın kalıcı hedef tasarımıdır. Buradaki özellikler, mevcut prototipte tamamlandıkları anlamına gelmez. Matter.js, yeni müdahaleler, aktif tutunma, zıplama, çanta toplama ve Canvas içine taşınmış HUD gibi hedeflerin mevcut durumu koddan ayrıca doğrulanır; uygulanmamış bir özellik varmış gibi raporlanmaz.

Bu vizyon, görsel dalın belge görevinde kaydedildi. Sonraki görevlerde vizyonu esas al, yalnızca aktif kullanıcı isteğinin kapsamını uygula. Güncel uygulama durumu `STATUS.md` içindedir: v0.2 fiziği ve aktif kontroller hazır; çanta toplama ve Canvas içine taşınmış tam HUD henüz yok. Süreler bölüm verisinden okunur; v0.2 referans sahnesi 8 saniye öngörü ve 1,8 saniye geri sarma kullanır.

## 1. Etkinlik, hedef ve kalite çıtası

- **Etkinlik:** CIVIL GAME JAM 2026 — İnşaat Mühendisleri Odası ve ODTÜ Kuzey Kıbrıs Kampüsü.
- **Tema:** Afete hazırlık ve farkındalık.
- **Hedef:** Birincilik için yarışabilecek, jürinin bizzat oynadığında mekanik derinliğini ve özenini görebileceği bir oyun. Derece garantisi verme.
- **Değerlendirme:** Temayla ilişki 25, oynanabilirlik 25, yaratıcılık 20, görsel/işitsel bütünlük 15, teknik bütünlük 15 puan. Mühendislik ve farkındalık, yalnızca metinde değil oyuncunun kararlarında ve sonuçlarında görünmelidir.
- **Kırmızı çizgi:** Beş dakikada üretilmiş özensiz bir AI web demosu görünümü ve durağan, sıkıcı bilgi ekranları kabul edilmez. Gerçek neden-sonuç ilişkileri, okunabilir tehlikeler, anlamlı seçimler ve tutarlı sanat yönetimi hedeflenir. Bu görsel kalite hedefi, AI katkısını gizleme gerekçesi değildir; gerçek kullanım beyan edilir.
- **İlham:** Into the Breach'in taktiksel öngörüsü, Katana ZERO'nun geri sarma hissi, This War of Mine / Fallout Shelter'ın yandan kesitli mimari atmosferi ve Broforce / Angry Birds'ün fiziksel yıkımı. Bunlar tasarım referansıdır; bu oyunların kodu, görselleri veya sesleri kopyalanmaz.

## 2. Oyun kimliği ve dört fazlı ana döngü

**ARTÇI / AFTERSHOCK: Tactical Rewind**, bir binanın **2D yandan kesitinde** geçen **Matter.js tabanlı gerçek 2D rijit cisim fiziği + zaman geri sarma + aktif hayatta kalma** oyunudur. Fizik ve müdahaleler dekoratif animasyonlardan ibaret olmamalı; nesnelerin etkileşimi ve oyuncunun tercihleri sonucu değiştirmelidir.

### FAZ 1 — FORESIGHT / Öngörü: 4 saniye

- Bölüm açılır açılmaz deprem yaşanır. Oyuncu önce müdahale edilmemiş felaket zincirini izler ve öğrenir.
- Sabitlenmemiş ağır dolaplar devrilir, zayıf masaları kırabilir; tavan lambaları kopar, gaz tesisatında hasar ve ateşleme birleştiğinde patlama/yangın oluşabilir, merdiven boşluğu çökebilir.
- NPC'ler panikle merdiven, balkon veya kapı kirişi gibi senaryoda yanlış seçilmiş noktalara yönelip enkaz altında kalabilir. Her bölüm bütün tehlikeleri aynı anda kullanmak zorunda değildir; görülen sonuçlar bölümün fiziksel düzeninden doğmalıdır.

### FAZ 2 — REWIND / Taktiksel geri sarma: 1,5 saniye

- Felaketin ardından görüntü ve ses, VHS kaset hissiyle **T = 0** anına geri sarılır.
- Nesneler ve NPC'ler gerçekten kaydedilmiş zaman çizelgesindeki durumları üzerinden geri döner. Yalnızca ekran efekti oynatıp sahneyi sıfırlamak bu hedefi karşılamaz.
- Başlangıca dönüş; konum, açı, hız, bağlantılar, kırılma/yangın ve karakter durumları gibi simülasyonu etkileyen verileri kapsamalıdır. İlk izleme ile tekrar oynatma aynı başlangıç koşullarını kullanmalı; sonuç farkı müdahalelerden ve izin verilen oyuncu girdilerinden doğmalıdır.

### FAZ 3 — PLANNING / Taktiksel mühendislik ve farkındalık

- Zaman durur. Tehlike yayları ve işaretleri (**telegraphing**), hangi eşyanın nereye devrileceğini, hangi bölgenin çökeceğini ve NPC'nin hangi rotaya yöneleceğini anlaşılır biçimde gösterir.
- Oyuncunun sınırlı **Aksiyon Puanı (AP / bütçe)** vardır; her şeyi düzeltemez. Asıl bulmaca fiziksel domino zincirini doğru müdahalelerle kesmektir.
- **Sabitleme / L-demir:** Gardırop veya kitaplık duvara fiziksel `Constraint` ile bağlanır → devrilme engellenir → altındaki masa kırılmaktan korunabilir.
- **Yapısal güçlendirme:** Zayıf kolon veya masa, oyun modelinde çelik çaprazla desteklenir → belirli yük ve moloz senaryolarına dayanımı artar → korunabilecek bir sığınma alanı oluşabilir. Kullanıcının bu alan için önerdiği **“Hayat Üçgeni / Safe Triangle”** adı, aşağıdaki farkındalık doğruluğu kuralına tabidir; gerçek dünyada garantili güvenli boşluk iddiası değildir.
- **Tesisat kesici:** Gaz vanasına sismik kesici eklenir → gaz akışı durur → gaz ve kıvılcımın birlikte oluşturacağı patlama/yangın zinciri kesilir.
- **Farkındalık komutu:** Panikle merdivene/asansöre yönelen NPC'ye, doğrulanmış güvenlik içeriğine uygun sığınma davranışı ve noktası gösterilir. Oyunda önerilen sığınma alanı ile Çök-Kapan-Tutun kavramları birbirine yanlış biçimde eşitlenmez.

### FAZ 4 — EXECUTION & EVACUATION / Aktif sarsıntı ve tahliye

- Oyuncu **Space** ile depremi tekrar başlatır. Bu faz yalnızca sonucu seyretmekten ibaret değildir.
- **SHAKING — Aktif tutunma / grip-balance:** Karakter uygun sığınma noktasında Çök-Kapan-Tutun animasyonu yaparken oyuncu sismik denge göstergesini tuş girdileriyle kontrol eder ve oyun içindeki savrulmayı azaltır.
- **EVACUATION — 12 saniyelik oyun penceresi:** Ana sarsıntı durduktan sonra, kurgusal artçı öncesi **12 saniyelik bölüm sayacı** başlar. Bu tasarımda “altın pencere” adı bir oyun süresini ifade eder; gerçek bir afet zamanlaması değildir.
- Oyuncu karakteri **WASD / yön tuşları ve zıplama** ile doğrudan yönetir; devrilmiş eşyaların arasından geçer, deprem çantasını alır ve bina çıkış kapısına ulaşmaya çalışır. Sarsıntı sürerken tahliye başlamaz.
- **REPORT — Sonuç:** Bölüm sonunda **S / A / B / C** derecesi ve oyuncunun müdahaleleri ile sonuçlarına göre değişen **Mühendislik ve Farkındalık Karnesi** gösterilir. Geri bildirim, hangi tercihin hangi zinciri değiştirdiğini açıklamalı; durağan bilgi duvarına dönüşmemelidir.

## 3. Sanat yönetimi ve görsel/işitsel standartlar

- **Mimari diorama:** Bina, yaşanmışlık hissi olan bir kesit maketi gibi görünür. Sıcak beton, tuğla, ahşap parke ve duvar kâğıdı; tutarlı ışık, gölge, malzeme ve ölçekle bir arada kullanılır.
- **Ayrıntı:** Raflardaki kitaplar, dolap kapakları, L-demir ve vidaları, vana çarkları gibi işlevsel ayrıntılar detaylı, estetik **prosedürel Canvas 2D** çizimleriyle görünür olmalıdır. Ana sahneyi düz renkli dikdörtgen kutularla veya siyah zemin üstü ucuz neon çizgilerle temsil etmek nihai kaliteyi karşılamaz.
- **Karakterler:** İnsanlar eklemli çizilir; koşma ve Çök-Kapan-Tutun gibi davranışlar okunabilir animasyonlarla anlatılır.
- **Canvas içinde oyun arayüzü:** Nihai HUD, modern taktiksel kartlar, klavye kısayolları ve sismografla oyun penceresine entegre edilir. Amatör web sayfası görünümündeki HTML butonları/tabloları nihai tasarım değildir. Mevcut DOM HUD, sonraki teknik görevde ele alınacak geçiş durumudur; bu belge güncellemesi sırasında değiştirilmez.
- **Ses ve görüntü bütünlüğü:** Sarsıntı, fiziksel darbe, kırılma, geri sarma ve oyuncu müdahalelerinin sesleri aynı olaylarla uyumlu olmalı; tehlikeleri anlamayı desteklemelidir. VHS etkisi, parçacık ve kamera hareketi taktiksel okunabilirliği örtmemelidir.

## 4. İki kişilik iş bölümü ve çakışmayı önleme

- **Kişi 1 — Core Physics, Simulation & Gameplay:** Core oyun geliştirme alanı `src/core/` dosyalarıdır; bu birleştirmede ortak sözleşme ve entegrasyon yazarı da Kişi 1’dir (aşağıdaki tablo). `Engine.ts`, `SimulationManager.ts`, `PhysicsHazardSystem.ts`, `TimelineRewind.ts` kapsamındaki Matter.js simülasyonu, fiziksel tehlikeler, zaman çizelgesi/snapshot ve aktif karakter kontrolünden sorumludur. Bu adlar hedef sorumlulukları tanımlar; eksik dosyaların mevcut olduğu varsayılmaz.
- **Kişi 2 — Art Direction, Renderer, UI/HUD, Audio & Levels:** Oyun geliştirme alanı yalnızca `src/ui_vfx/`, `src/levels/` ve `index.html` dosyalarıdır. `Renderer.ts`, `TacticalHUD.ts`, `SoundSynth.ts`, `ParticleSystem.ts` ve ilgili sunum dosyaları bu alandadır.
- **Ortak veri sözleşmesi:** `src/types/game.ts`, iki kişinin mutabakatıyla, önceden belirlenmiş tek yazar tarafından değiştirilir. Paralel görevler sırasında sözleşme dondurulur; yeni fizik/karakter/HUD verileri ortak arayüzden aktarılır.
- Birbirinin klasörüne girerek düzeltme yapma. Ortak giriş dosyası, paket/lock dosyası, test veya belge değişikliği gerekiyorsa bunu ayrı bir entegrasyon işi olarak belirt ve tek yazarı önceden belirle. Bu istisna iki tarafa sınırsız düzenleme yetkisi vermez.
- Amaç Git çakışmalarını önlemektir; mutlak **“sıfır Git çakışması” garantisi** verilmez. Ayrı dallar, dosya sahipliği ve ortak sözleşme üzerinde anlaşma esastır.

## 5. Farkındalık bilgisinin doğruluğu

- **“Hayat üçgeni” ile Çök-Kapan-Tutun aynı yöntem olarak sunulmaz.** Önerilen “Safe Triangle” etiketi içerik doğrulaması bekleyen bir oyun tasarımı adıdır; oyuncuya gerçek hayatta uygulanacak genel bir güvenlik önerisi olarak öğretilmez. Yerel AFAD/ilgili yetkili rehberleriyle doğrulanmış sığınma davranışları esas alınır. Kavram ayrımı için: [USGS — deprem sırasında davranış ve ilgili Triangle of Life açıklaması](https://www.usgs.gov/faqs/what-should-i-do-during-earthquake).
- Kolon/masa desteği, oyunun basitleştirilmiş modelidir; gerçek yapı güçlendirme talimatı, yapı güvenliği belgesi veya enkaz altında hayatta kalma garantisi değildir.
- **12 saniye**, zıplamalı tahliye, tutunma göstergesi ve geri sarma oyun mekanikleridir. Gerçek artçıların kesin zamanı veya herkes için geçerli bir “güvenli tahliye süresi” olarak aktarılmaz. Kaynak: [USGS — artçı tahminlerinin olasılıksal niteliği](https://earthquake.usgs.gov/data/oaf/overview.php).


---

# Codex çalışma kuralları — ARTÇI v0.2

- İşe başlamadan ilgili dosyaları, `README.md`, `STATUS.md`, `BEYAN.md` ve `git status` çıktısını incele.
- Ekip arkadaşının ve kullanıcının mevcut değişikliklerini koru. Görev dışı değişiklikleri silme, geri alma veya kendi commitine katma. Aynı dosyada çakışan işler varsa durumu açıkla ve değişiklikleri koruyarak ilerle.
- Teknoloji kararı: **Vite + TypeScript + Matter.js + HTML5 Canvas 2D + Web Audio API**. Çözünürlük 1280×720; grafik ve ses kodla prosedürel üretilir. Yeni oyun motoru, framework, görsel/ses/font dosyası veya bağımlılığı görev gerektirmedikçe ekleme.
- Yalnızca istenen kapsamda çalış. Kullanıcıya sonuçları, kontrolleri ve kalan sorunları anlaşılır Türkçeyle bildir.
- Commit ve push yalnızca kullanıcı istediğinde yapılır. Force push veya kullanıcı açıkça istemedikçe değişiklik kaybettiren Git komutları kullanma.

## İki kişilik paralel geliştirme

| Alan | Tek yazma sorumlusu | Sınır |
| --- | --- | --- |
| `src/core/**` | Kişi 1 — Core Physics, Simulation & Gameplay | Simülasyon, AP, deterministik fizik, geri sarma, tahliye, skor. |
| `src/ui_vfx/**` | Kişi 2 — Tactical UI, Audio, VFX & Levels | Çizim, DOM HUD, sentez, parçacıklar, stiller. |
| `src/levels/**` | Kişi 2 | `LevelData` uyumlu saf veri; core dosyalarını değiştirme. |
| `src/types/game.ts` | Kişi 1, iki kişinin mutabakatıyla | Ortak sözleşme; paralel çalışma sırasında dondurulur. |
| `index.html` | Kişi 2 | Sayfa giriş yapısı; ortak sözleşme/giriş değişikliği entegrasyon yazarıyla koordine edilir. |
| `src/main.ts`, `src/integration/**`, `index.html` dışındaki kök yapılandırmalar, `package-lock.json`, `tests/**` | Kişi 1 — entegrasyon | Bağlantılar ve ortak kontroller; eşzamanlı ikinci yazar olmaz. |
| `README.md`, `STATUS.md`, `AGENTS.md`, `BEYAN.md` | Kişi 1 — entegrasyon | Kişi 2 görev/AI/kaynak notlarını kendi PR açıklamasında iletir; birleştirirken Kişi 1 kaydeder. |

- Gerçek kişi adları henüz bildirilmedi; Kişi 1 / Kişi 2 rol etiketleridir. İsim uydurma.
- `main` entegrasyon dalıdır. İki kişi aynı başlangıçtan ayrı `feat/core-*` / `feat/ui-*` dallarında çalışır; kendi alanındaki dosyaları değiştirir.
- İki taraf yalnızca `src/types/game.ts` sözleşmesine bağlanır. UI, core sınıflarını doğrudan import etmez; `GameController` ve `GamePresentation` kullanılır. Core, UI veya bölüm modülü import etmez; `LevelData` constructor'a verilir.
- Sunum `DeepReadonly<GameState>` alır ve durumu değiştirmez. Olaylara verilen tepkiler yalnızca sunumda kalır. Ses/çizim rastgeleliği fizik sonucunu etkileyemez.
- Yeni ortak alan veya bağımlılık gerekiyorsa Kişi 2 bunu kendi PR açıklamasında belirtir; Kişi 1 tek bir entegrasyon değişikliği yapar. İki kişi aynı anda lock dosyası veya ortak belgeleri düzenlemez.
- Aynı dosyaya dokunmamak çakışmayı önleme yöntemidir; Git için mutlak sıfır çakışma garantisi verme. Sözleşme değiştiğinde iki dal da güncel sözleşmeye göre kontrol edilir.

## Teknik sözleşme ve kontroller

- `Phase`: `FORESIGHT → REWIND → PLANNING → EXECUTION`. Son fazda `SHAKING → EVACUATION → REPORT` adımları vardır.
- `Engine` 60 Hz oynanış, Matter dünyası 120 Hz alt adım kullanır. `SimulationManager` durumun tek sahibidir. `TimelineRewind`, her ikinci adımda (30 Hz) izole veri snapshot'ı alır; Matter gövdelerini/bağlarını doğrudan serialize etme. Kopan bağ ve parçaları da geri yükle. `Engine.clear` sonrasında broadphase listesini yeniden kur.
- P/S bileşenli temel hareketi ve kat kuvvetleri deterministik olmalı; duvar/floor kinematiği ile eşya kuvvetlerini çizim animasyonuna indirgeme. Birimlerin oyun ölçeğinde olduğunu belirt.
- NPC tutunması fiziksel bağdır; grip göstergesi bağın açılmasını/kapanmasını etkiler. Tahliyede yerçekimi, grounded/coyote ve yükselen kenarda zıplama kullan.
- Ortak v0.2 sözleşmesine göre `physicsBodies.parts` dünya köşeleri, `x/y` kütle merkezi, `angle` radyandır. Yeni görünümün referans entegrasyonu `src/integration/` içindedir; Kişi 2’nin `SceneArt` malzemeleri/sahnesi ve ParticleSystem efektlerini kullanır. Ayrıntılı Renderer/HUD’un fizik sözleşmesine geçişi takip işidir; Kişi 2 dosyalarını otomatik taşıma veya silme.
- AP yalnızca planlamada düşer; aynı müdahale iki kez uygulanmaz. Sarsıntı sırasında hareket girişi tahliye başlatmaz. Gizli sekmede süre durur.
- Kod değişikliğinde `npm run build` çalıştır. Faz, AP, snapshot, tehlike zinciri veya kontroller değişirse ilgili `npm test` senaryolarını da çalıştır. Gerekirse `npx playwright install chromium` ile test tarayıcısını kur.
- UI değişikliğinde normal/ölçeklenmiş ekranda tıklama, klavye, görsel yerleşim ve konsol hatalarını denetle. Dokümantasyonda içerik, bağlantılar ve `git diff --check` kontrol edilir. Yapılamayan kontrolleri gerekçeleriyle bildir.
- İş tamamlanınca entegrasyon sorumlusu `STATUS.md` görev ve sorun kayıtlarını günceller. Tamamlanmamış işi tamamlandı gösterme.

## CIVIL GAME JAM 2026 — AI ve hazır kaynak beyanı

Kaynak: [resmî kural kitapçığı v09](https://game.ktimo.com.tr/assets/CIVIL_GAME_JAM_Kural_Kitapcigi_v09.pdf), özellikle 3.3–3.7 ve 4.1–4.4; 16 Ekim 2026 tarihinde doğrulandı.

- AI ve hazır kaynak kayıtları `BEYAN.md` içinde **ayrı** tutulur. Her ikisinde **görsel, ses, kod, metin, diğer** kategorilerinin tamamı Kullanıldı/Kullanılmadı olarak doldurulur.
- AI için kullanılan araç/model, amaç, üretilen veya dolaylı yararlanılan çıktı ve etkilenen dosyalar açıklanır. Prosedürel çizim/ses kodunu AI üretmişse görsel/işitsel katkıyı da açıkla; dosya asseti olmaması AI kullanılmadığı anlamına gelmez.
- Hazır kaynak için ad, üretici/sağlayıcı, kaynak bağlantısı, lisans ve kullanım yeri yazılır. Değiştirilmiş ve küçük miktardaki kullanımlar da kaydedilir. Kaynak göstermek kullanım izninin yerini almaz.
- Üçüncü taraf lisans bildirimlerini koru; yeniden dağıtım hakkı olmayan ham dosyaları repoya koyma. Hazır kod kütüphaneleri ile geliştirme/test araçlarını da kaydet.
- AI için resmî bir oran sınırı veya otomatik puan kesintisi uydurma. Yanlış veya eksik beyan diskalifiye sebebidir; teslim öncesi ekip gerçek kullanımını kontrol edip formdaki karşılıklarına aktarır.
- Farkındalık metinleri güvenilir kaynağa bağlanır. Oyundaki geri sarma, basitleştirilmiş fizik ve artçı sayacı gerçek dünyaya ilişkin öngörü ya da güvenlik garantisi gibi sunulmaz.

## Korunan hazırlık ve teslim kayıtları

- Oyuna özgü üretim, resmî tema açıklamasından sonraki 48 saatlik etkinlik süresinde yapılır; başlangıç 16 Ekim 2026, 18.00 (UTC+3). Etkinlik öncesi eğitim dosyalarını yarışma oyununa taşıma.
- `ENGINE_DECISION.md` ve `PREPARATION.md` içindeki Godot yönergeleri tarihli arşivdir; kullanıcı ARTÇI için Vite/TypeScript kararını vermiştir. Arşivdeki motor kararını güncel görev gibi uygulama.
- Önceki AI/araştırma kayıtlarını `SOURCES.md` içinde koru; ARTÇI üretim kayıtları `BEYAN.md` içindedir. Teslim beyanında ikisini birlikte dikkate al.
- Jam tesliminde `SUBMISSION.md` taslağını, public repo erişimini ve gerçek oynanabilir sürümü kontrol et; kaynak, lisans veya sonuç uydurma.
