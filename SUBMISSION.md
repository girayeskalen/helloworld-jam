# Oyun teslim taslağı

**ARTÇI v0.1 yerel prototipi hazır; henüz resmî teslim yok.** Köşeli parantezler doldurulacak alanlardır. Bu belge hazırlık içindir; organizasyonun web formunun yerine geçmez.

Kural kontrolü: **16 Ekim 2026, güncel v09**. [Resmî kurallar](https://game.ktimo.com.tr/kurallar) · [Kural kitapçığı](https://game.ktimo.com.tr/assets/CIVIL_GAME_JAM_Kural_Kitapcigi_v09.pdf) · [Takım teslim ekranı](https://game.ktimo.com.tr/jam/teslim)

## Doldurulacak bilgiler

- Oyun adı: ARTÇI — AFTERSHOCK: Tactical Rewind
- Kısa açıklama ve temayla bağlantı: Afet hazırlığı ve farkındalık için 2D taktiksel öngörü, geri sarma, müdahale ve tahliye oyunu.
- Platform: Masaüstü web (Vite + TypeScript + Canvas 2D + Web Audio API)
- Test edilmiş oynanabilir sürümün ZIP dosyası: [dosya adı ve boyutu; en fazla 10 GB]
- Web oyunuysa ayrıca oynama bağlantısı: [HTTPS; hesapla giriş veya özel izin istememeli]
- Ayrı video dosyası: [MP4 veya AVI; en fazla 1 dakika ve 5 GB; oyun içi görüntüler veya trailer]
- Public repo: https://github.com/girayeskalen/helloworld-jam
- Gereksinimler ve kurulum: [doldurulacak]
- Başlatma adımları: [ZIP'ten açılacak gerçek dosya veya web sürümünün adımları]
- Oyunun amacı ve kontrolleri: [doldurulacak]
- Bilinen sorunlar ve varsa geçici çözümleri: [doldurulacak]
- Hazır kaynak beyanı: [görsel / ses / kod / metin / diğer kategorilerinin her birinde kullanım seçimi; kullanılanlarda kaynak, sağlayıcı, lisans ve kullanım açıklaması]
- AI beyanı: [aynı beş kategorinin her birinde kullanım seçimi; kullanılanlarda araç, amaç ve oyundaki kullanım yeri]
- Kaynak ve AI kayıtlarının dayanağı: [BEYAN.md](BEYAN.md) ve önceki araştırma için [SOURCES.md](SOURCES.md) içindeki gerçek kullanım bilgileri.
- Güncel kurallar ve teslim koşullarının kabulü: [temsilci kontrol edecek]
- Takım temsilcisi: [gerçek kişi]

Video bağlantısı, video dosyası yüklemenin yerine geçmez. ZIP ve video ayrı yüklenir. Web oyununda oynama bağlantısı da ZIP'in yerine geçmez.

## Kaynak sürümünü iç kayıtta tutma

Teslim edilen ZIP içindeki build ile public repodaki kaynak proje uyumlu olmalı. Hangi kaynaktan paketlediğimizi izlemek için final kaynak commitinin tam kimliğini `git rev-parse HEAD` ile ayrıca kaydedebiliriz. **Bu bir iç takip önerisidir; güncel v09 teslim alanlarında ayrı bir tam commit kimliği alanı zorunlu tutulmuyor.** Hazırlık dokümantasyonu commitini oyun sürümü olarak göstermeyin.

- Paketlenen kaynak commitinin tam kimliği: [oyun hazır olduğunda iç kayda alınacak]
- ZIP ve video dosya adları: [doldurulacak]
- Son başarılı web tesliminin makbuz numarası, sürümü ve kayıt zamanı: [yükleme doğrulandıktan sonra özel kayıtta saklanacak]

## Son kontrol

- [ ] Oyun yarışmanın 48 saatlik geliştirme süresinde üretildi.
- [ ] Çalışması için gereken dosyalarla birlikte ZIP hazır; en fazla 10 GB.
- [ ] ZIP içeriği ikinci bilgisayarda gerekli koşullar sağlanarak çalıştırıldı.
- [ ] Web oyunuysa oynama bağlantısı HTTPS ile, hesapla giriş yapmadan açılıyor.
- [ ] Video MP4/AVI biçiminde, en fazla 1 dakika ve 5 GB; açılıyor, ses ve görüntü kontrol edildi.
- [ ] Public repo, katılımcı hesabına giriş yapılmadan açılıyor.
- [ ] ZIP içindeki build ile public kaynak kod aynı oyun sürümünü temsil ediyor.
- [ ] Hazır kaynakların beş kategorisi de yanıtlandı; kullanılanların kaynak, lisans ve kullanım bilgileri tam.
- [ ] AI'ın beş kategorisi de yanıtlandı; kullanılanlarda araç, amaç ve gerçek kullanım yeri açıklandı.
- [ ] Yeniden dağıtımı kısıtlı ham assetler ve gizli bilgiler public repoda yok; gerekli edinme/kurulum bilgileri var.
- [ ] Kurulum ve kontroller anlaşılır; doldurulacak alanlar tamamlandı.
- [ ] Hak sahipleri kullanım iznini okudu ve temsilcinin teslim yetkisini onayladı.
- [ ] Video dahil toplam 3 dakikalık sunum hazır; video anlatım sırasında arkada oynayacak, jüri aynı sırada oyunu oynayıp puanlayacak; ek video veya soru-cevap süresi yok.
- [ ] ZIP ve video ikisi de yüklendi ve doğrulandı; makbuz numarası, sürümü, kayıt zamanı ve dosya adları kontrol edildi.
- [ ] Yükleme kaydı son saatten önce sunucuda oluştu; sonrasında aynı oyun sürümü, dosyalar ve kayıtlı teslim bilgileri korunacak.

Yeni teslim veya yeni sürüm başlatmak için **18 Ekim 2026, 18.00 (UTC+3) öncesinde sunucuda yükleme kaydı oluşmalı**. Yalnız gönderme düğmesine basmak yeterli değil. Zamanında başlatılan aynı ZIP/video aktarımı uzun sürerse sonra tamamlanabilir; aynı dosyalar ve kayıtlı bilgiler korunur. Bu izin ek geliştirme, dosya veya bilgi değiştirme ya da yeni sürüm başlatma izni değildir. Makbuz ancak iki dosya da yüklenip doğrulanınca oluşur; makbuz oyunun çalışırlığına veya kurallara uygunluğuna onay sayılmaz. Son başarılı teslim değerlendirmede esas alınır. Başarısız güncelleme, önceki başarılı teslimi geçersiz kılmaz (5.4).

Public repo ve varsa web oyunu değerlendirme bitimine kadar erişilebilir kalacak. Son saatten sonra değerlendirilecek oyun sürümü değiştirilmeyecek.

## Ekip hak sahiplerinin bilmesi gereken izin

PDF'nin 9. maddesine göre oyun ve özgün içerik hakları ilgili ekip üyelerinde kalır. Organizasyona bedelsiz, dünya genelinde, süresiz ve münhasır olmayan ticari olmayan kullanım izni verilir; ücretsiz yayımlama/dağıtma ve eğitim amaçlı uyarlama da kapsamdadır. Aynı kapsamla üçüncü kişilere yeniden izin verilebilir. Ticari kullanım ayrıca anlaşma gerektirir; ekip/oyun adına atıf ve uyarlamayı belirtme koşulları korunur. Üçüncü taraf lisansları genişlemez. Temsilci, teslim öncesinde ilgili hak sahiplerinin bu izni bildiğini ve onayladığını teyit eder; bu dosyanın hazırlanması o onayın alındığı anlamına gelmez.

Takım erişim kodunu ve kişisel başvuru kayıtlarını bu public dosyaya yazma. Teslim ekranına organizasyonun temsilciye verdiği kodla giriş yapılacak; ekran organizasyon teslimi açtığında kullanılabilir.
