# AFET KUŞATMASI / Disaster Siege

Doğal afet hazırlığı ve farkındalık temalı, Fallout Shelter esinli apartman kesitini bullet-hell hareketiyle birleştiren Godot oyunu. 4 kat × 4 oda = 16 benzersiz odalı apartmanda merdivensiz dolaş: çift zıplamayla üst kata süzül, S ile alt kata in, sekiz yönlü takla at, fırtına, deprem, çifte kuşatma, sel ve yangın bosslarının paternlerinden kaçın.

**Adım 2.7 — karanlık afet gecesi:** Oyun artık kasvetli bir pixel-art gecesinde geçer. Yağmur, kül ve soğuk şimşekler; elektrik kesintisinde karanlık odalar, titreyen amber/acil kırmızı lambalar, baret feneri, yazısız sade bina, çok parçalı canlı bosslar, neon parlayan mermiler ve daha hızlı, tok bir karakter hareketi.

**Adım 4.8:** Reflektörlü kurtarma uzmanı, ağırlıklı çanta/ceket animasyonu ve dört boss için üç tonlu yüzeyler; dört anlaşılır ekipman, 19 kartlık havuz ve her seçimde solda bir hazırlık + iki aksiyon kartı.

Claude ile devam için önce [devir notunu](CLAUDE_DEVIR.md) oku.

## Oyunu aç

1. Standart **Godot 4.3 veya üstünü** aç. .NET sürümü gerekmez.
2. Proje yöneticisinde **İçe Aktar** seçip bu klasördeki `project.godot` dosyasını seç.
3. **İçe Aktar ve Düzenle** ile aç; **F5** ile oyna. Ana sahne hazırdır; sprite atama veya sahne kurma gerekmez.

Windows'ta **`Oyunu-Ac.cmd` dosyasına çift tıklayarak** da çalıştırabilirsin. Başlatıcı önce `GODOT_BIN` ortam değişkenine, ardından masaüstü/Downloads içindeki standart Godot klasörlerine bakar. Bulamazsa Godot'tan `project.godot` dosyasını aç.

Linux terminalinde proje klasöründen `godot --path .` ile oynat, `godot --editor --path .` ile editörü aç (Godot komutu PATH içinde olmalı). Bu oturumun test motoru `/tmp/siege-tools/Godot_v4.3-stable_linux.x86_64` altındadır.

Godot'un konsol sürümüyle terminalden:

```powershell
& 'C:\Godot\Godot_console.exe' --path .
```

Yukarıdaki EXE yolunu kendi kurulumunla değiştir. Oyun artık yerel web sayfasından veya `npm run dev` ile açılmaz. Kaynak projeyi F5 ile çalıştırmak için export şablonu gerekmez; bağımsız EXE/web dağıtımı ayrı bir teslim işidir.

## Kontroller

| Tuş | İşlev |
| --- | --- |
| A/D veya ←/→ | Hızlı, anında tepki veren koşu (403 px/s); ters yöne basınca hemen döner |
| W/↑ | Katın içinde zıpla; basılı tutarsan daha yükseğe çık (tavanın altında kalır) |
| W/↑ havada ikinci kez | Çift zıplama: bulunduğun X'ten **bir üst kata** fırla; döşemenin biraz üstünde tepe yapıp yumuşakça in. Kat 03'te yalnız havada ikinci zıplama |
| S/↓ | Herhangi bir X'ten **bir alt kata** süzül (yerde veya havada). Kat 00'da havadaysan hızlı iniş |
| Shift, Space veya sağ tık + yön tuşları | Yerde/havada sekiz yöne takla (dash, 1150 px/s); 0,25 sn dokunulmazlık, 0,304 sn bekleme |
| T | Kamera sarsıntısını test et |
| F | Hazırlık süresini atlayıp sıradaki dalgayı başlat |
| 1 / 2 / 3 | Kart ekranında seçim; normal oyunda dalgayı değiştirmez |
| F9 | Test modunu aç/kapat; açıkken 1/2/3/4/5 boss testi yapar |
| E | Kuşatmada yalnız `[!] ONAR [E]` görünen odada kolon kitiyle onarım veya sabitleme/barikat kurulumu; inşaat evresinde onarım veya bir güçlendirme kiti kurma |
| U (F9 açıkken) | Kart + inşaat denemesi; normal kampanyada etkisiz |
| R | Oyuncuyu, odaları, loot'u ve dalga döngüsünü başa al |

**Adım 3'te Space yeniden takladır** (kullanıcı isteği); zıplama W/↑'dır. A/D ile yatay, W/S ile dikey takla yönünü seç; örneğin W+D+Shift sağ üst çapraza atılır. Yön basmazsan bakış yönüne atılırsın. Havada bir takla ve bir ikinci zıplama hakkı vardır; yere inince yenilenir. Her takla 32 enerji tüketir; enerji kısa gecikmeden sonra dolar. Sağ üstte can, takla enerjisi ve **binanın ayrı dayanıklılık barı** görünür.

**Merdiven yoktur.** Kat geçişi her X konumunda çalışır. **Yukarı (2x W, Adım 3-B):** karakter güçlü bir dikey hızla fırlar; yükselirken yalnızca üst katın döşemesi onu yok sayar (duvarlar çarpışmaya devam eder). Döşeme hizasında yapışmaz: yaklaşık 32 px daha yükselip tepe noktasına çıkar, orada dikey hızı sıfırlanır, döşeme çarpışması geri açılır ve normal yerçekimiyle alçalarak yumuşak bir basılma (squash) ve tozla iner. Tepeye varış ~0,35 sn sürer. **Aşağı (S):** 0,11 sn'lik ease-out fazlama döşemeden süzülür. Geçişte rüzgâr izi, hayalet iz ve döşeme tozu çıkar; yükselirken takla başlatılamaz, tepe noktasından sonra hava taklası kullanılabilir. A/D ile yatay kontrol sürer. Tek zıplama yerçekimi, değişken yükseklik, 0,1 sn coyote time ve kısa giriş tamponu kullanır; yukarı takla da tavanın altında durur. Çelik Halat Kancası seçilirse yalnız takla sırasında duvar/kat geçişi açılır; takla bitince çarpışma geri gelir.

Karakter zıplarken dikey uzar, yere veya yeni kata inince basılır (squash & stretch), koşarken hareket yönüne eğilir; havada bacaklarını toplar, mont etekleri, detaylı afet çantası ve baret kayışı hıza göre gecikerek hareket eder. Bunlar yalnızca görseldir; çarpışma kutusu değişmez. Baretin feneri baktığın yöne sıcak bir ışık konisi uzatır ve karanlık odaları aydınlatır (koni bulunduğun odanın duvarlarında kesilir).

## Oda hasarı, malzeme ve güçlendirme

Odalar başlangıçta 100 HP'dir. Sağlam: en az %70; hasarlı: %35–70 arası; kritik: %0–35 arası; yıkık: 0 HP. Güçlendirmeler hasar alınca kaybolmaz. Bina barı, 16 odanın kalan HP yüzdelerinin ortalamasıdır. **4 oda yıkılırsa veya bina barı sıfırlanırsa kaybedersin.** Yıkık odalar yeniden kurulamaz.

**Kuşatmada E:** Yalnız hasarlı/kritik odalarda görünen **[!] ONAR [E]** işareti onarım iznidir. Bir kolon kitiyle +45 HP onarılır ve çelik/FRP desteği kurulur. Yalnız sabitleme kitin varsa bu odayı sabitleyip barikat kurabilirsin; HP onarılmaz. Sağlam odada E sessizce hiçbir şey yapmaz ve etkileşim ipucu çıkmaz. Kolon kitin yoksa uyarı görünmeye devam eder, E eksik malzemeyi söyler. Bütün mermi, sarsıntı ve aşınma hasarı ortak denge kontrolünden geçer: aynı anda en fazla **3 hasarlı/kritik oda**. Yeni uyarı alan oda **10 saniye** ek hasardan korunur; sonra en fazla 1,3 HP/sn kaybeder (kısa darbe bütçesi 1,5 HP). Fırtınada da odalar kademeli aşınır; onarım bekleyen oda sayısı arttıkça sağlam odalara odaklanan aşınma yavaşlar. Onarmadan uzun süre beklersen oda yine yıkılır. Mermi hasarı, türüne göre çarptığı odada hesaplanır; kat süpürmesi o kattaki dört odayı etkiler.

**Malzemeler yalnız kuşatmada düşer:** İlk düşüş dahil her **5,5–6,5 saniyede**, oyuncunun bulunmadığı, yıkılmamış ve başka loot olmayan rastgele bir odaya. Oda havuzu mevcut konumdan koşu + kat geçişiyle tahmini ulaşım süresine göre süzülür; en az 0,5 sn toplama payı bırakılır (saldırılardan kaçınma süresi bu tahmine dahil değildir). Art arda aynı oda seçilmez. Aynı anda en fazla **3** eşya bulunabilir. 0,45 sn düşüş animasyonundan sonra **yerde tam 4,0 saniye** bekler; halka küçülür ve son 1,5 sn yanıp söner. Süresi dolunca “MALZEME ENKAZDA KAYBOLDU” yazısıyla silinir. Aynı kattaki eşyanın yanına giderek otomatik toplarsın. Dalga bitişi yerdeki malzemenin ömrünü kısaltmaz: kart ekranında sayaç durur, inşaatta kalan süreden devam eder. Kolon kiti yokken ve onarım beklerken her ikinci düşüş kolon kiti olur; rastlantı uzun süre onarım malzemesiz bırakmaz. Topladıkların sonraki evreye taşınır. Ölüm, zafer ve sıfırlamada yerdekiler temizlenir.

| Ekipman | Halka | Oyun etkisi |
| --- | --- | --- |
| Kolon Güçlendirme Kiti (`COLUMN_KIT`) | Kehribar | E ile +45 oda HP ve çelik X/karbon sargı; deprem ve yapısal oda hasarı %50 azalır |
| Eşya Sabitleme & Barikat Kiti (`BARRICADE_KIT`) | Mavi | Tek E ile ANCHOR + SHUTTER: avize dahil eşya tehlikesini durdurur, panjur/kum torbası kurar; fırtına/sel/yangın mermisinin oyuncu ve oda hasarını %50 azaltır |
| Afet & İlk Yardım Çantası (`EMERGENCY_BAG`) | Yeşil | Anında +25 can ve tam takla enerjisi; su, kuru gıda, sargı bezi, düdük etiketi |
| Yangın Tüpü & Gaz Kesici Vana (`SAFETY_KIT`) | Kırmızı/turuncu | Toplandığı odaya otomatik kurulur: aktif/uyarıdaki/gelecek zemin suyu ve alevi engeller, ısıyı temizler, gaz/elektrik kaynaklı ikincil oda hasarını keser |

Alt HUD'da **ONARIM KİTİ / SABİTLEME KİTİ**, sayıları ve kısa işlevleri görünür. Çanta anında tüketilir; güvenlik sayacı korunan benzersiz odaları gösterir. Drone/mıknatıs uzaktan toplasa da güvenlik sistemi loot'un **ilk düştüğü odada** kurulur; komşu odayı temizlemez. Kit, zemin alanını oda sınırlarından böler; çizim ve gerçek kapsül çarpışması aynı parçaları kullanır. Girdap çekimi ve havadaki mermiler güvenlik kitinden etkilenmez.

**İnşaat evresinde E:** Eksik HP varsa kolon kitiyle onarır. Sonra henüz kurulmayan kolon veya birleşik sabitleme/barikat kitini takar. Kolon bir, birleşik kit iki mevcut destek bileşenini doldurur; üç LED ve “TAM ODA DESTEĞİ” bunları gösterir. Aynı bileşen tekrar satın alınmaz. Bu bir gerçek bina güvenliği belgesi değildir. Kuşatmada sağlam odada E sessiz kalır; yıkık odalar kurulamaz.

## Afet hazırlık bülteni: 19 kart

İlk dört dalga sonunda **sol kart kesinlikle 5 hazırlık paketinden biri**, orta/sağ kartlar ise **14 aksiyon modülünden farklı ikisi** olur. Alınmış kart tekrar sunulmaz. 1/2/3 veya fareyle birini seç; süre ve hareket seçim sırasında durur. Her kartta net etki ve tek cümlelik “Afet Farkındalık Notu” vardır. Yaklaşık %35 farkındalık / %65 aksiyon hedefi kart yuvalarına uygulanır; eski aktif mekanikler korunur.

| Hazırlık paketi | Oyun etkisi |
| --- | --- |
| 72 Saatlik Tam Donanımlı Afet Çantası | Maksimum can +30, tam iyileşme, her dalga başında bir kez +15 can |
| L-Demir Eşya Sabitleme & Çök-Kapan-Tutun | Rastgele 4 ayakta oda sabitlenir; devrilen eşya hasarı %40 azalır |
| Karbon Fiber (FRP) Kolon Mantolama & Sismik İzolatör | Bütün odaların max HP'si +30; hasarı olan ayakta odalar +35 HP; deprem ve yapısal aşınma %35 azalır |
| Otomatik Gaz Kesici Vana & Duman Dedektörü | Gaz/elektrik ikincil hasarı ve zemin alevinin oyuncu/oda hasarı %45 azalır |
| Taşkın Bariyeri, Çekvalf & Tahliye Pompası | Zemin suyu koşuyu yavaşlatmaz; panjurun fırtına/sel bloklaması %50 → %70 (göreli +%40); yangında %50 kalır |

| Aksiyon modülü | Oyun etkisi |
| --- | --- |
| Otonom Kargo & Arama-Kurtarma Dronu | Loot 4 → 7 sn, oyuncunun toplama yarıçapı 36 → 90 px. Mevcut 430 px uzaktan drone ışını ve her 12 sn bedava +45 oda onarımı korunur |
| Pnömatik Kurtarma Botları & Kevlar Yelek | Koşu +%18, dash bekleme −%30; gerçek dokunulmaz takla süresi 0,25 → 0,35 sn |
| Hızlı Epoksi Enjeksiyon Tabancası & Kalkan Jeneratörü | E onarımı +45 → +85 HP; HP onarınca 2,5 sn gerçek hasar kalkanı |
| Erken Uyarı Sismograf & Meteoroloji Radarı | Her uyarı +0,25 sn, hareketli merminin yol saati ×0,88; dalga başında bir kolon ve bir sabitleme kiti. Sabit zemin alanlarının ömrü uzamaz |
| Takla-Onarım Modülü | Uyarılı odadan dash ile geçerken bir inşaat kitiyle +45 HP ve tam enerji; aynı dash aynı odayı tekrar onarmaz |
| Sismik Çizme & Şok İnişi | S veya 2x W hedef katının mevcut mermilerini şok halkasıyla siler |
| Rüzgar Türbini & Saptırıcı | Panjurda isabeti keser; +6 enerji, üç parçada bir kolon kiti |
| Çelik Halat Kancası | Dash hızı ×1,6, duvar/kat fazlaması; elektrik izi mermi yol saatini ×0,4 yapar |
| Merkezi Harç Pompası | E işleminde dört yöndeki komşuya onarım gücünün yarısı ve %27,5 destek; çapraz oda/sabitleme yok |
| Acil Durum Zaman Bükücü | Son 0,15 sn'de perfect dash: 1,5 gerçek sn yarı hız ve bir kolon loot'u; savaş sayacı gerçek zamanda kalır |
| Paratoner & Lazer Kulesi | Her 3 oyun saniyesinde en tehlikeli büyük mermiyi havada yok eder; ikincil parça üretmez |
| Manyetik Kargo Çekici | 580 px uzaktan çekim, loot 4 → 8 sn, toplamada 2 sn hız/kalkan. Drone ile birlikte 8 sn korunur |
| Otomatik Sprinkler & Söndürme | Yangın kaynaklı oyuncu/oda hasarı −%40; zemin alevi 3 → 1,8 sn |
| Dalgakıran & Drenaj Pompası | Sel kaynaklı oyuncu/oda hasarı −%40; yavaşlatma %35 → %21 |

Global kart indirimleriyle oda kitinin kaynak koruması çarpılarak birleşir; zincirin yarım desteği o kaynakta kit koruması yoksa kullanılır. Aynı kart iki kez alınamaz. R bütün değerleri ve oda kurulumlarını temizler. Eğitim notları [AFAD/USGS ve mühendislik kaynaklarıyla](SOURCES.md) eşleştirilmiştir. “Yaşam üçgeni standardı” güvenlik önerisine dönüştürülmedi; sabitleme ve Çök-Kapan-Tutun ayrı hazırlık/davranış bilgileri olarak sunulur. Anlık onarım ve hasar oranları oyun kurgusudur.

## Atmosfer ve görünüm (Adım 2.7)

- **Pixel-art render:** Dünya 960×540 çözünürlükte çizilip en yakın komşu filtresiyle 2× büyütülür; tüm prosedürel çizim gerçek bir piksel ızgarasına oturur. `MainGame` düğümündeki **Pixel Scale** 1 yapılırsa tam çözünürlüğe döner. Uyarı yazıları, boss saldırı adları, rüzgâr sayacı ve DODGE! keskin kalsın diye ayrı ekran katmanında (`WorldLabels`) çizilir.
- **Gece:** Gökyüzü `#0b0e14`–`#141923` aralığında, dither geçişli bantlarla çizilir. Boğuk bir ay, ağır bulutlar, uzakta yangın kızıllığı, karartılmış şehir silüeti (yalnız birkaç mum ışığı), sürekli eğik sağanak, uçuşan kül/köz ve ara sıra binanın yanına düşen soğuk şimşek vardır. Şimşek bir anlığına odaları da aydınlatır; fırtına bossu sahnedeyken şimşek daha sık çakar.
- **Elektrik kesintisi:** Odalar boyanmış parlaklığın yaklaşık %50'siyle, soğuk bir tonla görünür; duvarlarda su lekesi, çatlak, küf ve dither kir dokusu, köşelerde koyu gölge (ambient occlusion/vinyet) bulunur. Her tavan lambası yalnız altına sıcak amber, atölye/çamaşırhane/spor/çatı odalarında **acil durum kırmızısı** bir ışık konisi düşürür. Yorgun ampuller ara sıra titrer; deprem vuruşu veya sarsıntıda lambalar sarkaç gibi sallanır ve yanıp söner.
- **Yazısız bina:** Oda adı levhaları, sol taraftaki "KAT 00–03" kutuları ve çatıdaki apartman tabelası kaldırıldı. Odalar eşyalarıyla anlaşılır; çatıda yalnız havalandırma, su deposu ve anten vardır.
- **Neon mermiler:** Fırtına mermileri elektrik mavisi, deprem mermileri kor turuncusu kenar ışıması ve uzun hareket izi taşır; hepsinin ortasında parlak kırmızı bir tehlike çekirdeği vardır. Uyarılar da aynı renklerde neon kesik çizgi ve parlayan "!" işaretiyle çizilir.

## Karakter ve bosslar — Adım 4.8

Kurtarma uzmanında lacivert/antrasit üç tonlu mont, turuncu/sarı reflektör, vizörlü baret/fener, matara ve ilk yardım işaretli afet çantası, kemer/alet, eldiven ve koruyucu botlar vardır. Çanta yay/sönüm ile hareketi gecikmeli takip eder; koşu, hava ve takla pozu mevcut ayak pivotuna bağlıdır. Hitbox ve normal hareket değerleri değişmez.

Dört bossun yüzeyleri derin gölge, ana ton ve parlak kenarla katmanlanır: fırtınada bulut lobları, elektrik gözü/çatallı damarlar, bıçak kenarları/kiremitler; golemde asimetrik bazalt yüzey, fay dalları, çakıl/toz, dişli çene ve yumruk demirleri; hidrada lacivert su, turkuaz akıntılar, beyaz köpük taçları/avcı gözler/varil; titanda kömür plakaları, magma çatlakları/çekirdek, omuz alev örtüsü/boynuz ve sarmal korlar.


- **Sismik Golem (sağ):** Kalça, nefes alan gövde, iki omuz, dirsekleri dışa bükülen iki eklemli kollar, dev yumruklar, baş, ayrı menteşeli çene ve etrafında yerçekimsiz dönen kayalar ayrı ayrı ve faz farkıyla hareket eder. Beklerken ağır nefes alır, omuzları kalkıp iner, çenesi açılınca boğazındaki lav parlar ve ağzından duman/köz çıkar. Saldırı uyarısı boyunca kollarını başının üstüne kaldırıp geriye yaslanır, gözleri kor gibi parlar; mermi çıktığı anda yumruklarını apartmanın dibine indirir (çarpma flaşı, toz ve kaya parçası patlaması, şok halkası).
- **Yıkıcı Fırtına (sol):** 12 halkalı omurgası S şeklinde kıvrılan, halkaları genişleyip daralan canlı bir girdaptır; yüzü omurgayla birlikte kayar. Uyarı boyunca kendi içine büzülür, halkalarında ve çekirdeğinde elektrik birikir, şimşek arkları çakar; atış anında apartmana doğru aniden öne genişler, ağzı kükreyerek açılır ve rüzgâr çizgileri savurur.

## Kendi sprite'larını koy

`assets/sprites/` klasörüne şu dosyaları koyarsan oyun bir sonraki açılışta onları kullanır; yoksa karanlık prosedürel çizim çalışır (`scripts/art/AssetRegistry.gd`):

| Dosya | Kullanım |
| --- | --- |
| `player.png` | Oyuncu (sağa bakan, ayaklar alt ortada; 64×88 dünya birimine ölçeklenir, squash/eğilme/takla uygulanır) |
| `boss_storm.png` | Sol fırtına bossu (292×550; uyarıda büzülme, atışta öne genişleme) |
| `boss_quake.png` | Sağ golem (292×550; uyarıda geri çekilme, vuruşta öne çarpma) |
| `tileset.png` | Her odanın arka duvarına döşenen doku (oda rengiyle tonlanır) |

Klasörde ayrıntılı bir [README](assets/sprites/README.md) var. Bu dosyalar `resources/VisualAssets.tres` atamalarından önceliklidir.

## Odalar

| Kat | A | B | C | D |
| --- | --- | --- | --- | --- |
| 03 | Kış bahçesi/sera: cam bölmeler, saksı rafı, eğrelti/palmiye/ot, çatı penceresi | Spor odası: koşu bandı, dambıl rafı, kum torbası, ayna duvar | Resim atölyesi: şövale, boya masası, tablolar, boya lekeli örtü | Çatı elektrik/klima: büyük klima ünitesi, pano, havalandırma motoru, teras merdiveni |
| 02 | Ebeveyn yatak odası: çift yatak, komodin, **büyük gardırop**, perdeli kırık pencere | Banyo: ayaklı küvet, aynalı lavabo, şofben, karo duvar | Çocuk/genç odası: ranza, oyuncak rafı, posterler, klima, yıldızlı duvar | Misafir odası: tek yatak, valiz, komodin, tablo, pencere |
| 01 | Salon: kanepe, TV, sehpa/halı, büyük avize | Yemek odası: uzun masa, iki sandalye, vitrin, baklava desenli duvar | Çalışma odası/kütüphane: çift monitör, döner koltuk, kitaplık, mantar pano | Müzik/plak odası: duvar piyanosu, pikap ve plak dolabı, hoparlör, akustik panel |
| 00 | Teknik atölye/kazan dairesi: kazan, tezgâh, alet dolabı, alet çantası | Giriş lobisi: çift kanatlı kapı, posta kutuları, yangın dolabı, ana elektrik panosu | Mutfak/kiler: buzdolabı, ocak, aspiratör, tezgâh, tabak rafı | Çamaşırhane/vana odası: çamaşır ve kurutma makinesi, gaz/su vanaları, ip üstünde çamaşırlar |

Her eşyanın kimliği (`f<kat>_<ad>`), katı, durumu ve sprite atama yolu ayrıdır. Mobilyalar karakterin hareket alanını kapatan fizik engelleri değildir. Deprem paterninin oda eşyası kaynakları (gardırop, avize, mutfak, tezgâh, kitaplık, oyuncak rafı) 16 odada da birer tane kaldı; böylece deprem zorluğu artmadı.

## Kuşatma nasıl işler?

Oyun **8 saniyelik ilk hazırlıkla** başlar; F ile erken başlayabilirsin. Sonlu akış şöyledir:

1. **Dalga 1 — Yıkıcı Fırtına:** 90 saniye hayatta kal.
2. Kart seç → **tam 7 saniye inşaat** veya F.
3. **Dalga 2 — Sismik Golem:** 90 saniye; ardından kart + 7 sn inşaat.
4. **Dalga 3 — Çifte Felaket:** İki boss farklı katlarda ortak 2,8 sn saldırı temposuyla kuşatır. Ardından kart + 7 sn inşaat.
5. **Dalga 4 — Abisal Taşkın Hidrası:** 90 saniye, 1,8 sn saldırı aralığı; ardından kart + 7 sn inşaat.
6. **Dalga 5 — Piroklastik Kor Titanı:** 90 saniyelik final; 1,6 sn saldırı aralığı, son 10 saniyede saldırı hızı %25 artar (aralık 1,28 sn). Kızıl-beyaz kor ve duman cinneti görünür kılar.
7. Oyuncu ve bina ayaktaysa **“5 BÜYÜK AFET KUŞATMASI ATLATILDI! TAM HAZIRLIK ZAFERİ!”**. Altıncı dalga yoktur.

Her dalgada **1,2 sn giriş → tam 90 sn savaş → 1,0 sn çıkış** vardır; geçişler savaş sayacını tüketmez. Kart seçimi 7 saniyeyi tüketmez. Fırtına dönerek gökten iner/yükselir; golem toz ve sarsıntıyla yükselip parçalanarak gömülür; hidra köpüklü su olarak kabarıp çekilir; titan alev sütunu/kor ile belirip küle dağılır. Bosslar hedef katlara kayar ve hamle yapar; hidra iki cepheyi, titan iki cepheyi ve çatının arkasını kullanır. Çatıdaki titan tam boy çizilir; alt gövdesini bina örter.

**Selin beş şeması:** 3,5 sn zemin taşkını (bazen Kat 00 + 01), farklı katlara çift cephe su duvarı/bıçak, üç kez gerçek sınır sekmesinden sonra altı parçaya ayrılan basınç küreleri, merkeze çeken girdap + yedi zıpkın ve sinüs yolunda varil/kütük/kablo. Taşkında zıplamak zemin hasarından kurtarır; üst katlara geçmek de mümkündür.

**Yangının altı şeması:** Çatıdan/üst çaprazdan meteor ve darbe kıvılcımları, odaya 3 sn alev bırakan napalm, iki karşı fazlı ateş helezonu, 1 sn dolan halkadan sekiz yöne patlayan beş kor çekirdeği, termal çekimden sonra katı süpüren alev duvarı + komşu katlarda zıplanabilen alçak alevler, çift cephe ateş hücumu. Yanan odanın oyun içi sıcaklığı ve HP hasarı artar. Sürekli tehlikeler mevcut bir saniyelik isabet korumasına tabidir.

Bütün yeni saldırılar aynı dondurulmuş yol/alan verisini uyarı ve gerçek çarpışmada paylaşır. Kat duvarları, taşkın ve kor bombaları **1 sn**, diğerleri 0,55–0,75 sn uyarılır. İkincil kıvılcım/su parçaları da ayrı 0,55 sn uyarı alır. 128 mermilik havuz büyümez. Eski üç odalık onarım sınırı, 4 sn loot ve 2x W fizik yayı korunur.

Dalga geçişinde saldırılar temizlenir; oda hasarı, güçlendirmeler, can, envanter ve kartlar korunur. **F9 test modu:** `1` fırtına, `2` deprem, `3` çifte kuşatma, `4` sel, `5` yangın; `U` kart denemesi. Test başlangıcı taze dünya kurar; kart ekranında 1/2/3 yalnız seçim yapar. `F` hazırlığı bitirir, `R` kampanyayı sıfırlar. Oyuncu ateş etmez.

- **Zemin şoku:** Golem alçak dalgaları sağdan sola veya ortadan iki yana gönderir. Üstünden zıpla veya dash ile geç.
- **Fırtına döngüsü (Adım 3):** Fırtına 1,95 sn'de bir, altı vuruşluk döngüyle saldırır (üçüncü dalgada iki bossun ortak temposu 2,8 sn). Saniyedeki uyarılı mermi sayısı Adım 2.5'e göre yaklaşık 1,8 katıdır.
  - **Girdap halkası:** Oyuncunun üstünde olmayan bir odada mini hortum gözü açılır; 10 veya 12 cam/rüzgâr küresi dönerek genişleyen bir halka çizer. Halka kendi katının yüksekliğinde basıktır, alt kısmı ayaktaki oyuncuya değer; aralıkları kolla, zıpla veya takla at. Her döngüde dönüş yönü değişir.
  - **Çapraz yaylım:** Sol pencerelerden ve sağdaki çatı hava akımından gelen sığ çapraz atışlar katın ortasında X çizer; bir yaylım alttan yükselir, sonraki üstten dalar. Yanında uçan bir saksı ve rüzgâr bıçağı vardır.
  - **Hortum koridoru:** Bulunduğun kat 1,0 sn uyarıyla boydan boya süpürülür. 2x W ile üste ya da S ile alta kaç; komşu katlarda zeminden yuvarlanan alçak enkaz/saksı dalgası vardır, onun üstünden zıpla.
  - **Rüzgâr kükremesi:** 0,65 sn ok/sayaç uyarısından sonra bina boyu rüzgâr 2,2 sn seni fırtınadan uzağa (sağa) iter. Hareketsiz durursan sürüklenirsin; karşıya koşarak yavaş ilerler, takla ile tam hızda kesersin. Rüzgâr hasar vermez.
  - **Yelpaze / savrulan eşyalar:** Dönüşümlü 5/7 açılı cam ve rüzgâr küresi; saksı, sandalye ve rüzgâr bıçağı saldırıları korunur.
- **Parçalanan enkaz:** Beton zemine çarpınca üç parçaya ayrılır. Küçük parçalar önce **0,55 sn ayrı uyarı** gösterir, sonra sola/sağa sekerek gider; habersiz aynı-kare hasarı vermez.
- **Kat süpürmesi (deprem: yıkım tüneli):** Katın tamamı **1,0 sn** mavi/kırmızı çerçeveyle işaretlenir. Kat değiştir veya dar ve hızlı duvarı zamanlanmış dash ile aş; kısa zıplama yeterli değildir. Deprem golemi paternleri ve 2,8 sn temposu değiştirilmedi.
- **Oda eşyaları:** Sabitlenmemiş gardırop, avize, mutfak bıçak/tabakları, atölye testere/aletleri, kitap ve oyuncaklar kendi eşyalarının konumundan çıkar. Odasına inşaat evresinde sabitleme kiti kurulan eşya L-demirle sabitlenir ve bu saldırıyı üretmez; yıkık odadaki eşya enkaz altında kalır.
- Kat süpürmesi dışındaki tehlikeler **0,55–0,75 sn** önce uyarılır. Neon kesikli yol/parabol mermi yolunu; kor renkli sütun ve hedef çemberi düşüş alanını gösterir. Bossun saldırı hazırlığı (wind-up) bu uyarı süresi boyunca oynar. Uyarılar hasar vermez ve hedef sonradan değiştirilmez.
- Dash sırasında gerçek mermi teması hasar vermez ve **DODGE!** gösterir. Sadece yakınından geçmek veya isabet korumasında durmak DODGE sayılmaz.
- Normal isabet can azaltır; kısa kırmızı ekran parlaması, kamera sarsıntısı ve **1 saniyelik yanıp sönen hasar koruması** verir. Bu sürede koşu/kat geçişi kontrolü devam eder.
- Her çarpma düştüğü odayı aşındırır (yukarıdaki "Oda hasarı" bölümü). Can sıfırlanırsa, 4 oda yıkılırsa veya bina %0'a düşerse saldırılar durur; R ile yeniden dene.

Kasırga kategorisi, 7.4 golem etiketi, girdap/çapraz yaylım/rüzgâr itmesi, kat fazlaması, 8/7/90 saniye süreler, dash, oda HP değerleri, 4 oda çöküş kuralı ve "kit ile anında onarım" fantastik oyun tasarımıdır; gerçek afet davranışı, bina güvenliği tahmini veya güçlendirme tavsiyesi değildir. Kartlardaki oranlar, FRP etiketi ve fantastik ekipmanlar oyun dengesidir; uygulamalı yapı güçlendirme talimatı değildir.

## Dosyalar

```text
project.godot
scenes/MainGame.tscn
scripts/MainGame.gd
scripts/art/             Ortak cel çizimi, karakter (mont/çanta/eklem animasyonu), gece arka planı
scripts/art/NightWeather.gd   Yağmur, kül/köz ve şimşek; odaları aydınlatan flaş
scripts/art/AssetRegistry.gd  assets/sprites/ içindeki el yapımı PNG'leri otomatik yükler
scripts/building/        Apartman (karartma), oda dioraması (kir, AO/dither gölge), durumlu eşyalar
scripts/building/RoomLighting.gd Additive lamba konileri, sallanma ve titreme
scripts/player/Player.gd CharacterBody2D, hızlı koşu, 2x W üst kat / S alt kat fazlaması, squash & stretch, baret feneri, 8 yön dash
scripts/camera/          Camera2D, apply_shake ve sarsıntı gücü
scripts/ui/              Sabit ekran HUD'u ve keskin dünya etiketleri (WorldLabels)
scripts/bosses/          Dört çok parçalı, üç tonlu boss
assets/sprites/          İsteğe bağlı el yapımı sprite klasörü
scripts/combat/          Dalga, oda hasar tablosu, çöküş kuralı, telgraf, sabit havuz, mermi ve DODGE
scripts/loot/LootSystem.gd Süreli 4 ekipman, toplama, faza bağlı E onarımı/inşaat
scripts/combat/SiegeUpgrades.gd On dokuz kartın kataloğu ve seçimi
scripts/combat/SiegeMechanics.gd Dron, kule, türbin, zincir, manyetizma ve zaman bükme
scripts/ui/UpgradeOverlay.gd Fare/klavye ile üç kart seçimi
scripts/combat/BossPatterns.gd Fırtına girdap/çapraz/koridor, deprem paternleri ve uyarılı sekme zinciri
scripts/art/FurnitureArt.gd 16 odaya özgü detaylı prosedürel mobilya çizimleri
resources/VisualAssets.tres Kalıcı sprite atama alanları
tests/Step1Smoke.gd      Godot içinde giriş/fizik/durum kontrolleri
tests/Step2Smoke.gd      Kuşatma/uyarı/çarpışma/havuz kontrolleri ve görsel yakalama
tests/Step2Soak.gd       Beş tam 90 sn savaş, dört 7 sn ara, gerçek malzeme/onarım
tests/Step25Smoke.gd     16 oda, gerçek jump/2x W/S/air-dash, paternler ve PNG kaydı
tests/Step3Smoke.gd      Ekrana sığma, fırtına bullet-hell paternleri, rüzgâr ve PNG kaydı
tests/Step27Smoke.gd     Karanlık atmosfer, ışıklar, sprite yükleyici, akıcı hareket, boss iskeletleri, 1920×1080 PNG
tests/Step3LootSmoke.gd  2x W yayı, oda HP/durumları, çöküş, loot ve E onarımı, 1920×1080 PNG
tests/CampaignSmoke.gd   4 sn ömür, inşaat, kart modal input, 5 dalga, zafer, görsel kayıtlar
tests/Step45Smoke.gd     90/7 sn, giriş/çıkış, hasar sınırı, dokuz aktif kart ve görsel kayıtlar
scripts/combat/MarathonPatterns.gd Sel/yangın paternleri, kalıcı alanlar, ikincil saldırılar
scripts/bosses/MarathonArt.gd Çok parçalı hidra/titan ve su/ateş çizimleri
tests/MarathonSmoke.gd    Yeni paternler, sekmeler, alan hasarı, kartlar, hareket, cinnet, native PNG
tests/Step48Smoke.gd      Dört kit, yerel güvenlik, 19 kart, 200 seçim, sayısal etkiler ve native PNG
```

Görünür bileşenlerde Inspector'daki **Custom Sprite** alanına Texture2D sürüklenebilir; atanmazsa detaylı prosedürel çizim kullanılır. Bina bütünü için sprite atanırsa oda/eşya çizimleri gizlenir, fizik ve durum verisi korunur. Eşyalar `UNSECURED`, `REINFORCED`, `DAMAGED` durumlarını tutar; oda durumu değişince pencere kırılır/kepenk alır, eşyalar eğilir veya L-demirle sabitlenir; R yazılmış ilk durumlara döndürür.

Prosedürel oluşturulan eşyalar için kalıcı asset ataması: Godot FileSystem'de **`resources/VisualAssets.tres`** dosyasını seç, Inspector'da ilgili Player/Pillar/Window/Sofa vb. alanına PNG sürükle. Yeni mobilyalar dahil bir tek nesne farklı görünecekse `Object Overrides` sözlüğüne `f1_bookcase`, `f2_wardrobe` veya `f0_workbench` gibi `object_id` anahtarıyla Texture2D ekle. Böylece her çalıştırmada sprite yeniden atanır; Remote Inspector'daki geçici değişikliğe ihtiyaç kalmaz.

Boss sprite'ı için `assets/sprites/` klasörünü ya da sahnedeki `World/Viewport/StormBoss` veya `World/Viewport/EarthquakeBoss` düğümünün **Boss Sprite** alanını kullan. Atanmazsa çok parçalı prosedürel iskelet çalışır. Dünya düğümleri (bina, oyuncu, bosslar, kamera) `World/Viewport` SubViewport'unun içindedir.

## Kontrol ve ekip çalışması

```powershell
& 'C:\Godot\Godot_console.exe' --headless --path . --editor --quit
& 'C:\Godot\Godot_console.exe' --headless --path . --script res://tests/Step1Smoke.gd
& 'C:\Godot\Godot_console.exe' --headless --path . --script res://tests/Step2Smoke.gd
& 'C:\Godot\Godot_console.exe' --headless --fixed-fps 60 --path . --script res://tests/Step2Soak.gd
& 'C:\Godot\Godot_console.exe' --headless --fixed-fps 60 --path . --script res://tests/Step25Smoke.gd
& 'C:\Godot\Godot_console.exe' --headless --fixed-fps 60 --path . --script res://tests/Step3Smoke.gd
& 'C:\Godot\Godot_console.exe' --headless --fixed-fps 60 --path . --script res://tests/Step27Smoke.gd
& 'C:\Godot\Godot_console.exe' --headless --fixed-fps 60 --path . --script res://tests/Step3LootSmoke.gd
& 'C:\Godot\Godot_console.exe' --headless --fixed-fps 60 --path . --script res://tests/CampaignSmoke.gd
& 'C:\Godot\Godot_console.exe' --headless --fixed-fps 60 --path . --script res://tests/Step45Smoke.gd
& 'C:\Godot\Godot_console.exe' --headless --fixed-fps 60 --path . --script res://tests/MarathonSmoke.gd
& 'C:\Godot\Godot_console.exe' --headless --fixed-fps 60 --path . --script res://tests/Step48Smoke.gd
```

Linux'ta tüm paketler (kurulumuna göre `godot` yerine motor dosyasını yaz):

```sh
godot --headless --editor --path . --import --quit
for suite in Step1Smoke Step2Smoke Step25Smoke Step3Smoke Step27Smoke Step3LootSmoke CampaignSmoke Step45Smoke MarathonSmoke Step48Smoke Step2Soak; do
  godot --headless --fixed-fps 60 --path . --script "res://tests/$suite.gd" || break
done
godot --path . --script res://tests/Step48Smoke.gd -- --capture=/tmp/siege48-captures
```

Step48 native testi 1920×1080 sabit render viewport'unda dört bossun bekleme/hazırlığını, karakterin dört pozunu, loot/HUD ve 19 kartın tamamını kaydeder. Yakın karakter karelerinde yalnız test kamerası büyütülür. Küçük pencerenin gerçek ölçek dönüşümü üzerinden sentetik fare girişi ayrıca sınanır; testteki PNG tasarım çözünürlüğündedir.

Farklı Godot sürümleri arasında geçiş yaptıysan testten önce o sürümle `--editor --quit` çalıştır; aksi hâlde sınıf önbelleği eski kalabilir.

Görsel kontrol için aynı test, `--headless` olmadan `-- --capture=C:/Temp/disaster-siege` ile çalıştırılabilir. Yalnızca gerçek renderer görüntü üretebilir. `Step27Smoke` ve `Step3Smoke` görüntü alırken exclusive fullscreen'e geçer ve tam 1920×1080 kare kaydeder (ekran 1080p ise). `MarathonSmoke` tüm bossların giriş/çıkışlarını, yeni paternlerin uyarı/aktif hallerini, cinneti, iki yeni kartı ve beş dalga zaferini kaydeder. 1920×1080 fullscreen ve ölçeklenmiş pencerede gerçek fare seçimi kontrol edilir. Adım4.8 [görsel kanıt dizini](captures/step48/README.md) yerel kopyada bulunur (Git dışında). Test veya görsel sonuçları [STATUS.md](STATUS.md) içinde gerçek motor sürümüyle kaydedilir.

`--fixed-fps 60`, tam dalga testinde gerçek zamanı beklemeyi kaldırır; simülasyon yine 60 Hz adımlarla bütün dalgaları işler. Uzun testte oyuncu canı yalnızca test sahnesinde yükseltilir, böylece tüm saldırılar denetlenir. Test sürücüsü gerçek düşen malzemeleri toplar ve kazanılan kolon kitiyle onarım API'sini kullanır; insan refleksleri veya kaçınma zorluğunun kanıtı değildir. Normal oyunun can ayarı değişmez.

Güne başlamadan temiz çalışma ağacında `git fetch origin`, ardından görev dalına göre uygun güncelleme yap. Yeni işe ayrı `feat/...` dalında başla. Dosyalarını kaydet, Git farkını kontrol et, yalnızca ilgili dosyaları commit et ve kendi dalına pushla. İki kişi aynı dosyada eşzamanlı çalışmasın. Push, bir dalın otomatik olarak `main` ile birleşmesi değildir. Commit/push görevleri kullanıcı isteğiyle yapılır.

Önceki ARTÇI web sürümü kullanıcı isteğiyle kaldırıldı; `2647179` commitinde geçmiş kaydı korunur. Yeni kaynaklar bu sürümle karıştırılmaz. [AI/kaynak beyanı](BEYAN.md), [kaynaklar](SOURCES.md), [teslim kontrolü](SUBMISSION.md).
