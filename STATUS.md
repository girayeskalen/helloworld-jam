# Proje durumu

Son güncelleme: **16 Ekim 2026** · **ARTÇI v0.2 — Core + görsel dal entegrasyonu**

## Güncel kapsam

Vite + TypeScript + **Matter.js 0.20.0** + Canvas 2D + Web Audio API. Kullanıcı Kişi 1 rolünü üstlendi. İlk fizik görevinde Kişi 2 dosyaları değiştirilmedi; sonraki paylaşım isteğinde `origin/feat/ui-realistic-visuals` dalındaki `fa2de72` commitinin görsel kodu ve master tasarım vizyonu birleştirildi. Aktif PhysicsView, bu daldan SceneArt arka planı/malzemeleri, ParticleSystem ve genel stilleri kullanır. Kişi 1'in referans fizik sahnesi `src/core/PhysicsLevel.ts`, çalışan entegrasyon görünümü `src/integration/` içindedir.

| Görev | Sorumlu | Durum | Sonuç |
| --- | --- | --- | --- |
| Matter.js ve TypeScript tipleri | Kişi 1 | Tamamlandı | `matter-js` 0.20.0, `@types/matter-js` 0.20.2 kuruldu; lock ve MIT bildirimi güncellendi. |
| Rijit cisim dünyası ve temel hareketi | Kişi 1 | Tamamlandı | Fiziksel kat/duvar/kolon, ağır gardırop, kitaplık, buzdolabı, compound masa, askılı lamba ve tavan yükleri. P/S esinli kinematik temel ve kuvvet/tork. |
| Fiziksel müdahaleler ve hasar | Kişi 1 | Tamamlandı | L-demir/çelik çapraz bağları; yük ve darbe hasarı, kopan askı, fiziksel kırılma parçaları, gaz/kıvılcım zinciri. |
| Fizik geri sarma | Kişi 1 | Tamamlandı | Her 2 karede bir 30 Hz kayıt, 60 Hz interpolasyon; hız/açı/NPC/bağ/parça durumu geri alınır, T=0 temiz dünya. |
| Planlama ve sığınak seçimi | Kişi 1 | Tamamlandı | 5 AP, farklı 1/2 AP maliyetli 7 seçenek, masa/kolon sığınağı; tekrar ücretlendirme ve bütçe aşımı engelli. |
| Aktif tutunma | Kişi 1 | Tamamlandı | A/D ile denge, kısa Space tutuşları ve yenilenen enerji; yeşil bölge fiziksel tutuş bağını korur. Girişsiz denemede kopma/savrulma ve sağlık kaybı. |
| Aktif tahliye ve karne | Kişi 1 | Tamamlandı | 12 sn sayaç, yatay hareket, Space/W/↑ zıplama, S/↓ hızlı iniş, coyote süresi, havada tekrar zıplama engeli. S-rank oynanabilir rota doğrulandı. |
| Ortak v0.2 veri sözleşmesi | Kişi 1 | Tamamlandı | Salt okunur gövde/parts, kütle merkezi, açı, güvence, integrity, dangerArc, bağlar, grip, sismik hareket ve boşluk verisi. Matter nesneleri UI'ya sızmaz. |
| Fizik/tarayıcı doğrulaması | Kişi 1 | Tamamlandı | Son doğrulama sonuçları aşağıda. |
| Görsel dalı fizik sürümüyle birleştirmek | Kişi 1 — entegrasyon | Tamamlandı | Kod çakışması yok; AGENTS tasarım vizyonu ve v0.2 kuralları birlikte korundu. Yeni görsel kaynak/AI notları BEYAN'a işlendi. |
| Renderer ve TacticalHUD'u v0.2 sözleşmesine geçirmek | Kişi 2 | Bekliyor | Görsel dalın ayrıntılı Renderer/HUD'u hâlâ eski sözleşmede; SceneArt/efektler aktif referans görünümde bağlı. `PhysicsView.ts` çalışan kullanım örneğidir. AP/maliyet/süreleri LevelData'dan, gövde çizimini parts'tan alın. |
| Yeni fizik bölümü ve oyun dengesi | Kişi 2 / Kişi 1 entegrasyon | Bekliyor | Şu an tek referans sahne, iki sığınak ve bir kontrol edilebilir NPC var. Sabit kimlikli bağların genel bölüm verisine taşınması sonraki core işi. |
| İnsan oynanış/işitsel kalite ve diğer tarayıcılar | Ekip | Bekliyor | Birleşik v0.2 otomasyonu Chromium/Linux'ta; UI dalının Windows/v0.1 doğrulaması VISUAL_NOTES içinde kayıtlı. Birleşik v0.2 Windows, Firefox/Edge ve insan oynanış kontrolü bekliyor. |
| Jam teslimi ve son beyan | Ekip | Bekliyor | README, BEYAN, eski SOURCES ve SUBMISSION birlikte kontrol edilecek; bu görev yayın/teslim yapmıyor. |

## Doğrulama ve sınırlamalar

- `npm install matter-js` ve `npm install -D @types/matter-js` başarılı; kurulumda açık bildirilmedi.
- `npm run build`: görsel dal ile birleştirme sonrasında TypeScript ve üretim derlemesi başarılı.
- `npm test`: **8/8 geçti**. Beş fizik testi; deterministik tekrar ve tam geri sarma, rijit cisim/bağ/güçlendirme, AP/sığınak sınırları, grip etkisi/enerjisi, zıplama ve S/timeout sonuçlarını doğruladı. Üç tarayıcı testi gerçek tuş/fare girişleri, ölçekli tıklama, S-rank, yeniden başlatma, ses, sekme duraklaması ve panel yerleşimini doğruladı.
- Oynanış 60 Hz, fizik 120 Hz alt adım, kayıt 30 Hz. Gövdeler aynı başlangıç/aynı girişle aynı sonucu verdi; geri sarma NPC sağlığı, kopan bağlar ve oluşan parçalar dahil başlangıç durumuna döndü.
- Serbest gardırop devrilirken L-demirli gardırop dik kaldı; zayıf masa/kolon kırılırken güçlendirilmiş taşıyıcı yük taşıdı. Aynı planda aktif dengeleme sağlık/tutunuş kaybını azalttı. Kolon sığınağı planıyla 100/100 S-rank elde edildi.
- Fizik modeli gerçek rijit cisim çözücüsünü kullanır; deprem dalga yayılımı veya yapısal dayanım hesabı değildir. Kütle/hasar/süreler oyun ölçeğinde. `SafeTriangle` anlık destek ve çakışma boşluğudur; gerçek bina güvenliği garantisi değildir.
- Kesitte karakter sağlam masa ayaklarının önünden/arkasından geçebilir; karakter–enkaz ve eşya–masa temasları fizikseldir. Yeni grounded sorgusu aynı çarpışma filtrelerini dikkate alır.
- Ara kare snapshot geri yüklenirken solver temas önbelleği yeniden kurulur; bit düzeyinde warm-start devam garantisi yoktur. Planlama ve yeni execution T=0 dünyasından tekrar kurulur.
- Birleşik üretim paketi `npm run preview` ile HTTP üzerinden oynandı; planlama, tutunma, tahliye ve karne ekranları incelendi: gerçek tuş girişleriyle 100/100 S-rank, hatasız JavaScript konsolu ve harici kaynak isteği olmaması doğrulandı. Lisans bildirimi HTTP 200 ile sunuldu.
- `git diff --check`, yerel belge bağlantıları ve lock/sürüm uyumu kontrol edildi. Görsel dalın `src/ui_vfx/` dosyaları kaynak commit ile birebir korundu.
- Runtime Matter.js MIT metni `public/THIRD_PARTY_NOTICES.txt` içindedir ve build'e kopyalanır.
- İlk v0.2 görevi commit/push yapmadan tamamlandı. Kullanıcının sonraki paylaşım isteğiyle core çalışması `0abc518` olarak kaydedildi; arkadaşın `fa2de72` görsel commiti merge geçmişi korunarak alındı. GitHub gönderiminin sonucu uzak dal kontrolüyle doğrulanır.

## Önceki kayıtlar

<details>
<summary>v0.1 doğrulaması, Git paylaşımı ve yarışma hazırlık geçmişi</summary>

# Proje durumu

Son güncelleme: **16 Ekim 2026** · **ARTÇI — AFTERSHOCK: Tactical Rewind / Vertical Slice v0.1**

Tema: Afet Hazırlığı ve Farkındalık. Teknoloji: Vite + TypeScript + Canvas 2D + Web Audio API. Gerçek isimler henüz belirtilmedi; Kişi 1 ve Kişi 2 rol etiketleridir. Ortak dosyaların tek yazma sorumlusu Kişi 1'dir; Kişi 2 ilerleme notlarını PR açıklamasında iletir.

## Görevler

| Görev | Görev sahibi | Durum | Not |
| --- | --- | --- | --- |
| Oyun motoru / teknoloji yığını seçimi | Ekip | Tamamlandı | Vite + TypeScript + HTML5 Canvas 2D + Web Audio API. |
| Oyun fikri ve ilk hedef | Ekip | Tamamlandı | ARTÇI; dört fazlı öngörü, geri sarma, 3 AP planlama, tahliye. |
| İlk prototip iskeleti ve ortak sözleşmeler | Kişi 1 / Kişi 2 alanları | Tamamlandı | İstenen modüller, yapılandırmalar ve `LevelData` prototipi oluşturuldu. |
| Vertical Slice v0.1 oynanış döngüsü | Kişi 1 / Kişi 2 alanları | Tamamlandı | 4 sn deprem, 1,5 sn gerçek snapshot geri sarma, müdahaleler, 10 sn tahliye ve S-rank karnesi. |
| Dokümantasyon ve kaynak/AI beyan kaydı | Kişi 1 — entegrasyon | Tamamlandı | README, AGENTS ve BEYAN; resmî v09 kitapçığının beş kategorili ayrı beyan düzeni işlendi. |
| İlk derleme ve Chromium kontrolleri | Kişi 1 — entegrasyon | Tamamlandı | `npm install`, `npm run build`, `npm test`; altı tarayıcı/simülasyon testi geçti. |
| Fizik ve tehlike etkileşimlerini genişletme | Kişi 1 — `src/core/` | Bekliyor | Veri güdümlü tetikleyiciler, çoklu NPC ve daha kapsamlı çarpışma modeli. Ortak sözleşme değişiklikleri önce kararlaştırılacak. |
| Geri sarma performansı ve deterministik tekrar analizi | Kişi 1 — `src/core/` | Bekliyor | Birden fazla bölümde snapshot bellek sınırı ve tekrar tutarlılığı. |
| İkinci bölüm ve risk dengesi | Kişi 2 — `src/levels/` | Bekliyor | Mevcut `LevelData` sözleşmesiyle yeni bölüm verisi; henüz bölüm seçici yok. |
| Blueprint okunabilirliği, ses ve VFX iyileştirmeleri | Kişi 2 — `src/ui_vfx/` | Bekliyor | Gerçek kullanıcı geri bildirimi, farklı ekranlar, efekt/ses dengesi. |
| Windows / Firefox / Edge üzerinde manuel oynanış | Kişi 2 — sunum ve bölüm | Bekliyor | Otomasyon bu ortamda yalnız Chromium'da yapıldı; işitsel kalite insan tarafından dinlenecek. |
| Son beyan doğrulama ve jam teslim paketi | Kişi 1 — entegrasyon, ekip onayı | Bekliyor | Son kullanım kayıtları, oynama bağlantısı, ZIP/video ve repo sürümü eşlemesi. Kullanıcı talebi olmadan yayın/commit/push yapılmaz. |

Gerçek isimler paylaşılınca rol etiketlerini değiştir. Durum için `Bekliyor`, `Devam ediyor`, `Engellendi` veya `Tamamlandı` kullan. Kişi 1 ve Kişi 2 sıradaki core ve UI/bölüm görevlerini farklı dosyalarda paralel yürütebilir; ortak tip, giriş noktası, bağımlılık ve belgeleri eşzamanlı düzenlemezler.

## Bilinen sorunlar

Temel oynanış döngüsünde doğrulanmış engelleyici hata yok. Aşağıdakiler prototipin mevcut sınırları ve takip işleridir.

| Sorun | Takip eden kişi | Durum / sonraki adım |
| --- | --- | --- |
| Fizik, tek bölüm için basitleştirilmiş deterministik modeldir; yapısal analiz yapmaz. | Kişi 1 | Veri güdümlü sistem ve ek bölümde sınanacak. |
| Yalnız bir bölüm yükleniyor; üç müdahalenin tamamı en iyi sonuca götürüyor. | Kişi 2 | Alternatif maliyet/rota seçenekleri ve ikinci bölüm tasarlanacak. |
| Artçı için 10 sn sabit sayaç gerçek deprem öngörüsü değildir. | Kişi 1 / Kişi 2 | Oyun tasarımı olduğu README'de açıklanıyor; eğitim metinleri gözden geçirilecek. |
| Ses ilk kullanıcı jestine kadar tarayıcı tarafından engellenir. | Kişi 2 | Web Audio'nun beklenen davranışı; ses düğmesi ve M kısayolu var. |
| Windows ve Chromium dışı tarayıcılar bu Linux ortamında doğrulanmadı. | Kişi 2 | Ekip bilgisayarlarında manuel test; işitsel kalite kontrolü. |

Bir sorun ortaya çıktığında nasıl tekrarlandığını ve varsa hata mesajını kısaca ekle.

## Doğrulama kaydı

- `npm install`: başarılı; kurulumda güvenlik açığı bildirilmedi. Kilit dosyası üretildi.
- `npm run build`: sıkı TypeScript kontrolü ve Vite üretim derlemesi başarılı.
- `npm run dev`: yerel HTTP sunucusu açıldı; sayfa tarayıcıda başlatılıp Canvas/HUD görüntüsü incelendi.
- `npm run preview`: son üretim paketi HTTP üzerinden açıldı; üç müdahale ve aktif tahliye ile 100/100 S-rank doğrulandı. JavaScript hatası ve dış kaynağa ağ isteği görülmedi.
- `npm test`: altı test geçti. Chromium'da otomatik öngörü/rewind, müdahalesiz yaralanma, ölçekli canvas tıklaması ve AP, S-rank tahliye, klavye/DOM kontrolleri, plan sıfırlama, süre dolması, olay zinciri, snapshot sıfırlama, enkaz çarpışması, bölüm verisinin korunması, ses aç/kapat, gizli sekmede duraklama ve HUD yerleşimi doğrulandı.
- `git diff --check` ve yerel doküman bağlantıları kontrolü başarılı.
- `BEYAN.md` ve `AGENTS.md` için resmî v09 PDF'inin 3–4. maddeleri okundu. İlk prototip kontrolünde commit/push yapılmadı; kullanıcı sonrasında GitHub paylaşımını istedi.

## GitHub paylaşımı ve hazırlık geçmişi

Kullanıcının push talebi üzerine ARTÇI prototipi commit edildi. Uzak depodaki `1f7ab55` hazırlık commitinin kayıtları bu entegrasyonda korundu. Godot kararı ve “henüz oyun yok” ifadeleri aşağıda yalnız tarihli arşiv olarak tutulur; güncel durum yukarıdaki ARTÇI v0.1 kaydıdır. Gönderim sonucu Git geçmişi ve uzak dal üzerinden doğrulanır.

<details>
<summary>ARTÇI öncesi hazırlık durumunun tamamı (1f7ab55)</summary>

# Proje durumu

Bu dosyayı görev alırken ve işi tamamladığında güncelle. Görev sahibini ekipçe belirle; aynı iş üzerinde çalışmadan önce haberleş.

## Mevcut aşama

- Ortak Git kurulumu ve ilk dokümantasyon GitHub'a gönderildi; depo public.
- Kullanıcı, 14 Ekim 2026'da organizasyonun kesin katılım onayının geldiğini bildirdi; başvuru ve katılım onayı tamamlandı.
- İki üye de etkinlik mekânına gidebileceğini bildirdi.
- Bu çalışmada oyun kodu ve asset üretilmedi. Motor kararı standart Godot 4.7.2 + GDScript; başlangıç yaklaşımı Compatibility, küçük bir 2D oyun ve Windows x86_64 teslimi. [Araştırma ve gerekçeler](ENGINE_DECISION.md).
- Bu bilgisayarda Godot proje yöneticisi açıldı; CLI sürümü `4.7.2.stable.official.ed1daf0bf` doğrulandı. Standart export şablonu klasörü boş. Henüz oyun projesi, import/çalışma/export testi yok; arkadaşın kurulumu teyit edilmedi.
- Hazırlık rehberi, motor araştırması, kaynak/AI kaydı, teslim taslağı ve önceki tasarım arşivi bu depoda tutuluyor. Paylaşımın güncel durumu Git geçmişi ve uzak depo üzerinden kontrol edilir.
- 16 Ekim 2026, tema açıklaması öncesinde güncel v09 kurallarının tamamı, bu depodaki yedi Markdown dosyası ve üç commit incelendi. Oyuna özgü kod, tasarım, mekanik, seviye, prototip veya asset bulunmadı. Bu yerel inceleme, organizasyonun resmî uygunluk kararı değildir. Eski video/sunum/teslim yönergeleri güncellendi.
- 16 Ekim 2026, 18.00 sonrasında kullanıcı temayı “Afete hazırlık ve farkındalık” olarak bildirdi; ek zorunlu koşul olmadığını belirtti. Tema sonrasında tasarım araştırmasına başlandı. [GAME_DESIGN.md](GAME_DESIGN.md) alternatifleri, önerilen tek odalı hazırlık bulmacasını ve kapsamı içeriyor; ekip kararı henüz kesinleşmedi. Oyun kodu, proje ve asset henüz yok.
- 16 Ekim 2026, tema sonrasında v09 PDF'sinin 13 sayfası, ekleri ve haritası doğrudan incelendi; önceki site kural metni ve proje belgeleriyle karşılaştırıldı. Ana kural içeriğinde anlam farkı bulunmadı. Sunum sırasında jürinin oyunu oynaması, teslimde kayıtlı bilgilerin korunması, kullanım izni ve mekân koşulları ilgili belgelere işlendi.
- 16 Ekim 2026'da ekip başka bir oyun fikri seçtiğini bildirdi. Yeni fikrin ayrıntıları ve yapılacak işler kullanıcıdan beklenecek; o zamana kadar oyun geliştirmesine başlanmayacak. GAME_DESIGN.md seçilmeyen önceki öneri olarak işaretlendi; araştırma ve AI kayıtları korundu. Kullanıcı, bekleyen hazırlık belgelerinin commit edilip GitHub'a gönderilmesini istedi.

## Takvim

Bütün saatler UTC+3. Güncel duyuruları [resmî siteden](https://game.ktimo.com.tr/) takip et.

| İşlem | Tarih ve saat |
| --- | --- |
| Normal başvuru sonu | 11 Ekim 2026, 23.59 |
| Tema açıklaması ve geliştirme başlangıcı | 16 Ekim 2026, 18.00 |
| Git desteği istemek için sınır | 18 Ekim 2026, 12.00 |
| Son oyun teslimi | 18 Ekim 2026, 18.00 |

## Görevler

| Görev | Görev sahibi | Durum | Not |
| --- | --- | --- | --- |
| Takım adı ve temsilci bilgisini ortak kayda geçirmek | Ekip | Bekliyor | Başvuru gönderildi; seçilen takım adı ve temsilcinin gerçek adı bu dosyada henüz kaydedilmedi. |
| İki üyeli takım başvurusunu göndermek | Ekip | Tamamlandı | Kullanıcı 11 Ekim 2026'da gönderildiğini bildirdi. Başvuru numarasını kişisel olarak sakla; public repoya telefon veya erişim kodu ekleme. |
| Organizasyonun katılım onayını almak | Başvurudaki temsilci | Tamamlandı | Kullanıcı 14 Ekim 2026'da kesin katılım onayının geldiğini bildirdi. |
| Oyun motorunu seçmek | Ekip / Codex araştırması | Tamamlandı | Standart Godot 4.7.2 + GDScript; karar ENGINE_DECISION.md içinde. |
| Motoru iki bilgisayarda açmak ve export araçlarını hazırlamak | İki üye | Devam ediyor | Bu bilgisayarda editör ve CLI sürümü doğrulandı; export şablonları yok. Diğer bilgisayar bekliyor. Adımlar PREPARATION.md içinde. |
| Arkadaşın bilgisayarında Git kimliği ve pull kontrolü | İlgili üye (belirlenecek) | Bekliyor | Bu bilgisayarın kurulumu tamamlandı; diğer bilgisayarın durumu teyit edilmedi. |
| Görev sahiplerinin gerçek adlarını yazmak | Ekip | Bekliyor | Kod/proje, test/kaynak kaydı ve teslim sorumluluklarını paylaş. |
| Oyun fikrini seçmek | Ekip | Tamamlandı | Kullanıcı 16 Ekim 2026'da başka bir fikir seçildiğini bildirdi. GAME_DESIGN.md önceki, seçilmeyen araştırma olarak korundu. |
| Yeni fikri ve ilk uygulama hedefini belgelemek | Ekip / Codex | Bekliyor | Kullanıcı yeni fikrin ayrıntılarını ve yapılmasını istediği işleri paylaşacak; henüz oyun projesi veya kod oluşturulmadı. |
| Güncel kuralları ve bekleyen hazırlık belgelerini incelemek | Codex | Tamamlandı | 16 Ekim 2026: v09'a göre teslim ZIP'i, ayrı video, kategori beyanları ve sunum yönergeleri güncellendi; commit/push yapılmadı. |
| v09 PDF kitapçığını doğrudan okuyup karşılaştırmak | Codex | Tamamlandı | 16 Ekim 2026, 18.00 sonrası: 13 sayfa metin/görsel inceleme; site metni ve proje yönergeleriyle karşılaştırma tamamlandı. Oyun kodu/asset ve commit/push yok. |
| AI ve kaynak kayıtlarını güncel tutmak | Kaynak sorumlusu (belirlenecek) | Bekliyor | SOURCES.md içindeki kayıtlar gerçek kullanımla güncellenecek. |
| Godot arayüzü, Git, hata bildirimi ve kayıt araçlarına alışmak | İki üye / Codex | Bekliyor | PREPARATION.md içindeki tarihli hazırlık planı uygulanacak; eğitim dosyaları yarışma oyununa taşınmayacak. |

Yeni görev eklerken gerçek kişinin adını yaz. Durum için `Bekliyor`, `Devam ediyor`, `Engellendi` veya `Tamamlandı` kullan.

## Bilinen sorunlar

Henüz oyun hatası bildirilmedi; oyun projesi yok. Tamamlanmamış araç hazırlıkları aşağıda takip ediliyor.

| Sorun | Takip eden kişi | Durum / sonraki adım |
| --- | --- | --- |
| Export şablonları henüz kurulu değil | Ekip / Codex | Windows x86_64 şablonları hazırlanacak; açılmış editör, başarılı export kanıtı değil. |
| Arkadaşın motor ve export kurulumu teyit edilmedi | İlgili üye (belirlenecek) | Aynı Godot sürümünü ve gerçek kurulum sonucunu kaydet. |
| Bu oturumda native editör/tarayıcı UI otomasyonu erişimi yok | Codex | Dosya ve CLI kullanılabiliyor; gerçek görüntü, ses ve insan oynayış kontrolleri ayrıca yapılacak. |

Bir sorun ortaya çıktığında nasıl tekrarlandığını ve varsa hata mesajını kısaca ekle.

</details>

</details>
