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
- `BEYAN.md` ve `AGENTS.md` için resmî v09 PDF'inin 3–4. maddeleri okundu. Commit ve push yapılmadı.
