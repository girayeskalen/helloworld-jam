# AI ve hazır kaynak kayıtları

Bu dosya teslim beyanını hazırlamak içindir. Yalnızca gerçekten kullanılan araçları ve kaynakları yazın. Kayıtlar organizasyonun web teslim formuna aktarılacak; bu dosya tek başına teslim değildir.

Kurallar: [madde 3 ve 4](https://game.ktimo.com.tr/kurallar). Kural kontrolü: **16 Ekim 2026, v09**.

## AI kullanımı

| Araç | Aşama | Amaç ve kapsam | Oyundaki kullanım yeri |
| --- | --- | --- | --- |
| OpenAI Codex | Etkinlik öncesi hazırlık | Git ortak çalışma kurulumu, dokümantasyon, resmî kuralların araştırılması, hazırlık ve teslim kayıtları; üç araştırma ajanıyla motor karşılaştırması ve tartışma, Godot CLI sürüm kontrolü | Henüz oyun üretilmedi; oyuna özgü kod veya asset oluşturulmadı. |
| OpenAI Codex | 16 Ekim 2026, 18.00 sonrası; tema sonrasında tasarım araştırması | Üç ajanla alternatif oynanış fikirleri, Godot'ta uygulanabilirlik ve afet bilgisi incelemesi; adayların karşılaştırılması ve GAME_DESIGN.md taslağı | Öneri seçilmedi; belge arşiv olarak korundu. Oyun içi uygulama yok; tasarım/metin ve araştırma desteği. Oyun kodu, görsel veya ses üretilmedi. |
| OpenAI Codex | 16 Ekim 2026, 18.00 sonrası; v09 PDF incelemesi | Resmî PDF'nin 13 sayfasının metin ve görüntü incelemesi; üç ajanla site metni ve proje belgelerinin karşılaştırılması; teslim, alan koşulları ve tasarım önceliğinin güncellenmesi | Araştırma ve proje dokümantasyonu. Oyun kodu, görsel veya ses üretilmedi. |

16 Ekim 2026'da tema öncesindeki ilk incelemede Codex ile güncel site kurallarının tamamı ve bu depodaki hazırlık belgeleri incelendi; teslim yönergeleri v09 ile uyumlu hale getirildi. Bu ilk çalışma etkinlik öncesi araştırma/dokümantasyon kapsamındadır; oyun kodu veya asset üretilmedi.

Tema sonrasındaki ayrı incelemede [v09 PDF](https://game.ktimo.com.tr/assets/CIVIL_GAME_JAM_Kural_Kitapcigi_v09.pdf) doğrudan indirildi ve baştan sona okundu: 1–11. maddeler, EK A/B/C, kampüs haritası ve son teslim kontrol listesi dahil. Önceki resmî site metniyle ana kural içeriğinde anlam farkı saptanmadı; harita görselinin site görseliyle piksel karşılaştırması yapılmadı. PDF araştırma kaynağıdır; oyuna asset olarak eklenmedi. İndirilen dosyanın SHA-256 kimliği: `fa5571cd3c189c8f1a828953f0ea268fbf6357305b5e174076690ddb06888d67`.

Etkinlik sırasında yeni kullanım oldukça araç, amaç ve gerçek kullanım yerini ekleyin. Henüz yapılmamış işi yapılmış gibi yazmayın. Ön hazırlık kullanımını teslimde açıklama notuyla belirtmek önerimizdir; oyun geliştirmesinde AI kullanılırsa ilgili alanlar ayrıca doldurulacak.

## Tema sonrası bilgi ve tasarım referansları

16 Ekim 2026'da aşağıdaki resmî sayfalar, hazırlık bilgisi ve tasarım değerlendirmesi için incelendi. AFAD sayfalarının içeriği tarama aracındaki erişim hatasından sonra doğrudan HTTP ile kontrol edildi. Bunlardan oyun kodu, görsel, ses, logo veya PDF içeriği alınmadı; bilgi kaynağı olması asset yeniden dağıtım izni anlamına gelmez.

- [AFAD: Deprem öncesi, anı ve sonrası](https://afad.gov.tr/deprem-oncesi-ani-ve-sonrasi-onlemini-al-guvende-kal): hazırlık ve olay anı davranışlarını ayırma, eşya önlemleri ve malzeme hazırlığı.
- [AFAD: Toplanma alanına erişim](https://agri.afad.gov.tr/toplanma-alanina-erisim): önceden planlama, aileyle paylaşma ve erişilebilirlik. Türkiye hizmetleri KKTC için varsayılmadı.
- [USGS: Earthquake Facts & Earthquake Fantasy](https://www.usgs.gov/programs/earthquake-hazards/earthquake-facts-earthquake-fantasy): ağır eşyalar, sabitleme, hazırlık ve yapısal güvenlik değerlendirmesinin ayrılması.
- [FEMA: Çocuk bakım hizmetleri için hazırlık eğitimi](https://emilms.fema.gov/is_0036a/groups/166.html): çıkışları açık tutma, planı paylaşma ve deneme. Kurumun hedef bağlamı korundu; KKTC'ye özel talimat olarak kullanılmadı.
- [UNDRR: Kapsayıcı afet riski azaltma eğitimi](https://www.undrr.org/resource/training-course/disability-inclusive-disaster-risk-reduction-didrr-e-learning-course): farklı ihtiyaçları ve katılımı gözetme.
- [UNDRR: Stop Disasters öğretmen rehberi sayfası](https://www.undrr.org/publication/documents-and-publications/teaching-resilience-stop-disasters-game-teachers-guide): oyunla hazırlık kararlarını ve sonuçları tartışmaya bir örnek. Rehber PDF'si veya oyunun dosyaları alınmadı.

Henüz oyun üretilmediği için bu araştırma, oyunun öğrenme etkisinin veya afet güvenliğinin doğrulandığı anlamına gelmez. Tasarımda yer alacak somut kurallar üretim sırasında ilgili kaynakla eşleştirilecek.

## Kategori bazlı beyan ve değerlendirme

AI ve hazır kaynaklar ayrı beyan edilir. Her biri için görsel, ses, kod, metin ve diğer kategorilerinin tamamında "Kullanıldı" veya "Kullanılmadı" seçilecek; küçük miktarlar dahil gerçek kullanım açıklanacak. Hazırlık metinlerindeki AI kullanımı ile sonradan üretilecek oyun içeriğinin kullanımını ayrı kapsamlarla anlatın. Henüz oluşmamış oyun için bu seçimleri tamamlanmış saymayın.

Güncel madde 4.3'e göre AI için oran sınırı veya sabit/otomatik puan cezası yoktur; kullanım yoğunluğu, yaratıcılık ve görsel/sanatsal değerlendirmede jürinin kanaatini etkileyebilir. Gerçek kullanımın gizlenmesi veya yanlış beyanı diskalifiye nedenidir.

## Hazır kaynaklar

Henüz oyun için edinilmiş veya kullanılmış bir hazır kaynak kaydı yok. Aşağıdaki tablo taslaktır; boş olması son teslimde "hazır kaynak kullanılmadı" kararının verilmiş olduğu anlamına gelmez.

| Kaynak adı | Üretici / sağlayıcı | Kaynak bağlantısı | Lisans / izin bağlantısı | Oyundaki yeri ve değişiklik | Ham dosyanın repoda paylaşım koşulu |
| --- | --- | --- | --- | --- | --- |
| — | — | — | — | — | — |

Kullanılan görsel, ses, font, model ve kod kütüphanelerini kaydedin. Bir kaynağın ücretsiz olması yeniden dağıtım izni olduğunu göstermez. Paylaşılması kısıtlı ham dosyalar için edinme ve kurulum yolunu açıklayın; onları public repoya koymayın.

## Teslim öncesi kontrol

- AI kullanım kaydı gerçek çalışmalarla eşleşiyor mu?
- Hazır kaynakların sağlayıcı, bağlantı, lisans ve kullanım bilgileri tamam mı?
- Hiç kullanılmadı seçeneği yalnızca gerçekten kullanılmadıysa mı işaretlendi?
