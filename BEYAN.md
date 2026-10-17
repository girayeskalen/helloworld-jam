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
