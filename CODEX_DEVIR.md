# Codex devir notu — güncel Adım 6 (17 Ekim 2026)

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
