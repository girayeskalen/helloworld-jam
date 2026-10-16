# ARTÇI — AI ve hazır kaynak beyanı

Kayıt tarihi: **16 Ekim 2026** · Sürüm: **Vertical Slice v0.1**

ARTÇI öncesi hazırlık ve seçilmeyen tasarım araştırmasının AI/kaynak kayıtları [SOURCES.md](SOURCES.md) içinde korunur; teslimde bu dosyayla birlikte dikkate alınır.

Bu dosya teslim formuna aktarılacak geliştirme kaydıdır; tek başına etkinliğe teslim veya uygunluk onayı değildir. Ekip, sonraki değişikliklerde kayıtları günceller. Kişi 1 entegrasyon sorumlusudur; Kişi 2 kendi değişikliklerinin kullanım notlarını PR açıklamasında iletir.

Dayanak: [CIVIL GAME JAM resmî kural kitapçığı v09](https://game.ktimo.com.tr/assets/CIVIL_GAME_JAM_Kural_Kitapcigi_v09.pdf), 3.4 ve 4.1–4.4; PDF 16 Ekim 2026'da okunarak doğrulandı. AI ve hazır kaynak için beş kategori ayrı cevaplanır; küçük, değiştirilmiş veya dolaylı kullanımlar da açıklanır. Yanlış/eksik beyan diskalifiye sebebidir. Son teslimde güncel kitapçık ve gerçek kullanım yeniden kontrol edilmelidir.

## 1. AI kullanımı

Araç: **OpenAI Codex, GPT-6 tabanlı kodlama ajanı**. Bu oturumun tam model sürüm etiketi ayrıca doğrulanmadı; daha kesin bir model adı iddia edilmiyor. Sağlayıcı: [OpenAI](https://openai.com/codex/).

| Kategori | Durum | Amaç, çıktı ve kullanım yeri |
| --- | --- | --- |
| Görsel | Kullanıldı | Blueprint görsel tasarımının ve prosedürel çizim/VHS/parçacık kodunun AI ile üretimi: `src/ui_vfx/Renderer.ts`, `ParticleSystem.ts`, `styles.css`. AI görsel üretim aracı veya dış görsel dosyası kullanılmadı; katkı çizim kodu yoluyla dolaylıdır. |
| Ses | Kullanıldı | Osilatör, filtre, gürültü ve zarfla ses sentezi tasarımı/kodu: `src/ui_vfx/SoundSynth.ts`. AI ses üretim servisi veya hazır kayıt yok; katkı sentez kodu yoluyla dolaylıdır. |
| Kod | Kullanıldı | Vite/TypeScript iskeleti, ortak veri tipleri, dört faz, fizik olay zinciri, snapshot geri sarma, AP, tahliye, HUD, bölüm verisi ve tarayıcı testleri: `src/**`, kök yapılandırmalar, `tests/**`, `playwright.config.ts`. |
| Metin | Kullanıldı | Oyun içi Türkçe açıklamalar, müdahale ve karne metinleri, bu beyan ile README/STATUS/AGENTS güncellemeleri. Farkındalık cümleleri AFAD'dan kontrol edilerek özgün biçimde özetlendi. |
| Diğer | Kullanıldı | Mimari/faz modelleme, dosya sahipliği önerileri, test senaryoları ve doküman düzenleme desteği. |

Oyun adı, tema, teknoloji yığını, ana mekanik fikri ve üç müdahale kullanıcı tarafından bu görevde sağlandı. Bu kayıt, AI tarafından yazılan ilk uygulamayı açıklar; ekibin daha önceki veya gelecekteki başka araç kullanımı hakkında varsayım içermez. Çıktılar için otomatik MIT gibi bir lisans atanmamıştır; ekip, teslim ettiği içerik ve kullanım haklarını kendi adına kontrol eder.

## 2. Hazır kaynak kullanımı

| Kategori | Durum | Açıklama |
| --- | --- | --- |
| Görsel | Kullanılmadı | Harici sprite, fotoğraf, ikon paketi, texture veya model yok. Çizgiler/şekiller Canvas ile, metin ve işaretler sistem fontuyla çizilir. |
| Ses | Kullanılmadı | Hazır müzik, efekt, sample veya kayıt yok. Web Audio ile çalışma anında sentezlenir. |
| Kod | Kullanıldı | Aşağıdaki Vite, TypeScript, Playwright ve dolaylı araç bağımlılıkları. Hazır oyun kodu veya oyun şablonu kopyalanmadı. |
| Metin | Kullanıldı | AFAD'ın aşağıda bağlantısı verilen afet hazırlığı önerilerinden bilgi düzeyinde yararlanıldı; kaynak metin veya kılavuz dosyası oyuna kopyalanmadı. |
| Diğer | Kullanıldı | Node.js/npm geliştirme ortamı, test amaçlı Chromium ve işletim sisteminin mevcut yazı tipleri. Ayrı font dosyası veya test tarayıcısı oyunla dağıtılmıyor. |

### Doğrudan araçlar ve kaynaklar

| Ad / sürüm | Üretici veya sağlayıcı / kaynak | Lisans / hak bilgisi | Kullanım |
| --- | --- | --- | --- |
| Vite 8.3.4 | [Vite ekibi](https://github.com/vitejs/vite) | MIT | Geliştirme sunucusu ve üretim paketleme; kaynak değiştirilmedi. |
| TypeScript 7.0.2 | [Microsoft](https://github.com/microsoft/TypeScript) | Apache-2.0 | Tip kontrolü; kaynak değiştirilmedi. |
| @playwright/test, playwright, playwright-core 1.64.1 | [Microsoft](https://github.com/microsoft/playwright) | Apache-2.0 | Otomatik tarayıcı testleri; oyun paketine eklenmez. |
| Node.js 26.8.2 (bu ortam) | [Node.js contributors](https://github.com/nodejs/node/blob/main/LICENSE) | MIT ve birlikte gelen bileşen bildirimleri | JavaScript geliştirme çalışma ortamı; oyuna gömülmez. Minimum desteklenen sürüm 22.12. |
| npm 12.0.2 (bu ortam) | [npm contributors](https://github.com/npm/cli) | Artistic-2.0; bağımlılıkların kendi lisansları da geçerli | Paket kurulumu / lock dosyası; oyuna gömülmez. |
| Chromium / Chrome for Testing 156.0.8078.4, Playwright build 1248 | [Chromium projesi](https://chromium.googlesource.com/chromium/src/+/main/LICENSE) / Playwright dağıtımı | BSD tarzı Chromium lisansı ve üçüncü taraf bildirimleri | Sadece yerel test; `dist/` veya repoda dağıtılmaz. |
| Deprem öncesi, anı ve sonrası önerileri | [AFAD](https://afad.gov.tr/deprem-oncesi-ani-ve-sonrasi-alabileceginiz-onlemleri-biliyor-musunuz) | Sayfada açık yeniden dağıtım lisansı belirlenmedi; belge, logo ve görsel alınmadı. Bilgiler özgün cümlelerle özetlendi. | Eşya sabitleme, sağlam masa altında Çök-Kapan-Tutun, sarsıntıda merdivene koşmama ve sarsıntı sonrası tahliye metinleri. |
| Sistem yazı tipleri / Canvas 2D / Web Audio | Kullanıcının işletim sistemi ve tarayıcısı | Platformun kendi koşulları; font/binary dosyası dağıtılmıyor | `ui-monospace`, `system-ui` ve yerel fallback'ler; tarayıcı çizim/ses API'leri. |

### Bu ortamda kurulu dolaylı kod bağımlılıkları

Kaynak: `package-lock.json` ve kurulu paketlerin `package.json` lisans/üretici kayıtları. Hepsi geliştirme/test araç zincirindedir; kaynaklarında değişiklik yapılmadı. Windows/macOS veya başka mimaride npm, aynı araçların platforma uygun native paketini seçebilir; kilit dosyası bu varyantları da içerir.

| Kaynak / sağlayıcı | Paketler / sürümler | Lisans |
| --- | --- | --- |
| [Oxc contributors](https://github.com/oxc-project/oxc) | `@oxc-project/types` 0.154.0 | MIT |
| [Rolldown contributors](https://github.com/rolldown/rolldown) | `rolldown`, `@rolldown/binding-linux-x64-gnu` 1.2.14 | MIT |
| [Rolldown plugins contributors](https://github.com/rolldown/plugins) | `@rolldown/pluginutils` 1.0.1 | MIT |
| [Microsoft](https://github.com/microsoft/TypeScript) | `@typescript/typescript-linux-x64` 7.0.2 | Apache-2.0 |
| [Lovell Fuller / detect-libc](https://github.com/lovell/detect-libc) | `detect-libc` 2.1.2 | Apache-2.0 |
| [thecodrr / fdir](https://github.com/thecodrr/fdir) | `fdir` 6.5.0 | MIT |
| [Parcel contributors](https://github.com/parcel-bundler/lightningcss) | `lightningcss`, `lightningcss-linux-x64-gnu` 1.33.0 | MPL-2.0 |
| [Andrey Sitnik / Nano ID](https://github.com/ai/nanoid) | `nanoid` 3.3.20 | MIT |
| [Alexey Raspopov](https://github.com/alexeyraspopov/picocolors) | `picocolors` 1.1.1 | ISC |
| [Jon Schlinkert / micromatch](https://github.com/micromatch/picomatch) | `picomatch` 4.0.7 | MIT |
| [PostCSS contributors](https://github.com/postcss/postcss) | `postcss` 8.5.30 | MIT |
| [Valentin Semirulnik](https://github.com/7rulnik/source-map-js) | `source-map-js` 1.2.2 | BSD-3-Clause |
| [Superchupu](https://github.com/SuperchupuDev/tinyglobby) | `tinyglobby` 0.2.17 | MIT |

`node_modules/`, test tarayıcıları ve indirilen kural kitapçığı repoya veya oyuna eklenmedi. Bağımlılık sürümleri değiştiğinde bu kayıt ve ilgili lisans bildirimleri yeniden kontrol edilir. Into the Breach / Katana ZERO yalnızca mekanik esin referanslarıdır; bu oyunlardan kod, görsel veya ses alınmadı.

## 3. Teslim öncesi ekip kontrolü

- İki kişinin ek AI/asset kullanımlarını bu kayda ekleyin; teslim formunda AI ve hazır kaynak için beş kategoriyi ayrı ayrı doldurun.
- Bu dosyadaki araçların amaç, kullanım yeri, kaynak ve lisans bilgilerini form alanlarına aktarın. Takım temsilcisi gerçek kullanımın eksiksizliğini doğrulasın.
- Son build, oynama bağlantısı ve public repo sürümünün eşleşmesini doğrulayın; paket içindeki gerekli üçüncü taraf bildirimlerini koruyun. Teslim/yayın bu görev kapsamında yapılmadı.
