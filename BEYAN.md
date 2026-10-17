# AFET KUŞATMASI — AI ve hazır kaynak kaydı

17 Ekim 2026 · Yeni Godot projesi / Adım 1 + Adım 2 + Adım 2.5 + Adım 3 + Adım 2.7 (görsel/atmosfer) + Adım 3-B (loot/oda hasarı).

Bu kayıt yalnızca aktif yeni proje içindir. Önceki ARTÇI beyanları Git geçmişindeki `2647179:BEYAN.md` ve `2647179:SOURCES.md` içinde korunur; proje değişimi önceki AI kullanımını yok sayma gerekçesi değildir. Son teslimde gerçek toplam kapsam gözden geçirilir.

## AI kullanımı

Araçlar: Adım 1–2.5 için **OpenAI Codex** (kesin model sürüm etiketi ayrıca doğrulanmadı); Adım 3, Adım 2.7 ve Adım 3-B için **Anthropic Claude Code, Claude Opus 5.5** (`claude-opus-5-5`). Kapsamlar aşağıda ayrı ayrı yazılıdır.

| Kategori | Durum | Amaç ve dosyalar |
| --- | --- | --- |
| Görsel | Kullanıldı | Diorama, mobilya, çevre, karakter ve efektlerin prosedürel GDScript çizim kodu AI yardımıyla üretildi: `scripts/art/`, `scripts/building/`, `scripts/player/`, `scripts/ui/`. Resim üretim servisi veya harici görsel kullanılmadı. |
| Ses | Kullanılmadı | Bu adımda ses/müzik üretimi veya ses dosyası yok. |
| Kod | Kullanıldı | Godot proje/sahne mimarisi, statik tipli GDScript, hareket, merdiven, dash/dokunulmazlık, efektler, kamera, Windows başlatıcı ve testler. |
| Metin | Kullanıldı | Oyun arayüzü, README/AGENTS/STATUS/SOURCES/SUBMISSION ve bu beyan. |
| Diğer | Kullanıldı | Mimari kararlar, test senaryoları ve görsel kontrol desteği. |

İsim, sanat yönü, Adım 1 gereksinimleri ve mekanik hedefler kullanıcı tarafından sağlandı. AI katkısını gizleyen veya insan çizimi olduğunu iddia eden bir beyan yapılmaz.

## Hazır kaynak kullanımı

| Kategori | Durum | Açıklama |
| --- | --- | --- |
| Görsel | Kullanılmadı | Harici sprite/PNG, ikon, texture, model veya görsel paket yok. |
| Ses | Kullanılmadı | Harici müzik/sample/efekt yok. |
| Kod | Kullanıldı | Godot motoru ve yerleşik GDScript/Canvas/2D fizik API'leri; proje scriptleri bu görevde yazıldı, hazır oyun şablonu alınmadı. |
| Metin | Kullanıldı | Godot resmî API belgelerinden teknik bilgi düzeyinde yararlanıldı; eğitim/afet talimatı bu adımda üretilmedi. |
| Diğer | Kullanıldı | Godot'un yerleşik varsayılan fontu; ayrıca font dosyası eklenmedi. |

- Godot: [Godot contributors](https://godotengine.org/license/), MIT; motor ve birlikte gelen üçüncü taraf bildirimleri dağıtımda korunmalı. Runtime/export paketi bu adımda oluşturulmadı.
- Godot'un varsayılan fontu motor dağıtımının lisans/bildirimlerine tabidir; başka font indirildiği iddia edilmez.
- Fallout Shelter, Enter the Gungeon ve Undertale yalnızca kullanıcı tarafından verilen estetik/mekanik referanslardır. Bu oyunlardan kod, görsel, ses veya dosya alınmadı.
- Doğrulanan resmî teknik belge bağlantıları [SOURCES.md](SOURCES.md) içindedir. Ekibin sonraki araç/asset kullanımı ayrıca kaydedilir.

## Adım 2 ek kapsamı

OpenAI Codex ile iki animasyonlu prosedürel boss, mermi/uyarı çizimleri, DODGE metni ve savaş HUD'u üretildi; **görsel katkı AI tarafından yazılmış çizim koduyla dolaylıdır**. Kod katkısı `scripts/bosses/`, `scripts/combat/`, MainGame/sahne bağlantıları, oyuncunun hasar koruması, bina dayanıklılığı, eşya titremesi, kamera ve HUD entegrasyonunu kapsar. Metin/diğer katkı; arayüz ifadeleri, test tasarımı, görsel inceleme ve bu belgelerin güncellenmesidir. Ses katkısı yoktur.

Yeni görsel/ses/font dosyası, asset paketi veya üçüncü taraf eklenti alınmadı. Mevcut Godot araçları kullanıldı; Geometry2D, Node, CanvasItem ve Window resmî 4.3 belgelerinden teknik bilgi düzeyinde yararlanıldı. Boss tasarımları fantastik yorumdur; gerçek afet/mühendislik doğruluğu iddiası değildir.

## Adım 2.5 ek kapsamı — 17 Ekim 2026

OpenAI Codex; altı odanın renk/malzeme/mobilya çizimlerini, oda kimliklerini, tesisat donanımlarını, yeni mermi görsellerini ve arayüz metinlerini GDScript ile üretti. Zıplama/değişken yükseklik/coyote, platform tutunma/drop-through, fast-fall, sekiz yönlü hava dash'i, beş patern ailesi ve enkazın ayrı uyarılı sekme zinciri AI destekli kod kapsamındadır. Testler, gerçek renderer görüntü incelemesi ve belgeler de AI desteği içerir. Görsel katkı prosedürel çizim kodudur; harici resim üretimi, sprite paketi, ses veya yeni font kullanılmadı. Loot sistemi bu görevin kapsamında değildir.

## Adım 3 ek kapsamı — 17 Ekim 2026

Araç: **Anthropic Claude Code / Claude Opus 5.5**. Kullanıcının istediği üç değişiklik bu araçla yazıldı:

| Kategori | Durum | Amaç ve dosyalar |
| --- | --- | --- |
| Görsel | Kullanıldı (prosedürel kod) | 16 odanın duvar/zemin desenleri ve oda adları (`RoomDiorama.gd`), 20 yeni mobilya çizimi — kazan, posta kutuları, giriş kapısı, çamaşır makinesi, vitrin, yemek masası/sandalyesi, piyano, pikap, hoparlör, küvet, aynalı lavabo, valiz, saksı rafı, koşu bandı, dambıl rafı, kum torbası, şövale, boya masası, klima ünitesi (`FurnitureArt.gd`); çatı tabelası (`ApartmentBuilding.gd`); ölçeklenen dış çevre (`WorldBackdrop.gd`); girdap gözü, rüzgâr uyarısı/çizgileri, enkaz mermisi (`TelegraphSystem.gd`, `HazardProjectile.gd`); kat geçişi izi/tozu (`Player.gd`). Harici görsel veya resim üretim servisi kullanılmadı. |
| Ses | Kullanılmadı | — |
| Kod | Kullanıldı | Merdivenin kaldırılması, W/2x W/S kat sistemi ve tavan sınırı (`Player.gd`, `MainGame.gd`), 4×4 bina ve kamera zoom'u (`ApartmentBuilding.gd`, `MainGame.tscn`), fırtına girdap/çapraz yaylım/koridor/rüzgâr paternleri ve döngüsü (`BossPatterns.gd`, `DisasterBoss.gd`, `DisasterWaveManager.gd`, `HazardAttack.gd`), HUD yerleşimi (`GameHUD.gd`), testlerin güncellenmesi ve yeni `tests/Step3Smoke.gd`. |
| Metin | Kullanıldı | Oyun içi oda/patern/kontrol metinleri, README/AGENTS/STATUS/SUBMISSION ve bu bölüm. |
| Diğer | Kullanıldı | Yerleşim hesapları, test senaryoları ve gerçek renderer PNG'lerinin görsel incelemesi. |

Tasarım istekleri (16 oda listesi, kontrol şeması, fırtına paternleri) kullanıcıdan geldi. Yeni bağımlılık, asset, ses veya font eklenmedi.

## Adım 2.7 ek kapsamı — 17 Ekim 2026 (görsel temizlik, karanlık atmosfer, akıcı hareket, çok parçalı bosslar)

Araç: **Anthropic Claude Code / Claude Opus 5.5**.

| Kategori | Durum | Amaç ve dosyalar |
| --- | --- | --- |
| Görsel | Kullanıldı (prosedürel kod) | Gece gökyüzü/şehir/dither (`WorldBackdrop.gd`), yağmur/kül/şimşek (`NightWeather.gd`), oda kiri ve AO/vinyet/dither gölgesi (`RoomDiorama.gd`), additive lamba konileri (`RoomLighting.gd`), sallanan lamba (`BuildingProp.gd`), squash/eğilme/pelerin/baret feneri (`CharacterArt.gd`, `Player.gd`), çok parçalı golem ve 12 halkalı fırtına iskeleti (`DisasterBoss.gd`), neon mermi ışıması/iz/çekirdek ve uyarılar (`HazardProjectile.gd`, `TelegraphSystem.gd`), pixel-art SubViewport render (`MainGame.tscn`, `MainGame.gd`). Tabela/oda adı/kat levhaları kaldırıldı. Harici görsel, resim üretim servisi veya hazır shader kullanılmadı. |
| Ses | Kullanılmadı | — |
| Kod | Kullanıldı | Hareket ayarları ve görsel durumlar (`Player.gd`), sprite otomatik yükleyici (`AssetRegistry.gd`), ekran katmanı etiketleri (`WorldLabels.gd`), kamera sarsıntı gücü (`GameCamera.gd`), testlerin güncellenmesi ve yeni `tests/Step27Smoke.gd`. |
| Metin | Kullanıldı | README/AGENTS/STATUS/SOURCES/SUBMISSION, `assets/sprites/README.md` ve bu bölüm. |
| Diğer | Kullanıldı | 1920×1080 gerçek renderer görüntülerinin incelenmesi ve buna göre ayar (lamba yoğunluğu, şimşek konumu, golem kol bükümü). |

Atmosfer yönü (This War of Mine / Dead Cells / Carrion) kullanıcı tarafından yalnızca estetik referans olarak verildi; bu oyunlardan kod, görsel, ses veya dosya alınmadı. `assets/sprites/` klasörü boştur (yalnız README); oraya konacak el yapımı dosyaların kaynağı ayrıca bu belgeye yazılmalıdır.

## Adım 3-B ek kapsamı — 17 Ekim 2026 (doğal üst kat yayı, oda hasarı/çöküş, loot ve onarım)

Araç: **Anthropic Claude Code / Claude Opus 5.5**.

| Kategori | Durum | Amaç ve dosyalar |
| --- | --- | --- |
| Görsel | Kullanıldı (prosedürel kod) | Oda hasar durumları: çatlak, sıva deliği, sarkan tavan, bel veren kolon, kıvılcım/toz/moloz, enkaz yığını ve duman, çelik X-kiriş (`RoomDiorama.gd`); kepenk + kum torbası ve L-demir (`BuildingProp.gd`); durumlara göre lamba titremesi/kırmızı/sönme (`RoomLighting.gd`); loot simgeleri, halka ve ışık hüzmesi (`LootSystem.gd`); HUD malzeme sayacı ve çöküş ekranı (`GameHUD.gd`), `[!] ONAR [E]` ve uçan yazılar (`WorldLabels.gd`). Harici görsel kullanılmadı. |
| Ses | Kullanılmadı | — |
| Kod | Kullanıldı | Fizik tabanlı 2x W yayı (`Player.gd`), oda HP/durum modeli (`RoomDiorama.gd`), bina ortalaması/çöküş kuralı/aşınma (`ApartmentBuilding.gd`), oda hasar tablosu ve `FailReason` (`DisasterWaveManager.gd`), yıkık odada eşya tehlikesinin durması (`BossPatterns.gd`), loot/toplama/E onarımı (`scripts/loot/LootSystem.gd`), E tuşu (`MainGame.gd`), test güncellemeleri ve yeni `tests/Step3LootSmoke.gd`. |
| Metin | Kullanıldı | Oyun içi uyarı/geri bildirim metinleri, README/AGENTS/STATUS/SOURCES/SUBMISSION ve bu bölüm. |
| Diğer | Kullanıldı | Hasar/loot dengesinin otomatik dalga testiyle ölçülmesi ve 1920×1080 görüntülerin incelenmesi. |

Mekanik istekleri (oda durumları, çöküş koşulu, loot türleri, E onarımı) kullanıcı verdi. Oda HP değerleri ve "çimento/kepenk ile anında onarım" kurgusal oyun mekaniğidir; gerçek yapı güçlendirme veya afet güvenliği tavsiyesi olarak sunulmaz.

## Üç dalgalı kampanya ve afet hazırlığı ek kapsamı — 17 Ekim 2026

Araç: **OpenAI Codex**; kesin model etiketi bu çalışmada ayrıca doğrulanmadı. Kullanıcının verdiği tasarımla yalnız hasarlı odada kuşatma onarımı, 5 tip süreli loot, üç bileşenli inşaat ve %55 hasar azaltımı, 9 seçilebilir kartın gerçek oyun etkileri, 20 sn inşaat araları, koordineli çift boss finali ve zafer ekranı kodlandı. `SiegeUpgrades.gd`, `UpgradeOverlay.gd`, `CampaignSmoke.gd` eklendi; mevcut dalga/loot/oda/HUD ve uygun testler güncellendi. Claude'un 16 oda çizimleri, parabolik 2x W kat zıplaması ve çok parçalı boss rigleri korundu.

Görsel katkı: AI destekli GDScript çizimleriyle büyük çelik X-kiriş/perçin/şerit, kepenk, kum torbası, sabitleme kemeri, LED, 5 loot simgesi/ömrü ve üç kart arayüzü. Yeni harici sprite, font, ses, asset, eklenti veya resim üretim servisi kullanılmadı. Metin katkısı: kart açıklamaları, arayüz ve proje belgeleri. Doğrulama: motor içi testler ve gerçek Compatibility renderer görüntülerinin incelenmesi (sonuç STATUS'ta).

Kart adları, C40 etiketi ve oranları kullanıcı tasarımıdır; bu görevde gerçek afet veya mühendislik bilgisi doğrulaması yapılmadı. Anlık yapı onarımı, dokunulmaz takla, hidrolik bot ve manyetik drone gibi etkiler gerçek afet davranışı/teknik güvence olarak sunulmaz. Bu ek bir resmî kurum onayı veya bağımsız oyun teslimi değildir.

## 17 Ekim 2026 — Adım 4.5 / aktif mekanikler ve dalga dengesi

OpenAI Codex, kullanıcının ekli tasarımıyla 90 sn savaş / 15 sn inşaat, kilitli üç boss sırası, 1,5 sn giriş / 2,5 sn çıkış / kart fade-in, ortak üç odalık hasar sınırı, 10 sn onarım payı, görsel salınım/çatlak/toz ve dokuz yeni aktif kartı uyguladı. Eski pasif kart havuzu kaldırıldı. `SiegeMechanics.gd` dron/kule/türbin/iz/şok/ışın çizimlerini ve etkileri içerir; mevcut Claude oda çizimleri, gece atmosferi ve 2x W fizik yayı temel alınarak korundu. Boss rigine çıkış ayrışması eklendi. Yeni ses, harici görsel, font, paket veya servis kullanılmadı; görseller GDScript ile prosedüreldir. Kart isimleri/fantastik etkiler gerçek afet davranışı veya mühendislik uygulaması tavsiyesi değildir.

Testler yeni faz ve mekaniklere uyarlandı; `Step45Smoke.gd` eklendi. Gerçek test sonuçları ve native görsel kayıtların yeri `STATUS.md` içindedir. Commit/push veya dağıtım yapılmadı.

## 17 Ekim 2026 — Beş dalgalı boss maratonu

Araç: **OpenAI Codex (GPT-6 tabanlı kodlama ajanı)**. Kesin model alt sürümü bu oturumda ayrıca doğrulanmadı. Kullanıcının ekli devir/tasarım metni ve `3c6ae04` Godot sürümü temel alındı. Eski `main` çalışma ağacındaki kullanıcı değişikliklerine dokunulmadan `feat/disaster-siege-step1` ayrı worktree'de açıldı.

| Kategori | Durum | Kapsam |
| --- | --- | --- |
| Görsel | Kullanıldı | Çok parçalı üç başlı su hidrası, dört alev kollu kor titanı, su/ateş mermileri, zemin alanları, giriş/çıkış/cephe/çatı hareketi, kızıl duman, uyarılar ve beş dalga HUD'u için AI destekli prosedürel GDScript çizimi: `scripts/bosses/MarathonArt.gd`, `DisasterBoss.gd`, `NightWeather.gd`, `RoomDiorama.gd`, combat ve UI dosyaları. Görsel üretim servisi veya harici bitmap kullanılmadı. |
| Ses | Kullanılmadı | Yeni ses kodu/kayıt/müzik eklenmedi; giriş/çıkış anlatımı görseldir. |
| Kod | Kullanıldı | `MarathonPatterns.gd`; beş dalga/7 sn ara/1,2 sn giriş/1 sn çıkış; dondurulmuş sekmeli yollar, kalıcı tehlike alanı ve ısı/çekim/yavaşlatma; iki direnç kartı, kısayollar, yeni `MarathonSmoke.gd` ve mevcut test güncellemeleri. |
| Metin | Kullanıldı | Kart/uyarı/zafer metinleri, README/AGENTS/STATUS ve bu kayıt. |
| Diğer | Kullanıldı | Test tasarımı, Godot 4.3 Linux doğrulaması, native renderer ekran görüntülerinin incelenmesi ve düzeltmeler. |

**Hazır kaynak:** Görsel Kullanılmadı; Ses Kullanılmadı; Kod Kullanıldı (mevcut Godot motoru/API'leri); Metin Kullanılmadı (bu görevde yeni üçüncü taraf içerik alınmadı); Diğer Kullanıldı (mevcut Godot varsayılan fontu ve test motoru). Godot **4.3.stable.official.77dcf97d8**, [resmî Godot builds 4.3 sürümünden](https://github.com/godotengine/godot-builds/releases/tag/4.3-stable) yalnız `/tmp/siege-tools` içine alındı; motor MIT ve beraberindeki üçüncü taraf bildirimlerine tabidir. Motor/ZIP/font veya ekran görüntüleri oyun asseti olarak repoya eklenmedi. Yeni bağımlılık/eklenti/asset paketi yoktur.

Su/ateş düşmanları, hasar yüzdeleri, sprinkler/drenaj etkileri, kat geçişi ve takla kurgusal oyun mekaniğidir; gerçek afet veya yapı güvenliği talimatı değildir. Bu görevde yeni afet davranışı kaynağı araştırılmadı; oranlar kullanıcı tasarımındaki oyun etkileridir. Test sonuçları STATUS'ta gerçek kapsamıyla kaydedilir. Commit, push, main birleştirmesi veya bağımsız export yapılmadı.

## 17 Ekim 2026 — Adım 4.8 / karakter, dört boss, ekipman ve farkındalık kartları

Araç: **OpenAI Codex (GPT-6 tabanlı kodlama ajanı)**. Kullanıcının ayrıntılı tasarımı ve önceki Godot kodu üzerinden çalışıldı; kesin model alt etiketi ayrıca doğrulanmadı.

| AI kategorisi | Durum | Çıktı / etkilenen dosyalar |
| --- | --- | --- |
| Görsel | Kullanıldı | Kurtarma uzmanı, çanta/ceket eklemleri; dört bossun üç tonlu yüzey/doku/elektrik/fay/köpük/magma detayları; dört ekipman simgesi, karbon sargı ve otomatik güvenlik kurulumu; kart/HUD yerleşimi. `CharacterArt.gd`, `EquipmentArt.gd`, `Player.gd`, `DisasterBoss.gd`, `MarathonArt.gd`, `RoomDiorama.gd`, loot/UI/telegraph çizimleri. Yeni bitmap veya görsel üretim servisi yok. |
| Ses | Kullanılmadı | Ses, müzik veya ses üretim kodu eklenmedi. |
| Kod | Kullanıldı | Dört loot, yerel güvenli alan kesimi, kaynak bazlı koruma, beş hazırlık ve üç yeni aksiyon kartı, mevcut drone revizyonu, 1+2 seçim kuralı, tek seferlik dalga ödülleri, reset ve testler. `LootSystem`, `SiegeUpgrades`, `SiegeMechanics`, building/combat/UI ve `tests/Step48Smoke.gd`; eski regresyonlar yeni ekipmana uyarlandı. |
| Metin | Kullanıldı | Kart etki/farkındalık notları, ekipman etiketleri, HUD ve README/AGENTS/STATUS/SOURCES/BEYAN kayıtları. Notlar resmî kaynaklarla dar kapsamda karşılaştırıldı; kaynak ve erişim sınırlamaları SOURCES'ta. |
| Diğer | Kullanıldı | Test tasarımı, 200 kart seçimi, Godot 4.3 Linux motor kontrolleri, native 1920×1080 karelerinin incelenmesi ve ekran kenarı düzeltmeleri. |

| Hazır kaynak kategorisi | Durum | Sağlayıcı / kullanım / lisans |
| --- | --- | --- |
| Görsel | Kullanılmadı | Harici resim/sprite/doku/asset paketi yok; kaynaklardan görsel alınmadı. |
| Ses | Kullanılmadı | Hazır ses/müzik yok. |
| Kod | Kullanıldı | Mevcut Godot motoru/API'leri; Godot Engine ve katkıcıları, [Godot 4.3](https://github.com/godotengine/godot-builds/releases/tag/4.3-stable), MIT ve motorun üçüncü taraf bildirimleri. Yeni bağımlılık/eklenti yok. |
| Metin | Kullanıldı | AFAD, USGS, İMO/İPKB ve Godot dokümantasyonundaki olguların kısa özgün özetleri; bağlantı ve kullanım yerleri SOURCES'ta. Kurumsal metinlerin açık yeniden kullanım lisansı doğrulanmadı; ham belgeler veya uzun alıntılar dağıtılmadı. |
| Diğer | Kullanıldı | Mevcut Godot varsayılan fontu ve test motoru; font/motor dosyaları repoya eklenmedi, mevcut üçüncü taraf bildirimleri korundu. |

“Yaşam üçgeni standardı” ve yapı güçlendirmesine kesin sonuç atfeden kullanıcı metinleri güvenlik önerisi olarak aynen kullanılmadı; sabitleme/Çök-Kapan-Tutun ve uzman incelemesi ayrımı korundu. Hasar yüzdeleri, anlık onarım ve tek odada su/alev temizleyen hibrit güvenlik kiti kurgusal oyun etkileridir. Doğrulamanın gerçek sonucu STATUS'tadır; insan zorluk/eğlence testi ve bağımsız export bu adımda yapılmadı. Commit/push/main birleştirmesi yapılmadı.


## 17 Ekim 2026 — Git teslimi ve Claude devir belgesi

Kullanıcının açık commit/push ve Claude ile devam isteği üzerine OpenAI Codex, `CLAUDE_DEVIR.md` belgesini hazırladı; README/STATUS bağlantılarını ve proje açıklamasındaki kart sayısını güncelledi. AI metin/kod desteği kullanıldı; yeni görsel, ses, font veya oyun bağımlılığı eklenmedi. Git teslim aracı olarak GitHub CLI v2.102.0 kullanıldı (GitHub ve katkıcıları, MIT); resmî yayın arşivi SHA256 kontrolünden geçti. Araç kullanıcı dizininde, lisans bildirimi yanında tutulur; binary/kimlik bilgileri repoya eklenmedi. Hazır kaynak kod/diğer kategorilerine bu geliştirme aracı da dahildir. Bu kayıt önceki geliştirme aşamalarındaki “commit/push yapılmadı” notlarından sonraki teslim talebidir; eski kayıtlar tarihsel olarak korunur. Oyun kodu bu devir görevi sırasında değiştirilmedi. Testlerin geliştirmede alınan sonuçları ile devirde yapılan kontroller belgede ayrılır.

## 17 Ekim 2026 — Adım 4.9 / minimal HUD, 60 sn dalgalar ve Kataklizma Titanı

Araç: **Anthropic Claude Code, Claude Opus 5.5** (`claude-opus-5-5`). Gereksinimler (HUD sadeleştirme, 60 sn faz, final boss tasarımı/yetenekleri, 1–6 kısayolları) kullanıcı tarafından verildi.

| Kategori | Durum | Kapsam |
| --- | --- | --- |
| Görsel | Kullanıldı (dolaylı) | Piksel kalp/şimşek/kalkan ikonları, kontur barlar ve slotlar (`scripts/ui/GameHUD.gd`); Titan'ın bazalt kafa/boynuz/taç, hortum kol, magma pençe, gövde kanatları, tsunami tabanı ve birleşme efektleri (`scripts/bosses/CataclysmArt.gd`); buhar sütunu ve alev bıçağı çizimi. Hepsi AI'nın yazdığı prosedürel GDScript çizim kodudur; resim üretim servisi, harici sprite/ikon/font kullanılmadı. |
| Kod | Kullanıldı | 6. dalga ve 2,0 sn birleşme akışı, 60 sn süre, 0,8 sn mühür uyarı kuralı, beş birleşik yetenek ve buhar etkileşimi (`scripts/combat/CataclysmPatterns.gd`), nova ve ek loot (`LootSystem.emergency_drop`), Titan iskeleti/katmanları (`DisasterBoss.gd`), doğrudan 1–6 ve Tab/H (`MainGame.gd`), yeni `tests/Step49Smoke.gd` ve mevcut testlerin yeni davranışa uyarlanması. |
| Metin | Kullanıldı | HUD/yetenek/banner metinleri, README/AGENTS/STATUS/CLAUDE_DEVIR ve bu beyan. |
| Ses | Kullanılmadı | Ses eklenmedi. |
| Diğer | Kullanıldı | Native 1920×1080 ekran görüntülerinin AI tarafından incelenmesi ve buna göre sanat düzeltmeleri. |

Hazır kaynak: yeni dosya, paket veya eklenti alınmadı. Dead Cells, Celeste ve Enter the Gungeon yalnız kullanıcının HUD için verdiği üslup referanslarıdır; bu oyunlardan kod, görsel, ikon veya ses alınmadı. Dört afetin tek canavarda birleşmesi, buhar sütunu, mühür ve nova kurgusal oyun mekanikleridir; gerçek afet davranışı veya güvenlik tavsiyesi değildir.

## 17 Ekim 2026 — Adım 5 / duraklatma paneli ve prosedürel ses motoru

Araç: **Anthropic Claude Code, Claude Opus 5.5** (`claude-opus-5-5`). Gereksinimler (ESC/P duraklatma, tuş rehberi, M/ses seviyesi, ses kategorileri ve miks kuralları) kullanıcı tarafından verildi.

| Kategori | Durum | Kapsam |
| --- | --- | --- |
| Ses | Kullanıldı (dolaylı) | Oyundaki bütün ses efektleri ve atmosfer müziği (yağmur, drone, gerilim pedi, nabız; 51 ses) AI'nın yazdığı GDScript sentez kodu ve tarifleriyle oyun açılışında üretilir: `scripts/audio/SoundSynth.gd`, `SoundRecipes.gd`, `SoundManager.gd`. Hazır ses/müzik dosyası, örnek (sample), ses üretim servisi veya TTS kullanılmadı. Sesler sayısal ölçümlerle (tepe, tık, DC, parlaklık, döngü sürekliliği) test edildi; AI sesleri kulakla dinleyemez, insan dinleme kontrolü ayrıca yapılmalıdır. |
| Görsel | Kullanıldı (dolaylı) | Duraklatma paneli, tuş kapakları, satır ikonları, ses göstergesi ve HUD köşe hoparlörü prosedürel çizim kodudur (`scripts/ui/PauseMenu.gd`, `GameHUD.gd`). |
| Kod | Kullanıldı | Duraklatma akışı, ses bus/limiter kurulumu, arka plan pişirme thread'i, olay bağlantıları için yeni sinyaller (oyuncu zıplama/iniş, loot yere değme, boss hazırlığı, türbin engellemesi), `tests/Step5Smoke.gd`. |
| Metin | Kullanıldı | Panel metinleri, README/AGENTS/STATUS ve bu beyan. |

Hazır kaynak: yeni dosya, paket, ses kütüphanesi veya eklenti alınmadı. Sentezde kullanılan Chamberlin durum-değişkenli filtre ve Paul Kellet pembe gürültü yaklaşımı bilinen DSP formülleridir; kod proje içinde yazıldı (bkz. SOURCES).

## 17 Ekim 2026 — Adım 5.5 (OpenAI Codex)

Claude'un Adım 4.9/5 değişiklikleri ve mevcut SFX/oyuncu/4×4 bina/loot/onarım temel alınarak kullanıcı tasarımı uygulandı. Kampanya FIRTINA → DEPREM → SEL → DEPREM • SEL • FIRTINA olarak dört faza indirildi; yangın bossu ve çifte faz kaldırıldı. Birleşik saldırı/sanat yalnız rüzgâr, kaya ve su kullanır; eski ateş jetleri köpüklü su jetlerine dönüştürüldü. BossCinematic ile ayrı 2,5/2,8 sn giriş, hafif kamera odağı, şimşek/kaya/su sahnelemesi ve letterbox; GameHUD'da alt boss barı eklendi.

Özgün BGM bestesi ve sentez kodu AI yardımıyla MusicScore.gd içinde üretildi: 16 ölçü Re minör, sıcak bas, stereo akor pedleri, yumuşak davul/hat ve arpej, hazırlık/kuşatma/final düzenlemeleri. Ses dosyası veya dış müzik/asset indirilmedi; örnekler çalışma anında AudioStreamGenerator'a üretilir. Mevcut SoundRecipes/SoundSynth efektleri korunur. Test için geçici WAV/PNG çıktıları Git dışındadır. Müzik kalitesi ölçüm ve gerçek sürücüyle çalıştırmayla incelendi; kulakla öznel dinleme yapılmadı. Lisans veya insan bestesi iddiası eklenmedi.

Step55Smoke eklendi; önceki paketlerde kaldırılan dalga/ateşli final/üst HUD beklentileri yeni tasarıma uyarlandı. Motor sürümleri ve gerçek sonuçlar STATUS.md içindedir.

## 17 Ekim 2026 — Adım 6 (OpenAI Codex)

Kullanıcının FPS/BGM/final zorluğu talebi doğrultusunda AI yardımıyla mevcut GDScript değiştirildi: statik oda/mobilya/AO/güçlendirme/arka plan doku önbellekleri; sabit hava parçacıkları, dört noktalı mermi izi, savaş öncesi hazırlanan ortak mermi siluetleri, daha az boss mikro geometrisi ve toplu telgraf çizgileri. Oyuncu hareketi, 16 oda kimliği, loot/onarım/kartlar ve mevcut SFX korunur.

MusicScore artık çalışma karesinde canlı sentez yapmaz; açılışta özgün Re minör bas/davul/melodi/akor katmanlarından 22.050 Hz 16-bit mono AudioStreamWAV üretir. Ayrı Master/−5 dB/ALWAYS oynatıcı, örnek adedine göre ileri döngü ve mute'a saygılı watchdog eklendi. 120 BPM'de sekiz 4/4 ölçü 16 sn olduğundan, çelişen 12,8 sn yerine bu müzikal uzunluk kullanıldı. Dış müzik, ses örneği, servis, asset veya bağımlılık indirilmedi; önbellekler mevcut prosedürel çizimlerin çalışma anındaki kopyalarıdır.

Yalnız finalde cooldown×1,3, adet round(×0,7), hız×0,8, oyuncu/bina hasarı×0,7 ve uyarı+0,20 sn uygulandı. Bu mekanik katsayılar ölçülür; insanın algıladığı toplam zorluğun tam %30 değiştiği iddia edilmez. Step6Smoke ve PerformanceBench eklendi, eski test beklentileri güncellendi. Gerçek test/FPS/ses çıkışı ölçümleri ve sınırlar STATUS.md'dedir; insan kulakla dinleme veya bütün bilgisayarlarda FPS garantisi iddiası yoktur.


## 17 Ekim 2026 — Adım 7 / tempo rampası, okunabilir koreografiler ve sıyrılma (Claude)

Araç: **Anthropic Claude Code, Claude Opus 5.5** (`claude-opus-5-5`). Süreler (50/5 sn), tempo eğrisi (0,90× / 1,00→1,25× / 1,45×), beş fırtına ve dört deprem deseninin adları ve davranışları, renk kodları, 0,55 sn uyarı + 0,12 sn beyaz parlama ve 18–26 px sıyrılma ödülü kullanıcı tarafından tanımlandı. Uygulama, sayısal ayrıntılar ve testler AI yardımıyla yazıldı.

| Kategori | Durum | Kapsam |
| --- | --- | --- |
| Kod | Kullanıldı | `DisasterWaveManager` (50/5 sn, `tempo_at`, tempo ile çarpılan saldırı saatleri, mermi hızı rampası, desen bazlı oda hasarı, sıyrılma sayacı), `BossPatterns` (5 fırtına + 4 deprem koreografisi), `DisasterBoss` (desen döngüleri, fırtına dalışı ve uzun/kompakt hortum formu, eşya fırlatmanın kaldırılması), `HazardAttack`/`TelegraphSystem` (sabit 0,55 sn, lazer/dolgu uyarıları, beyaz parlama), `HazardProjectile`/`ProjectilePool` (sıyrılma tespiti, 12 gövde dokusu), `Player.graze`, `ApartmentBuilding.set_combat_dim`, `SoundManager` doruk perdesi, yeni `tests/Step7Smoke.gd` ve eski testlerin yeni kurallara uyarlanması. |
| Görsel | Kullanıldı (dolaylı) | Kontur/neon/beyaz çekirdekli küre-bıçak-kaya-diken mermi siluetleri, lazer çizgisi ve oda/kat dolgulu uyarılar, tavan kaya yağmuru, sıyrılma kıvılcım halkası, kompakt hortum çekirdeği ve dalış izleri prosedürel çizim kodudur. Resim üretim servisi veya harici görsel yok. |
| Ses | Kullanıldı (dolaylı) | Yeni `graze` efekti mevcut SoundSynth tarif biçimiyle yazıldı (kısa yükselen ton + bant geçiren gürültü + çıtırtı). Doruğda BGM'nin oynatma hızı 1,05× olur; WAV yeniden üretilmez. Kulakla öznel dinleme yapılmadı. |
| Metin | Kullanıldı | Desen etiketleri, “GÜVENLİ KAT” ve “SIYRILDI! +ENERJİ” yazıları, README/AGENTS/STATUS/CLAUDE_DEVIR ve bu beyan. |

Hazır kaynak: yeni dosya, paket, asset veya eklenti alınmadı. Güvenli kat ruleti, sıyrılma enerjisi, tempo rampası, tavan kaya yağmuru ve diğer boss davranışları kurgusal oyun mekanikleridir; gerçek afet davranışı veya güvenlik tavsiyesi değildir.

## 18 Ekim 2026 — Adım 8 (OpenAI Codex)

Claude'un commit edilmemiş Adım 7 çalışması korunarak kullanıcı tasarımı uygulandı. OpenAI Codex/GPT ailesi, Godot GDScript kodu, özgün prosedürel piksel ikon/efekt çizimi, kısa Türkçe kart metinleri, testler ve çalışma belgelerinde kullanıldı. Tam model sürümüne dair ayrı kanıt olmadığı için sürüm adı uydurulmadı.

- Kod: yalnız deprem fazına cooldown×1,10, hareketli yol hızı×0,90, ölçülü kaçış boşluğu×1,10; dokuz aktif mekanik; gerçek mermi/oyuncu çarpışması, yerel zaman alanı, iniş koruması, uzaktan onarım ve olay sesi bağlantıları.
- Görsel: UpgradeIcon ve UpgradeOverlay, çanta/koruyucu kubbe, iki orbital, zaman kubbesi, zırhlı oda çerçevesi, dron/onarım ışınları, takla/iniş halkaları. Bunlar AI yardımıyla yazılmış prosedürel çizim kodudur; resim üretim servisi veya harici asset yoktur.
- Metin: AFAD/USGS temelli kısa bilgi cümleleri; bağlantı/erişim kapsamı SOURCES.md'de. Kurgusal kalkanın adı Çök-Kapan-Tutun olarak yazıldı. L-demir/karbon manto için bina yıkımını kesin önleme iddiası kullanılmadı. Anlık onarım, şifa, mermi temizleme ve zaman bükme oyun kurgusudur.
- Ses: yeni ses dosyası/beste/sentez tarifi eklenmedi; mevcut block/heal/repair/graze/dash/landing sesleri mevcut sınırlı SoundManager havuzuyla gerçek modül olaylarına bağlandı. Mevcut WAV BGM değişmedi.
- Kontrol: motor içi otomatik davranış testleri ve native renderer PNG incelemesi. Gerçek sonuçlar STATUS.md'dedir; otomatik sürücü, insan eğlence/zorluk veya kulakla dinleme deneyi sayılmaz.

Harici kod/asset/font/ses paketi ya da bağımlılık indirilmedi. Godot/MIT ve önceki kaynak bildirimleri korunur. Eski kartların değişen tasarımına ait testler yeni davranışlara uyarlandı; hareket, 16 oda, 4 faz, uyarı/havuz ve kit regresyonu korunur. Bu görevde commit/push yapılmadı.

## 18 Ekim 2026 — Adım 9 (OpenAI Codex)

Kullanıcının Giray Eskalen/ODTÜ diploma, TV uyarısı, kurtarma kıyafetini kuşanma, dört bossa özel yıkım ve güneşli zafer senaryosu AI yardımıyla GDScript olarak uygulandı. Araç: OpenAI Codex/GPT ailesi. Yeni CutsceneDirector, OpeningStoryArt, FinaleStoryArt, Step9Smoke; mevcut MainGame/faz/ses/loot kilit bağlantıları ve belgeler bu kapsamdadır. Önceden commit edilmemiş Adım 7–8 çalışması korunmuştur.

- Görseller: özgün prosedürel salon, ahşap/altın diploma çerçevesi, dekoratif mühür/imza, TV, dolap kapakları, ev kıyafeti, mevcut kurtarma karakterinin animasyonu; hortum/şimşek, kaya yumrukları, tsunami köpükleri, dört parçalı kat çöküşü, parçacıklar, kalkan, güneş/ışın/ağaç/kuş/çiçek. Mevcut oda çiziminin tek kare kopyası yalnız çalışma belleğinde çöküş animasyonuna dönüşür. Resim üretim servisi, harici sprite veya resmî ODTÜ diploma/logo görseli kullanılmadı.
- Ses: üç yeni özgün SoundSynth tarifi (alarm, kuşanma, Re majör umut melodisi); mevcut WAV BGM, bus/havuz/mute/seviye sistemi korunur. Hazır beste veya ses örneği alınmadı. Objektif PCM testleri insan kulakla dinleme sayılmaz.
- Metin: diploma/isim/başlıklar kullanıcının isteğidir. Üç günlük haber ve Kategori 6 ulti kurgu olarak etiketlendi; gerçek tahmin veya yapı güvenliği garantisi değildir. USGS/NHC kontrol kapsamı SOURCES.md'dedir. Oyun bitişindeki sıfır hasar kalkanı yalnız sinematik bir oyun sonucudur.
- Test: mevcut regresyon paketleri hikâyeyi açıkça kapatarak kendi mekaniklerini sınar; yeni Step9Smoke normal hikâyeli açılışı ve sonları ayrıca doğrular. Sonuç, native PNG ve ölçüm sınırları STATUS.md'dedir.

Harici asset, font, ses dosyası, kod paketi veya yeni bağımlılık eklenmedi. Bu görevde commit/push yapılmadı.

## 18 Ekim 2026 — video intro ve kesin sinematik temizliği (OpenAI Codex)

Son kullanıcı isteğiyle önceki Adım 9'un diploma/salon/kuşanma/yıkılış/gündüz çizimleri, CutsceneDirector ve eski BossCinematic kaldırıldı. Boss giriş/çıkış fazları, fusion/retreat görsel yolları, I/V/K ön izlemeleri ve dört kullanılmayan sinematik ses tarifi silindi. Normal boss anatomisi/saldırı wind-up/vuruşları, 9 aktif mekanik, 2x W, oda/loot/uyarı/havuz, 50/5 sn ve özgün WAV BGM korunur.

AI kullanımı: OpenAI Codex; IntroOverlay GDScript/TSCN, VideoStreamPlayer bağlantıları, minimalist Türkçe isim kartı/bülten/fade, faz/ses sadeleştirmesi, VideoIntroSmoke ve değişen sinematik beklentilerinin yeni testleri, belgeler. Resim/video üretim servisi kullanılmadı. Gerçek hikâye videosu eklenmedi; gerçek OGV çözme ve bitiş deneyi için yalnız %TEMP% altında FFmpeg testsrc ile özgün test deseni üretildi. Test videosu ve FFmpeg aracı projeye/oyuna eklenmedi.

Yeni hazır kaynak: **Press Start 2P Regular**, Copyright 2012 The Press Start 2P Project Authors (cody@zone38.net), SIL Open Font License 1.1; Google Fonts resmî deposundan orijinal TTF ve OFL.txt alındı. Font değiştirilmedi; gerçek Türkçe karakter desteği test edildi. Fontun isim/lisans dosyaları assets/fonts içinde tutulur ve dağıtımda korunmalıdır. Bağlantılar SOURCES.md'dedir. Dış müzik/kod/oyun sprite paketi alınmadı. WebM'in standart Godot4'te desteklenmediği açıkça belgelendi; ek çözücü yoksa güvenli metin girişi kullanılır.

Nihai motor/test/görüntü sonuçları STATUS.md'nin en üstündedir. Bu görevde commit/push yapılmadı.
