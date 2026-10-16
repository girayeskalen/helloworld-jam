# Yarışma öncesi hazırlık

Kural ve teslim yönergeleri **16 Ekim 2026'da güncel v09 kitapçığıyla** kontrol edildi. [Güncel kitapçık](https://game.ktimo.com.tr/assets/CIVIL_GAME_JAM_Kural_Kitapcigi_v09.pdf).

**16 Ekim, 18.00 sonrası notu:** Aşağıdaki yarışma öncesi plan tarihli hazırlık kaydıdır. Kullanıcı temayı bildirdi ve sonrasında başka bir oyun fikri seçtiğini açıkladı; yeni fikrin ayrıntıları henüz aktarılmadı. [GAME_DESIGN.md](GAME_DESIGN.md) seçilmeyen önceki önerinin arşividir; güncel görevler STATUS.md içinde. Aynı gün v09 PDF'sinin 13 sayfası, ekler ve teslim kontrol listesi doğrudan okunup sayfa görüntüleriyle kontrol edildi.

Bu rehber, ilk kez oyun yapacak iki kişi için önerilen sıradır. Kazanma hedefimizi, temaya iyi uyan ve düzgün çalışan küçük bir oyunla destekleyeceğiz. Oyunun fikri ve mekanikleri tema açıklandıktan sonra belirlenecek.

## Şu anki durum ve yarışmaya kadar plan

14 Ekim 2026'da kullanıcı kesin katılım onayının geldiğini bildirdi; başvuru ve onay tamamlandı. Bu bilgisayarda Godot 4.7.2 daha önce açıldı; 14 Ekim kontrolünde standart export şablonu klasörü hâlâ boş. Diğer bilgisayarın tam sürümü ve export hazırlığı teyit edilmedi.

Aşağıdaki tarihler ekibimizin önerilen çalışma sırası; yarışmanın ek zorunlulukları değil. Tamamlanan adımı yeniden yapmayın. Şimdi oyunu geliştirmek yerine yarışma sırasında kullanacağımız araçlara ve iş düzenine hazırlanıyoruz.

| Zaman | Yapılacak hazırlık | Tamamlandığını nasıl anlayacağız? |
| --- | --- | --- |
| 11–12 Ekim | Temsilci, başvuru kaydını ve gelecek organizasyon mesajlarını takip etsin. İki bilgisayarda aynı Godot sürümü ve Windows export şablonları kontrol edilsin. | Başvuru kaydı saklandı; onay ayrı takip ediliyor. Motor açılıyor ve gereken şablon dosyaları mevcut. |
| 12–13 Ekim | Repo dışında ayrı bir boş eğitim alanında sahne, node, Inspector, kaydetme ve çıktı/hata paneline alışın; genel export sürecini öğrenin. | Boş araç denemesinin çıktısı diğer bilgisayarda editör olmadan açılabiliyor. Yarışma için kod veya içerik üretilmedi. |
| 13–14 Ekim | Genel dokümanlarla ortak Git düzenini prova edin; kaydetme, commit, push ve pull arasındaki farkı öğrenin. | Bir genel doküman değişikliğini iki kişi görebiliyor; aynı dosyaya eşzamanlı görev verilmemiş. Commit/push yalnız kullanıcı talebiyle yapılır. |
| 14–15 Ekim | İyi oyunları değerlendirirken kullanacağınız kısa bir kontrol listesi çıkarın; kaynak lisanslarını inceleyin. Video ve ses kaydını deneyin. | Kontrollerin anlaşılabilirliği için sorularınız hazır; kaynak adaylarının lisans bağlantıları var; kısa kayıt dosyası izlenebiliyor. |
| 15 Ekim | Ulaşım, cihazlar, şarj cihazı, fare ve kulaklığı hazırlayın. Motorun ve belgelerin internet olmadan açıldığını kontrol edin. | İki bilgisayarın araçları ve yerel belgeleri erişilebilir; mekâna ulaşım planı net. Codex'in internet erişimi ayrıca gerekli. |
| 16 Ekim, 18.00 öncesi | Katılım onayı, ekipman ve araçların son kontrolünü yapın; resmî duyuruları takip edin. | Oyuna özgü üretime başlanmamış; 18.00'de açıklanan tema için çalışma düzeni hazır. |

Eğitim ve boş export denemesi, aşağıda açıklanan genel araç öğrenimi yorumumuza dayanır. Bu dosyalar yarışma reposunun dışında kalacak; oyuna aktarılmayacak.

Teknik kodlama ve proje dosyalarını yarışma sırasında Codex üstlenecek. Sizin öncelikli öğrenmeniz gerekenler oyunu açmak, oynamak, değişiklikleri paylaşmak ve bir hatayı anlaşılır anlatmak. Bir hata bildirirken **ne yaptım, ne bekledim, ne oldu ve hata çıktısı neydi** bilgilerini yazın. Görsel bir sorun varsa ekran görüntüsü; davranış sorunu varsa kısa video yardımcı olur. Şifre ve erişim kodu paylaşmayın.

Küçük oyunları incelerken genel sorular sorun: amaç ve kontroller hemen anlaşılıyor mu, kaybetme nedeni belli mi, yeniden denemek kolay mı, görüntü ve ses aynı deneyimi destekliyor mu? Bu öğrenme oyununuzun fikrini önceden hazırlamak veya başka bir oyunu kopyalamak için değil, yarışma sırasındaki test alışkanlığı içindir.

Hazır kaynak adayları için [Kenney'nin lisans açıklamasını](https://kenney.nl/support) inceleyebilirsiniz; asset sayfalarındaki kaynaklar CC0 olarak sunuluyor. Kullanmayı seçtiğiniz paketin kendi sayfasını ve lisansını ayrıca kontrol edin. Genel lisanslı kaynakları repo dışında saklayın; yarışma oyununa ekledikçe SOURCES.md içine gerçek kullanımını yazın. Ücretsiz olmak tek başına paylaşım izni değildir.

Windows'ta kısa bir uygulama kaydı denemesi için Xbox Game Bar kullanılabilir: **Win+G** kontrolleri açar, **Win+Alt+R** kaydı başlatır/durdurur. Game Bar'ın etkin ve ilgili uygulama penceresinin açık olması gerekir. Kaydı açıp görüntü ve sesi gerçekten kontrol edin; kullanılamıyorsa farklı kayıt aracı seçilir. [Microsoft'un Türkçe rehberi](https://support.microsoft.com/tr-tr/accessibility/windows/use-a-screen-reader-to-record-your-screen-with-xbox-game-bar). Deneme kaydı yarışma teslim videosu değildir; oyun içi görüntü veya trailer içeren gerçek teslim videosu oyun oluşunca hazırlanacak. Güncel kurala göre video en fazla 1 dakika olmalı ve ZIP'ten ayrı MP4/AVI dosyası olarak yüklenmeli.

## Kurallardaki sınır

[CIVIL GAME JAM kuralları](https://game.ktimo.com.tr/kurallar), madde 3.1: motor kurulumu, genel araç hazırlığı ve kullanım hakkı bulunan kaynakların edinilmesi ön hazırlık olabilir. Oyuna özgü geliştirme etkinliğin 48 saatinde yapılır.

- Şimdi: başvuru, motor kurulumu, ekip iş bölümü, Git öğrenimi, teslim ve beyan kayıtları.
- Tema açıklandıktan sonra: yarışma oyununun tasarımı, kodu, mekanikleri, seviyeleri ve oyuna özel görsel/ses üretimi.
- Kendi hareket, savaş veya envanter sistemimizi önceden yazıp adına "template" demek zaman kuralını değiştirmez.
- Motor arayüzünü öğrenme ve ayrı bir boş eğitim projesinde export denemesi, genel araç öğrenimi olarak yorumumuzdur; kurallar bu deneyi ismen saymıyor. Eğitimde üretilen projeyi/kodu yarışma oyununa taşımayacağız.
- AI izni, geliştirme zamanını değiştirmez. Gerçek kullanımı SOURCES.md içinde kaydedeceğiz.

## 1. Başvuru ve katılım onayı

Normal başvuru sonu: **11 Ekim 2026, 23.59 (UTC+3)**.

**Sizin başvurunuz ve kesin katılım onayınız tamamlandı** (kullanıcı bildirimi: 14 Ekim 2026). Aşağıdaki adımlar genel rehber olarak korunuyor; aynı başvuruyu tekrar göndermeyin.

1. Takım adını ve iki üyeden hangisinin temsilci olacağını belirleyin.
2. [Başvuru sayfası](https://game.ktimo.com.tr/basvuru) → **Yarışmacı başvurusu** → **Takım olarak** seçin.
3. İki üyenin gerçek iletişim ve katılım bilgilerini doldurun; kitapçığı ikiniz de okuyun.
4. Onay kutusundan sonra **Kontrol et** → **Başvuruyu gönder** adımlarını tamamlayın.
5. Başvuru numarasını saklayın; organizasyonun katılım onayını ayrıca bekleyin. STATUS.md içinde yalnız durum bilgisini güncelleyin.

Başvuru, GitHub depo davetinden ayrıdır. Etkinlik yüz yüze; ulaşım planını da yapın. Takım erişim kodunu, telefonları ve diğer kişisel kayıtları public repoya koymayın.

### Takım, mekân ve cihaz koşulları

v09 PDF, 2.6 ve 11. maddeleri ile EK B:

- Takım 2–4 kişi olmalı. Yarışma başladıktan sonra çekilen üye geri dönemez ve yerine yeni üye alınamaz; iki kişilik ekibimizde bir üyenin çekilmesi alt sınırın altına düşürür. Kişisel kısa giriş çıkışlar, ekipten çekilmekle aynı şey değildir.
- Kişilerin giriş çıkışı serbest; bilgisayarlar yarışma sırasında etkinlik alanından çıkarılamaz. Arıza veya yarışmadan çekilmede organizasyon onayıyla çıkarılabilir.
- Bina içinde elektronik ve bitkisel ürünler dahil tütün tüketimi yasak; kitapçık bu ihlali ilgili üyenin ve tüm takımın elenmesine bağlıyor. Kampüs ve bina içinde alkol bulundurmak/tüketmek de yasak.
- Ayrı uyku tesisi ve alanda görevli sağlık personeli yok. Kitapçıkta küçük yastık/battaniye dağıtımı ve Crew/kampüs güvenliği üzerinden acil durum koordinasyonu belirtiliyor; sağlık ve yaya haritası bilgileri EK C'de.
- Oyun hakları ve geniş ticari olmayan kullanım izni için 9. maddeyi iki üye de okumalı; kısa açıklama SUBMISSION.md içinde. Teslimi temsilci yürütür.

## 2. İki bilgisayarda aynı çalışma düzenini hazırlayın

Arkadaşın kendi proje klasöründe README.md içindeki Git kimliği ve pull adımlarını uygulasın. Yerel değişiklik varsa önce durumu birlikte değerlendirin.

- Biriniz proje/kod değişikliklerini takip etsin.
- Diğeriniz oynayarak test, kaynak kayıtları, video ve teslim hazırlığını takip etsin.
- Bunlar önerilen sorumluluklar; ikiniz de test yapacaksınız. Gerçek isimleri STATUS.md içine yazın.
- Aynı dosyada aynı anda çalışmadan önce haberleşin. Codex'e verilen görevin kapsamını ve dokunacağı dosyaları belirtin.

## 3. Seçilen motoru hazırlayın

Seçim: **standart Godot 4.7.2 + GDScript**, başlangıç yaklaşımı Compatibility, küçük bir 2D oyun ve ilk teslim hedefi Windows x86_64. [Karşılaştırma ve gerekçeler](ENGINE_DECISION.md). Bu bilgisayarda proje yöneticisi açıldı ve terminalden tam sürüm doğrulandı; export şablonları henüz yok. Arkadaşın bilgisayarındaki kurulum teyit edilmedi. Yeniden motor indirmeye gerek yok; tamamlanan adımı tekrar yapmayın.

1. [Godot Windows indirme sayfasını](https://godotengine.org/download/windows/) açın. 11 Ekim 2026 kontrolünde kararlı sürüm **4.7.2**.
2. Windows x64 bilgisayarda **Godot Engine 4.7.2 / x86_64** seçin. Standart sürümü kullanacağız; `.NET` seçeneği C# içindir. Diğer bilgisayarın işletim sistemi ve mimarisini ayrıca kontrol edin.
3. ZIP dosyasına sağ tıklayıp **Tümünü ayıkla** seçin. Godot'u yarışma repo klasörünün dışında bir araç klasörüne çıkarın; editör EXE dosyasını açın. Proje yöneticisinin açılması ilk kontrolümüzdür.
4. İkiniz de aynı tam editör sürümünü kullanın. Sürümü ve açılma sonucunu STATUS.md içine yazın.
5. Genel araç öğrenimi için proje yöneticisindeki yeni proje oluşturma düğmesini kullanın. Adı `egitim-deneme`, klasörü repo dışında boş bir eğitim klasörü olsun; **Compatibility** seçip projeyi oluşturun ve editörde açın. Bu ayrı eğitim projesi yarışma oyununa taşınmayacaktır. Proje açılınca aşağıdaki **Editor** menüsü görünür. [Resmî proje oluşturma rehberi](https://docs.godotengine.org/en/stable/getting_started/first_2d_game/01.project_setup.html).
6. Editörde **Editor → Manage Export Templates** açın. Gereken Windows platformu/mimarisini seçip **Install Selected Templates** ile dosyaları kurun. Şablonlar editör sürümüyle eşleşmeli.

Kaynaklar: [sistem gereksinimleri](https://docs.godotengine.org/en/stable/about/system_requirements.html), [export araçları](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html).

Export, editördeki projeden oyuncunun çalıştıracağı sürümü hazırlamaktır. Proje yöneticisini açabilmek ile oyunu teslim edebilmek ayrı kontrollerdir. Kurulum hatasını aynen kaydedin; başarısız adımı tamamlandı işaretlemeyin.

## 4. Başlangıca kadar öğrenilecekler

Her kavramı küçük bir adımda öğrenin:

- Sahne: Godot'ta birlikte kullanılan öğelerin düzeni.
- Node: sahnedeki tek bir öğe; örneğin bir yazı veya görsel.
- Inspector: seçili öğenin ayarlarının gösterildiği bölüm.
- Kaydetmek, Git commit oluşturmak ve push yapmak arasındaki fark.
- Export ekranı ve hata mesajlarını okumak.

Bu aşamada yarışma için karakter hareketi, oyun menüsü, puan sistemi veya bölüm hazırlamayacağız. SOURCES.md ve SUBMISSION.md kayıtlarının ne istediğini öğrenmek yeterli.

## 5. Tema açıklandığında başlayacak çalışma

Planlanan başlangıç **16 Ekim 2026, 18.00 (UTC+3)**. Resmî tema ve güncel duyuruyu kontrol edin.

Önerilen çalışma sırası:

1. Temayı birlikte anlayıp tek ana mekaniği olan küçük bir fikir seçin. Çok oyunculu, büyük 3D dünya veya hesap sistemi gibi kapsamlar ilk deneyimimiz için hedef değil.
2. Her seferinde tek görevle çalışın; Codex'in yaptığı değişikliği açıp deneyin. Bir hata varsa yeni özellikten önce hatayı düzeltin.
3. İlk çalışan sürümü erken hazırlayın; iki bilgisayarda test edin.
4. Kalan sürede kontrolleri, tema bağlantısını, görsel/ses uyumunu ve hataları iyileştirin.
5. Son altı saati teslim kontrollerine ayırmayı hedefleyin. Test edilmiş oyun ZIP'i (en fazla 10 GB), ayrı MP4/AVI videosu (en fazla 1 dakika ve 5 GB), public repo, web oyununda ayrıca oynama bağlantısı ve kategori bazlı beyanlar SUBMISSION.md üzerinden hazırlanacak. Kaynak/build uyumu için tam commit kimliğini iç kayıt olarak tutabiliriz; güncel formda ayrı bir zorunlu alanmış gibi sunmayacağız. Video dahil toplam 3 dakikalık sunumu da prova edin.

Yeni teslim/sürüm başlatmak için **18 Ekim 2026, 18.00 (UTC+3) öncesinde** sunucuda yükleme kaydı oluşmalı; yalnız düğmeye basılması yeterli değil. Zamanında başlatılan aynı ZIP/video aktarımı sonradan tamamlanabilir; bu ek geliştirme veya dosya değiştirme izni değil. ZIP ve video doğrulandıktan sonra makbuzu kontrol edin. Git desteği gerekiyorsa **18 Ekim 12.00'ye kadar** isteyin. Bunlar yarışma takvimi; yukarıdaki iş sırası ise ekibimiz için öneridir.
