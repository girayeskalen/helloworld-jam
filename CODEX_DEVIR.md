# Codex devir notu — AFET KUŞATMASI

> **En güncel — 18 Ekim 2026: cila (Claude).** Savaş 40 sn ve ilk saniyeden tam tempo, Hazırlık 15/10 sn (boş ara Hazırlık 3 sn), sarsıntı 1,0+1,4 sn ve 8 sn arayla, loot 6 sn ve %20 daha sık. Ekranın üstünde tek görev satırı (Hazırlık ilerlemesi + görev/neden, öğretici adımları, ilk onarım rehberi). Hasarlı oda çerçeve + büyük elmas + halka + `alarm` sesi. Ayrıntı AGENTS.md son madde, sonuçlar STATUS.md başı.

> **Önceki — 18 Ekim 2026: afete hazırlık güncellemesi (Claude).** Jüri ölçütleri için sıra DEPREM → FIRTINA → SEL → final. Her afetten önce Hazırlık (20/15 sn): E ile eşya sabitleme, gaz, çanta, sonra kepenk ve sigorta (`scripts/prep/`). Depremde ve finalde sarsıntılar (`TremorSystem`): C ile Çök-Kapan-Tutun, sabitlenmemiş eşya devrilir, kepenksiz cam kırılır, gaz açıksa kaçak; sarsıntıda desenler bekler. Normal girişte yazısız öğretici açıktır (çıplak MainGame testinde kapalı). Her afetten sonra karne (en çok 3 satır). DOME kartı "Sakin Kal". Kurallar AGENTS.md son maddede, sonuçlar STATUS.md başında; `tests/Step9Smoke.gd`.

> **Önceki — 18 Ekim 2026: minimal arayüz (Claude).** Kullanıcı tasarım kararlarını Claude'a bıraktı. Oyun sırasında yazı yalnız boss adı, kit sayısı ve E tuş başlığıdır; saldırı adı, DODGE/SIYRILDI, yüzde/saniye ve köşe ipuçları kaldırıldı. Sol üst: 10 dilimli can, enerji çizgisi, 4×4 oda haritası; sol alt: üç kit ikonu + sayı; alt orta: ince boss çizgisi (`BOSS_BAR` Rect2(610,1040,700,6)). Bütün yazılar özgün `PixelFont` + `UIStyle` (24/36/48/72). Menü: Başla/Ayarlar/Çıkış; pause: Devam/Yeniden başla/Ana menü/Ses. Kartlar yalnız ikon + kısa ad + ≤7 kelimelik etki (yeni adlar README'de); `FieldUI.gd` kaldırıldı. Kurallar AGENTS.md'nin son maddesinde, sonuçlar STATUS.md'nin en üstünde; yeni yazı eklemeden önce kullanıcıya sor. `tests/MinimalUISmoke.gd` bu kuralları denetler.

> **Güncel — 18 Ekim 2026: ana menü ve saha ikmali.** Önce STATUS.md'nin en üst bölümünü ve AGENTS.md'yi oku. Normal giriş `scenes/Launch.tscn`; Başla / Ayarlar / Çıkış, kalıcı ses/ekran tercihleri ve pause'tan ana menüye dönüş var. Başlangıç ve kart sonrası hazırlık **4/4 sn**, savaşlar **50 sn**. Adım 8'in dokuz aktif kartı yeni dosya görünümünde; eski boss giriş/çıkışı ve final birleşmesi korunur. Adım 9 hikâye/video açılışı geri alındı. Linux Godot 4.3: **18 paket / 1.297 kontrol**, native FrontEnd 32 ve Step8 103 geçti. Dal `feat/disaster-siege-step1`; geri dönüş commit'i `2f045cc`, menü teslimi onun üzerindedir. Aşağıdaki eski süre, Git durumu ve “commit/push yapılmadı” ifadeleri tarihsel kayıtlardır. Yeni özellik veya kullanıcı görevi varsayma.

> **18 Ekim 2026 — Adım 8 (Codex) günceldir.** Eski19 kart yerine9 aktif mekanik ve kısa ikonlu A/B/B seçim; yalnız deprem cooldown×1,1/hız×0,9/boşluk×1,1. 50/5sn, dört faz, 2xW, gece cache ve BGM korunur. `STATUS.md` en üstte gerçek sonuç/kanıt ve sınırları içerir; `tests/Step8Smoke.gd` yeni davranışları sınar. Claude Adım7 değişiklikleriyle birlikte çalışma ağacındadır; bu görevde commit/push yapılmadı. Eski kart/12sn drone/tümkat iniş temizliği/global bullet-time maddeleri tarihçedir.

> **Adım 7 (Claude, 17 Ekim 2026) bu notun üstündedir:** 50 sn faz / 5 sn inşaat, 0,90→1,25→1,45 tempo rampası, beş fırtına + dört deprem koreografisi (eşya fırlatma yok), sabit 0,55 sn uyarı + beyaz parlama, konturlu neon mermiler, kuşatmada karartılan mobilya ve sıyrılma (+25 enerji). Ayrıntı: STATUS.md en üst bölüm, AGENTS.md sonundaki Adım 7 maddeleri ve CLAUDE_DEVIR.md. Aşağıdaki 60/7 sn ifadeleri tarihçedir.

**Önce STATUS.md'nin Adım 6 bölümünü oku.** Dört faz/BossCinematic/alt HUD/1–4 korunur. Yeni sürümde statik render önbellekleri, bağımsız −5 dB mono WAV BGM ve yalnız finalde azaltılmış yoğunluk/hız/hasar + uzatılmış uyarı vardır. Aşağıdaki Claude/Adım 5.5 devri tarihçedir; canlı generator müzik yolu kaldırılmıştır.

Claude, Adım 4.9 ve Adım 5'i tamamladı. Önce `AGENTS.md`'yi (güncel kurallar) ve `STATUS.md`'nin en üstteki iki bölümünü oku.

## Git durumu — önce bunu kontrol et

- Dal: `feat/disaster-siege-step1`, son commit `fec865f`.
- **Adım 4.9 ve 5 commit edilmedi**; çalışma ağacında duruyor (değişen dosyalar + yeni `scripts/audio/`, `scripts/ui/PauseMenu.gd`, `scripts/bosses/CataclysmArt.gd`, `scripts/combat/CataclysmPatterns.gd`, `tests/Step49Smoke.gd`, `tests/Step5Smoke.gd` ve yeni `.uid` dosyaları).
- Bu değişiklikleri kaybettirecek reset/checkout/stash/clean yapma.
- Commit/push yalnız kullanıcı isterse yapılır. `.uid` dosyaları repoda izleniyor; commit edilirse onları da ekle.

## Şu an oyunda olanlar

- **6 dalga, her biri 60 sn:**
  - Sıra: fırtına → deprem → çifte → sel → yangın → **Kataklizma Titanı**.
  - Final dalgasında 2,0 sn birleşme girişi, 5 birleşik yetenek ve son 15 sn Nova var.
  - İlk hazırlık 8 sn; dalga arası inşaat 7 sn.
- **Kısayollar:** 1–6 F9 olmadan doğrudan boss seçer. Kart ekranında 1/2/3 yalnız kart seçer. U hâlâ F9 ister.
- **Minimal HUD:**
  - Sol üst: kalp/şimşek/kalkan barları.
  - Üst orta: ince boss şeridi.
  - Sol alt: KOLON/SABİTLE/GÜVENLİK slotları.
  - Tab/H basılıyken yardım kartı açılır.
  - Testler `GameHUD.drawn_texts` alanını okur.
- **ESC/P duraklatma:**
  - `PauseMenu`, `PROCESS_MODE_ALWAYS` ile çalışır.
  - M her yerde sesi kapatır/açar.
  - -/+ ses seviyesini değiştirir; yazılan karakterden okunur (TR klavye uyumu).
- **Ses:**
  - Ses dosyası yok. `SoundRecipes` → `SoundSynth` → `SoundManager` zinciri sesleri açılışta arka plan thread'inde pişirir (~3 sn).
  - Mermi sesleri ana efektlerden 8 dB kısıktır.
  - Her çalmada 0,94–1,06 perde; ses başına kısıtlama vardır.

## Dokunurken dikkat

- **Final boss:** saldırılar element kaynağını (0–3) taşır; panjur/kart mantığı buna dayanır.
- **Titan katmanları:**
  - Gövde binanın arkasında (z −1).
  - Kafa `front_layer` (z 7) üzerinde; çıkışta binanın arkasına iner.
  - Birleşme efekti `fusion_layer` üzerinde.
- **Mühür uyarısı:** tam 0,8 sn (`HazardAttack.SEAL_WARNING`).
- **Yeni oyun olayına ses eklerken:** mevcut sinyali kullan ve `Step5Smoke`'a ekle. Sesin hazır sinyalleri:
  - `Player.jumped/landed`
  - `LootSystem.landed`
  - `DisasterBoss.cued`
  - `SiegeMechanics.blocked`

## Test

13 paket, son kodla **1.071/1.071** geçti (Godot 4.3 ve 4.7.2, Windows):

```text
Step1Smoke Step2Smoke Step25Smoke Step3Smoke Step27Smoke Step3LootSmoke CampaignSmoke
Step45Smoke MarathonSmoke Step48Smoke Step49Smoke Step5Smoke Step2Soak
```

Çalıştırma: `--headless --fixed-fps 60 --path . --script res://tests/<Suite>.gd`. Step1 ve Step2 `--fixed-fps` olmadan da çalışır. Motor değiştirdiysen önce `--headless --editor --quit` ile içe aktar.

Bu makinedeki motorlar:

- `C:\Users\halil\OneDrive\Desktop\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
- `C:\Users\halil\AppData\Local\Temp\disaster-siege-godot43\Godot_v4.3-stable_win64_console.exe`

Görsel kanıt için `--headless` olmadan `-- --capture=<klasör>` ile çalıştır (Step49 ve Step5 1920×1080 PNG üretir). Yerel kopyalar `captures/step49/` ve `captures/step5/` altında (Git dışında).

## Açık konular

- Sesler kulakla dinlenmedi; yalnız ölçümle doğrulandı (tepe/tık/DC/parlaklık/döngü).
- Final bossun zorluğu insanla oynanarak ölçülmedi.
- Fiziksel F5 penceresinde 1–6, Tab/H, ESC ve M elle denenmedi.
- Ses ayarı kalıcı değil (diske yazılmıyor).
- AI kullanımını yeni işlerde de `BEYAN.md`/`SOURCES.md`'ye gerçek kapsamıyla ekle.

## Codex devamı — Adım 5.5

Yukarıdaki altı dalga/1–6/ateşli final/müzik nabzı açıklamaları Claude'un devrettiği eski sürümü anlatır. Güncel oyun dört fazlıdır: FIRTINA → DEPREM → SEL → DEPREM • SEL • FIRTINA; 60 sn savaş / 7 sn inşaat; ayrı 2,5/2,8 sn sinematik, alt boss barı ve MusicScore ile kesintisiz özgün stereo BGM. Yangın bossu ve çifte faz kaldırıldı; yardım/kısayollar 1–4. Yeni dosyalar MusicScore.gd, BossCinematic.gd, Step55Smoke.gd. Yeni tam sonuçlar ve bilinen sınırlar STATUS.md başındadır. Claude'un önceki değişiklikleri korunmuştur; Git durumu için her zaman git status / git log kullan.
