# Codex çalışma kuralları — ARTÇI v0.1

- İşe başlamadan ilgili dosyaları, `README.md`, `STATUS.md`, `BEYAN.md` ve `git status` çıktısını incele.
- Ekip arkadaşının ve kullanıcının mevcut değişikliklerini koru. Görev dışı değişiklikleri silme, geri alma veya kendi commitine katma. Aynı dosyada çakışan işler varsa durumu açıkla ve değişiklikleri koruyarak ilerle.
- Teknoloji kararı: **Vite + TypeScript + HTML5 Canvas 2D + Web Audio API**. Çözünürlük 1280×720; grafik ve ses kodla prosedürel üretilir. Yeni oyun motoru, framework, görsel/ses/font dosyası veya bağımlılığı görev gerektirmedikçe ekleme.
- Yalnızca istenen kapsamda çalış. Kullanıcıya sonuçları, kontrolleri ve kalan sorunları anlaşılır Türkçeyle bildir.
- Commit ve push yalnızca kullanıcı istediğinde yapılır. Force push veya kullanıcı açıkça istemedikçe değişiklik kaybettiren Git komutları kullanma.

## İki kişilik paralel geliştirme

| Alan | Tek yazma sorumlusu | Sınır |
| --- | --- | --- |
| `src/core/**` | Kişi 1 — Core Simulation & Physics | Simülasyon, AP, deterministik fizik, geri sarma, tahliye, skor. |
| `src/ui_vfx/**` | Kişi 2 — Tactical UI, Audio, VFX & Levels | Çizim, DOM HUD, sentez, parçacıklar, stiller. |
| `src/levels/**` | Kişi 2 | `LevelData` uyumlu saf veri; core dosyalarını değiştirme. |
| `src/types/game.ts` | Kişi 1, iki kişinin mutabakatıyla | Ortak sözleşme; paralel çalışma sırasında dondurulur. |
| `src/main.ts`, kök yapılandırmalar, `package-lock.json`, `tests/**` | Kişi 1 — entegrasyon | Bağlantılar ve ortak kontroller; eşzamanlı ikinci yazar olmaz. |
| `README.md`, `STATUS.md`, `AGENTS.md`, `BEYAN.md` | Kişi 1 — entegrasyon | Kişi 2 görev/AI/kaynak notlarını kendi PR açıklamasında iletir; birleştirirken Kişi 1 kaydeder. |

- Gerçek kişi adları henüz bildirilmedi; Kişi 1 / Kişi 2 rol etiketleridir. İsim uydurma.
- `main` entegrasyon dalıdır. İki kişi aynı başlangıçtan ayrı `feat/core-*` / `feat/ui-*` dallarında çalışır; kendi alanındaki dosyaları değiştirir.
- İki taraf yalnızca `src/types/game.ts` sözleşmesine bağlanır. UI, core sınıflarını doğrudan import etmez; `GameController` ve `GamePresentation` kullanılır. Core, UI veya bölüm modülü import etmez; `LevelData` constructor'a verilir.
- Sunum `DeepReadonly<GameState>` alır ve durumu değiştirmez. Olaylara verilen tepkiler yalnızca sunumda kalır. Ses/çizim rastgeleliği fizik sonucunu etkileyemez.
- Yeni ortak alan veya bağımlılık gerekiyorsa Kişi 2 bunu kendi PR açıklamasında belirtir; Kişi 1 tek bir entegrasyon değişikliği yapar. İki kişi aynı anda lock dosyası veya ortak belgeleri düzenlemez.
- Aynı dosyaya dokunmamak çakışmayı önleme yöntemidir; Git için mutlak sıfır çakışma garantisi verme. Sözleşme değiştiğinde iki dal da güncel sözleşmeye göre kontrol edilir.

## Teknik sözleşme ve kontroller

- `Phase`: `FORESIGHT → REWIND → PLANNING → EXECUTION`. Son fazda `SHAKING → EVACUATION → REPORT` adımları vardır.
- `Engine` sabit 1/60 saniye fizik adımı kullanır. `SimulationManager` durumun tek sahibidir. Geri sarma tam ve izole durum kopyalarıyla yapılır.
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
