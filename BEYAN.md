# AFET KUŞATMASI — AI ve hazır kaynak kaydı

17 Ekim 2026 · Yeni Godot projesi / Adım 1 + Adım 2 + Adım 2.5 + Adım 3 + Adım 2.7 (görsel/atmosfer) + Adım 3-B (loot/oda hasarı).

Bu kayıt yalnızca aktif yeni proje içindir. Önceki ARTÇI beyanları Git geçmişindeki `2647179:BEYAN.md` ve `2647179:SOURCES.md` içinde korunur; proje değişimi önceki AI kullanımını yok sayma gerekçesi değildir. Son teslimde gerçek toplam kapsam gözden geçirilir.

## Güncel ek kayıt — Adım 14 teslim düzeltmeleri (18 Ekim 2026)

Tasarım kullanıcı üzerinden Claude tarafından sağlandı; uygulama ve doğrulama aracı **OpenAI Codex**. Önceki ses/müzik ve kaynak kayıtları korunur.

| Kategori | AI kullanımı | Hazır kaynak kullanımı |
| --- | --- | --- |
| Görsel | Kullanıldı: GameHUD görev bandı/mini harita ve WorldLabels yön, hale, braket, ünlem gliflerinin prosedürel çizim kodu. | Yeni görsel/font kullanılmadı. |
| Ses | Kullanıldı: mevcut iyileşme ve UI tık olaylarının bağlanması; yeni kayıt/sentez bestesi üretilmedi. | Önceki Ovani efektleri ve CC0 müzikler build'de korunur; yeni ses kaynağı yok. |
| Kod | Kullanıldı: faz sonu iyileşme, ölümcül mermi referansı, TutorialGuide/Preparedness rehber durumu, pause çizim temizliği, Step14 ve eski beklenti güncellemeleri, export ön ayarları. | Godot 4.7.2 resmî Windows/Linux export şablonları ve mevcut Godot API'leri; yeni oyun bağımlılığı yok. |
| Metin | Kullanıldı: README/AGENTS/STATUS/BEYAN ve OYNA_BENI teslim rehberi. Mevcut görev cümleleri korundu. | Godot'un resmî export belgelerinden teknik bilgi. |
| Diğer | Kullanıldı: test/PNG incelemesi, paketleme ve açılış doğrulaması. | Python standart kütüphanesi, resmî Godot 4.3/4.7.2 geliştirme araçları. |

Export teknik kaynakları: [Windows](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html), [Linux](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_linux.html). Gerçek test/build sonuçları STATUS'tadır; insan oynanış ve kulak değerlendirmesi otomatik kontrol diye sunulmaz. Commit/push yapılmadı.

## Güncel ek kayıt — Adım 13 sürekli atmosfer müziği (18 Ekim 2026)

Parça seçimi, seviyeler, döngü noktaları ve durum tasarımı kullanıcının aktardığı **Claude** kararlarıdır. Uygulama/test/belgeleme aracı **OpenAI Codex**. Hazır bestelerin üreticileri aşağıdadır; AI tarafından bestelenmiş gibi gösterilmez.

| Kategori | AI kullanımı | Hazır kaynak kullanımı |
| --- | --- | --- |
| Görsel | Bu görevde kullanılmadı; mevcut sanat korundu. | Yeni kaynak kullanılmadı. |
| Ses | Kullanıldı: mevcut ses sistemine bağlama, A/B geçiş, perde/seviye/miks ve önizleme kodu. Yeni hazır müziklerin ses içeriği AI ile üretilmedi/değiştirilmedi. | Kullanıldı: SkyleTheFrench — Blackout / Dark Place; SRG774 — Sector / Urgent / Victory (Dark Sci-Fi Audio Pack), beşi de CC0. Önceki Ovani sesleri korundu. |
| Kod | Kullanıldı: `MusicDirector.gd`, SoundManager bağlantısı, AudioPreview genişletmesi, `Step13Smoke.gd` ve ilgili eski test uyarlamaları. | Kullanıldı: Godot'un yerleşik MP3/Vorbis, AudioStreamPlayer ve ses bus API'leri. Yeni bağımlılık yok. |
| Metin | Kullanıldı: README/AGENTS/STATUS/SOURCES/BEYAN ve ses lisansı kapsam ayrımı. Yeni oyun içi metin yok. | Kullanıldı: OpenGameArt üretici/lisans bilgileri. |
| Diğer | Kullanıldı: hash karşılaştırması, test tasarımı, mixer ölçümleri ve doğrulama belgeleri. | Kullanıldı: resmî Godot 4.3 / 4.7.2 ve Python standart kütüphanesi geliştirme araçları. |

[Blackout](https://opengameart.org/content/blackout), [Dark Place](https://opengameart.org/node/159643), [Dark Sci-Fi Audio Pack](https://opengameart.org/content/dark-sci-fi-audio-pack) kaynaklarında CC0 doğrulandı. Dosyalar yalnız yeniden adlandırıldı; kaynak ve hedef SHA-256 değerleri aynı. Tam yollar/hash'ler ve gerçek kontroller STATUS/SOURCES içindedir. CC0 müzikler ile Ovani efektlerinin farklı lisansları korunur. İnsan kulağıyla dinleme/miks beğenisi ekibin yapacağı kontroldür; otomatik ölçüm bunun yerine geçmez. Commit/push yapılmadı.

## Güncel ek kayıt — Adım 12 ses revizyonu (18 Ekim 2026)

Tasarım, kullanıcının aktardığı Claude kararlarıdır. Uygulama aracı **OpenAI Codex**. Aşağıdaki eski "ses kullanılmadı/harici ses yok" kayıtları kendi tarihli adımlarını anlatır; bu ekle birlikte güncel toplam kapsam değişmiştir.

| Kategori | AI kullanımı | Hazır kaynak kullanımı |
| --- | --- | --- |
| Görsel | Bu görevde kullanılmadı; mevcut AI destekli sanat korundu. | Kullanılmadı; yeni görsel/font yok. |
| Ses | Kullanıldı: beş katmanlı özgün MusicScore bestesi, uyarı bipleri, pentatonik geri bildirim, kayıtların işlenmesi ve miks kodu AI desteğiyle yazıldı. | **Kullanıldı: Ovani Sound SFX Starter Pack Vol. 1 (royalty-free)**. Kullanıcının sağladığı gerçek kayıtlar;48 işlenmiş türev. Kayıtların asıl üreticisi Ovani'dir. |
| Kod | Kullanıldı: `tools/audio/build_sfx.py`, `scripts/audio/`, NightWeather/Tremor sinyalleri, MainGame önizleme, menü ses bağlantıları, Step12 ve ses regresyonları. | Kullanıldı: mevcut Godot API'leri; üretimde Python standart kütüphanesi, yeni oyun bağımlılığı yok. |
| Metin | Kullanıldı: README/AGENTS/STATUS/SOURCES/BEYAN teknik ve kaynak kayıtları. Yeni oyun içi metin yok. | Kullanıldı: Ovani lisans koşulları ve Godot resmî API belgelerinden teknik bilgi. |
| Diğer | Kullanıldı: otomatik ölçümler, test tasarımı, gerçek renderer kayıt incelemesi. İnsan kulağıyla dinleme AI tarafından yapılmış gibi raporlanmaz. | Kullanıldı: resmî Godot4.3 ve4.7.2 doğrulama araçları. |

Ovani [lisansı](https://ovanisound.com/policies/terms-of-service) ve kullanılan dosyalar [manifest](assets/audio/manifest.json)/[SOURCES](SOURCES.md) içindedir. Ham ZIP/WAV repo içinde yoktur. İşlenmiş sesler de aynı lisansa tabidir; ayrı public WAV dağıtımına izin verildiği varsayılmaz. AI eğitimi veya modele ses yüklemesi yapılmadı; Python betiği yerel sinyal işlemedir. Commit/push yapılmadı.

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


## 18 Ekim 2026 — Ana menü, dört saniye hazırlık ve saha ikmal arayüzü

Araç: **OpenAI Codex (GPT-6 tabanlı kodlama ajanı)**. Kullanıcı tasarım kararlarını bu görevde Codex'e bıraktı; ana menü, kasvetli atmosfer, yaklaşık dört saniye hazırlık ve daha tematik kart seçimi istedi. Önceki Adım 8 geri dönüşü esas alındı; geri dönüş ayrı committe, eski web klasöründeki çalışmalar ise kendi çalışma ağacında korunur.

- Görsel — Kullanıldı: AI destekli GDScript çizimiyle mevcut apartman/gece görsellerinin menü kompozisyonu, yağmurlu pencere izi, boyalı metal/kağıt tonları, sınırlı doku/aşınma, dosya köşeleri, rivet/çizim ızgarası ve kart giriş hareketi. `scripts/ui/FrontEnd.gd`, `FieldUI.gd`, `UpgradeDossier.gd`, `UpgradeOverlay.gd`. Raster görsel üretim servisi veya başka oyundan görsel alınmadı.
- Ses — Kullanıldı (önceki katkının yeniden kullanımı): mevcut AI destekli prosedürel müzik/ortam/UI sesleri menüde de çalışır; yeni beste, ses kaydı veya sentez tarifi eklenmedi. Ana ses ve sessiz ayarı mevcut SoundManager'a bağlandı.
- Kod — Kullanıldı: Launch sahnesi, menü/simülasyon/girdi ayrımı, oynatma/ayar/çıkış, pause'tan menüye dönüş, ConfigFile ile tercih kalıcılığı ve ses mikserini boşaltarak temiz çıkış; ilk ve dalga arası hazırlık 4 sn. MainGame, DisasterWaveManager, PauseMenu, proje girişi ve ilgili testler güncellendi.
- Metin — Kullanıldı: özgün kısa Türkçe menü, kart ekranı başlıkları, README/STATUS/AGENTS ve bu kayıt. Dokuz kartın mevcut farkındalık notları ve mekanikleri korunur.
- Diğer — Kullanıldı: tasarım kararları, otomatik akış/girdi testleri ve gerçek renderer görüntü incelemesi. Testte kullanıcı ayarları yerine ayrı geçici ConfigFile kullanılır.

Hazır kaynaklar: yeni görsel/ses/font/metin paketi veya bağımlılık kullanılmadı; mevcut Godot/MIT ve motor sistem fontu kullanılır. AI görsel/metin/kod katkısı bu kayıtta açıkça beyan edilir. Gerçek kontroller ve sınırlamalar STATUS.md'dedir; otomatik testler insan estetik beğenisi veya eğlence/zorluk onayı sayılmaz.


## 18 Ekim 2026 — Geri dönüş ve menü Git teslimi

Kullanıcının açık push isteği üzerine OpenAI Codex, Adım 8 geri dönüşünü ve sonraki ana menü/saha arayüzü çalışmasını ayrı commitler olarak kaydetti. STATUS ve devir belgelerindeki güncel giriş/süre/teslim bilgileri düzenlendi. Bu aşamada yeni oyun kodu, görsel veya ses üretilmedi; önceki 18 paket / 1.297 kontrol ve native sonuçlarının kayıtları ile değişikliklerin aynı olduğu kontrol edildi. Eski web worktree'sindeki 22 yerel değişiklik teslimin dışındadır. Yeni araç/bağımlılık eklenmedi; önceki Git/GitHub CLI geliştirme aracı beyanı geçerlidir.

## 18 Ekim 2026 — Minimal arayüz ve özgün piksel yazı tipi (Claude)

Araç: **Anthropic Claude (Claude Code, Opus 5.5)**. Kullanıcı bütün tasarım kararlarını Claude'a bıraktı ve arayüzün "AI yazmış" görünmesinden, her yerdeki yazılardan şikâyet ederek olabildiğince minimal, oynanışa odaklı bir ekran istedi.

- Görsel — Kullanıldı: AI destekli GDScript çizimiyle 10 dilimli can barı, enerji çizgisi, 4×4 oda haritası, sayı rozetli ekipman ikonları, ince boss çizgisi, çarpılı hoparlör, onarım elması, E tuş başlığı, güvenli kat çerçevesi, kutusuz menü/duraklatma/kart düzeni ve odak karesi. `scripts/ui/GameHUD.gd`, `WorldLabels.gd`, `PauseMenu.gd`, `FrontEnd.gd`, `UpgradeOverlay.gd`, `UpgradeDossier.gd`, `BossCinematic.gd`, `MenuItem.gd`, `UIStyle.gd`. `FieldUI.gd` kaldırıldı; oyuncu üstündeki dünya içi can/enerji barı silindi.
- Yazı tipi — Kullanıldı (AI üretimi): `scripts/ui/PixelFont.gd` içindeki 5×7 büyük harf, Türkçe aksanlı harf (Ç Ğ İ Ö Ş Ü), rakam ve noktalama glifleri bu görevde satır satır yazıldı; çalışma anında Godot `FontFile` olarak üretilir. Harici font dosyası indirilmedi veya repoya eklenmedi; denenen Press Start 2P dosyaları (Türkçe büyük harfleri küçük harf yüksekliğinde çizdiği için) silindi ve kullanılmıyor.
- Metin — Kullanıldı: kısa Türkçe menü/duraklatma/sonuç yazıları ve dokuz kartın yeni kısa adları ile en çok yedi kelimelik etki satırları. Kart yüzündeki AFAD/USGS kaynaklı bilgi notları kaldırıldı; kartlarda gerçek hayat güvenlik tavsiyesi veya yapı garantisi yoktur.
- Kod — Kullanıldı: HUD/dünya işareti/menü yeniden yazımı, `mute_drawn` ve `room_color` gibi test kancaları, yeni `tests/MinimalUISmoke.gd`, eski metin beklentilerinin yeni davranışa uyarlanması (Step2/5/7/8/27/3Loot/48/49).
- Ses — Kullanılmadı: yeni ses yok; mevcut seslerin bağlantısı değişmedi.
- Diğer — Kullanıldı: tasarım kararları, Godot 4.7.2/4.3 otomatik testleri ve gerçek renderer ile 1920×1080 PNG incelemesi.

Hazır kaynaklar: yeni görsel/ses/font/metin paketi veya bağımlılık kullanılmadı. Godot motoru ve önceki kaynak bildirimleri geçerlidir. Gerçek test sonuçları ve denenmeyenler STATUS.md'dedir; otomatik testler insan beğenisi yerine geçmez.

## 18 Ekim 2026 — Afete hazırlık güncellemesi: Hazırlık, sarsıntı, öğretici ve karne (Claude)

Araç: **Anthropic Claude (Claude Code, Opus 5.5)**. Kullanıcı bütün tasarım kararlarını Claude'a bıraktı ve oyunun game jam teması "afete hazırlık ve farkındalık"tan uzaklaştığını, jüri ölçütlerine (oynanabilirlik, temayla ilişki, yaratıcılık, görsel/işitsel, teknik) göre uyarlanmasını ve ilk bossun öğretici olmasını istedi.

- Tasarım — Kullanıldı (AI kararı): deprem-önce kampanya; Hazırlık görevleri (eşya sabitleme, gaz, çanta, kepenk, sigorta) ve oyundaki karşılıkları; sarsıntı ve Çök-Kapan-Tutun mekaniği; yazısız öğretici; karne. Sayılar oyun dengesidir.
- Kod — Kullanıldı: `scripts/prep/Preparedness.gd`, `TutorialGuide.gd`, `Debrief.gd`, `scripts/combat/TremorSystem.gd`; DisasterWaveManager (sıra, süreler, desen beklemesi), Player (C ile örtünme, sallantıda yavaşlama/kat kilidi), BuildingProp/RoomDiorama (sabitlenmiş/devrilmiş eşya), TelegraphSystem (sarsıntı uyarısı), ProjectilePool, MainGame, HUD/WorldLabels/UpgradeOverlay/FrontEnd/PauseMenu; yeni `tests/Step9Smoke.gd` ve eski testlerin yeni sıra/süreye uyarlanması.
- Görsel — Kullanıldı (AI destekli GDScript çizimi): görev işaretleri, E iş halkası, tuş başlıkları ve oklar, sarsıntı uyarı çerçevesi/tavan tozu/ekran kenarı, devrilen eşya animasyonu, kapatılmış vana/pano etiketi, çömelmiş oyuncu pozu, cam kırıkları ve gaz sisi, karne işaretleri.
- Ses — Kullanıldı (AI tarifi, prosedürel sentez): `tremor`, `topple`, `secure`, `cover` tarifleri mevcut SoundSynth ile üretilir; harici ses dosyası yok.
- Metin — Kullanıldı: kısa Türkçe karne satırları ve öneriler, menü alt başlığı, kart adı "Sakin Kal", README/AGENTS/STATUS/BEYAN/SOURCES. Karne önerileri AFAD sayfalarının arama sonuçlarındaki kısa özetlerine dayanır (SOURCES.md); gerçek hayatta güvenlik garantisi veya mühendislik talimatı olarak sunulmaz.
- Diğer — Kullanıldı: Godot 4.7.2/4.3 otomatik testleri ve gerçek renderer ile 1920×1080 PNG incelemesi.

Hazır kaynaklar: yeni görsel/ses/font paketi, eklenti veya bağımlılık kullanılmadı. AFAD sayfaları doğrudan açılamadı (HTTP 500); bilgiler resmî alan adındaki arama sonucu özetlerinden alındı ve SOURCES.md'de bu sınırlamayla kayıtlıdır.

## 18 Ekim 2026 — Cila: akış, görev satırı ve onarım öğreticisi (Claude)

Araç: **Anthropic Claude (Claude Code, Opus 5.5)**. Kullanıcının oyun testinden sonraki geri bildirimiyle (ne yapıldığı anlaşılmıyor, onarım uyarısı zor görülüyor ve öğretilmiyor, bölümler yavaş; loot 6 sn ve %20 daha sık) tasarım kararları Claude'a bırakıldı.

- Kod — Kullanıldı: görev satırı (`TutorialGuide` objective, `Preparedness.objective`, `GameHUD._draw_objective`), onarım rehberi ve oda çerçevesi/halkası (`WorldLabels`), boş ara Hazırlık kısaltması, 40 sn savaş ve tempo/sarsıntı/öğretici süreleri, loot süresi/sıklığı; Step9Smoke `_polish` ve eski testlerin yeni sürelere uyarlanması.
- Görsel — Kullanıldı (AI destekli GDScript çizimi): üst görev bandı, hasarlı oda çerçevesi, büyük uyarı elması ve halkalar, kit üstü ok.
- Ses — Kullanıldı (AI tarifi, prosedürel): `alarm` (oda hasar uyarısı). Harici ses dosyası yok.
- Metin — Kullanıldı: kısa Türkçe görev satırları ("Gardırobu sabitle: devrilmesin" vb.).

Hazır kaynak, eklenti veya bağımlılık eklenmedi.

## 18 Ekim 2026 — Bölüm kontrol noktası ve bölüm seçimi (OpenAI Codex)

Araç: **OpenAI Codex**. Tasarım kullanıcı tarafından aktarılan Claude kararlarıdır. Kod katkısı: PhaseCheckpoint değer kopyaları, yenilgide aynı fazın Hazırlık evresinden tekrar, kart/kit/oda/eşya/görev/öğretici durumunun geri yüklenmesi, tam sıfırlamadan ayrım; CAMPAIGN sıralı 1–4, ana menü bölüm öğeleri, Hazırlık satırı ve finalin AFET adı. Metin/görsel katkısı mevcut PixelFont/UIStyle ile kısa bölüm ve tekrar ipuçlarıdır. Step10Smoke ve etkilenen regresyon beklentileri, iki motorla doğrulama ve belgeler bu kapsamda AI desteğiyle hazırlanmıştır. Yeni harici görsel/font/ses/bağımlılık veya afet güvenliği iddiası eklenmedi. Test sonuçları STATUS.md dosyasındadır; commit/push yapılmadı.

## 18 Ekim 2026 — Başarı anları ve oyun hissi (OpenAI Codex)

Araç: **OpenAI Codex**. Kullanıcının aktardığı Claude kararları ve sayıları uygulandı. Kod/görsel katkı: FeelFX sınırlı dünya efektleri, görev bandı tiki, tek oda durum geçişinden yeşil onarım çerçevesi, doğru Çök-Kapan-Tutun halkası, can izi/kenar vinyeti/titreme/iyileşme, loot ikon uçuşu/slot hareketi ve KarneReveal kademeli satırları. Ses/müzik katkısı: SoundRecipes safe/karne_ok/karne_miss tarifleri ve MusicScore başlangıçta pişirilen senkron Re minör ek PCM katmanı; harici ses örneği yok. Normal girişte istekteki kısa vuruş donması ve bütün iptal noktaları eklendi. Metin katkısı yalnız belgeler; oyun içi metinler ve oynanış sayıları korunur. Step11Smoke, Step5 olay/kalite kontrolleri, mevcut regresyonlar ve native görüntü incelemesi AI desteğiyle hazırlanmıştır. Yeni harici görsel/font/ses/eklenti/bağımlılık veya afet güvenliği iddiası eklenmedi. Gerçek doğrulama ve sınırlar STATUS.md dosyasındadır. Commit/push yapılmadı.
