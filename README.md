# ARTÇI — AFTERSHOCK: Tactical Rewind

CIVIL GAME JAM 2026 için **Afet Hazırlığı ve Farkındalık** temalı, 2D yandan kesitli taktiksel afet öngörü ve zamanı geri sarma oyunu. Into the Breach'in risk okuması ve Katana ZERO'nun yeniden deneme fikrinden esinlenir; bu oyunların kodu veya kaynakları kullanılmaz.

İki kişilik ekibimizin ortak deposu: [girayeskalen/helloworld-jam](https://github.com/girayeskalen/helloworld-jam).

**Fizik prototipi v0.2:** Vite + TypeScript + **Matter.js 0.20.0** + HTML5 Canvas 2D + Web Audio API. Bütün grafikler kodla çizilir; sesler çalışma anında sentezlenir. Harici görsel, ses veya font dosyası indirilmez. Çizim yüzeyi 1280×720'dir ve pencereye orantılı ölçeklenir.

## Kurulum ve çalıştırma

[Node.js](https://nodejs.org/) **22.12 veya üstü** ve npm gerekir. Güncel masaüstü Chrome/Edge/Firefox gibi Canvas 2D ve Web Audio destekleyen bir tarayıcı kullanın. Chromium üzerinde otomatik doğrulama yapılmıştır; diğer tarayıcılarda manuel kontrol sıradaki görevdir.

Proje kökünde:

```sh
npm install
npm run dev
```

Geliştirme sunucusu varsayılan olarak `http://127.0.0.1:5173` adresini tarayıcıda açar. Port doluysa terminalde yazan adresi kullanın. Ses tarayıcı kuralı gereği ilk tıklama/tuştan sonra açılır; **M** veya ses düğmesiyle kapatılabilir. Sekme gizlenince simülasyon ve geri sayım duraklar.

```sh
npm run build
npm run preview
```

`build`, önce sıkı TypeScript kontrolünü sonra Vite üretim derlemesini çalıştırır. Çıktı `dist/` dizinindedir. `preview` bu çıktıyı yerelde sunar; terminaldeki adresi açın. Üretim sürümünü `index.html` dosyasına çift tıklayarak değil, HTTP üzerinden çalıştırın. Kurulu bağımlılıkları kilit dosyasından birebir yenilemek için `npm ci` kullanılabilir.

Oynanış testlerini çalıştırmak için bir kez test tarayıcısını kurun:

```sh
npx playwright install chromium
npm test
```

Testler kendi Vite sunucusunu 5174 portunda açar; portun boş olması gerekir. Linux'ta eksik sistem kütüphaneleri bildirilirse Playwright'ın [kurulum rehberini](https://playwright.dev/docs/browsers#install-system-dependencies) izleyin. Normal oyun/derleme için test tarayıcısı kurulumu gerekmez.

## Nasıl oynanır?

1. **FORESIGHT / Öngörü:** 8 saniyelik sarsıntıda gerçek gövdelerin hareketini izle. Darbeler, kopan askılar, devrilme, masa/kolon hasarı ve gaz-kıvılcım zinciri sonucu değiştirir.
2. **REWIND / Geri sarma:** Her iki fizik karesinden biri kaydedilir (30 Hz). Gövdeler, hızlar, açılar, NPC sağlığı, parçalar ve bağlar 1,8 saniyede interpolasyonla geri oynar. Planlama T=0'da temiz dünya ile başlar.
3. **PLANNING / Hazırlık:** **5 AP** vardır. **1:** gardırop sabitle (1), **2:** kitaplık sabitle (1), **3:** buzdolabı sabitle (1), **4:** masa çaprazı (2), **5:** kolon çaprazı (2), **6:** gaz kesici (1), **7:** sığınma planı (1). Nesne veya düğmeye tıklanabilir. Masa altı/kolon yanı hedefi değiştirilebilir; ilk sığınak seçimi plan komutunu 1 AP'ye alır, hedef değiştirmek tekrar ücretlendirilmez. **R** bütün planı ve bağlarını sıfırlar.
4. **EXECUTION / Aktif tutunma:** **Space** ile başlat. **A/D veya ←/→** ile göstergeyi yeşil bölgede tut. **Space** kısa bir tutuşla merkeze çeker; sürekli basmak enerjiyi tüketir. Tuşu bırakınca enerji yenilenir. Denge bozulursa tutuş bağı çözülür; karakter fiziksel olarak savrulabilir ve yaralanabilir.
5. **EVACUATION / Tahliye:** Sarsıntı durunca **12 saniye** başlar. **A/D veya ←/→** ile koş; **Space, W veya ↑** ile zıpla; **S/↓** havada hızlı iniş sağlar. Havada ikinci zıplama yoktur. Enkaz, devrilmiş eşyalar ve yerinde kalan taşıyıcılar fiziksel yolu değiştirebilir. Sağdaki kapıya ulaş. Karnede **R** yeniden başlatır.

Dört ana `Phase` korunur; tutunma, tahliye ve karne `EXECUTION` içindeki adımlardır. Örnek başarılı plan: kolon çaprazı (2) + gardırop sabitleme (1) + gaz kesici (1) + kolon yanında sığınma planı (1). Tek başına düğmelere basmak tam puan vermez; tutunuş ve tahliye de tamamlanmalıdır. Başka planların açık bıraktığı rotayı öngörüden okuyun.

Karne: mühendislik 40 + farkındalık/tutunma 30 + tahliye 30. Mühendislik puanı gerçekten ayakta kalan güçlendirme, dik kalan sabit eşya, gaz kesici ve patlamanın önlenmesini hesaba katar. Yeşil bölgede geçirilen süre farkındalık puanını etkiler. **S: ≥90 ve başarılı tahliye; A: ≥75 ve başarılı tahliye; B: ≥50; C: diğer sonuçlar.** Bu, jam jüri puanlamasından ayrı oyun içi sistemdir.

P/S dalga esinli hareketli temel ve kat kesme kuvveti fizik motoruna aktarılır; bu bir sismik dalga yayılımı veya yapı mühendisliği çözücüsü değildir. Kütleler, yük/hasar eşikleri ve süreler oyun birimleridir. `SafeTriangle`, destek gövdesi hâlâ ayaktayken karakter hacminin diğer cisimlerle çakışmadığı oyun içi boşluğu gösterir; gerçek bir binada güvenlik garantisi değildir. Eğitim davranışı, [AFAD'ın sağlam masa altında Çök-Kapan-Tutun ve sarsıntı sonrasında tahliye önerisine](https://afad.gov.tr/deprem-oncesi-ani-ve-sonrasi-alabileceginiz-onlemleri-biliyor-musunuz) dayanır. 12 saniye gerçek artçı zamanı tahmini değildir.

## Mimari ve dosya sahipliği

```text
src/
  types/game.ts                 Ortak sözleşme; değişiklikler koordineli
  core/                         Kişi 1 — Core Simulation & Physics
    Engine.ts                   Sabit 60 Hz adım / render döngüsü
    SimulationManager.ts        Dört faz, AP, giriş, tahliye, karne
    TimelineRewind.ts            İzole snapshot kaydı ve ters örnekleme
    PhysicsHazardSystem.ts      Matter dünyası, darbeler, kırılma ve gerçek bağlar
    PhysicsLevel.ts             Kişi 1 referans fizik sahnesi; eski bölüm verisini korur
  ui_vfx/                       Kişi 2 — Tactical UI, Audio, VFX
    Renderer.ts                 Blueprint kesit, tehlike vektörleri, VHS
    TacticalHUD.ts              Erişilebilir DOM düğmeleri ve karne
    SoundSynth.ts               Web Audio sentezi ve ses kontrolü
    ParticleSystem.ts           Olay tabanlı parçacıklar
    styles.css                  HUD ve duyarlı ekran yerleşimi
  levels/levels.ts              Kişi 2 — Salt bölüm verisi ve farkındalık
  integration/                  Kişi 1 — Yeni fizik sözleşmesinin çalışan referans sunumu
    PhysicsView.ts              Gövde köşeleri, tutunma ve planlama kontrolleri
    physics.css                 Referans görünüm stilleri
  main.ts                       Kişi 1 — Sistem bağlantıları / entegrasyon
tests/game.spec.ts              Kişi 1 — Gerçek tuş/fare, faz ve HUD kontrolleri
tests/physics.spec.ts           Kişi 1 — Rijit cisim, snapshot, AP, grip ve tahliye testleri
```

Core, DOM/Canvas/Web Audio'ya bağımlı değildir; `Engine` yalnızca zamanlama için tarayıcı API'sini kullanır. Sunum, `GamePresentation` üzerinden salt okunur `GameState` alır; müdahaleleri `GameController` aracılığıyla iletir. `Phase` dört ana durumdan oluşur; son fazın `ExecutionStage` adımları `SHAKING`, `EVACUATION`, `REPORT` olarak ayrılır. Oynanış 60 Hz, Matter alt adımları 120 Hz, kayıt 30 Hz'dir. Çizim ve ses rastgeleliği fiziği etkilemez. Snapshot içinde Matter nesnesi tutulmaz; konum, hız, açı, kırılma, gaz durumu ve bağ varlığı serileştirilir. Geri sarma sırasında fizik ileri işletilmez. Planlama/tekrar başlangıcı temiz dünyadan yeniden kurulur. Ara bir snapshot'tan devam için solver temas önbelleği yeniden oluşturulur; bit düzeyinde ara kare devamı garantisi verilmez.

**Kişi 2'ye entegrasyon:** `src/ui_vfx/` ve `src/levels/` dosyaları bu görevde değiştirilmedi. `main.ts` şu an `src/integration/PhysicsView.ts` referans sunumunu kullanır; SoundSynth ve ParticleSystem mevcut modüllerden alınır. Kişi 2 kendi Renderer/HUD'unu yeni `GameState.physicsBodies`, `constraints`, `safeTriangles`, `grip`, `seismic` alanlarına geçirebilir. `x/y` kütle merkezi, `angle` radyandır; kaymış kütle merkezi ve compound masayı doğru çizmek için `parts` dünya köşelerini kullanın. `dangerArc` sabitlenmemiş yüksek eşyaların öngörü alanıdır. AP, müdahale maliyeti ve süreleri `LevelData` üzerinden okuyun; eski HUD 3 AP varsaydığı için doğrudan yeniden bağlanmamalıdır.

`PhysicsLevel.ts`, eski bölüm verisini değiştirmeden v0.2 fizik tanımlarına dönüştürür. `LevelData.physics` ile yeni veri geçirilebilir; şu referans sistem `ground`, `upper-floor`, `wall-left`, `column`, `ceiling-beam`, `ceiling-a`, `ceiling-b`, `lamp`, `gas` ve `desk` kimliklerini bekler. Şu an bir kontrol edilebilir NPC vardır. Kesit modelinde NPC, masa ayaklarının önünden/arkasından geçebilir: yalnız sağlam masa/NPC çarpışması filtrelenir; eşya–masa ve karakter–enkaz temasları tam fizikseldir. NPC diğer eşyaların içinden geçmez.

Paralel çalışma sırasında `feat/core-*` ve `feat/ui-*` gibi ayrı dallar kullanın. **Kişi 1**, ortak tipler, giriş noktası, kök yapılandırmalar, lock dosyası ve ortak belgelerin entegrasyon sorumlusudur. **Kişi 2**, `src/ui_vfx/` ve `src/levels/` dışında değişiklik yapmadan arayüz taleplerini kendi PR açıklamasında iletir. Ortak sözleşme değişikliği önce birlikte kararlaştırılır, sonra tek kişi uygular. Ayrı dosya sahipliği aynı satırların paralel düzenlenmesini önler; Git bütün olası birleştirmelerde sıfır çakışma garantisi vermez. Ayrıntılar [AGENTS.md](AGENTS.md) içinde.

## Ortak çalışma düzeni

- Herkes kendi bilgisayarındaki proje kopyasında, kendi GitHub ve Codex hesabıyla çalışır.
- Değişiklikleri GitHub üzerinden paylaşırız. Bir kişinin Codex sohbeti diğer kişinin sohbetine aktarılmaz; ortak kararları ve görev durumlarını dosyalara yazarız.
- `main` entegrasyon dalıdır; herkes kendi görev dalında çalışır. Aynı dosyayı aynı anda değiştirmeden önce haberleşiriz; görev sahiplerini `STATUS.md` içinde belirtiriz.
- **Kaydetmek** dosyayı bilgisayarında günceller. **Commit** değişikliklerin yerel Git kaydını oluşturur. **Push** commitleri GitHub'a gönderir. **Pull** GitHub'daki değişiklikleri bilgisayarına alır.

## 1. Projeyi aç

VS Code'da **Dosya → Klasör Aç** menüsünden mevcut `helloworld-jam` klasörünü seç. Windows'ta kısayol: önce `Ctrl+K`, sonra `Ctrl+O`. Zaten indirilmiş projeyi yeniden clone etmene gerek yok.

**Terminal → Yeni Terminal** menüsünü aç. Aşağıdaki komutları proje klasöründeki terminalde çalıştır:

```powershell
git status
git remote -v
```

`git status` bu klasörün Git durumunu gösterir. `origin` adresinin `https://github.com/girayeskalen/helloworld-jam` olması gerekir; adresin sonunda `.git` bulunması da normaldir.

## 2. Kendi Git kimliğini kontrol et

Her bilgisayarda bir kez kontrol et:

```powershell
git config user.name
git config user.email
```

Bir değer eksik veya sana ait değilse aşağıdaki örneklerdeki adı ve e-postayı kendi bilgilerinle değiştir. `--local` yalnızca bu projeyi etkiler:

```powershell
git config --local user.name "Ad Soyad"
git config --local user.email "GitHub e-postan"
```

Ad, commitlerde görünen isimdir; GitHub kullanıcı adın olmak zorunda değildir. E-posta için GitHub hesabına eklediğin adresi veya GitHub **Settings → Emails** sayfasındaki gizlilik amaçlı `noreply` adresini kullanabilirsin. Bunlar GitHub'a giriş yapmanın yerine geçmez.

## 3. İşe başlamadan arkadaşının değişikliklerini al

Önce durumu kontrol et:

```powershell
git status
```

Kaydedilecek yerel değişiklik yoksa (`working tree clean`) güncelle:

```powershell
git pull --ff-only
```

Bu komut ortak geçmişi otomatik birleştirme commiti oluşturmadan günceller. Yerel değişikliklerin varsa önce dosyaları kaydet ve aşağıdaki adımlarla commit oluştur. Pull hata verirse çalışmaya devam etmeden önce aşağıdaki hata bölümüne bak.

## 4. Değişiklikleri kaydet ve kontrol et

Dosyaları düzenledikten sonra `Ctrl+S` ile kaydet. Birden fazla açık dosya için **Dosya → Tümünü Kaydet** menüsünü kullan. Kaydetmek tek başına commit veya push yapmaz.

```powershell
git status
git diff
```

`git status` değişen ve yeni dosyaları listeler. `git diff` henüz commit için seçilmemiş, Git'in zaten takip ettiği dosyalardaki değişiklikleri gösterir; yeni dosyaların içeriğini VS Code'da da incele.

## 5. Açıklayıcı bir commit oluştur

Yalnızca bu görevde değiştirdiğin dosyaları commit için seç. Örneğin görev durumu için sadece `STATUS.md` değiştiyse:

```powershell
git add -- STATUS.md
git diff --cached
git status
git commit -m "Görev durumunu güncelle"
```

Başka dosyaları değiştirdiysen `git add --` sonrasına onların gerçek yollarını yaz. VS Code'un **Kaynak Denetimi** bölümünde ilgili dosyaların yanındaki **+** düğmesi de aynı seçimi yapar. `git diff --cached` ve `git status` ile commitin içeriğini kontrol et; mesajı yaptığın işi anlatacak şekilde değiştir.

Küçük ve tek bir işi anlatan commitler oluştur. Ekip arkadaşının veya başka bir görevin değişikliklerini kendi commitine katma. Şifreleri, erişim anahtarlarını ve kişisel ayar dosyalarını ekleme.

## 6. GitHub'a gönder

```powershell
git push
git status
```

Push başarılı olunca GitHub depo sayfasında son commit görünür. `git status` yerel dalın takip ettiği uzak dalla güncel olduğunu ve çalışma alanının temiz olduğunu göstermelidir.

GitHub oturum açma ekranı çıkarsa **Sign in with your browser** düğmesine tıkla, tarayıcıda kendi hesabına giriş yap ve gösterilen yetkilendirmeyi tamamla. Şifreni veya erişim anahtarını README'ye ya da sohbete yazma.

## Pull veya push hata verirse

- Push reddedildiyse arkadaşın senden önce yeni bir commit göndermiş olabilir. Yerel değişikliklerini önce kaydet ve commit et, sonra `git pull --ff-only` dene. Başarılı olursa yeniden `git push` çalıştır.
- `Not possible to fast-forward`, `divergent branches` veya bir çatışma mesajı görürsen dur. Çıktıyı Codex'e göster ve "Yerel çalışmalarımı ve ekip arkadaşımın değişikliklerini koruyarak bunu çöz" de. Yerel ve uzak commitler ayrıştıysa birleştirme gerekebilir.
- **Force push kullanma.** Sorunu aşmak için dosya silme, `git reset --hard` veya `git clean` çalıştırma.

## Arkadaşın bu dosyaları nasıl alır?

Arkadaşının bilgisayarında proje zaten varsa VS Code'da o klasörü açıp, yerel değişikliği olmadığını kontrol ettikten sonra `git pull --ff-only` çalıştırması yeterli.

Henüz kendi bilgisayarına indirmediyse VS Code'da `Ctrl+Shift+P` → **Git: Clone** seçeneğine tıklayıp `https://github.com/girayeskalen/helloworld-jam` adresini girebilir. Yerel klasörü seçip indirme tamamlandıktan sonra **Open / Aç** düğmesine tıklar. Ardından kendi Git kimliğini yukarıdaki adımlarla kontrol eder.

## Ortak kayıtlar

- `STATUS.md`: görevler, görev sahipleri ve bilinen sorunlar.
- `AGENTS.md`: Codex'in bu depoda çalışırken uyması gereken kurallar.
- `BEYAN.md`: AI ve hazır kaynak kullanımı, kaynaklar ve lisans kayıtları. Teslim formuna aktarılacak canlı kayıttır.

## Önceki hazırlık kayıtları

- [PREPARATION.md](PREPARATION.md): tarihli yarışma öncesi hazırlık; Godot kurulum adımları ARTÇI için uygulanmaz.
- [ENGINE_DECISION.md](ENGINE_DECISION.md): önceki motor araştırması ve Godot kararı; güncel karar yukarıdaki Vite/TypeScript yığınıdır.
- [GAME_DESIGN.md](GAME_DESIGN.md): seçilmeyen önceki fikirlerin arşivi. Güncel ARTÇI kapsamı bu README içindedir.
- [SOURCES.md](SOURCES.md): önceki araştırma/AI kayıtları. Oyun geliştirme beyanı BEYAN.md ile birlikte değerlendirilir.
- [SUBMISSION.md](SUBMISSION.md): jam teslim taslağı ve temsilcinin tamamlayacağı kontrol listesi.
