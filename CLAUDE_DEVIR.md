# Claude için devir — AFET KUŞATMASI / Adım 4.8

> **18 Ekim 2026 — Adım 8 (Codex) günceldir.** Eski19 kart yerine9 aktif mekanik ve kısa ikonlu A/B/B seçim; yalnız deprem cooldown×1,1/hız×0,9/boşluk×1,1. 50/5sn, dört faz, 2xW, gece cache ve BGM korunur. `STATUS.md` en üstte gerçek sonuç/kanıt ve sınırları içerir; `tests/Step8Smoke.gd` yeni davranışları sınar. Claude Adım7 değişiklikleriyle birlikte çalışma ağacındadır; bu görevde commit/push yapılmadı. Eski kart/12sn drone/tümkat iniş temizliği/global bullet-time maddeleri tarihçedir.

17 Ekim 2026. Kullanıcı sonraki geliştirmeyi Claude ile sürdürecek. Bu dosya, beş dalgalı maraton ve Adım 4.8 değişiklikleriyle aynı teslim commitindedir. Yeni görev henüz verilmedi; aşağıdaki bekleyen işler kendiliğinden kapsam sayılmaz.

## Adım 7 güncellemesi (Claude, 17 Ekim 2026) — en güncel

Önce [STATUS.md](STATUS.md) en üstteki Adım 7 bölümünü ve [AGENTS.md](AGENTS.md) sonundaki Adım 7 maddelerini oku. Özet:

- **Süreler:** faz 50 sn (`siege_duration`), kart sonrası inşaat 5 sn (`build_duration`), ilk hazırlık 8 sn. Dört faz, BossCinematic, alt boss barı, BGM ve Adım 6 önbellekleri korunur.
- **Tempo:** `DisasterWaveManager.tempo_at(elapsed)`; boss saatleri ×tempo, final yarım pay; `bullet_tempo()` mermi hızını uç nokta sabit kalacak şekilde artırır; `is_climax()` (35 sn+) BGM'yi 1,05× yapar.
- **Desenler:** fırtına ve deprem `BossPatterns` sonundaki Adım 7 fonksiyonlarını kullanır (`pinwheel`, `safe_floor_roulette`, `sine_tunnel`, `scissor`, `cyclone_rings`, `checker_crush`, `fault_wave`, `tectonic_rings`, `boulder_stampede`). Eski yardımcılar (`vortex`, `crossfire`, `corridor`, `fan`, `furniture`, `room_objects` …) yalnız eski doğrudan testler için durur, bosslar çağırmaz. Yeni Kind `ROCKFALL` (oda alanı), yeni Pattern'ler `PINWHEEL … BOULDER_STAMPEDE`.
- **Görünürlük:** `HazardProjectile` kontur/neon/beyaz çekirdek ve 12 gövde dokusu; `TelegraphSystem` sabit 0,55 sn, lazer/dolgu, `is_flashing()` son 0,12 sn; `ApartmentBuilding.set_combat_dim`.
- **Sıyrılma:** `ProjectilePool.grazed` → `DisasterWaveManager._on_grazed` → `Player.graze` (+25) → `grazed` sinyali (CombatFeedback, WorldLabels, SoundManager `graze`).
- **Testler:** yeni `tests/Step7Smoke.gd`; eski paketler 50/5 sn ve yeni desenlere uyarlandı. Toplam **16 paket**.

## Adım 4.9 güncellemesi (Claude, 17 Ekim 2026)

Bu dosyanın aşağısı Adım 4.8 devridir; şu kurallar artık değişti (ayrıntı [STATUS.md](STATUS.md) ve [README.md](README.md)):

- **6 dalga:** yangından sonra kart + 7 sn inşaat ve **Dalga 6 — Kataklizma Titanı** (`Mode.CATACLYSM`, `DisasterBoss.Kind.CATACLYSM`, sahnede `CataclysmBoss`). Final girişi **2,0 sn** birleşme (`FINAL_INTRO_DURATION`, %55'te `fusion_burst`). Zafer altıncı çıkıştadır; kampanyada 5 kart seçimi olur.
- **Her savaş 60 sn** (`siege_duration`); ilk hazırlık 8 sn, inşaat 7 sn değişmedi.
- **1–6 doğrudan boss kısayolu** (F9 gerekmez; kart modalında 1/2/3 yine yalnız kart seçer). `U` hâlâ F9 ister.
- **Minimal HUD:** başlık/sağ kutu/alt kontrol tablosu kaldırıldı; Tab/H basılıyken yardım. E istemi oyuncu üstünde kısa metin.
- Final yetenekleri `scripts/combat/CataclysmPatterns.gd`, çizim `scripts/bosses/CataclysmArt.gd`. Mühür uyarısı tam **0,8 sn** (`HazardAttack.SEAL_WARNING`). Yeni tür `STEAM_COLUMN`; yeni desenler `STEAM_TSUNAMI … CATACLYSM_NOVA`.
- Yeni test `tests/Step49Smoke.gd`.
- **Adım 5:** `ESC`/`P` duraklatma paneli (`scripts/ui/PauseMenu.gd`, `PROCESS_MODE_ALWAYS`), `M` sessiz, `-`/`+` seviye. Ses dosyası yok: `scripts/audio/SoundRecipes.gd` (51 tarif) → `SoundSynth.gd` (sentez) → `SoundManager.gd` (olaylar, miks, müzik nabzı). Yeni sinyaller: `Player.jumped/landed`, `LootSystem.landed`, `DisasterBoss.cued`, `SiegeMechanics.blocked`. Yeni test `tests/Step5Smoke.gd`; artık **13 paket** çalıştırılır.

## Önce doğru projeyi aç

- Repo: <https://github.com/girayeskalen/helloworld-jam>
- Aktif dal: `feat/disaster-siege-step1`. Bu teslimin tabanı `3c6ae04`; güncel commit için `git log -1 --oneline` kullan.
- Bu bilgisayarda Godot çalışma ağacı: `/home/asd/Desktop/helloworld/helloworld-jam-godot`.
- Ayrı `/home/asd/Desktop/helloworld/helloworld-jam` klasörü eski TypeScript/ARTÇI `main` çalışma ağacıdır ve kullanıcının korunacak yerel değişikliklerini içerir. Oradaki npm/Playwright dosyalarını bu oyunun testleriyle karıştırma; orada reset/clean/stash/checkout yapma.
- Önce [AGENTS.md](AGENTS.md), [STATUS.md](STATUS.md), [README.md](README.md), [BEYAN.md](BEYAN.md), [SOURCES.md](SOURCES.md) ve `git status` oku. Aktif teknoloji **Godot 4.3+ / GDScript / Compatibility**. Eski ARTÇI tasarımını veya Matter.js kararını bu oyuna uygulama.
- Godot'tan `project.godot` aç, F5 ile çalıştır. Bu Linux oturumundaki motor `/tmp/siege-tools/Godot_v4.3-stable_linux.x86_64`; `/tmp` kalıcı kurulum değildir. Başka bilgisayarda kendi standart Godot yolunu kullan; .NET gerekmez.

Başka temiz bilgisayarda dalı almak için:

```sh
git clone --branch feat/disaster-siege-step1 https://github.com/girayeskalen/helloworld-jam.git
cd helloworld-jam
git status
```

Depo zaten varsa önce `git status` ve `git worktree list` ile doğru çalışma ağacını bul. Temiz ve doğru dalda `git pull --ff-only` kullan. Bu bilgisayarda dal zaten `helloworld-jam-godot` worktree'sinde; eski `main` klasöründen aynı dalı zorla açmaya çalışma.

Bu Linux kurulumunda commit kimliği ve GitHub oturumu başlangıçta yoktu. Kullanıcının tarayıcı girişinden sonra `404f-st` hesabının yazma yetkisi doğrulandı; teslim commit kimliği bu hesaba ve GitHub noreply adresine eşlendi. Git kimliği ve GitHub credential helper yalnız bu repo için ayarlandı; global Git ayarı değiştirilmedi. Resmî GitHub CLI v2.102.0 `/home/asd/.local/bin/gh` altında; kimlik bilgileri repoya yazılmadı. Başka bilgisayarda kendi Git kimliğini ve `gh auth status` çıktısını doğrula.

## Tamamlanan sürüm

- **5 dalga:** Fırtına → Deprem → Çifte Felaket → Sel Hidrası → Yangın Titanı. Her savaş 90 sn; giriş 1,2 sn, çıkış 1 sn. İlk hazırlık 8 sn, ilk dört dalga arası kart seçimi + **tam 7 sn inşaat**. Kart seçimi sayacı durdurur; F hazırlığı erken bitirir. Beşinci dalgadan sonra zafer; altıncı dalga yok.
- **16 odalı karanlık diorama:** Dünya 960×540'ta çizilip nearest ile 1920×1080'e büyür; HUD/etiketler ayrı keskin ekran katmanındadır. Yağmur, kül, şimşek, oda/baret ışıkları ve eski oda detayları korunur.
- **Yeni kurtarma uzmanı:** Lacivert/antrasit üç tonlu mont, reflektör, gözlük/vizörlü baret, fener, çanta/matara/ilk yardım işareti, alet kemeri, eldiven/bot. Çanta yay/sönüm ile, mont etekleri ve eklemler mevcut hareket pozu ile çalışır; hitbox/normal hareket korunur.
- **4 detaylı boss:** Fırtınada bulut katmanları, elektrik gözü/çatallı damarlar, rüzgâr kenarları ve kiremit; golemde üç yüzeyli bazalt, fay/çakıl/rebar ve ayrı çene; hidrada turkuaz akıntı, beyaz köpük, gözler ve varil; titanda kömür plakası, magma çekirdeği, alev örtüsü/boynuz ve sarmal korlar. Golemin ara hazırlık dirseği ve selin sol görsel dayanağı çerçeveye alındı; saldırı yolu bundan etkilenmez.
- **Sel/yangın paternleri:** Üç gerçek sınır sekmesi/altı ayrı uyarılı su parçası, su duvarları, zemin taşkını, girdap çekimi, enkaz; meteor/napalm, çift sarmal, beş adet sekiz yönlü kor çekirdeği, termal çekim + alev duvarı. Yangının son 10 sn'sinde saldırı aralığı %25 hızlanır. Dondurulmuş uyarı yolları ve 128 node havuzu korunur.

### Dört ekipman

| Tür | Gerçek oyun davranışı |
| --- | --- |
| `COLUMN_KIT` / ONARIM KİTİ | E ile +45 oda HP (epoksi kartıyla +85), STEEL + FRP çizimi; deprem/yapısal oda hasarı %50 azalır. |
| `BARRICADE_KIT` / SABİTLEME KİTİ | Tek E ile ANCHOR + SHUTTER; avize dahil eşya saldırılarını durdurur; fırtına/sel/yangın oyuncu ve oda mermi hasarı %50 azalır. |
| `EMERGENCY_BAG` | Anında +25 can ve tam takla enerjisi; stoklanmaz. |
| `SAFETY_KIT` | Loot'un **ilk düştüğü odaya** anında kurulur; drone/mıknatıs uzaktan toplasa da bu oda korunur. Mevcut/uyarıdaki/gelecek zemin suyu-alevini o odadan çıkarır, ısıyı temizler, gaz/elektrik kaynaklı ikincil oda hasarını durdurur. Komşu odalar, girdap ve havadaki mermiler etkilenmez. Tamamen etkisiz kalan bekleyen uyarı kaldırılır. HUD benzersiz korunan oda sayar. |

Loot yalnız savaşta 5,5–6,5 sn arayla, oyuncunun olmadığı erişilebilir başka odaya düşer; aynı anda max3. Ömür **yere indikten sonra 4 sn**; düşüş 0,45 sn, son1,5 sn blink. Drone 7 sn; eski mıknatıs 8 sn; birlikte 8 sn. Kolon kiti yok/hasar var ise her ikinci rastgele drop kolon kitidir. İki stok (kolon/barikat), iki anlık ekipman vardır; eski cement/steel/anchor/shutter envanter adlarını geri getirme.

Kuşatmada E yalnız DAMAGED/CRITICAL uyarılı odada çalışır. Sağlam odada sessiz kalır. Hazırlıkta eksik HP onarılabilir veya eksik destek kurulabilir; tekrar satın alma yok. Yıkık oda yeniden kurulamaz. Aynı anda max3 gerçek hasarlı/kritik oda, yeni uyarıda10 sn koruma ve sonra1,3 HP/sn bütçe ortak hasar kapısından geçer.

### Kartlar: 19 tanım, her seçimde 1 + 2

Eski11 kart korunup drone revize edildi; beş hazırlık ve üç yeni aksiyon eklendi. Solda seçilmemiş **hazırlık**, orta/sağda farklı iki seçilmemiş **aksiyon** garantilidir. Normal kampanyada4 seçim olduğundan5 hazırlık kartı tükenmez. Her kart etki + tek kısa farkındalık notu taşır.

- Hazırlık: maxcan+30/tam iyileşme/dalga+15; rastgele4 oda sabitleme/eşya hasarı−%40; bütün odalarda maxHP+30/hasarlıya+35/deprem-yapısal−%35; utility ve zemin alevi hasarı−%45; sel yavaşlatması0/panjur fırtına-sel bloklaması%50→70 (yangın50 kalır).
- Yeni/revize aksiyon: drone ömrü7sn/oyuncu toplama yarıçapı36→90px, mevcut430px drone ışını ve12sn ücretsiz45HP onarım korunur; bot koşu+%18/cooldown−%30/dash iframe0,35; epoksiE85/kalkan2,5sn; radar bütün uyarılara+0,25sn/hareketli mermi saatine×0,88/dalga başına bir kolon+bir barikat kiti.
- Bag/radar ödülü dalgada bir kez. Radar sabit zemin alanlarının ömrünü uzatmaz. Global kart indirimleri ve kaynak bazlı oda kitleri çarpılır; zincirin yarım desteği o kaynakta kit koruması yoksa kullanılır. R bütün modifier/kurulumları temizler.
- Eski dash-onarım, şok inişi, türbin, halat, zincir, perfect dodge/zaman bükme, kule, mıknatıs, sprinkler ve drenaj gerçek mekaniklerdir; isimden ibaret pasif bonuslara dönüştürme.

## Kontroller ve teknik sınırlar

A/D koşu; W tek zıplama; havada ikinci W bir üst kata fizik yayı; S alt kata kısa faz; Shift/Space/sağ tık sekiz yönlü takla; E oda işlemi; F hazır; R sıfırla. F9 açıkken1–5 boss testi, U kart denemesi; modalda1/2/3 yalnız kart seçer.

2xW yükselirken **yalnız üst döşeme** çarpışma istisnasıdır; tepe noktasında geri açılır, normal yerçekimiyle iniş vardır. Işınlama/snap ekleme. Uyarı ve mermi aynı `HazardAttack` geometrisini paylaşır. Uyarısız/erken spawn reddedilir; ikincil parçalar da uyarılır. `safe_areas` kopyaları birbirinden ayrıdır; çizim, uyarı ve kapsül çarpışması aynı alan parçalarını kullanır. Havuzu savaşta büyütme. Zaman bükme savaşın90 sn gerçek sayacını değiştirmez; faz/ölüm/R zaman ölçeğini temizler.

Önemli dosyalar:

| Alan | Dosyalar |
| --- | --- |
| Giriş / sahne | `project.godot`, `scenes/MainGame.tscn`, `scripts/MainGame.gd` |
| Karakter / ekipman çizimi | `scripts/player/Player.gd`, `scripts/art/CharacterArt.gd`, `scripts/art/EquipmentArt.gd` |
| Boss / patern | `scripts/bosses/DisasterBoss.gd`, `MarathonArt.gd`, `scripts/combat/BossPatterns.gd`, `MarathonPatterns.gd` |
| Akış / gerçek etkiler | `DisasterWaveManager.gd`, `SiegeUpgrades.gd`, `SiegeMechanics.gd` (`scripts/combat/`) |
| Hasar / loot | `scripts/building/ApartmentBuilding.gd`, `RoomDiorama.gd`, `scripts/loot/LootSystem.gd` |
| Uyarı / çarpışma | `scripts/combat/HazardAttack.gd`, `HazardProjectile.gd`, `ProjectilePool.gd`, `TelegraphSystem.gd` |
| HUD / kart / metin | `scripts/ui/GameHUD.gd`, `UpgradeOverlay.gd`, `WorldLabels.gd` |

## Doğrulama ve yeniden çalıştırma

Son geliştirme doğrulaması: **Godot4.3 Linux / Compatibility / Intel UHD**. 11 headless paket **884/884**, native Step48 **101/101**, import/parse ve ana sahnenin900 adımı hatasız. Bu Git/devir görevi oyun kodunu değiştirmez; proje açıklamasındaki kart sayısı19 olarak düzeltildi. Önceki test sonuçlarını bu görevde bütün testler yeniden çalıştırılmış gibi raporlama. Ayrıca commit arşivinden ayrı temiz klasör oluşturulup eski `.godot` önbelleği olmadan import ve Step48Smoke **68/68** yeniden doğrulandı.

Tam kampanya 29.821 adım,450 sn savaş +28 sn inşaat:3.552 uyarılı mermi,33 tür,tepe71/128,0 taşma;50 onarım/55 toplama;final bina%75,8 ve0 yıkık oda. Test karakterinin canı yükseltilmiştir; insan kazanma oranı değildir.

Linux'ta (kendi motor yolunu kullan):

```sh
GODOT_BIN=/tmp/siege-tools/Godot_v4.3-stable_linux.x86_64
"$GODOT_BIN" --headless --path . --editor --import --quit
for suite in Step1Smoke Step2Smoke Step25Smoke Step3Smoke Step27Smoke Step3LootSmoke CampaignSmoke Step45Smoke MarathonSmoke Step48Smoke Step49Smoke Step5Smoke Step2Soak; do
  "$GODOT_BIN" --headless --fixed-fps 60 --path . --script "res://tests/$suite.gd" || break
done
"$GODOT_BIN" --path . --script res://tests/Step48Smoke.gd -- --capture=/tmp/siege48-captures
```

Uzun kampanya testi birkaç dakika sürebilir. Başka motor sürümünde önce import yap. Headless görsel doğrulama değildir.

**22 adet1920×1080 native PNG:** dört bossun bekleme/hazırlığı, dört karakter pozu, loot/HUD,19 kartın tamamını gösteren yedi düzen ve küçük pencere düzeni. Bu bilgisayarda `captures/step48/README.md`, `captures/step48/logs/` ve `/tmp/siege48-*` altında. **Bu dosyalar Git dışında; başka bilgisayara push ile taşınmaz.** Yukarıdaki native komutla yeniden üret. Küçük fiziksel pencere950×1033 idi; çıktı sabit1920×1080 render viewport'udur, dosyalar sonradan büyütülmedi. Mouse testi pencerenin gerçek ölçek dönüşümünü kullanır. Karakter yakın planında yalnız test kamerası büyütülür.

## Bekleyen işler / kararlar

1. İnsan oynayışıyla özellikle son iki boss,4 sn loot rotaları ve kartların algılanan gücü ölçülmedi. Değerleri otomasyonun başarısına bakarak rastgele düşürme/yükseltme; kullanıcı göreviyle playtest yap.
2. Yeni ses/müzik, bağımsız Linux/Windows/web export, teslim paketi ve farklı donanım/4.7.2 doğrulaması yapılmadı.
3. Mobilya/kolonlar rigid-body yıkım simülasyonu değildir; diorama/durum/mermi kaynaklarıdır. Yıkık oda yürünebilir kalır. Oyuncu ateş etmez; silah/puan sistemi ekleme isteği henüz yok.
4. Oyun yüzdeleri, anlık onarım/alan temizleme/kalkan ve bosslar kurgu. “Yaşam üçgeni standardı” öğretisi yerine kaynaklı sabitleme/Çök-Kapan-Tutun ve uzman incelemesi ayrımı kullanıldı. Tam sayfa erişimi kısıtlı kaynakların kapsamı SOURCES'ta; resmî onay veya yapı güvenliği garantisi iddia etme.
5. Yeni harici asset, ses/font, motor veya bağımlılık eklenmedi. AI katkısı prosedürel görsel kodu dahil BEYAN'da açık. Gelecek katkıları da gerçek kapsamıyla ekle.

Kullanıcının yeni isteğini bekle; mevcut mekanikleri değiştirmek için bu listeyi açık görev olarak kabul etme. Aynı dosyaya iki ajan/kişi eşzamanlı yazmasın. Commit/push izni bu teslim için verildi; sonraki görevde ilgili kullanıcı isteğini esas al. Force push ve kullanıcı değişikliği kaybettiren Git işlemleri yapma; `main`'e birleştirme ayrı bir adımdır.

## Claude'a verilecek başlangıç mesajı

> AFET KUŞATMASI Godot projesine devam edeceğiz. Önce CLAUDE_DEVIR.md, AGENTS.md, STATUS.md, README.md, BEYAN.md ve SOURCES.md'yi oku; git status ile doğru dal/çalışma ağacını doğrula. Aktif proje feat/disaster-siege-step1 dalındaki Godot sürümü; eski ARTÇI/TypeScript main çalışma ağacına dokunma. Altı dalga (final Kataklizma Titanı), 60/7 saniye, minimal HUD, doğrudan 1–6 kısayolları, 16 oda, 2xW fizik yayı, dört ekipman, 19 kart ve 1 hazırlık+2 aksiyon kuralını koru. Yeni görevimi verdikten sonra yalnız o kapsamda çalış; uygun testleri çalıştırıp sonucu Türkçe bildir.
