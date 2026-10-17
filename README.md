# AFET KUŞATMASI / Disaster Siege

Doğal afet hazırlığı ve farkındalık temalı, Fallout Shelter esinli apartman kesitini bullet-hell hareketiyle birleştiren Godot oyunu. 4 kat × 4 oda = 16 benzersiz odalı apartmanda merdivensiz dolaş: çift zıplamayla üst kata süzül, S ile alt kata in, sekiz yönlü takla at, **FIRTINA → DEPREM → SEL → DEPREM • SEL • FIRTINA** sırasındaki dört bossun paternlerinden kaçın.

**18 Ekim — ana menü ve saha ikmali:** F5/normal açılışta canlı yağmurlu apartman üstünde **Sahaya Gir / Ayarlar / Çıkış** menüsü gelir. Menüde savaş/oyuncu durur; hava, oda ışıkları ve müzik sürer. Başlangıç ve kart sonrası hazırlık **4 saniyedir**; 2,5 sn boss girişleri (final 2,8) ayrıca korunur. Kartlar saha dosyası görünümünde, dokuz mevcut mekanik ve A/B/B seçimiyle sunulur. Ayarlarda ana ses, sessiz ve pencere/tam ekran; tuşlar, Enter/fare seçimi ve ESC geri dönüşü vardır. Ayarlar `user://siege-settings.cfg` içinde saklanır. Pause ekranındaki **Ana Menü** mevcut koşuyu sıfırlayıp açılışa döner.

**Adım 2.7 — karanlık afet gecesi:** Oyun artık kasvetli bir pixel-art gecesinde geçer. Yağmur, kül ve soğuk şimşekler; elektrik kesintisinde karanlık odalar, titreyen amber/acil kırmızı lambalar, baret feneri, yazısız sade bina, çok parçalı canlı bosslar, neon parlayan mermiler ve daha hızlı, tok bir karakter hareketi.

**Karakter ve ekipman:** Reflektörlü kurtarma uzmanı, ağırlıklı çanta/ceket animasyonu ve dört boss için üç tonlu yüzeyler; dört anlaşılır ekipman. Adım 8 ile dokuz aktif kart ve her seçimde solda bir hazırlık + iki aksiyon kartı.

**Adım 5.5:** Dört faz, özgün ve kesintisiz Re minör oyun müziği, her bossa ayrı 2,5 sn sinematik giriş (final 2,8 sn), alt ortada geniş boss HP/süre barı. `ESC/P` duraklatır, `M` sesi kapatır, `-/+` seviyeyi ayarlar.

**Adım 6:** Statik oda/eşya/gölge/güçlendirme/arka plan önbellekleri, 50 hava parçacığı, dört noktalı mermi izleri ve ortak mermi dokuları. Her kare canlı müzik sentezinin yerini ayrı −5 dB WAV döngüsü aldı. Yalnız finalde saldırı arası ×1,3; mermi adedi yaklaşık ×0,7 (tam sayıya yuvarlanır), hız ×0,8, oyuncu/bina hasarı ×0,7, uyarı +0,20 sn. Bu katsayılar beraber uygulanır; toplam insan zorluğunun tek başına tam %30 değiştiği iddia edilmez.

**Adım 8:** Dokuz aktif mekanik ve ikon odaklı kısa kartlar; yalnız depremde bekleme/kaçış boşluğu +%10, hareketli mermi hızı −%10. [Yeni kart etkileri](#afet-hazırlık-bülteni-9-aktif-mekanik-adım-8) aşağıda.

**Adım 7 — okunabilir hızlanan bullet-hell:** Fazlar 50 sn, kart sonrası inşaat artık 4 sn (18 Ekim menü revizyonu). Her savaş 0–15 sn 0,90× sakin ısınma, 15–35 sn 1,00×→1,25× doğrusal artış ve 35–50 sn 1,45× doruk temposuyla ilerler; dorukta müzik ~%5 hızlanır. Fırtınanın beş, depremin dört yeni geometrik koreografisi var; odalardan rastgele eşya fırlatılmaz. Mermiler siyah konturlu, boss neonlu ve beyaz çekirdekli; bütün olağan uyarılar tam 0,55 sn sürer ve son 0,12 sn beyaz parlar. Kuşatmada mobilyalar ~%25 kararır. Mermiye çok yakından değmeden geçmek (**sıyrılma**) +25 takla enerjisi verir.

**Güncel HUD:** Sol üstte kalp/enerji/bina barları, sol altta üç ekipman slotu; boss adı ve 50 sn kuşatma barı alt ortadadır. Girişte sinematik siyah şeritler ve tek büyük boss adı görünür. `1/2/3/4` doğrudan boss testi; `5/6` kaldırıldı.

Codex ile devam için önce [kısa devir notunu](CODEX_DEVIR.md), Claude için [Claude devir notunu](CLAUDE_DEVIR.md) oku.

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
| 1 / 2 / 3 | Kart ekranında seçim (kart ekranı açıkken boss kısayolu çalışmaz) |
| 1 – 4 | Doğrudan, taze dünya: `1` FIRTINA, `2` DEPREM, `3` SEL, `4` DEPREM • SEL • FIRTINA. Kart ekranında 1/2/3 yalnız seçim yapar. |
| Tab veya H (basılı tut) | Küçük kontrol yardımı; bırakınca ekranın altı yine temiz |
| ESC veya P | Oyunu duraklat / devam et (duraklatma paneli ve tuş rehberi) |
| M | Sesi kapat / aç (oyunda ve duraklatma panelinde) |
| - / + | Ses seviyesi (10 kademe; klavye düzeninden bağımsız, sayısal tuş takımı da olur) |
| F9 | Test modunu aç/kapat (yalnız `U` kart denemesi için gerekir) |
| E | Kuşatmada yalnız `[!] ONAR [E]` görünen odada kolon kitiyle onarım veya sabitleme/barikat kurulumu; inşaat evresinde onarım veya bir güçlendirme kiti kurma |
| U (F9 açıkken) | Kart + inşaat denemesi; normal kampanyada etkisiz |
| R | Oyuncuyu, odaları, loot'u ve dalga döngüsünü başa al |

**Adım 3'te Space yeniden takladır** (kullanıcı isteği); zıplama W/↑'dır. A/D ile yatay, W/S ile dikey takla yönünü seç; örneğin W+D+Shift sağ üst çapraza atılır. Yön basmazsan bakış yönüne atılırsın. Havada bir takla ve bir ikinci zıplama hakkı vardır; yere inince yenilenir. Her takla 32 enerji tüketir; enerji kısa gecikmeden sonra dolar.

**Minimal HUD (Adım 5.5):** Sol üstte can/enerji/bina barları; alt ortada 1020×22 px kalın siyah konturlu boss barı, üstünde yalnız boss adı, sağında kalan saniye ve yüzde. Sol alttaki KOLON / SABİTLE / GÜVENLİK slotlarıyla çakışmaz. Tab/H yardımı, E istemi ve sağ üst M/ESC ipuçları korunur. Sinematik girişte HUD gizlenir; başlık ve letterbox görünür.

**Merdiven yoktur.** Kat geçişi her X konumunda çalışır. **Yukarı (2x W, Adım 3-B):** karakter güçlü bir dikey hızla fırlar; yükselirken yalnızca üst katın döşemesi onu yok sayar (duvarlar çarpışmaya devam eder). Döşeme hizasında yapışmaz: yaklaşık 32 px daha yükselip tepe noktasına çıkar, orada dikey hızı sıfırlanır, döşeme çarpışması geri açılır ve normal yerçekimiyle alçalarak yumuşak bir basılma (squash) ve tozla iner. Tepeye varış ~0,35 sn sürer. **Aşağı (S):** 0,11 sn'lik ease-out fazlama döşemeden süzülür. Geçişte rüzgâr izi, hayalet iz ve döşeme tozu çıkar; yükselirken takla başlatılamaz, tepe noktasından sonra hava taklası kullanılabilir. A/D ile yatay kontrol sürer. Tek zıplama yerçekimi, değişken yükseklik, 0,1 sn coyote time ve kısa giriş tamponu kullanır; yukarı takla da tavanın altında durur.

Karakter zıplarken dikey uzar, yere veya yeni kata inince basılır (squash & stretch), koşarken hareket yönüne eğilir; havada bacaklarını toplar, mont etekleri, detaylı afet çantası ve baret kayışı hıza göre gecikerek hareket eder. Bunlar yalnızca görseldir; çarpışma kutusu değişmez. Baretin feneri baktığın yöne sıcak bir ışık konisi uzatır ve karanlık odaları aydınlatır (koni bulunduğun odanın duvarlarında kesilir).

## Duraklatma ve ses (Adım 5)

**ESC veya P** bütün oyunu durdurur (`get_tree().paused`): savaş sayacı, saldırılar, uyarılar, loot süresi ve oyuncu donar. Panel ve ses yöneticisi `PROCESS_MODE_ALWAYS` ile çalışmaya devam eder. Yarı saydam `#0b0e14` karartmanın üstünde kalın `#111518` konturlu panelde ikonlu tuş rehberi tablosu (koşu, zıplama/2x W, S, takla, E, F, 1–4, Tab/H, R, M, ESC/P) ve alt sırada **[ESC / P] DEVAM ET**, **[M] SES: AÇIK/KAPALI**, **-** / ses göstergesi / **+** ve **[R] YENİDEN BAŞLAT** düğmeleri vardır; hepsi fareyle ve klavyeyle (ok tuşları + Enter dahil) çalışır. Kart ekranının üstünde de duraklatılabilir; devam edince kart seçimi olduğu gibi bekler. HUD'un sağ üst köşesinde küçük `[H] YARDIM  [ESC] DURAKLAT  🔈 [M] SES` ipucu durur; sessizde hoparlör çarpılı ve `SES KAPALI` olur. Ses ayarı bu oturum boyunca geçerlidir (diske yazılmaz).

**Ses motoru (`scripts/audio/`):** Harici ses/müzik dosyası kullanılmaz. Mevcut `SoundRecipes`/`SoundSynth` 51 efekt/atmosfer tarifini arka plan iş parçacığında 22,05 kHz 16-bit PCM'e pişirir. Asıl BGM ayrı `MusicScore` ile açılışta bir kez üretilir; oyun sırasında örnek sentezi veya generator tamponu doldurma işi yoktur.

- **Asıl oyun müziği:** Özgün Re minör dark synth/chiptune; ritmik D–F–G–A–Bb–A bası (0,32), kick/snare/hat (0,25), D–F–A–G–E–F–D üst melodi (0,22) ve loş akorlar. 120 BPM / 8 adet 4/4 ölçü = **16 saniye**; istekteki 12,8 sn bu tempo/ölçüyle uyuşmadığından müzikal döngü korundu. 22.050 Hz, 16-bit mono WAV, `LOOP_FORWARD`, `loop_end = örnek sayısı`. Ayrı `bgm_player`, Master, −5 dB, ALWAYS; dalga/menü/yeni oyun sesi kesmez. Beklenmedik durma watchdog ile toparlanır; M kasıtlı sessizi korur. Pause'ta BGM sürer, yalnız eski atmosfer kanalı filtrelenir. SFX miks kuralları korunur; kulakla öznel beğeni ayrıca değerlendirilmelidir.
- **Boss giriş/çıkış sesleri:** FIRTINA için rüzgâr/gök gürültüsü, DEPREM için sismik uğultu ve iki yumruk darbesi, SEL için basınçlı su/köpük, final için üç afetin birleşme darbesi. Önceki oyuncu, onarım, loot, uyarı, darbe, arayüz ve duraklatma efektleri korunur.
- **Saldırı:** Her boss hazırlığında kısa radar uyarı tınısı; fırlatmada element sesi (fırtına hava yarılması, deprem balyoz darbesi, sel basınçlı su, yangın ateş topu patlaması) ve yumuşak savrulma; çarpmada cam / ahşap / taş / metal / su / ateş sesi. Panjurlu odaya gelen fırtına/sel/yangın darbesi ve türbin engellemesi metalik **BLOKLANDI** sesi çalar.
- **Oyuncu ve dünya:** Zıplama, 2x W yükselme süpürmesi, S inişi ve sert inişte tok ayak sesi, takla hava yarılması, DODGE! parlak çınlama, hasarda tok darbe + kısa kalp atışı, loot düşme/toplama (çantada ferahlatıcı akor, güvenlik kitinde tıslama), E onarımında çekiç-somun-hidrolik kilit + onay tınısı, kart ekranı açılış/seçim sesi, oda ve bina çöküşü, zafer akoru ve yenilgi.
- **Miks kuralları:** Her çalmada 0,94–1,06 rastgele perde; aynı ses için 0,05–0,5 sn kısıtlama (mermi fırlatma 0,12 sn, çarpma türü başına 0,11 sn); mermi fırlatma/çarpma sesleri ana efektlerden (−9 dB) **8 dB daha kısık** (−17 dB). Music / SFX / UI bus'ları, Master'da sınırlayıcı; 18 efekt + 4 nabız + 4 arayüz sesi sabit havuzdur, savaşta yeni ses düğümü oluşmaz.

## Oda hasarı, malzeme ve güçlendirme

Odalar başlangıçta 100 HP'dir. Sağlam: en az %70; hasarlı: %35–70 arası; kritik: %0–35 arası; yıkık: 0 HP. Güçlendirmeler hasar alınca kaybolmaz. Bina barı, 16 odanın kalan HP yüzdelerinin ortalamasıdır. **4 oda yıkılırsa veya bina barı sıfırlanırsa kaybedersin.** Yıkık odalar yeniden kurulamaz.

**Kuşatmada E:** Yalnız hasarlı/kritik odalarda görünen **[!] ONAR [E]** işareti onarım iznidir. Bir kolon kitiyle +45 HP onarılır ve çelik/FRP desteği kurulur. Yalnız sabitleme kitin varsa bu odayı sabitleyip barikat kurabilirsin; HP onarılmaz. Sağlam odada E sessizce hiçbir şey yapmaz ve etkileşim ipucu çıkmaz. Kolon kitin yoksa uyarı görünmeye devam eder, E eksik malzemeyi söyler. Bütün mermi, sarsıntı ve aşınma hasarı ortak denge kontrolünden geçer: aynı anda en fazla **3 hasarlı/kritik oda**. Yeni uyarı alan oda **10 saniye** ek hasardan korunur; sonra en fazla 1,3 HP/sn kaybeder (kısa darbe bütçesi 1,5 HP). Fırtınada da odalar kademeli aşınır; onarım bekleyen oda sayısı arttıkça sağlam odalara odaklanan aşınma yavaşlar. Onarmadan uzun süre beklersen oda yine yıkılır. Mermi hasarı, türüne göre çarptığı odada hesaplanır; kat süpürmesi o kattaki dört odayı etkiler.

**Malzemeler yalnız kuşatmada düşer:** İlk düşüş dahil her **5,5–6,5 saniyede**, oyuncunun bulunmadığı, yıkılmamış ve başka loot olmayan rastgele bir odaya. Oda havuzu mevcut konumdan koşu + kat geçişiyle tahmini ulaşım süresine göre süzülür; en az 0,5 sn toplama payı bırakılır (saldırılardan kaçınma süresi bu tahmine dahil değildir). Art arda aynı oda seçilmez. Aynı anda en fazla **3** eşya bulunabilir. 0,45 sn düşüş animasyonundan sonra **yerde tam 4,0 saniye** bekler; halka küçülür ve son 1,5 sn yanıp söner. Süresi dolunca “MALZEME ENKAZDA KAYBOLDU” yazısıyla silinir. Aynı kattaki eşyanın yanına giderek otomatik toplarsın. Dalga bitişi yerdeki malzemenin ömrünü kısaltmaz: kart ekranında sayaç durur, inşaatta kalan süreden devam eder. Kolon kiti yokken ve onarım beklerken her ikinci düşüş kolon kiti olur; rastlantı uzun süre onarım malzemesiz bırakmaz. Topladıkların sonraki evreye taşınır. Ölüm, zafer ve sıfırlamada yerdekiler temizlenir.

| Ekipman | Halka | Oyun etkisi |
| --- | --- | --- |
| Kolon Güçlendirme Kiti (`COLUMN_KIT`) | Kehribar | E ile +45 oda HP ve çelik X/karbon sargı; deprem ve yapısal oda hasarı %50 azalır |
| Eşya Sabitleme & Barikat Kiti (`BARRICADE_KIT`) | Mavi | Tek E ile ANCHOR + SHUTTER: eşya sabitleme görselleri, panjur/kum torbası kurar; fırtına/sel/yangın mermisinin oyuncu ve oda hasarını %50 azaltır |
| Afet & İlk Yardım Çantası (`EMERGENCY_BAG`) | Yeşil | Anında +25 can ve tam takla enerjisi; su, kuru gıda, sargı bezi, düdük etiketi |
| Yangın Tüpü & Gaz Kesici Vana (`SAFETY_KIT`) | Kırmızı/turuncu | Toplandığı odaya otomatik kurulur: aktif/uyarıdaki/gelecek zemin suyu ve alevi engeller, ısıyı temizler, gaz/elektrik kaynaklı ikincil oda hasarını keser |

Sol alttaki **KOLON / SABİTLE / GÜVENLİK** slotları adetleri gösterir. Çanta anında tüketilir; güvenlik sayacı korunan benzersiz odaları gösterir. Drone uzaktan toplasa da güvenlik sistemi loot'un **ilk düştüğü odada** kurulur; komşu odayı temizlemez. Kit, zemin alanını oda sınırlarından böler; çizim ve gerçek kapsül çarpışması aynı parçaları kullanır. Girdap çekimi ve havadaki mermiler güvenlik kitinden etkilenmez.

**İnşaat evresinde E:** Eksik HP varsa kolon kitiyle onarır. Sonra henüz kurulmayan kolon veya birleşik sabitleme/barikat kitini takar. Kolon bir, birleşik kit iki mevcut destek bileşenini doldurur; üç LED ve “TAM ODA DESTEĞİ” bunları gösterir. Aynı bileşen tekrar satın alınmaz. Bu bir gerçek bina güvenliği belgesi değildir. Kuşatmada sağlam odada E sessiz kalır; yıkık odalar kurulamaz.

## Afet hazırlık bülteni: 9 aktif mekanik (Adım 8)

İlk üç faz sonunda solda **yeşil bir hazırlık kartı**, orta ve sağda **mavi/mor iki farklı aksiyon kartı** sunulur. Alınmış kart tekrar gelmez. **1/2/3 veya fare** ile birini seç; seçimde süre ve hareket durur. Kartlarda büyük özgün piksel ikon, kısa başlık, en fazla 12 kelimelik mekanik açıklama ve tek cümlelik kaynaklı bilgi (en çok iki satır) vardır. Sayısal ayrıntılar aşağıdadır; kart yüzünde uzun istatistik listeleri yoktur.

| Grup | Kart | Gerçek oyun etkisi |
| --- | --- | --- |
| A | Çök-Kapan-Tutun Kalkanı | İlk kalkan 0,35 sn sabit durunca açılır; ilk isabet mermisini yok eder. Tüketilince 6 sn sonra otomatik yeniden dolar. |
| A | 72 Saatlik Afet Çantası | Can %45'in altına düşünce fazda bir kez aktif mermileri temizler, +40 can ve 4 sn hız verir. Ölüm kararı öncesinde işler. Tıbbi loot ayrıca 2 sn, 105 px mermi itme/dağıtma çevresi açar. |
| A | L-Demir & Karbon Manto | Karttan sonra onarılan/güçlendirilen odada mavi-kehribar zırh görünür. Odaya giren hareketli mermi başına bir kez %45 bloklama denenir; o odada enerji yenilenmesi iki kat olur. |
| B | Sonik Takla | Takla sırasında gerçek kapsüle değen mermileri, yüksek hızlı kesişmeler dahil parçalar; bitişte şok halkası çizer. |
| B | Otonom Onarım Dronu | Omuz üzerinde uçar; 580 px içindeki yerdeki loot'u oyuncuya çeker. Her 6,5 sn en hasarlı ayakta odaya ücretsiz +45 HP onarım ışını gönderir. Loot'un temel yerde kalma süresi 4 sn'dir. |
| B | Zaman Bükücü Sismograf | Ödül veren sıyrılma (graze), oyuncu merkezinde 220 px / 2,5 sn kubbe açar; içindeki hareketli mermiler %55 yavaşlar. Oyuncu, savaş saati ve sabit zemin alanı süreleri yavaşlamaz. |
| B | Hidrolik Kalkan Küreleri | Zıt konumda dönen iki çelik uydu, kendilerine temas eden hareketli mermileri süpürülmüş çarpışma kontrolüyle dağıtır. Aralarından mermi geçebilir. |
| B | Sismik Çivi Botları | 2x W üst kat yayı ve S inişi boyunca dokunulmazlık; gerçek inişte yalnız hedef odanın mevcut mermileri temizlenir ve +20 HP onarılır. Komşu odalar ve uyarılar korunur. |
| B | Uzaktan Lazer Vinç | Herhangi bir odada E: bir inşaat kiti karşılığında en hasarlı en fazla iki ayakta odaya +45'er HP; bütün aktif mermilerin hareket/ömür/çarpışması 1 sn durur. Yıkık oda dirilmez, gereksiz işlem malzeme harcamaz. |

Kuşatmada normal E hâlâ yalnız görünür onarım uyarısında işler; **Uzaktan Lazer Vinç bu kurala açık istisnadır**. Üç seçimde üç kart edinilir. R bütün kartları, oda enerji zırhını, zaman etkilerini ve faz haklarını temizler. Önceki 19 kartlık havuz ve pasif istatistik bonusları kaldırıldı; standart kit/oda korumaları korunur. Mobilya saldırısı normal kampanyada yoktur; oda eşyaları görsel kimlik/sabitleme detayıdır.

Deprem fazında desen arası bekleme ×1,10; hareketli kaya/şok hızı ×0,90. Sütunlar arası net kaçış boşluğu ×1,10; 12'li merkez halkalarının net kenar boşluğu merkezden 200 px referansında ×1,10'dur (daha küçük kaya hitbox'ı). Uç noktalar, uyarılar, hasar değerleri, fırtına/sel/final desenleri korunur. Bu üç katsayı insanın algıladığı toplam zorluğun tam %10 azalmasını garanti etmez.

[AFAD/USGS bilgi kaynakları](SOURCES.md) oyun etkilerinden ayrıdır: kurgusal kubbe, mermi temizleme, anlık onarım ve kat değiştirme gerçek afet davranışı değildir. Kalkan adı “Çök-Kapan-Tutun” olarak kullanılır; L-demir/karbon uygulaması için yıkımı önleme garantisi verilmez.

## Atmosfer ve görünüm (Adım 2.7)

- **Pixel-art render:** Dünya 960×540 çözünürlükte çizilip en yakın komşu filtresiyle 2× büyütülür; tüm prosedürel çizim gerçek bir piksel ızgarasına oturur. `MainGame` düğümündeki **Pixel Scale** 1 yapılırsa tam çözünürlüğe döner. Uyarı yazıları, boss saldırı adları, rüzgâr sayacı ve DODGE! keskin kalsın diye ayrı ekran katmanında (`WorldLabels`) çizilir.
- **Gece:** Gökyüzü `#0b0e14`–`#141923` aralığında, dither geçişli bantlarla çizilir. Boğuk bir ay, ağır bulutlar, uzakta yangın kızıllığı, karartılmış şehir silüeti (yalnız birkaç mum ışığı), sürekli eğik sağanak, uçuşan kül/köz ve ara sıra binanın yanına düşen soğuk şimşek vardır. Şimşek bir anlığına odaları da aydınlatır; fırtına bossu sahnedeyken şimşek daha sık çakar.
- **Elektrik kesintisi:** Odalar boyanmış parlaklığın yaklaşık %50'siyle, soğuk bir tonla görünür; duvarlarda su lekesi, çatlak, küf ve dither kir dokusu, köşelerde koyu gölge (ambient occlusion/vinyet) bulunur. Her tavan lambası yalnız altına sıcak amber, atölye/çamaşırhane/spor/çatı odalarında **acil durum kırmızısı** bir ışık konisi düşürür. Yorgun ampuller ara sıra titrer; deprem vuruşu veya sarsıntıda lambalar sarkaç gibi sallanır ve yanıp söner.
- **Yazısız bina:** Oda adı levhaları, sol taraftaki "KAT 00–03" kutuları ve çatıdaki apartman tabelası kaldırıldı. Odalar eşyalarıyla anlaşılır; çatıda yalnız havalandırma, su deposu ve anten vardır.
- **Neon mermiler:** Fırtına mermileri elektrik mavisi, deprem mermileri kor turuncusu kenar ışıması ve uzun hareket izi taşır; hepsinin ortasında parlak kırmızı bir tehlike çekirdeği vardır. Uyarılar da aynı renklerde neon kesik çizgi ve parlayan "!" işaretiyle çizilir.

## Karakter ve bosslar — Adım 4.8

Kurtarma uzmanında lacivert/antrasit üç tonlu mont, turuncu/sarı reflektör, vizörlü baret/fener, matara ve ilk yardım işaretli afet çantası, kemer/alet, eldiven ve koruyucu botlar vardır. Çanta yay/sönüm ile hareketi gecikmeli takip eder; koşu, hava ve takla pozu mevcut ayak pivotuna bağlıdır. Hitbox ve normal hareket değerleri değişmez.

Dört bossun yüzeyleri derin gölge, ana ton ve parlak kenarla katmanlanır: fırtınada bulut lobları, elektrik gözü/çatallı damarlar, bıçak kenarları/kiremitler; golemde asimetrik bazalt yüzey, fay dalları, çakıl/toz, dişli çene ve yumruk demirleri; selde lacivert su, turkuaz akıntı ve köpük; birleşik finalde bazalt, hortum halkaları, köpüklü su jetleri ve şimşek damarları.


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

Menüde Sahaya Gir seçildiğinde oyun **4 saniyelik ilk hazırlıkla** başlar; F ile erken başlayabilirsin. Sonlu akış şöyledir:

1. **FIRTINA:** 2,5 sn rüzgâr/şimşek sinematiği → 50 sn savaş → 1 sn çıkış.
2. Kart seçimi + 4 sn inşaat (F ile erken bitir) → **DEPREM:** 2,5 sn zemin çatlağı, yükselen kayalar ve iki yumruk sinematiği → 50 sn savaş.
3. Kart + 4 sn inşaat → **SEL:** 2,5 sn yükselen köpüklü su ve iki cephe tsunami sinematiği → 50 sn savaş.
4. Son kart + 4 sn inşaat → **DEPREM • SEL • FIRTINA:** 2,8 sn üç afetin birleşme sinematiği → 50 sn final → çıkış ve zafer. Beşinci faz yoktur.

Girişte oyuncu hareketi kilitlenir, saldırı veya hasar üretilmez; kamera hafif odaklanır, üst/alt siyah şeritler ve büyük boss adı görünür. Savaş başlayınca eski kadraj ve kontroller geri gelir. Giriş/çıkış 50 saniyeyi, kart seçimi 4 saniyeyi tüketmez.

**Tempo rampası (Adım 7):** Her savaşın kendi saati vardır. 0–15 sn saldırı temposu **0,90×** (tek tek, net desenler); 15–35 sn **1,00× → 1,25×** doğrusal; 35–50 sn **1,45×** doruk. Geçişler 1 sn yumuşatılır, tempo kare içinde sıçramaz. Saldırı saati tempoyla çarpılır, bu yüzden dorukta boss desen değiştirmeyi ~1,6 kat sıklaştırır. Mermi hızı tempo fazlasının yarısı kadar artar (dorukta 1,225×) ve yolun uç noktası değişmez; ısınmada mermiler yazıldığı hızdadır. Final, Nova'sının üstüne rampanın yarısını alır. Dorukta BGM 1,05× oynar (yavaşça geçer, aynı WAV).

**Selin beş şeması:** Zemin taşkını, iki cepheden su duvarları, gerçek üç sekmeli basınç küreleri, girdap/zıpkın ve sinüs yolunda varil/kütük. Uyarı, yerel güvenlik kitleri ve kaçınma yolları korunur.

**Finalin birleşik saldırıları — ateş elementi yoktur:**

- Alt iki kata taşkın + üç gecikmeli çatı kayası. Canlı suya çarpan beton, 0,75 sn ayrı uyarıyla basınç sütunu + iki su/iki kaya parçası saçar; kuru zeminde iki kaya parçası.
- Rüzgâr çekimi + iki yedi mermilik su/rüzgâr girdap halkası ve bir çapraz rüzgâr bıçağı.
- Bir sismik zemin şoku + tsunami duvarı + üç kez seken bir basınç küresi + tavan enkazı.
- Dört köşedeki üç afet kaynağından **1,0 sn uyarılı 20 mermi**; daha geniş kaçış aralıkları.
- Son 15 sn Nova: üç afetli **iki 11'lik halka**, yer değiştirme, ortak sınırdan geçen oda hasarı ve ek kolon/çanta loot'u.

Birleşik bossun bazalt/kaya gövdesi, hortum kolu, su kaplı kaya eli, köpük taçları, girdapları ve şimşekleri binayı çevreler. Alev/lav çizimleri, yangın bossu ve eski çifte faz oyun akışından kaldırıldı. Korunmuş eski yangın tehlikesi yardımcıları ve ekipman direnç verileri normal kampanyada çağrılmaz.

Her saldırı aynı dondurulmuş uyarı/hitbox yolunu kullanır; havuz 128 ile sınırlıdır. Fazlar arasında oda hasarı, envanter ve kartlar korunur; boss testleri taze dünya kurar. `1/2/3/4` boss, kartta `1/2/3` seçim; `F9+U` kart denemesi, `F` hazırım, `R` yeni oyun.

- **Fırtına (Adım 7):** Her desenden önce fırtına hedef kata hızla dalar (0,3 sn, rüzgâr izleriyle). Tünel ve siklon vuruşlarında o katın penceresi önünde tek kat boyunda yoğun bir hortum çekirdeğine büzülür; diğerlerinde tam boyuna uzanır. Beş koreografi sırayla döner:
  - **A · İkiz Girdap Çarkı:** Binanın ortasındaki fırtına gözünden saat yönünde dönen dört kollu kesintisiz sarmal (9 adım, 0,1 sn arayla 11°).
  - **B · Güvenli Kat Ruleti:** Dört kattan üçü kırmızı kenarlı turkuaz rüzgâr koridoruyla işaretlenir, **0,65 sn** içinde 2x W veya S ile işaretsiz komşu kata geç (üstünde ▲/▼ GÜVENLİ KAT plakası). İlk süpürme geçince ikinci rulet başka bir güvenli kat açar.
  - **C · Sinüs Rüzgâr Tüneli:** Sol cepheden sağa akan iki paralel sinüs akımı; aradaki tünel ~78 px yüksektir. Tepe noktasının altında ayakta kal, çukurda zıpla.
  - **D · Çapraz Rüzgâr Makası:** Sol üst ve sol alt köşeden odanı hedefleyen üçer bıçak X çizer; 0,45 sn sonra daha dar ikinci X gelir.
  - **E · Siklon Halkası & İtme:** Hafif uyarılı bir rüzgâr itmesi ve senden en az bir oda uzakta üç genişleyen halka: 1. alçak (zıpla), 2. kafa hizası (yerde kal), 3. dört boşluklu tam halka.
- **Deprem (Adım 7):** Golem odalardan eşya fırlatmaz; her wind-up'ta sabitlenmemiş mobilya yalnız görsel olarak titrer. Dört koreografi sırayla döner:
  - **1 · Dama Tahtası Sütun Çökmesi:** A ve C oda sütunları her katta turuncuyla işaretlenip tavan kaya yağmuruyla çöker; 0,5 sn sonra B ve D. Az önce temizlenen sütuna geç.
  - **2 · Yürüyen Sismik Fay Dalgası:** Yumruk yere iner; her katta sağdan sola dikenli kaya dalgası sırayla yürür. Zıpla.
  - **3 · Sismik Merkez Halkaları:** Orta sütundan üç dalga 12'li simetrik kaya halkası; aynı koridorlar her dalgada açık kalır.
  - **4 · Kat Ezici Balyoz:** Bulunduğun ve komşu katta sağdan sola yuvarlanan kaya blokları: alçak olanın üstünden zıpla, yüksek olanın altında yerde kal; ikinci çift yükseklikleri değiştirir.
- **Uyarılar (Adım 7):** Olağan her tehlike **tam 0,55 sn** önce ince keskin bir lazer çizgisiyle (yol) ya da oda/kat dolgusuyla (alan) gösterilir ve son **0,12 sn** beyaz parlar: “şimdi kaç”. Uzun sınıflar kendi süresini korur: kat duvarı/taşkın 1,0 sn, mühür 0,8 sn, güvenli kat ruleti 0,65 sn; finalde +0,20, radarda +0,25 sn eklenir. Gecikmeli dalgalar kendi tam uyarısını alır. Renkler boss neonudur: fırtına `#00f0ff`, deprem `#ff9500`, sel `#2b7fff`. Bossun wind-up'ı uyarı süresi boyunca oynar.
- **Mermiler (Adım 7):** 3 px `#05070a` dış kontur, içte boss neonu, ortada beyaz `#ffffff` çekirdek; küre, bıçak, kaya ve diken siluetleri. 4 siluet × 3 neon = 12 atlas dokusu savaştan önce pişirilir; her dokuda kontur silueti ve gövde ayrı hücrelerdir, kontur hücresi yarıçap + sabit kalınlığa ölçeklenir, böylece mermi tek doku/tek batch kalır.
- **Kuşatma mobilyası:** Savaşta odaların gevşek mobilyası ~%25 daha koyu ve mat tona yumuşakça geçer; kolon ve pencereler tam parlaklıktadır. Fazlar arasında geri açılır. Önbellek yeniden çizilmez.
- **Parçalanan enkaz (final/uyumluluk):** Beton zemine çarpınca üç parçaya ayrılır. Küçük parçalar önce kendi tam uyarısını gösterir, sonra sola/sağa sekerek gider.
- Dash sırasında gerçek mermi teması hasar vermez ve **DODGE!** gösterir. Sadece yakınından geçmek veya isabet korumasında durmak DODGE sayılmaz.
- **Sıyrılma (graze, Adım 7):** Bir mermi gövdene değmeden kenardan kenara ~22 px yakınından geçerse (koşarken, zıplarken veya taklada) turkuaz/sarı kıvılcım halkası, yumuşak elektrik tıkırtısı ve küçük **SIYRILDI! +ENERJİ** yazısıyla takla enerjisi anında +25 olur. Her mermi bir kez sayılır, iki ödül arasında en az 0,12 sn vardır; isabet alan, isabetten hemen önce pencereye giren veya hasar korumasında geçen mermi ödül vermez. Kat duvarları ve alanlar sıyrılma sayılmaz.
- Normal isabet can azaltır; kısa kırmızı ekran parlaması, kamera sarsıntısı ve **1 saniyelik yanıp sönen hasar koruması** verir. Bu sürede koşu/kat geçişi kontrolü devam eder.
- Her çarpma düştüğü odayı aşındırır (yukarıdaki "Oda hasarı" bölümü). Can sıfırlanırsa, 4 oda yıkılırsa veya bina %0'a düşerse saldırılar durur; R ile yeniden dene.

Kasırga kategorisi, 7.4 golem etiketi, dört afetin tek canavarda birleşmesi, buhar sütunu/mühür/nova, girdap/çapraz yaylım/rüzgâr itmesi, kat fazlaması, 8/5/50 saniye süreler, tempo rampası, güvenli kat ruleti, sıyrılma enerjisi, dash, oda HP değerleri, 4 oda çöküş kuralı ve "kit ile anında onarım" fantastik oyun tasarımıdır; gerçek afet davranışı, bina güvenliği tahmini veya güçlendirme tavsiyesi değildir. Kartlardaki oranlar, FRP etiketi ve fantastik ekipmanlar oyun dengesidir; uygulamalı yapı güçlendirme talimatı değildir.

## Dosyalar

```text
project.godot
scenes/Launch.tscn       Ana menülü normal giriş
scenes/MainGame.tscn     Menü atlanan oynanış/test sahnesi
scripts/MainGame.gd
scripts/art/             Ortak cel çizimi, karakter (mont/çanta/eklem animasyonu), gece arka planı
scripts/art/NightWeather.gd   Yağmur, kül/köz ve şimşek; odaları aydınlatan flaş
scripts/art/AssetRegistry.gd  assets/sprites/ içindeki el yapımı PNG'leri otomatik yükler
scripts/building/        Apartman (karartma), oda dioraması (kir, AO/dither gölge), durumlu eşyalar
scripts/building/RoomLighting.gd Additive lamba konileri, sallanma ve titreme
scripts/player/Player.gd CharacterBody2D, hızlı koşu, 2x W üst kat / S alt kat fazlaması, squash & stretch, baret feneri, 8 yön dash
scripts/camera/          Camera2D, apply_shake ve sarsıntı gücü
scripts/ui/              Sabit ekran HUD'u ve keskin dünya etiketleri (WorldLabels)
scripts/bosses/          Dört çok parçalı, üç tonlu boss + final Titan (CataclysmArt.gd)
assets/sprites/          İsteğe bağlı el yapımı sprite klasörü
scripts/combat/          Dalga, oda hasar tablosu, çöküş kuralı, telgraf, sabit havuz, mermi ve DODGE
scripts/loot/LootSystem.gd Süreli 4 ekipman, toplama, faza bağlı E onarımı/inşaat
scripts/combat/SiegeUpgrades.gd On dokuz kartın kataloğu ve seçimi
scripts/combat/SiegeMechanics.gd Dron, kule, türbin, zincir, manyetizma ve zaman bükme
scripts/ui/UpgradeOverlay.gd Fare/klavye ile üç kart seçimi
scripts/ui/PauseMenu.gd   ESC/P duraklatma paneli, tuş rehberi, ses düğmeleri
scripts/audio/            SoundManager (olaylar/miks), SoundSynth/SoundRecipes (SFX), MusicScore (bir kez pişen BGM)
scripts/combat/BossPatterns.gd Adım 7 fırtına (5) ve deprem (4) koreografileri; eski yardımcılar uyumluluk testleri için
scripts/art/FurnitureArt.gd 16 odaya özgü detaylı prosedürel mobilya çizimleri
resources/VisualAssets.tres Kalıcı sprite atama alanları
tests/FrontEndSmoke.gd   Normal giriş, menü/ayarlar/kalıcılık, gerçek GUI, 4 sn, ara kart ve çıkış
tests/Step1Smoke.gd      Godot içinde giriş/fizik/durum kontrolleri
tests/Step2Smoke.gd      Kuşatma/uyarı/çarpışma/havuz kontrolleri ve görsel yakalama
tests/Step2Soak.gd       Dört tam 50 sn savaş, üç 4 sn ara, gerçek malzeme/onarım
tests/Step25Smoke.gd     16 oda, gerçek jump/2x W/S/air-dash, paternler ve PNG kaydı
tests/Step3Smoke.gd      Ekrana sığma, fırtına bullet-hell paternleri, rüzgâr ve PNG kaydı
tests/Step27Smoke.gd     Karanlık atmosfer, ışıklar, sprite yükleyici, akıcı hareket, boss iskeletleri, 1920×1080 PNG
tests/Step3LootSmoke.gd  2x W yayı, oda HP/durumları, çöküş, loot ve E onarımı, 1920×1080 PNG
tests/CampaignSmoke.gd   4 sn ömür, inşaat, kart modal input, 4 faz, zafer, görsel kayıtlar
tests/Step45Smoke.gd     50/4 sn, giriş/çıkış (final 2,8 sn), hasar sınırı, aktif kartlar ve görsel kayıtlar
scripts/combat/MarathonPatterns.gd Sel/yangın paternleri, kalıcı alanlar, ikincil saldırılar
scripts/bosses/MarathonArt.gd Çok parçalı hidra/titan ve su/ateş çizimleri
tests/MarathonSmoke.gd    Yeni paternler, sekmeler, alan hasarı, kartlar, hareket, cinnet, native PNG
tests/Step48Smoke.gd      Dört kit, yerel güvenlik, 9 aktif kart, 150 seçim ve native PNG
scripts/combat/CataclysmPatterns.gd Final Titan'ın beş birleşik yeteneği, buhar etkileşimi ve nova
tests/Step49Smoke.gd      Minimal HUD, 50 sn, 1–4 kısayolları, birleşme girişi, beş yetenek, nova, gerçek 50 sn final ve native PNG
tests/Step5Smoke.gd       Duraklatma (klavye/fare), M/-/+, sentez kalitesi, miks kuralları, olay sesleri (sıyrılma dahil), kesintisiz PCM müziği ve native PNG
tests/Step55Smoke.gd      Dört faz, sinematikler, alt HUD, ateşsiz paternler ve müzik ölçümleri
tests/Step6Smoke.gd       Statik önbellek, 128 havuz, final ayarı, BGM döngüsü/watchdog
tests/Step8Smoke.gd       Deprem katsayıları, 9 gerçek mekanik, 300 kart seçimi, sıfırlama ve native kart/efekt/input kanıtı
tests/Step7Smoke.gd       50/4 sn, tempo rampası, 5 fırtına + 4 deprem koreografisi (geometri ve gerçek kaçış), 0,55 sn uyarı/flash, mermi paleti, mobilya karartması, sıyrılma, BGM doruğu, dört gerçek 50 sn savaş ve native PNG
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
& 'C:\Godot\Godot_console.exe' --headless --fixed-fps 60 --path . --script res://tests/Step49Smoke.gd
& 'C:\Godot\Godot_console.exe' --headless --fixed-fps 60 --path . --script res://tests/Step5Smoke.gd
& 'C:\Godot\Godot_console.exe' --headless --fixed-fps 60 --path . --script res://tests/Step55Smoke.gd
& 'C:\Godot\Godot_console.exe' --headless --fixed-fps 60 --path . --script res://tests/Step6Smoke.gd
& 'C:\Godot\Godot_console.exe' --headless --fixed-fps 60 --path . --script res://tests/Step8Smoke.gd
```

Linux'ta tüm paketler (kurulumuna göre `godot` yerine motor dosyasını yaz):

```sh
godot --headless --editor --path . --import --quit
for suite in FrontEndSmoke Step8Smoke Step7Smoke Step1Smoke Step2Smoke Step25Smoke Step3Smoke Step27Smoke Step3LootSmoke CampaignSmoke Step45Smoke MarathonSmoke Step48Smoke Step49Smoke Step5Smoke Step55Smoke Step6Smoke Step2Soak; do
  godot --headless --fixed-fps 60 --path . --script "res://tests/$suite.gd" || break
done
godot --path . --script res://tests/Step48Smoke.gd -- --capture=/tmp/siege48-captures
godot --path . --script res://tests/Step49Smoke.gd -- --capture=/tmp/siege49-captures
```

Step49 native testi minimal HUD'u (hazırlık, kuşatma, Tab/H yardımı), birleşme girişinin dört karesini, Titan'ı, beş yeteneğin uyarı/aktif hâllerini, Nova'yı, geri çekilmeyi ve dört faz zaferini 1920×1080 kaydeder.

Step48 native testi 1920×1080 sabit render viewport'unda dört bossun bekleme/hazırlığını, karakterin dört pozunu, loot/HUD ve 9 aktif kartın tamamını kaydeder. Yakın karakter karelerinde yalnız test kamerası büyütülür. Küçük pencerenin gerçek ölçek dönüşümü üzerinden sentetik fare girişi ayrıca sınanır; testteki PNG tasarım çözünürlüğündedir.

Farklı Godot sürümleri arasında geçiş yaptıysan testten önce o sürümle `--editor --quit` çalıştır; aksi hâlde sınıf önbelleği eski kalabilir.

Görsel kontrol için aynı test, `--headless` olmadan `-- --capture=C:/Temp/disaster-siege` ile çalıştırılabilir. Yalnızca gerçek renderer görüntü üretebilir. `Step27Smoke` ve `Step3Smoke` görüntü alırken exclusive fullscreen'e geçer ve tam 1920×1080 kare kaydeder (ekran 1080p ise). `MarathonSmoke` tüm bossların giriş/çıkışlarını, yeni paternlerin uyarı/aktif hallerini, cinneti, iki yeni kartı ve dört faz zaferini kaydeder. 1920×1080 fullscreen ve ölçeklenmiş pencerede gerçek fare seçimi kontrol edilir. Adım4.8 [görsel kanıt dizini](captures/step48/README.md) yerel kopyada bulunur (Git dışında). Test veya görsel sonuçları [STATUS.md](STATUS.md) içinde gerçek motor sürümüyle kaydedilir.

`--fixed-fps 60`, tam dalga testinde gerçek zamanı beklemeyi kaldırır; simülasyon yine 60 Hz adımlarla bütün dalgaları işler. Uzun testte oyuncu canı yalnızca test sahnesinde yükseltilir, böylece tüm saldırılar denetlenir. Test sürücüsü gerçek düşen malzemeleri toplar ve kazanılan kolon kitiyle onarım API'sini kullanır; insan refleksleri veya kaçınma zorluğunun kanıtı değildir. Normal oyunun can ayarı değişmez.

Güne başlamadan temiz çalışma ağacında `git fetch origin`, ardından görev dalına göre uygun güncelleme yap. Yeni işe ayrı `feat/...` dalında başla. Dosyalarını kaydet, Git farkını kontrol et, yalnızca ilgili dosyaları commit et ve kendi dalına pushla. İki kişi aynı dosyada eşzamanlı çalışmasın. Push, bir dalın otomatik olarak `main` ile birleşmesi değildir. Commit/push görevleri kullanıcı isteğiyle yapılır.

Önceki ARTÇI web sürümü kullanıcı isteğiyle kaldırıldı; `2647179` commitinde geçmiş kaydı korunur. Yeni kaynaklar bu sürümle karıştırılmaz. [AI/kaynak beyanı](BEYAN.md), [kaynaklar](SOURCES.md), [teslim kontrolü](SUBMISSION.md).

Adım 5.5 kontrolleri: `tests/Step55Smoke.gd` dört faz/sinematik/alt HUD ve gerçek BGM PCM ölçümlerini içerir. Native kanıt: `--script res://tests/Step55Smoke.gd -- --capture=C:/Temp/step55 --audio=C:/Temp/step55-music.wav` (headless olmadan). Müzik kodu `scripts/audio/MusicScore.gd`, sinematik kodu `scripts/ui/BossCinematic.gd`. Son test sonuçları STATUS.md içindedir.

Adım 6: `tests/Step6Smoke.gd` önbellek yenileme/dormant havuz/uyarı geometrisi/final katsayıları/WAV watchdog'unu kontrol eder. Gerçek ses sürücüsünde iki döngü sınırı ve Master çıkış enerjisi: `--script res://tests/Step6Smoke.gd -- --audio-live --capture=C:/Temp/step6`. FPS karşılaştırması: **headless ve fixed-fps kullanmadan** `--script res://tests/PerformanceBench.gd -- --live --capture=C:/Temp/step6-perf`. Test gerçek makinenin kare süresi/p95/çizim çağrılarını raporlar; tüm bilgisayarlar için FPS garantisi vermez. Statik önbellekler `UPDATE_ONCE` sonrası kapanır; Compatibility/pixel_scale=2 korunur. Sonuçlar STATUS.md'dedir.

Ana menü ve gerçek ara kart native kontrolü: `godot --path . --fixed-fps 60 --script res://tests/FrontEndSmoke.gd -- --capture=/tmp/siege-menu-native`. Dokuz kartın tamamı: `godot --path . --fixed-fps 60 --script res://tests/Step8Smoke.gd -- --capture=/tmp/siege-cards-native`. Menü testi geçici ayrı ayar dosyası kullanır; kullanıcının ses/ekran tercihlerini değiştirmez.
