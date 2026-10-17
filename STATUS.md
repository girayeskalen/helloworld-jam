# AFET KUŞATMASI — proje durumu

17 Ekim 2026 · Adım 4.5 / aktif kartlar ve 90/15 sn kampanya · Godot / GDScript

Kullanıcı yeni proje istedi. ARTÇI web kaynakları kaldırıldı; Git geçmişi korundu. İş dalı `feat/disaster-siege-step1`; Adım 4.5 sonu bu dala commit edilip GitHub'a pushlandı (`main` değişmedi).

## Devralma notu (ikinci bilgisayar / ikinci Codex hesabı)

1. `git fetch origin` → `git switch feat/disaster-siege-step1` (ilk sefer: `git switch -c feat/disaster-siege-step1 --track origin/feat/disaster-siege-step1`).
2. Godot **4.3 veya üstü** (standart, .NET değil) ile `project.godot` dosyasını aç; ilk açılışta içe aktarma birkaç saniye sürer. `.godot/` önbelleği repoda yoktur, her bilgisayar kendi üretir.
3. Yeni işe başlamadan **AGENTS.md**, bu dosya ve README'yi okut; Codex'e "AGENTS.md kurallarına uy" de.
4. Değişiklikten sonra README'deki test komutlarını çalıştır (9 paket). Farklı Godot sürümüne geçildiyse önce `--headless --path . --editor --quit`.
5. Aynı anda iki bilgisayarda aynı dosyayı düzenlemeyin; bitince commit edip aynı dala pushlayın, diğer taraf `git pull` yapsın. `main`'e birleştirme ayrı ve bilinçli bir adımdır; force push kullanmayın.

## Güncel sürüm — Adım 4.5 / 17 Ekim 2026

- **Akış:** 8 sn ilk hazırlık; üç kez 1,5 sn giriş → **90 sn savaş** → 2,5 sn çıkış. Boss sırası **Fırtına → Deprem → Çifte Felaket**. İlk iki çıkışın ardından kart seçimi ve **15 sn inşaat**; final çıkışından sonra zafer. Kartlar 0,35 sn fade-in ile açılır. Seçim sırasında süre durur; F hazırlığı erken bitirebilir. Normal 1/2/3 ve U dalgayı tekrar başlatmaz; boss/kart testleri **F9** ile açılır.
- **Bina:** Tüm saldırı, slam ve aşınma hasarı ortak sınırdan geçer; aynı anda en fazla **3 gerçek hasarlı/kritik oda**. Yeni uyarıya **10 sn ek hasar koruması**; sonra en fazla 1,3 HP/sn hasar bütçesi. Fırtınada pasif aşınma da uyarı üretir. Bina çizimleri hafif salınır, dış cepheden parçalar/toz çıkar ve kılcal çatlaklar birikir; fizik zemini sabittir. Ulaşım hesabı loot oda seçimini süzer; çimento yokken/onarım varken her ikinci düşüş çimento olur.
- **Dokuz aktif kart:** takla-onarım, uçan tamir dronu, kat geçişinde mermi silen halka, pencere türbini, uzun/fazlayan/mermi yavaşlatan dash, komşu odalara zincir onarım, kusursuz kaçışta zaman bükme, çatı lazer kulesi, mıknatıs ve toplama kalkanı. Eski pasif kartlar kaldırıldı. Zincir komşuya +22,5 HP ve yarım destek (%27,5 zırh) verir; ücretsiz tam sabitleme kiti vermez. Yeni etkiler `SiegeMechanics.gd` içinde; detaylar README'de.
- **Görsel geçiş:** Fırtına incelerek yükselir; golem rig parçaları ayrışarak sarsılır ve yere gömülür. Dünya mermileri hasar/split üretmeden dağılır. Boss çizimi zemin düzleminde kırpılır; alt HUD'a taşmaz. Oda kimlikleri, karanlık pixel-art paleti ve parabolik 2x W hareketi korundu.

### Doğrulama

Godot **4.3.stable.official.77dcf97d8** ve kurulu **4.7.2.stable.official.ed1daf0bf** ile import/parse ve motor içi kontroller:

| Test | Kontrol |
| --- | --- |
| Step1Smoke | 129 |
| Step2Smoke | 53 |
| Step25Smoke | 145 |
| Step3Smoke | 44 |
| Step27Smoke | 61 |
| Step3LootSmoke | 75 |
| CampaignSmoke | 59 |
| Step45Smoke | 87 |
| Step2Soak | 11 |

Son kontrol turu (17 Ekim 2026, Claude Code ile, Codex'in yarım kalan doğrulaması): yukarıdaki dokuz paketin tamamı headless olarak **Godot 4.3 ve 4.7.2'de 0 hata** ile geçti; iki sürümde sayılar ve tam kampanya istatistikleri birebir aynı.

- Tam kampanya sürücüsü **19.201 fizik adımı**, **16.200 savaş adımı = 270 sn**, **1.800 inşaat adımı = 30 sn**, 270 giriş / 450 çıkış adımı yürüttü. **1.820 uyarılı mermi, 19/19 tür, tepe 29/128 aktif, 0 havuz taşması**. En fazla **3** onarım uyarısı. Kazanılan kaynaklarla 28 manuel onarım ve dron desteğiyle finalde bina **%79,3** kaldı.
- Bu uzun test gerçek düşen malzemeleri otomatik toplar ve onarım için karakter konumunu ayarlar; canı yalnız testte yükseltir. İnsan oyuncunun kaçınma/rota zorluğunu veya oyunun kazanılma oranını ölçmez. Gerçek oyuncu playtest'i hâlâ gerekli.
- Native renderer ile yeni dokuz kartın üç sayfası, dron/türbin/kule/ışınlar, boss giriş/çıkışları; ayrıca inşaat/loot/final/zafer ekranları kaydedildi. Görüntüler: `C:/Users/halil/AppData/Local/Temp/siege-step45-captures/` ve `C:/Users/halil/AppData/Local/Temp/siege-step45-campaign/`. Bunlar yerel test kanıtıdır, repo asseti değildir.
- Eksik kapsam: ikinci bilgisayar, bağımsız export/HTTPS dağıtımı, insan oynanış dengesi ve sesli boss kükremesi doğrulanmadı/eklenmedi. Çıkışın kükreme/dağılma anlatımı animasyonla veriliyor; yeni ses dosyası yok.
- Kullanıcının isteğiyle Adım 4.5 sonundaki durum `feat/disaster-siege-step1` dalına tek commit olarak pushlandı (eski web dosyası silmeleri dahil). Görev öncesindeki kullanıcı/Claude değişiklikleri korundu. Adım 4.5 öncesi yerel yedek: `C:/Users/halil/AppData/Local/Temp/siege-step45-baseline-20261017-042743/`.

## Önceki sürüm kaydı — Adım 4 (aşağıdaki eski süre/kartlar artık aktif değil)

| Görev | Sorumlu | Durum / sonuç |
| --- | --- | --- |
| Uyarıya bağlı kuşatma onarımı | Codex | Tamamlandı. Hasarlı/kritik oda için dünya işareti ve E aynı `repair_alert` koşulunu kullanır. Sağlam odada E sessizdir; çimento +45 HP onarır, kuşatmada zırh eklemez. |
| Beş malzeme ve süreli loot | Codex | Tamamlandı. İlk düşüş dahil 5,5–6,5 sn, oyuncunun olmadığı uygun oda, max 3. Düşüşten sonra tam 4,0 sn; son 1,5 sn blink ve küçülen halka. Çimento, X-kiriş, sabitleme, kepenk, +25 can/tam enerji medkit. Kart modalında sayaç durur; dalga geçişi kalan ömrü kesmez. |
| Üç kademeli inşaat | Codex | Tamamlandı. İlk iki dalgadan sonra 20 sn veya F. E hasarlı odada mevcut çimentoyla onarır; sonra eldeki eksik çelik/kepenk/sabitleme bileşenlerinden birini kurar. Üç farklı kit = tam sığınak; aynı bileşene tekrar malzeme harcanmaz. |
| Görünür güçlendirme | Codex | Tamamlandı. Büyük sarı-siyah çelik X-kiriş, perçin/plaka, ağır kepenk, zeminde kum torbası, eşyalarda çelik kemer, üç LED ve hazırlıkta ekran katmanında güvenli oda yazısı. En az bir bileşeni olan oda %55 az hasar alır; sabitleme bileşeni avize dahil oda eşyalarının saldırı üretmesini engeller. |
| Dokuz kart / üç seçenek | Codex | Tamamlandı. 9 karttan rastgele 3, bir oyun içinde aynı kart ikinci kez alınmaz. Fare ve 1/2/3 ile seçim; seçim sırasında oyuncu ve geri sayım durur, F/E seçimi atlayamaz. Bütün kartların hasar/hız/can/ışık/loot/onarım etkileri bağlı. |
| Üç boss ve final | Codex | Tamamlandı. Fırtına → kart+inşaat → deprem → kart+inşaat → koordineli çift boss. Ortak final temposu 2,8 sn, farklı kat hedefleri. Üçüncü dalga bittiğinde oyuncu ve bina ayaktaysa zafer; dördüncü dalga yok. |
| Kontroller ve sıfırlama | Codex | Tamamlandı. E/F/U ve bağlama göre 1/2/3, R ile bütün kart/loot/bina/oyuncu değerlerinin sıfırlanması. Kartlar normal fazlar arasında korunur; boss test tuşları taze test kurar. |
| Mevcut sanat ve hareket | Codex | Korundu. 16 odanın temel çizim bölümü, Player'ın zıplama/kat geçişi/dash fiziği ve boss rig/animasyon bölümü görev başındaki Claude dosyalarıyla metin karşılaştırmasında aynı. |
| Belgeler ve katkı kaydı | Codex | README, AGENTS, BEYAN, SOURCES ve SUBMISSION güncellendi. Yeni harici asset/eklenti/font/ses eklenmedi. |

### Doğrulama — 17 Ekim 2026

Godot **4.3.stable.official.77dcf97d8** ve kurulu **4.7.2.stable.official.ed1daf0bf**: import/parse hatasız. Her iki motorda 60 Hz headless sonuçları:

| Paket | Sonuç |
| --- | --- |
| Step1Smoke | 129/129 |
| Step2Smoke | 53/53 |
| Step25Smoke | 145/145 |
| Step3Smoke | 44/44 |
| Step27Smoke | 61/61 |
| Step3LootSmoke | 75/75 |
| CampaignSmoke | 91/91 |
| Step2Soak | 10/10 |

- Toplam **608 kontrol**, sıfır hata. Hareket/atmosfer/rig regresyonları korundu; eski sonsuz iki dalga, 3 loot türü, 5 eşya sınırı ve sağlıklı odada kuşatma onarımı beklentileri yeni kurallarla değiştirildi.
- Yeni `CampaignSmoke`: 3,999/4,000 sn ömür sınırı; aynı karede süre dolması-toplama önceliği; dalga sonundaki malzemenin kalan ömrü; oyuncunun odasına fallback düşmemesi; 5 tür/medkit; aynı bileşenin iki kez satın alınmaması; %55 hasar azalması; avizenin sabitlenmesi; 9 kartın gerçek etkileri ve tekrar uygulanmaması; 130 HP odalarda normalize bina yüzdesi; yavaşlatılmış 5 mermi hareket yolunun uyarıyla eşleşmesi; ayrı 1,5 sn kalkan; 6,5 sn drone ömrü; jeneratörün normal/tam-kat/gust uyarıları ve +2 kaynağı; modalda klavye/fare ile seçim, sayaç/oyuncu kilidi; tam 20 sn inşaat, üçüncü boss ve terminal zafer; ölüm/çöküşün zaferden önce değerlendirilmesi.
- Gerçek **Compatibility/OpenGL renderer**: CampaignSmoke iki motorda **103/103**. Motor başına 9 adet 1920×1080 PNG; tüm kartlar, kademeli odalar, beş loot simgesi, onarım işaretleri, çift boss, jeneratör ve zafer görüntüleri. Kart açıklamalarının ilk görüntüde taşması düzeltildi; metnin kendi kartı içinde kaldığı otomatik kontrol eklendi. Son zafer HUD'u artık sonraki dalga/geri sayım göstermiyor.
- Görseller: `%TEMP%/siege-campaign-visuals/` (4.7.2), `%TEMP%/siege-campaign-visuals-43/` (4.3). Loglar `%TEMP%/siege-final-*.log` ve `%TEMP%/siege-43-*.log`. 4.3 görüntüleri son zafer üst-bar metni düzeltmesinden önce alındı; bu son HUD düzeltmesi 4.7.2 native görüntüsünde ayrıca doğrulandı.
- Tam üç dalga ve iki 20 sn arayı süre atlamadan oynatan test: **536 uyarılı mermi, 19/19 tür, 128'lik havuzda tepe 26, sıfır taşma**. Test karakteri yüksek canlıdır ve onarım yapmaz; kesici ve izolatör kartları seçilir. Bina normal dalga geçişlerinde yeniden kurulmaz: ilk iki dalga sonunda %59,5, final sonunda **%34,0 / 3 yıkık oda** ile zafer. Bu otomasyon insan oyuncunun zorluk değerlendirmesi değildir.
- Görev başındaki dosyaların yedeği: `%TEMP%/siege-pre-campaign-20261017-034523/`. Kullanıcının/Claude'un önceki değişiklikleri korunarak çalışıldı; eski web dosyalarının zaten var olan silinmeleri bu görevde yapılmadı. `git diff --check` geçti. Commit/push yapılmadı.

### Kalan işler

- İnsan oyuncuyla zorluk, 4 saniyede malzemeye yetişme ve kart seçiminin anlaşılabilirliği denenmeli. Otomatik hareket ve sınır testleri geçti; insan oynanış dengesi garanti edilmez.
- Bağımsız export/dağıtım, ses ve düşük donanımda performans ölçümü bu görevde yapılmadı. F5 ile kaynak projeyi çalıştırmak hazır.
- Kartların adları ve sayısal etkileri kullanıcı tasarımı / oyun kurgusudur; gerçek mühendislik tavsiyesi veya resmî kurum onayı olarak sunulmaz.

## Adım 3-B — önceki sürüm kaydı (doğal üst kat yayı, oda hasarı/çöküş, loot ve E onarımı)

Kullanıcı bu adımı "Adım 3" diye adlandırdı; önceki 4×4 "Adım 3" ile karışmasın diye belgelerde "Adım 3-B" denir.

| Görev | Sorumlu | Durum / sonuç |
| --- | --- | --- |
| 2x W doğal yay | Claude | Tamamlandı. Betikli 0,13 sn yapışma kaldırıldı. İkinci W fizik fırlatmasıdır: yalnız üst kat döşemesi çarpışma istisnası (duvarlar çarpışır), ayrık 60 Hz yay için hesaplanan hızla tepe döşemenin **32 px** üstünde; tepede hız 0, döşeme çarpışması geri açılır, normal yerçekimiyle iniş, squash + toz. Tepeye ~0,35 sn. W bırakmak fırlatmayı kesmez; yükselişte takla yok, tepeden sonra hava taklası serbest. S (0,11 sn) değişmedi. |
| Oda HP ve 5 görsel durum | Claude | Tamamlandı. Güçlendirilmiş (X-kiriş, kepenk + kum torbası, L-demir; %50 hasar), sağlam, hasarlı (çatlak, sıva deliği, kırık cam, eğik eşya, toz, arızalı lamba, HP çubuğu), kritik (bel veren kolon, sarkan tavan, kıvılcım/moloz, kırmızı yanıp sönen lamba, `[!] ONAR [E]`), yıkık (enkaz, kiriş, duman, sönük lamba; onarılamaz, içindeki loot kaybolur). |
| Hasar kaynakları ve çöküş | Claude | Tamamlandı. Mermi bittiği odaya türe göre hasar (cam 0,8 … beton/avize/gardırop 6; kat süpürmesi kattaki 4 odaya 4), golem vuruşu katı 1 sarsar, hasarlı/kritik oda 0,25 HP/sn aşınır. Bina dayanıklılığı = 16 oda ortalaması. 4+ yıkık oda veya %0 → bina sarsılarak çöker, ışıklar söner, "BİNA ÇÖKTÜ! ODALARI ZAMANINDA ONARAMADIN". |
| Loot ve E onarımı | Claude | Tamamlandı. İlk drop 1,2 sn, sonra 3,5–4,0 sn'de bir; önceki odadan farklı, mümkünse oyuncunun olmadığı, yıkık olmayan odaya; en fazla 5 drop. Çimento (kehribar), kepenk kiti (mavi), ilk yardım (yeşil; +20 can ve tam enerji). Üstünden geçince toplama, "+1 …" yazısı, sol altta MALZEME sayacı. E: +45 HP + güçlendirme, "ODA ONARILDI & GÜÇLENDİRİLDİ!". Alt bara `E: ODAYI ONAR / GÜÇLENDİR` eklendi. |
| İnsan oynayış dengesi, ses, export | Ekip / sonraki görev | Bekliyor. Hasar/loot oranları otomatik testle ayarlandı; insanla oynanmadı. |

Yorum kararları: "+2 Can" can ölçeği 100 olduğu için 2 can birimi = **+20 HP** olarak uygulandı (`LootSystem.medkit_heal`). Yıkık oda "zamanında onarılmadı" anlamında kalıcıdır (R'ye kadar). İki malzeme türü de E'de aynı etkiyi yapar (+45 HP ve güçlendirme); hasarlı odada önce çimento, sağlam odada önce kepenk kiti harcanır.

### Adım 3-B doğrulaması — 17 Ekim 2026

- Godot **4.3.stable.official.77dcf97d8** ve **4.7.2.stable.official.ed1daf0bf**, headless (iki sürüm aynı): **Step1 129/129, Step2 53/53, Step25 145/145, Step3 44/44, Step27 61/61, Step3Loot 75/75, tam dalga 10/10**.
- Gerçek Compatibility/OpenGL renderer, iki sürüm: **Step1 129/129, Step2 64/64, Step25 156/156, Step3 54/54, Step27 71/71, Step3Loot 82/82**; sürüm başına 50 PNG (Step3Loot, Step27, Step3 tam 1920×1080). Kayıtlar `%TEMP%/disaster-siege-step3b-final-472/` ve `%TEMP%/disaster-siege-step3b-final-43/`.
- Yeni `tests/Step3LootSmoke.gd`: üç farklı ikinci-basış zamanında yay tepesi **32,0–32,1 px** (28–36 aralığı), yükselişte yalnız üst döşeme istisnası, tepede hız ≈0 + istisna kalkmış + ayaklar döşeme üstünde, ardından gerçek düşüş ve iniş (squash 0,93, toz); durum sınırları 70/35/0; hasarlı odada kırık cam + eğik eşya; arızalı lamba titremesi (%27 karartı, sağlam odada %8); kritik kırmızı yanıp sönme; yıkıkta lamba 0, onarılamazlık, gömülü eşyanın tehlike üretmemesi; güçlendirmede L-demir/kepenk ve %50 hasar; ortalama dayanıklılık; aşınma; gerçek tuğla/kat süpürmesi/golem vuruşu hasarının doğru odalara gitmesi; 3 yıkıkta ayakta, 4'te çöküş + mesaj + temizleme + sarsıntı + ışıkların sönmesi, çöküşten sonra onarım yok, %0 kuralı, R ile tam sıfırlama; 40 drop'ta 1,2 sn ilk drop ve 3,5–4,0 sn aralık, art arda aynı oda yok, oyuncu/yıkık odadan kaçınma, ≥10 farklı oda, 3 tür, oda içi zemin konumu, 5 drop sınırı, yıkılan odada drop kaybı; düşerken alınamama, üstünden geçince toplama, "+1" yazısı, ilk yardım +20/tam enerji, başka kattan toplanamama; E'nin malzemesiz/yeterli/gereksiz/yıkık/çökmüş hallerinin tümü, çimento önceliği, kepenk kitiyle güçlendirme, dayanıklılık artışı, ipucu ve `[!] ONAR [E]` etiketi, alt barda E.
- Tam program (hareketsiz, hiç onarmayan test oyuncusu): fırtına + deprem sonunda **2 yıkık / 7 hasarlı oda, %59,5**; kaos (yeniden kurulmuş bina) sonunda 2 yıkık, %61,0. Bina iki ölçümde de ayakta. Mermi sayısı 642 → 637 (yıkık odadaki eşyalar artık fırlatılmıyor); türler 19/19, tepe 27, 0 taşma.
- Eski testlerde güncellenenler: Step1 ve Step25 üst kat beklentisi `collision_mask == 0` yerine "yalnız üst döşeme istisnası" ve gerçek iniş beklemesi; Step27'deki 0,13 sn beklentisi yay beklentisiyle değiştirildi (hızlı fırlatma, ~0,35 sn tepe, iniş squash'ı). Kapsam silinmedi.
- Görsel incelemede düzeltilenler: loot simgeleri %35 büyütüldü ve ışık hüzmesi güçlendirildi; çöken odada kalan drop artık kayboluyor; bina çöktükten sonra onarım ipucu/E kapatıldı.
- Denenmedi: insanla oynanış ve dengenin hissi (özellikle loot sıklığı vs. deprem hasarı), export, ses. Yeni harici asset/ses/font/eklenti yok; commit/push yapılmadı.

## Adım 2.7 — önceki sürüm kaydı (görsel temizlik, karanlık atmosfer, akıcı hareket, çok parçalı bosslar)

Numara kullanıcının etiketidir; içerik Adım 3'teki 4×4 yapının üzerine eklendi.

| Görev | Sorumlu | Durum / sonuç |
| --- | --- | --- |
| Yazı ve tabelaları kaldırma | Claude | Tamamlandı. Oda adı levhaları, sol "KAT 00–03" kutuları, çatı "DAYANIŞMA APARTMANI" tabelası, "TERAS" ve "TOOLS" yazıları kaldırıldı. Oda adı yalnız veri (`room_name()`). Dünya içi uyarı yazıları ekran katmanına (`WorldLabels`) taşındı. |
| Karanlık pixel-art atmosfer | Claude | Tamamlandı. Dünya 960×540 SubViewport'ta çizilip 2× nearest büyütülüyor (`pixel_scale`). Gece gökyüzü `#0b0e14`–`#141923` + dither bantlar, karartılmış şehir, uzak yangın kızıllığı, 260 yağmur çizgisi, 70 kül/köz, binanın yanına düşen şimşek (odaları kısa süre aydınlatır). Odalar ~%50 parlaklık + soğuk ton, su lekesi/çatlak/küf/dither kir, köşe AO/vinyet. 15 lamba (11 amber, 4 acil kırmızı) additive koni; sarsıntıda sallanır ve titrer. Baret feneri bakılan yöne, oda duvarlarında kesilen additive koni. |
| Sprite otomatik yükleyici | Claude | Tamamlandı. `res://assets/sprites/` içindeki `player.png`, `boss_storm.png`, `boss_quake.png`, `tileset.png` otomatik kullanılır; yoksa prosedürel çizim. Klasör yalnız README içerir. |
| Hızlı/akıcı hareket | Claude | Tamamlandı. Koşu 310→403 px/s, ivme 2200→9000, ayrı dönüş ivmesi 16000 (yön değişimi 2 karede), kat fazı 0,24→0,13 sn / 0,20→0,11 sn ease-out, dash 980→1150 px/s (0,25 sn dokunulmazlık korundu, mesafe ~245→~290 px), bekleme 0,38→0,304 sn. Squash & stretch, koşu eğilmesi, hava pozu, pelerin ve baret kayışı. |
| Çok parçalı bosslar | Claude | Tamamlandı. Golem: kalça, nefes alan gövde, omuzlar, dirsekleri dışa bükülen IK kollar, yumruklar, baş, ayrı çene (lav + duman/köz), yörüngede 6 kaya; uyarı süresince kollar yukarı/geri + kor gözler, mermi çıkınca yumruklar bina dibine (flaş, toz/kaya patlaması, şok halkası). Fırtına: 12 halkalı S-omurga, nefes alan halkalar; uyarıda büzülme + şimşek arkları, atışta binaya doğru genişleme + kükreyen ağız + rüzgâr çizgileri. Golem x 2240'a alındı. |
| Neon mermi ve uyarılar | Claude | Tamamlandı. Her havuz mermisine (128, savaş öncesi oluşturulur) additive ışıma: fırtına elektrik mavisi, deprem kor turuncusu, 10 noktalı iz, kırmızı tehlike çekirdeği. Uyarılar neon renk + parlayan çizgi + çizilmiş "!" ikon. |
| Oynanış dengesi, ses, export | Ekip / sonraki görev | Bekliyor. Daha hızlı karakter dalga zorluğunu düşürebilir; insanla denenmedi. |

### Adım 2.7 doğrulaması — 17 Ekim 2026

- Godot **4.3.stable.official.77dcf97d8** ve **4.7.2.stable.official.ed1daf0bf**, headless (her iki sürüm aynı): **Step1 129/129, Step2 53/53, Step25 145/145, Step3 44/44, Step27 61/61, tam dalga 10/10**. Tam program sonuçları önceki adımla birebir aynı (**642 mermi, 19 tür, tepe 27, 0 taşma, bina 40,4**): savaş zamanlaması değişmedi.
- Gerçek Compatibility/OpenGL renderer, her iki sürüm: **Step1 129/129, Step2 64/64, Step25 156/156, Step3 54/54, Step27 71/71**. Step27 ve Step3 görüntüleri exclusive fullscreen ile **tam 1920×1080** (sürüm başına 19 kare), diğerleri 1280×720 pencereden (24 kare). Kayıtlar: `%TEMP%/disaster-siege-step27-1080-472/` ve `%TEMP%/disaster-siege-step27-1080-43/`.
- Yeni `tests/Step27Smoke.gd`: oda levhası yokluğu, 960×540 pixel grid ve nearest büyütme, `world_to_screen`, gece paleti, yağmur/kül, 16 sn içinde ortam şimşeği, şimşeğin odaları aydınlatıp sönmesi, odaların ~%50 parlaklığı, 15 lamba konisi (additive, amber + kırmızı), sakin lambaların durması, sarsıntıda sallanma (>0,08 rad) ve titreme, lamba gövdesi–koni senkronu, baret feneri yönü/odada kesilmesi, gerçek PNG dosyalarıyla sprite yükleyici ve geri dönüş, +%30 koşu, 3 karede %90 hız, 2 karede dönüş, dash mesafesi, 0,13/0,11 sn faz ve ease-out, zıplamada uzama, inişte/kat varışında basılma, eğilme ve pelerin yönü, golem parçalarının bağımsız hareketi/çene/duman/nefes, dışa bükülen dirsekler, wind-up'ta yumruklar omuz üstünde + kor gözler, vuruşta bina dibine yumruk + toz patlaması, fırtına S-eğrisi/nefes/büzülme+şimşek/öne atılma+rüzgâr çizgileri, tüm pozlarda bossların ekranda kalması, 128 mermi ışıması, renkler ve ekran etiketleri.
- Eski testlerde güncellenenler: Step2 koşu hızı beklentisi (310 → 403); Step25 hava dash'i 3 yerine 2 karede ölçülür (daha hızlı dash 116 px tavan sınırına çarpmasın diye); coyote test platformu artık dünya viewport'una eklenir ve oyuncunun gerçekten platformda durduğu ayrıca doğrulanır (önceki hâli yeni yapıda yanlışlıkla geçiyordu); Step3 ekran sığması `world_to_screen` ve bossların gerçek poz sınırlarıyla ölçülür, rüzgâra karşı koşu eşiği koşu hızına göre.
- Görsel incelemede düzeltilenler: lamba konileri hafifletildi (oda daha karanlık), şimşek bina arkasında kalıyordu → binanın yanına düşüyor ve daha kalın; golemin kaldırılmış kolunda IK dirseği içe kırıyor ve ekrandan taşıyordu → dirsek her zaman dışa, kollar daha düz.
- Denenmedi: insan oyuncuyla hız/zorluk hissi, düşük performanslı makinede FPS ölçümü, bağımsız export, ses. Yeni harici asset, font, ses, shader veya eklenti yok; commit/push yapılmadı.

## Adım 3 — önceki sürüm kaydı

| Görev | Sorumlu | Durum / sonuç |
| --- | --- | --- |
| Merdivenin kaldırılması, 2x W üst kat / S alt kat | Claude | Tamamlandı. W/↑ katın içinde zıplar (en fazla ~115 px, tavan sınırı 116 px; kat değiştirmez). Havada ikinci W/↑ her X'te 0,24 sn fazlamayla üst kata çıkar; Kat 03'te yalnız hava zıplamasıdır. S/↓ yerde ya da havada her X'te 0,2 sn ile alt kata iner; Kat 00'da havada fast-fall. Fazlama collider'ı kapatır, hedef zemine hizalar ve geri açar; rüzgâr izi, döşeme tozu ve hayalet iz çizer. Kenara tutunma ve exception tabanlı drop-through kaldırıldı. |
| Space = takla | Claude | Tamamlandı. Shift/Space/sağ tık sekiz yönlü I-frame takla. Adım 2.5'teki "Space'i dash'e bağlama" kuralı kullanıcının yeni açık isteğiyle değişti; AGENTS güncellendi. |
| 4×4 = 16 benzersiz oda | Claude | Tamamlandı. Kullanıcının listesindeki 16 oda; her birinin duvar rengi, duvar/zemin deseni, ad levhası ve mobilya seti farklı. 20 yeni prosedürel mobilya türü. Deprem oda-eşyası kaynakları tek kaldı (8 tehlike, öncekiyle aynı). |
| Kamera/ölçek ve HUD | Claude | Tamamlandı. Odalar 400×220 korunup kamera zoom 0,78 yapıldı; bina, iki boss, alt/üst HUD 1920×1080'e sığıyor (test ile ölçülüyor). Arka plan zoom'lu alana göre çiziliyor; apartman tabelası çatıya taşındı; alt bar istenen kontrol metnini gösteriyor. |
| Fırtına bullet-hell güçlendirmesi | Claude | Tamamlandı. 6 vuruşluk döngü, 1,95 sn tempo: girdap halkası (10/12, dönen ve genişleyen, kat bandında kalan), çapraz yaylım (X kesişen pencere/çatı akımı atışları + saksı/bıçak), hortum koridoru (oyuncunun katına 1,0 sn uyarılı süpürme + komşu katlarda zıplanacak alçak enkaz/saksı), rüzgâr kükremesi (0,65 sn uyarı, 2,2 sn 150 px/s itme), yelpaze ve savrulan eşya. Uyarılı mermi yoğunluğu 3,42/sn (Adım 2.5: ~1,86/sn). |
| Deprem zorluğu | Claude | Korundu. Aynı üç patern ve 2,8 sn tempo; yalnız 4 kata/1600 px genişliğe uyarlanan hedef/konumlar. |
| İnsan oynayış dengesi, ses, export | Ekip / sonraki görev | Bekliyor. Fırtına zorluğu otomatik ölçümle ayarlandı; insan oyuncuyla "bunaltıcı değil" hissi denenmedi. |

### Adım 3 doğrulaması — 17 Ekim 2026

- Godot **4.3.stable.official.77dcf97d8** ve kurulu **4.7.2.stable.official.ed1daf0bf**: import/parse ve beş test paketi başarılı. Headless, her iki sürümde: **Step1 129/129, Step2 53/53, Step25 144/144, Step3 44/44, tam dalga testi 10/10**. Gerçek Compatibility/OpenGL renderer penceresinde (her iki sürüm, 1280×720): **Step1 129/129, Step2 64/64, Step25 155/155, Step3 54/54** ve 35 PNG.
- Eski beklentiler yeni kurallara göre güncellendi, kapsam silinmedi: merdiven testleri → her X'te 2x W/S kat geçişi, dash'in geçişi kesememesi, çatı sınırı, collider geri açılması; "Space zıplar" → "Space takla atar"; 9 oda/4 kolon → 16 oda/5 kolon; fan ömrü 1600 px cepheye göre uzatıldı (160 → 210 kare bekleme); fırtına sırası değiştiği için Step2 fan/eşya testleri ilgili paterni doğrudan çağırıyor.
- Yeni `tests/Step3Smoke.gd`: bina ve bossların HUD barları arasına ve ekrana sığması, arka planın görüş alanını ve zemin çizgisini karşılaması, fırtına döngüsündeki altı patern, yoğunluğun artıp sınırlı kalması, deprem döngüsünün değişmemesi, girdabın oyuncu üstünde açılmaması/dönmesi/genişlemesi/kat bandında kalması, çapraz yaylımın X kesişimi (4 kesişim) ve aynalanması, koridordan 2x W ve S ile hasarsız kaçış, alçak enkazın zıplamayla aşılması, rüzgârın uyarı sırasında itmemesi, idle sürüklenme 70,8 px / 0,5 sn, rüzgâra karşı koşu 60,7 px, taklanın tam hızı, R ile rüzgârın temizlenmesi ve tam fırtına döngüsünde 40 uyarılı atış / havuz tepe 12.
- Tam program (hazırlık + 30 sn fırtına + hazırlık + 30 sn deprem + 30 sn kaos, 60 Hz): **642 mermi, 19/19 tür, tepe 27 aktif, 0 havuz taşması**, kaos sonunda bina 40,4/100.
- Görseller `%TEMP%/disaster-siege-step3-final-472/` ve `%TEMP%/disaster-siege-step3-final-43/` altında; 4×4 bina, girdap, çapraz yaylım, koridor, rüzgâr uyarısı/itmesi, kaos, kat fazlaması incelendi. İnceleme sonrası düzeltilenler: lamba/çatı penceresinin oda adlarını örtmesi (ad levhası ayrı katmana alındı), rüzgâr sayacının çatı kenarında okunmaması (koyu levha) ve rüzgâr çizgilerinin silik olması.
- Ekranlı Step1 testi önceden ara belleğe alınmış girdiyi boşaltmıyordu; kısa tuş basışları için diğer testler gibi `Input.flush_buffered_events()` eklendi.
- Denenmedi: insan oyuncuyla fiziksel klavye oynanışı (ekranlı test penceresi fiziksel girdiyi almaz; F5 penceresi alır), bağımsız export, ses. Yeni asset, font, ses veya eklenti yok; commit/push yapılmadı.

## Adım 2.5 — önceki sürüm kaydı

| Görev | Sorumlu | Durum / sonuç |
| --- | --- | --- |
| Altı benzersiz oda | Codex | Tamamlandı; teknik atölye, mutfak, salon, kütüphane, yatak odası ve çocuk/hobi/teras. Ayrı renk/malzeme, durumlu mobilyalar, farklı orta tesisat donanımları. |
| Gerçek zıplama ve kat geçişi | Codex | Tamamlandı; basılı tutmayla yükseklik, 0,1 sn coyote, kısa giriş tamponu, W merdiven önceliği, Space zıplama, kenara tutunma, S drop-through/fast-fall. |
| Sekiz yönlü yerde/havada dash | Codex | Tamamlandı; yön normalizasyonu, Shift/sağ tık, 0,25 sn dokunulmazlık, tek hava hakkı/inişte yenilenme, stamina/iz/toz ve fast-fall iptali. |
| Beş saldırı patern ailesi | Codex | Tamamlandı; yatay alçak şok, 5/7 yelpaze, üç parçaya ayrılan sekmeli enkaz, tam kat süpürmesi ve oda eşyaları. Saksı/sandalye/rüzgâr saldırıları korundu. |
| Adil uyarı ve çarpışma | Codex | Tamamlandı; normal 0,55–0,75 sn, kat süpürmesi 1,0 sn. Enkaz parçaları ayrı 0,55 sn uyarılır. Dondurulmuş yol, erken spawn reddi, komşu kata vurmayan dar/uzun duvar. |
| Kontroller, belgeler ve AI kaydı | Codex | Tamamlandı; alt bar, README/AGENTS, SOURCES/BEYAN ve teslim taslağı güncel. |
| Loot / insan oynayış dengesi / ses / export | Ekip / sonraki görev | Bekliyor; bu adım loot veya hazır teslim paketi içermez. |

### Adım 2.5 doğrulaması — 17 Ekim 2026

- Godot **4.3.stable.official.77dcf97d8** ve kurulu **4.7.2.stable.official.ed1daf0bf**: import/parse ve motor içi dört test paketi başarılı. Her sürümde **Step1 83/83, Step2 53/53, Step25 102/102, tam dalga testi 10/10**; toplam **248 kontrol / 0 hata**.
- Gerçek klavye/fizik: Space/W/↑ zıplama, W+D+Shift çapraz dash, merdiven önceliği, değişken yükseklik (testte kısa 45,2 px / basılı 191,0 px), gerçek platformdan ayrıldıktan sonra coyote, havada sınırsız zıplamanın engellenmesi, sekiz dash yönü, tek hava hakkı, platform tutunma, alt kata düşüş ve collider'ın geri açılması doğrulandı.
- Patern testleri: 5/7 farklı açı, yatay şokun zıplamayla aşılması, kat duvarının 1 sn beklemesi ve komşu kata değmemesi, gerçek duvardan dash ile hasarsız DODGE, iki betonun toplam altı uyarılı parçaya ayrılması, sekme matematiği ve kaynak eşyası güçlendirilince saldırının kesilmesi doğrulandı.
- Tam program, hazırlık + 30 sn fırtına + hazırlık + 30 sn deprem + 30 sn kaosu 60 Hz adımlarla yürüttü: **562 mermi, 18/18 tür, tepe 23 aktif**, normal programda **0 havuz taşması**. Kaos sonunda bina **39,3/100**. Hareketsiz test oyuncusunun canı yalnız bu testte yükseltilir; normal oyunda 100'dür.
- Gerçek Compatibility/OpenGL renderer: 4.3'te **1280×720**, 4.7.2'de **960×540**. Altı oda, jump, air-dash, yelpaze/şok, kat uyarısı/süpürme, parçalanma/sekme ve oda eşyaları için her sürümde **11 PNG**. Kayıtlar `%TEMP%/disaster-siege-step25-43/` ve `%TEMP%/disaster-siege-step25-472/`; görüntüler görsel olarak incelendi.
- Yeni harici asset, font, ses veya eklenti yok. Önceki yerel çalışmalar/Git geçmişi korundu; commit/push yapılmadı. Bağımsız export ve insan zorluk/eğlence testi yapılmadı.

## Adım 2 — önceki sürüm kaydı

| Görev | Sorumlu | Durum / sonuç |
| --- | --- | --- |
| Dalga ve faz yöneticisi | Codex | Tamamlandı; 8 sn hazırlık, F ile erken başlama, 30 sn fırtına/deprem döngüsü ve erken boşalan dayanım barı. |
| İki animasyonlu boss | Codex | Tamamlandı; sol hortum, sağ sismik golem, hazırlık/slam hareketi, boss_sprite ve custom_sprite alanları. |
| Telgraf ve mermi havuzu | Codex | Tamamlandı; 0,55–0,75 sn uyarı, dondurulmuş ortak yol, uyarısız spawn reddi ve 128 sabit node. |
| Dokuz tehlike türü | Codex | Tamamlandı; cam, saksı, sandalye, rüzgâr bıçağı, tuğla, beton, avize, şok dalgası ve saçılan kitap. |
| Hasar, dash ve geri bildirim | Codex | Tamamlandı; 1 sn isabet koruması, blink/hit flash, kamera, gerçek temaslı tek DODGE ve hızlı göreli süpürme sorgusu. |
| Bina dayanıklılığı ve savaş HUD'u | Codex | Tamamlandı; ayrı bina/takla barları, üst orta boss/zaman/faz, 1/2/3/F ve R ile temiz yeniden başlatma. |
| Adım 1 kontrollerini/görsellerini koruma | Codex | Tamamlandı; koşu/dash ayarları, merdiven ve diorama çizim dili korundu. |
| İnsan oynayış dengesi, ses ve jam export'u | Ekip / sonraki görev | Bekliyor; otomatik kontroller insan eğlence/denge testinin yerine geçmez. |

### Adım 2 doğrulaması

- Godot **4.3** ve **4.7.2** üzerinde import/parse ve motor içi çalışma başarılı. Adım 1 hareket regresyonu **74/74**; yeni savaş davranış kontrolleri **53/53** geçti.
- Her iki motorun gerçek Compatibility/OpenGL renderer'ında savaş testi ve 11 PNG kaydı **64 kontrol / 0 hata** ile bitti. Godot 4.3: 1280×720; kurulu 4.7.2: 960×540. Fırtına uyarısı/mermileri/mobilya/rüzgâr, deprem uyarısı/slam/enkaz, kaos, DODGE ve hit flash görüntüleri incelendi.
- Görseller `%TEMP%/disaster-siege-step2-godot43/` ve `%TEMP%/disaster-siege-step2/` altında. Oyun penceresi normal kullanımda giriş alır; yalnız ekranlı test penceresi fiziksel kullanıcının tuş/mouse girdilerini sentetik testten ayırır.
- Tam program testi, 60 Hz simülasyonda hazırlık ve iki adet 30 sn normal dalgayı, ardından 30 sn kaosu süre atlamadan yürüttü: **10/10 kontrol**, **256 mermi**, **9 tür**, **12 tepe aktif mermi**, normal programda **0 havuz taşması**. Son kaosun bina dayanıklılığı 34,6/100; ölümün test akışını kesmemesi için yalnız test oyuncusunun canı yükseltildi.
- Uyarı süresi sınırları, uyarıdan sonra hedefin değiştirilememesi, aynı mermiye tek DODGE, yakın geçişte DODGE verilmemesi, 1 sn koruma, havuz doyumu/yeniden kullanım, dalga/boss değişimi ve ölüm/R temizliği kontrol edildi.
- Ana oyun kaynakları, Godot 4.x GDScript'tir. Yeni bağımlılık, resim, ses veya font dosyası eklenmedi. Commit/push yapılmadı; önceki Adım 1 yerel çalışması korunarak genişletildi.

## Adım 1 altyapısı — önceki doğrulama kaydı

| Görev | Sorumlu | Durum |
| --- | --- | --- |
| Godot giriş sahnesi ve ölçeklenebilir 1920×1080 alan | Codex | Tamamlandı |
| Üç kat, dokuz oda, dört kolon ve prosedürel diorama | Codex | Tamamlandı |
| Bağımsız eşya durumları ve Custom Sprite alanları | Codex | Tamamlandı |
| Koşu, merdiven, 0,25 sn dash, iz/toz ve dayanıklılık | Codex | Tamamlandı |
| Kamera apply_shake ve T testi | Codex | Tamamlandı |
| Parse, motor içi test ve gerçek render incelemesi | Codex | Tamamlandı |
| Boss/mermi desenleri | Codex / Adım 2 | Tamamlandı; güncel kayıt yukarıda |
| Export, insan oynayış testi ve jam teslimi | Ekip / Codex | Bekliyor |

## Kontrol kaydı

- **Windows x64 / Godot 4.3.stable.official.77dcf97d8:** Resmî taşınabilir motor yalnızca doğrulama için Temp klasörüne alındı. ZIP, resmî `SHA512-SUMS.txt` ile karşılaştırıldı; hash eşleşti. Repo içine motor kopyalanmadı, mevcut Godot kurulumu değiştirilmedi.
- **Kurulu Godot 4.7.2.stable.official.ed1daf0bf:** Import/parse tamamlandı; yeni kaynaklar bu sürümde de açıldı.
- **Motor içi kontroller:** Son test dosyası her iki sürümün gerçek Compatibility/OpenGL renderer'ında **74 kontrol / 0 hata** ile bitti. Dokuz oda/dört kolon/benzersiz durum kayıtları; fiziksel D, W, ↑, S, Shift, Space, sağ tık, T, R girdileri; frenleme, kat sınırı, çarpışmanın geri açılması, dash/hasar/stamina, iz/toz, kamera sakinleşmesi ve sprite atama/override davranışı kontrol edildi.
- **Görsel inceleme:** NVIDIA RTX 4070 Laptop GPU üzerinde 4.7.2'de 1280×720, 4.3'te 960×540 pencere. Apartman, dash ve merdiven PNG'leri açılıp incelendi; üç kat, çevre boşlukları, HUD, karakter ve efektler görünür. Captures: `%TEMP%/disaster-siege-step1/` ve `%TEMP%/disaster-siege-step1-godot43/`.
- İlk ekranlı testte pencerenin açılış/odak olayı ilk sentetik girdiyi etkiledi; test başlangıcına odak beklemesi ve daha geniş hareket örnekleme aralığı eklendi. Son iki motor çalıştırmasında test hatası veya script çalışma hatası görülmedi.
- Eski web oyununun kaynakları aktif klasörden kaldırıldı. Eski üretilmiş npm/build/test önbellekleri, silme yerine `%TEMP%/disaster-siege-old-web-cache-20261016/` dış klasörüne taşındı; yeni oyun bunları kullanmaz. Git geçmişi, `.git` ve eski commitler korundu.
- Kalıcı sprite ataması için `resources/VisualAssets.tres` hazır. Harici PNG ile editörde insan tarafından sürükle-bırak kontrolü yapılmadı; Texture2D ataması ve türe/kimliğe göre öncelik motor testinde doğrulandı.

## Bilinen sınırlar

- Odalar ve mobilyalar dioramadır; sabitlenmemiş eşyalar odaya özgü tehlikeler saçar, oda hasarı görsel durumlar ve eğik eşyalarla gösterilir; rijit cisimli mobilya/kolon fiziği yoktur, yıkık oda yürünebilir kalır.
- Oyuncu silahı, puanlama ve eğitim kararı döngüsü henüz yok. Oda hasarı dalgalar arasında birikir; yıkık oda R'ye kadar onarılamaz. R ve 1/2/3 test başlangıcı binayı yeniler (R malzemeyi ve loot'u da sıfırlar).
- 2x W üst kat yayı fiziktir (yalnız üst döşeme istisnası, duvarlar çarpışır); S ile alt kat 0,11 sn'lik kontrollü fazlamadır (X iç duvarlarla sınırlanır). Yükselişte ve S fazında takla başlatılamaz; oyuncu bu sırada hasar alabilir.
- Loot denge değerleri (3,5–4,0 sn, 5 drop, +45 HP, %45/30/25 tür ağırlığı) otomatik testle seçildi; insanla oynanarak ayarlanmadı.
- Dünya 960×540 çizilip büyütülür. 1920×1080'de pikseller tam 2×2'dir; varsayılan 1280×720 pencerede oran 1,33 olduğundan pikseller eşit boyutta görünmez. Gerekirse `MainGame.pixel_scale = 1` ile tam çözünürlüğe dönülür.
- Harici görsel, müzik veya font dosyası kullanılmıyor; prosedürel çizim AI yardımıyla yazıldı.
- F5 çalıştırması bağımsız EXE/web export doğrulaması değildir.
