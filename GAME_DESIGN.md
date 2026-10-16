# Arşiv: seçilmeyen oyun fikirleri ve tasarım önerisi

Tarih: **16 Ekim 2026, 18.00 sonrası (UTC+3)**. Kullanıcı temayı **“Afete hazırlık ve farkındalık”** olarak bildirdi; ayrıca zorunlu afet türü, yaş grubu veya başka bir koşul açıklanmadığını belirtti. Tema, bu çalışmada organizasyonun sitesinden bağımsız olarak doğrulanmış değildir.

**Durum: seçilmedi; geçmiş tasarım araştırması olarak korunuyor.** Ekip, 16 Ekim 2026'da başka bir oyun fikri seçtiğini bildirdi. Yeni fikrin ayrıntıları ve uygulama talimatları henüz paylaşılmadı. Bu belgenin aşağıdaki önerileri yeni oyunun görevleri veya kabul edilmiş tasarımı değildir; yalnız önceki araştırmanın kaydıdır. Bu belgeyle oyun kodu, Godot projesi veya asset üretilmedi. Kayıt sırasında motor kararı standart Godot 4.7.2 + GDScript, Compatibility, küçük 2D oyun ve ilk teslim hedefi Windows x86_64 idi.

## Kararı neye göre veriyoruz?

İki kişilik ekip oyun geliştirmede başlangıç seviyesinde; teknik üretim Codex ile yürütülecek. İnsanların görevi yaratıcı seçim yapmak, gerçek sürümleri oynamak, anlaşılmayan noktaları bildirmek ve teslim/sunum sorumluluğunu üstlenmek. İki bilgisayar olması oyunun çevrimiçi iki oyunculu yapılmasını gerektirmiyor.

[Güncel resmî kuralların](https://game.ktimo.com.tr/kurallar) 7. maddesindeki ağırlıklar: oynanabilirlik 25, temayla ilişki 25, yaratıcılık 20, görsel/işitsel bütünlük 15, teknik bütünlük 15. Aşağıdaki değerlendirmeler tasarım yargısıdır; jüri puanı veya kazanma olasılığı tahmini değildir.

Karar ilkeleri:

- Hazırlık, oyuncunun yaptığı işin ve sonucun içinde görülmeli.
- İlk hedef yaklaşık 10–15 saniyede anlaşılmalı; ilk anlamlı sonuç uzun bir eğitimden önce gelmeli. Bunlar test edilecek hedeflerdir.
- Az içerik içinde birbirini etkileyen kararlar bulunmalı. Çok sayıda doğru cevaba tıklamak yeterli değil.
- Tek bir afet odağı ve birkaç doğru hazırlık ilişkisi, bütün afetleri yüzeysel anlatmaktan daha uygulanabilir.
- Gerçek güvenlik bilgisiyle oyunun basitleştirilmiş kuralları ayrılmalı.
- Çalışan, tamamlanmış bir küçük oyun; çok sistemli fakat yetişmemiş bir projeden daha uygun hedef.

## Farklı oyun yönleri

| Fikir | Oyuncu ne yapar? | Temayı nasıl taşır? | Başlıca güçlük | Bu ekip için karar |
| --- | --- | --- | --- | --- |
| **ÖNCE — Aynı Oda, İki Sonuç** | Eşyaları ortak kullanılan konumlara yerleştirir; aynı olay senaryosunda sonuçları karşılaştırır. | Hazırlık kararının görünür etkisi vardır. | Yerleşim kararları birbirini etkilemezse kontrol listesine dönüşür. | **Birinci öneri; gerçek yerleşim bulmacası şartıyla.** |
| **Son Bağlantı** | Mahalle iletişim planında bağlantılar kurar; bir bağlantı devre dışıyken bilgi erişimini sürdürür. | Önceden anlaşma ve yedek plan önem kazanır. | Afet bağlamı zayıf kalırsa genel kablo bulmacasına dönüşür. | Güçlü ikinci seçenek; az görsel gerektirir. |
| **Tatbikat Trafiği** | Kurmaca mahallede önceden tanımlı güzergâhlardaki tatbikat akışını yönlendirir. | Planın provada sınanmasını gösterir. | Hareket, kuyruk, rota ve hız dengesi; yanlış tahliye çağrışımı. | Canlı oynanış potansiyeli yüksek, ilk proje için daha riskli. |
| **Sinyal Gürültüsü** | Kısa mesajları doğrular, güvenilir bilgiyi ulaştırır, söylenti zincirlerini keser. | Bilgi kirliliği ve güvenilir kaynak farkındalığı. | Fazla okuma ve çoktan seçmeli teste dönüşme; her mesajın doğrulanması. | Farklı bir yaklaşım; içerik yükü yüksek. |
| **Aynı Anda** | Birkaç ekibin hazırlık görevlerini sıraya koyar; planı paylaşmadan provaya geçmenin etkisini görür. | Ortak plan ve koordinasyon doğrudan kural olur. | Komut sırasını öğretmek ve başarısızlığın nedenini göstermek. | Küçük tutulursa yapılabilir; ilk dakikası daha zor. |
| **Altı Hafta Önce** | Birkaç turda zaman ve ekip gücünü hazırlık faaliyetlerine ayırır. | Planlama, paylaşma ve prova birbirini tamamlar. | Sayı ve kart dengesi; elektronik tablo hissi. | Strateji seven hedef kitleye uygun; bu ekip için ikinci planda. |
| **Hazırlık Atölyesi** | İstasyonları düzenler, hazırlık görevlerini ve malzeme akışını koordine eder. | Bireysel çantadan daha geniş toplu hazırlığı işler. | Taşıma/üretim sistemleri temanın önüne geçebilir. | 48 saatlik ilk sürüm için fazla sistem içeriyor. |
| **Çanta yerleştirme bulmacası** | Eşyaları sınırlı alana yerleştirir, kişisel ihtiyaçları dikkate alır. | Hazırlık malzemelerini tanıtır. | Gerçek ihtiyaçları sırf puan/yer için dışlama, yanlış tam liste izlenimi. | Ana oyun yerine dikkatle doğrulanacak küçük ek fikir. |

Trafik ve ağ fikirleri, oda önerisine karşı ayrıca değerlendirildi. Trafik daha hareketli; ağ daha az görsel istiyor. Oda fikrinin avantajı, hazırlıkla sonuç arasındaki bağı küçük bir sahnede açıklayabilmesi. Sadece “doğru düğmelere bas” sürümü yapılacaksa oda fikri tercih edilmeyecek.

Afet odağı için deprem, sel ve yangın hazırlığı da düşünüldü. Sel odağında küçük bir mahalle planlama bulmacası; yangın odağında önceden düzenleme ve planı paylaşma oyunu kurulabilir. Ancak su yayılımı, bina yıkımı veya duman fiziğini gerçekçi modellemek ilk sürümün hedefi değil. Genel tema bütün afetleri tek oyunda anlatmayı zorunlu kılmıyor; kullanıcı ek koşul olmadığını bildirdi. Bir afete odaklanmak kapsam tercihimiz, diğer afetler için aynı davranışların geçerli olduğu iddiası değil.

## Birinci öneri: ÖNCE — Aynı Oda, İki Sonuç

Çalışma adı kesin değil. Kısa anlatım: **“Bir odayı hazırlıyorsun; aynı senaryoyu yeniden gördüğünde, yaptığın küçük değişikliklerin etkisini fark ediyorsun.”**

Tür: sakin tempolu, tek oyunculu 2D yerleşim bulmacası. Sabit kamera, okunaklı oda kesiti veya üstten görünüş. İlk hedef kitle gençler ve yetişkinler; resmî yaş sınıflandırması yapılmış değildir. Bir tam deneme için yaklaşık 3–5 dakika hedeflenir; sunumda ana farkın 45–60 saniyelik kesitte gösterilebilmesi amaçlanır.

**v09 PDF kontrolünden çıkan tasarım önceliği (7.3, s.6):** Jüri üç dakikalık sunum sırasında oyunu da oynayıp puanlıyor. Bu nedenle ilk anlamlı karar ve görünür sonuç, oyunu ilk kez açan kişinin de yaklaşık ilk dakikada deneyimleyebileceği şekilde tasarlanmalı. Yalnız videoda kısa kesit göstermek yeterli bir varsayım değil. 3–5 dakikalık tam tur hedefi bir kural ihlali değil; girişte uzun eğitim veya sonuca kadar uzun bekleme bu sunum düzenine uygun olmayabilir. İlk dakika hedefi ekibimizin tasarım tercihi; kuralda ayrıca bir oynanış süresi sınırı yok.

Hikâye çerçevesi, önceden yapılabilen hazırlık ve oyun içi bir denemedir. “90 saniye sonra gerçek deprem olacak” geri sayımı kullanılmaz. Olayı oyuncu **Senaryoyu dene** düğmesiyle başlatır; bu düğmenin bir gerçek deprem tahmini olmadığı bağlamdan anlaşılır.

### Asıl oynanış

1. Oyuncu odada bir nesneyi seçer.
2. Yerleştirilebileceği iki veya üç konum görünür; bunlar yalnız doğru cevaplar değildir.
3. Oyuncu bir konuma tıklar. Ortak kullanılan konumlar ve erişim ilişkileri değişir.
4. Üç görünür hazırlık hedefini aynı anda sağlamaya çalışır.
5. Senaryoyu başlatır, sonuçları görür ve düzenini değiştirerek yeniden dener.

İlk hedef **dört taşınabilir nesne, beş veya altı konum ve üç hedef**. Bunlar gerçek ev ölçüsü veya güvenlik standardı değil, bulmacanın kapsamıdır. Serbest sürükleme, döndürme, karakter dolaştırma ve gerçekçi fizik ilk sürümde yok.

Örnek karar: geçişteki kutuyu kaldırmak gerekiyor; fakat onu hazırlık malzemesinin önüne bırakmak başka bir erişim sorununa yol açıyor. Alt konumdaki yeri ağır eşya için kullanmak istiyorsan oradaki nesneye başka yer bulmalısın. Böylece her nesnenin tek bir “doğru” düğmesi olmuyor; bütün düzeni düşünmek gerekiyor.

Bir nesneyi seçebilmek için çok küçük veya görünmez ayrıntıları avlamak gerekmemeli. Konumun dolu olması ile hazırlık hedefini karşılamaması ayrı gösterilmeli. Kurallar görünür olmalı; çözüm, oyuncu düşünmeden yeşil noktaya tıklamaya indirgenmemeli.

### Kararların birbirini etkilediği örnek

Bu, uygulanmış veya oynanmış bir bölüm değil; bulmacanın neden yalnız kontrol listesi olmayabileceğini gösteren tasarım örneği:

| Nesne | Başlangıç konumu | Örnekteki konum seçenekleri |
| --- | --- | --- |
| Ağır eşya kutusu | Üst raf | Üst raf / alt raf |
| Hazırlık malzemesi | Alt raf | Alt raf / erişilebilir köşe |
| Depo kutusu | Geçiş alanı | Geçiş alanı / depolama yeri |
| Hafif tekstil kutusu | Erişilebilir köşe | Erişilebilir köşe / depolama yeri / üst raf |

Başlangıçta depolama yeri boş. Oyuncu hafif kutuyu geçici olarak oraya alır; hazırlık malzemesini köşeye, ağır eşyayı alt rafa taşır. Boşalan üst konuma hafif kutuyu aldıktan sonra depo kutusunu depolama yerine koyabilir. Böylece geçişi açma, ağır eşyayı alçaltma ve malzemeye erişim hedefleri birlikte çözülebilir. Yanlış sırayla kullanılan boş yer başka bir işi bekletebilir; geri alma serbesttir.

Bu örnek yalnız konumların doluluğunu ve karar sırasını açıklar; gerçek raf kapasitesi, güvenli montaj veya eksiksiz ev güvenliği modeli değildir. Sahnenin okunurluğu, seçimin anlamlılığı ve eğlencesi ancak gerçek bir denemeyle anlaşılacak. Bu düzen zoraki gelirse kural/nesne sayısını artırmak yerine düzen sadeleştirilecek.

### İlk üç öğrenme hedefi

| Hedef | Oyun içindeki karşılığı | Gerçek bilgi dayanağı / sınır |
| --- | --- | --- |
| Düşebilecek ağır eşyayı ve devrilebilecek mobilyayı fark etmek | Eşyanın konumu veya uygun önlemi, o nesnenin senaryo sonucunu değiştirir. | USGS ağır/kırılgan eşyaları alçak raflara alma ve uygun sabitleme önerilerini listeler. Bu, binanın taşıyıcısını güçlendirmek değildir. |
| Geçişi önceden engellerden arındırmak | Bir nesneyi kaldırmak başka bir alanı kapatmamalı; oda düzeni birlikte çözülür. | FEMA hazırlık eğitiminde çıkış yollarını açık tutma yer alır. Bu genel ilke, sarsıntı sırasında dışarı koşma görevi olarak kullanılmayacak. |
| Hazırlık malzemelerine erişimi düşünmek | Malzeme yalnız sahnede bulunmakla kalmaz; bulmacanın temsil ettiği erişim koşulunu karşılar. | AFAD ve USGS önceden malzeme hazırlamayı ele alır. Bir oyun çantası eksiksiz gerçek ihtiyaç listesi gibi sunulmayacak. |

Bilgi kaynakları: [USGS hazırlık, eşya ve yapı güvenliği](https://www.usgs.gov/programs/earthquake-hazards/earthquake-facts-earthquake-fantasy), [AFAD deprem öncesi/ anı/sonrası](https://afad.gov.tr/deprem-oncesi-ani-ve-sonrasi-onlemini-al-guvende-kal), [FEMA hazırlık eğitimi](https://emilms.fema.gov/is_0036a/groups/166.html). FEMA sayfası çocuk bakım hizmetleri için hazırlanmış bir eğitimdir; yerel mevzuat veya KKTC'ye özel talimat olarak kullanılmıyor. AFAD sayfası tarama aracında hata verdi; doğrudan HTTP erişimiyle metni kontrol edildi. Her somut nesne/yerleşim kuralı, üretime alınmadan önce bu genel hedeflerle ayrıca eşleştirilecek.

Aile iletişim planı, buluşma yerini önceden konuşma ve farklı ihtiyaçları gözetme de tema açısından değerli. Ancak ilk çalışan oyuna üç ayrı mini oyun olarak eklenmeyecek. Zaman kalırsa tek kısa ikinci düzen üzerinden ele alınabilir. [AFAD plan ve toplanma alanı](https://agri.afad.gov.tr/toplanma-alanina-erisim), [UNDRR kapsayıcı hazırlık](https://www.undrr.org/resource/training-course/disability-inclusive-disaster-risk-reduction-didrr-e-learning-course).

AFAD'ın Türkiye hizmetleri KKTC'de varmış gibi anlatılmayacak. Gerçek bir KKTC toplanma alanı, telefon veya kurum talimatı doğrulanmadan yazılmayacak; oyun haritası ve buluşma yeri kurmaca olacak.

### Sonuç gösterimi ve yeniden deneme

- Aynı düzen ve aynı seçimler aynı sonucu verir. İlk sürümde rastgele olay yok.
- Sonuç, karmaşık eşya çarpışmalarından hesaplanmaz; kaynaklarla eşleştirilip kontrol edilecek basitleştirilmiş oyun kurallarıyla belirlenir. Animasyon bu sonucu gösterir.
- Seçilen nesnenin yanında kısa bir neden–sonuç açıklaması görünür. Örneğin erişimi kapatan kutu işaretlenir; sonraki denemede bu ilişki tekrar görülebilir.
- Önceki ve sonraki düzenin iki veya üç farkı karşılaştırılır. İki tam simülasyonu aynı anda çalıştırmak gerekmez.
- Geri alma, başlangıca dönme ve yeniden deneme bulunur. Denemeler arasında eski ses/işaret/durum kalmaması kontrol edilir.
- Başarı ifadesi “Bu senaryonun hazırlık hedefleri tamamlandı” kapsamındadır. Ölüm sayısı, hayatta kalma yüzdesi veya “evin artık kesin güvenli” sonucu yok.

Özgünlük hedefi, aynı sahnedeki küçük değişikliklerin görünür sonuçları ve birbirine bağlı yerleşim kararlarıdır. Hazırlık yapıp sonuç görme yaklaşımının benzerleri vardır; bunu daha önce yapılmamış bir tür diye sunmuyoruz. [UNDRR'nin Stop Disasters öğretmen rehberi sayfası](https://www.undrr.org/publication/documents-and-publications/teaching-resilience-stop-disasters-game-teachers-guide) bu alandaki resmî bir örnektir. Sayfa incelendi; rehberin PDF'si, oyun kodu veya assetleri alınmadı.

### Görsel, ses ve erişilebilirlik

Tek perspektif, tutarlı küçük bir renk paleti, okunaklı eşya siluetleri. İlk sürümde izometrik/3D görünüş yok. Az nesne için yerleşim ve durum değişikliği anlaşılır hale getirilecek; görsel sayısını artırmak öncelik değil.

Hedefler yalnız renkle anlatılmayacak; simge ve kısa Türkçe yazı eşlik edecek. Fareyle seçim, belirgin odak, okunaklı metin, duraklatma, sesi kapatma ve azaltılmış hareket hedeflenecek. Kamera sarsıntısı varsayılan olarak hafif veya kapalı tutulabilir. Kontroller gerçek cihazda denenecek; yapılmadan erişilebilirlik testi geçti denmeyecek.

Ani çığlık, ölüm görüntüsü, zorunlu yüksek siren veya sürekli yanıp sönme kullanılmayacak. Kurmaca kişilerin farklı ihtiyaçları yeni hazırlık koşulları olabilir; kişinin kendisi başarısızlık/puan cezası olmayacak. [UNDRR kapsayıcı hazırlık kaynağı](https://www.undrr.org/resource/training-course/disability-inclusive-disaster-risk-reduction-didrr-e-learning-course).

## Kapsam ve bırakılacak işler

**İlk çalışan sürümde gerekli:** tek oda, dört nesne, birkaç ortak konum, üç anlaşılır hedef, kısa senaryo gösterimi, neden–sonuç geri bildirimi, geri alma/yeniden deneme, başlangıçtan sona ulaşan akış, temel ses/hareket seçenekleri, gerçek Windows çıktısı.

**Ancak ana sürüm tamamlanırsa:** ikinci oda düzeni, ikinci ihtiyaç profili, kısa iletişim planı katmanı, ek ses/animasyon, İngilizce metinler veya web çıktısı. Bunların hepsi birden hedeflenmeyecek.

**Bu sürüme alınmayacak:** çevrimiçi çok oyunculu sistem, büyük şehir, açık dünya, gerçekçi bina yıkımı, çok sayıda afet, uzun hikâye, karmaşık envanter, gerçek zamanlı AI API bağlantısı ve gerçek kişisel veri toplama. Ekipte iki kişi var diye iki oyunculu oyun zorunlu değil.

Gaz/elektrik müdahalesi, ilkyardım ve kurtarma gibi ayrı uzmanlık gerektiren görevler boşluk doldurmak için eklenmeyecek. Sarsıntı sırasında kaçış hızı ödüllendirilmeyecek. Eşyaları hazırlamak yapısal güvenlik incelemesinin yerine geçmeyecek. Sonuçlar, afet zararının bireyin hatasına indirgenmesi için kullanılmayacak.

## Üretim sırası ve karar noktaları

Takvim, etkinliğin 16 Ekim 18.00 başlangıcından itibaren geçen saatlere göredir; bütün yerel saatler UTC+3. Plan insanların dinlenmesini de içermeli; 48 saat kesintisiz çalışma hedefi değildir.

| Aşama | Somut çıktı | Karar / kontrol |
| --- | --- | --- |
| İlk 2 saat | Kapsam, gerçek Godot proje dosyaları, export araçları ve girişten sonuca temel akış | Export şablonları şu anda doğrulanmış değil; önce bu belirsizlik giderilecek. |
| 2–8. saat | Basit şekillerle birkaç yerleşim kararı ve tamamlanabilen tek döngü; ilk Windows çıktısı | İkinci bilgisayarda açılmalı. Nesne sayısını artırmadan kararların birbirini etkilediği görülmeli. |
| 8–20. saat | Üç hedef, okunur sonuçlar, tutarlı oda görselleri ve kısa ses geri bildirimleri | Temel döngü yetişmezse içerik azaltılır; ikinci senaryo başlamaz. |
| 20–30. saat | Yeni oyuncuların açıklama verilmeden denediği sürüm | Yanlış anlaşılan kontrol ve bilgi ilişkileri düzeltilir. |
| 30–40. saat | Özellik eklenmeyen, tekrar denemesi ve paketi kontrol edilen sürüm | İkinci bilgisayar, ekran boyutu, Türkçe karakterler ve tekrar başlatma denenir. |
| Son 8 saat | ZIP, ayrı video dosyası, kaynak/AI beyanı ve sunum | Yeni sistem eklenmez; gerçek teslim ve olası yükleme sorunları için pay bırakılır. |

Git desteği için yayımlanan sınır 18 Ekim 12.00; oyun geliştirme ve yeni yükleme başlatma sonu 18 Ekim 18.00. Teslim ayrıntıları [SUBMISSION.md](SUBMISSION.md) içinde. Son ana kadar oyun geliştirmek planın parçası değil.

İlk denemede oynanış oluşmazsa daha fazla eşya, animasyon veya uzun metin eklemek çözüm sayılmayacak. Önce yerleşim kararlarının ilişkisi sadeleştirilecek. Ağ bulmacası bir alternatif tasarım olarak tutuluyor; geç saatte sıfırdan ikinci oyun başlatılmayacak.

## İnsan testi ve teknik kontroller

Henüz prototip veya test sonucu yok. Aşağıdakiler önerilen kabul kontrolleridir:

- Yeni oyuncu ilk hedefi bizim sözlü açıklamamız olmadan anlayabiliyor mu?
- İlk denemeden sonra hangi yerleşimin hangi sorunu doğurduğunu gösterebiliyor mu?
- İkinci denemede ezbere aynı düğmelere basmak yerine düzenini gerekçeyle değiştiriyor mu?
- Oyundan sonra en az birkaç hazırlık fikrini söyleyebiliyor ve bunları kesin güvenlik garantisi sanmıyor mu? Bu gözlem tek başına kalıcı öğrenme kanıtı değil.
- Çözümü tamamlamak mümkün mü; geri alma ve başlangıca dönme bütün oyun durumunu geri kuruyor mu?
- Senaryo sırasında çift tıklama, duraklatma ve tekrar başlatma akışı bozuyor mu?
- Paket ikinci bilgisayarda gerekli dosyalarıyla açılıyor mu; metin, ses ve hedefler okunuyor mu?

Önce iki ekip üyesi, sonra mümkünse ekip dışından birkaç kişi oynar. Gözlem yapılmadan “kolay anlaşılıyor”, “hatasız”, “öğrettiği kanıtlandı” veya “iki bilgisayarda çalışıyor” yazılmayacak.

## Ekip çalışması ve beyan

Geçici rol önerisi: bir üye her yeni sürümü oynayıp kontrol/akış hatalarını kaydeder; diğeri bilgi doğruluğu, kaynaklar, video ve teslim listesini takip eder. İkiniz de tasarım kararı verir ve son sürümü oynarsınız. Gerçek görev sahipleri ekipçe atanacak.

İki Codex aynı dosyaları eşzamanlı değiştirmeyecek; geliştirme görevleri bölünecek, değişiklikten önce Git durumu ve son ekip değişiklikleri okunacak. Commit/push yalnız kullanıcı isteğiyle yapılacak.

Bu tasarım araştırması ve metni Codex ile, üç araştırma/değerlendirme ajanı yardımıyla hazırlandı; kayıt [SOURCES.md](SOURCES.md) içinde. Bu aşamada oyun içi kod, görsel veya ses kullanımı oluşmadı. Sonradan oluşan kullanımlar gerçek kapsamıyla eklenecek. Bilgi kaynağını okumak, sayfadaki görseli/logo/metni oyuna kopyalama veya yeniden dağıtma izni değildir.
