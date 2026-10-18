# AFET KUŞATMASI — proje durumu

## Güncel — Başarı anları ve oyun hissi (18 Ekim 2026, OpenAI Codex)

Kullanıcının aktardığı Claude kararları uygulandı; önceki kontrol noktası/bölüm seçimi ve commit edilmemiş hazırlık/cila çalışmaları korundu. **Commit/push yapılmadı.** Yeni oyun içi metin veya hasar/süre/loot/oda HP değişikliği yoktur; yalnız normal menülü girişte istenen kısa vuruş donması oynanış saatini etkiler.

- **Görev / onarım / korunma:** FeelFX dünya pixel grid'inde z=7; görevde 12 ışın + çizgi tiki, görev bandında .5sn (hepsi bitince .8sn) yeşil pop. Odanın DAMAGED/CRITICAL → INTACT/FORTIFIED geçişi tek gözlemciden .7sn yeşil çerçeve ve .6sn yükselen artılar üretir; kolon/dron/vinç dahil, sağlam kurulum ve reset hariç. Doğru Çök-Kapan-Tutun .55sn halka + .4sn kubbe ve safe sesi; taş darbesi 3dB kısık. Tür başına8 dünya olayı, en çok16 oda çerçevesi; efektler statik oda/eşya cache'lerini yenilemez.
- **İsabet / sağlık:** .35sn kenar vinyeti ve 5px→0 can barı titremesi; .12sn bekleyip 120HP/sn eriyen soluk can izi, iyileşmede .4sn yeşil. Tam ekran darbe örtüsü en çok .15, altı ayrı kenar bandı en çok .45 alfa; <%30 can .06–.14 /1.6Hz hafif kenar nabzı. Hitstop çıplak MainGame'de kapalı, FrontEnd'de açık; yalnız ölümcül olmayan SIEGE isabetinde .3sn gerçek zaman aralık/.05 time_scale/.06sn ignore_time_scale timer. Reset/fail/finish/collapse/pause açma/menü açma-çıkış/scene exit normal hıza döner; token eski timer'ın yeni duruma sızmasını önler.
- **Loot / karne:** Yeni picked_up(kind, world_position), collected imzası korunur. En çok6 ikon .5sn kuadratik yayla slota/can barına uçar; kit sayısı hemen, slot flaşı ve .28sn pop varışta; toplama dışı artış eski flaşı korur. KarneReveal .2sn sonra/.22sn arayla/.18sn 36px kayarak satırları açar; Overlay ve HUD karne_revealed sunar, metadata metin/sırası ve kart modulate.a fade'i korunur. Sonuçta başlık .25sn, ipucu son satırdan sonra; karne_ok/miss UI sinyallerinden çalar.
- **Ses / müzik:** safe, karne_ok, karne_miss ORDER/all/MIX ve Step5 olay/kalite kontrollerinde. Yeni katman bir kez 22.050Hz/16bit/mono/16sn/120BPM Re minör PCM'e pişer; D2/D3 bas, filtreli hi-hat, D5/F5/A5 arpej. BGM ile aynı karede başlayan Master/ALWAYS oynatıcısı durmadan çalar, pitch eşittir, watchdog konumu eşler. Doruk/son10sn/Nova -10dB, diğer durumlar -60dB; .8sn geçiş; Master ses/sessiz ve çıkış temizliği ortak.

### Doğrulama

- **Godot 4.7.2.stable.official.ed1daf0bf ve 4.3.stable.official.77dcf97d8, Windows:** Her motorda import/parse, **22 paket /1.708 sayaçlı kontrol + Step2Soak tam kampanya**, sıfır başarısız kontrol, SCRIPT ERROR veya son koşu uyarısı. Önceki1.611 korunur: Step11 **91**, Step5 **73→78** (yeni tarif ve olaylar), FrontEnd **30→31** (normal giriş hitstop). Eski regresyon beklentisi/kapsamı silinmedi.
- Paketler: Step1 129, Step2 53, Step25 145, Step3 43, Step27 61, Step3Loot 76, Campaign 59, Step45 73, Marathon 90, Step48 42, Step49 85, Step5 78, Step55 77, Step6 57, Step7 99, Step8 89, FrontEnd 31, MinimalUI 20, Step9 86, Step10 224, Step11 91, Step2Soak geçti (ayrıca11 kampanya koşulu).
- Step11 görev/safe havuz sınırı ve ömrü, gerçek kolon/dron/vinç onarım geçişi, kurulumsuz/reset kutlaması, cache revision ve düğüm sayısı, doğru/yanlış korunma sesi, donma/cooldown/pause/reset/fail/finish/collapse/lethal/exit, can izi ve vinyet, bütün loot hedefleri/yay/varış, karne kademeleri/doğru ses/metin sırası/fade, tek müzik pişirimi/format/tepe/DC/dikiş/ısınma/doruk/Nova/yenilgi/pitch/watchdog/mute sınar. İlk yeni testte headless kayıt yardımcısı çizim beklemediğinden iki görsel metadata kontrolü erken okunuyordu; yardımcı gerçek çizim turunu bekleyecek şekilde düzeltildi, iki motorda son koşu temizdir.
- Ek müzik PCM ölçümü: tepe **0,35520**, DC **−0,0000139**, RMS **0,08985**, en büyük komşu örnek farkı **0,03226**, ilk/son örnek0; .6 tepe sınırı ve tıksız döngü kontrolü geçer. Bunlar insan kulağıyla kalite onayı değildir.
- **İki motorda native Compatibility /1920×1080:** Step11 **97/97**, FrontEnd **37/37**. Toplam **20 PNG** açılıp incelendi: görev ışını/bant tiki, yeşil onarım çerçevesi/artılar, güvenli halka/kubbe, kırmızı kenar/can izi, yarı yolda ikon, yarım karne ve menü/ayarlar/savaş/ara kart. Yazılar kırpılmıyor/çakışmıyor; mevcut gece sanatı ve bölüm menüsü korunur. Son import 4.7.2 ile yapıldı.
- Kanıtlar: `C:/Users/halil/AppData/Local/Temp/siege-step11-validation/` (report.json, native-report.json, loglar, PNG'ler); görev başı kaynak yedeği `C:/Users/halil/AppData/Local/Temp/siege-step11-before.zip`.
- **Denenmeyenler:** İnsan kulağıyla ses/miks/döngü dinleme, insan oyuncuyla oyun hissi/okunabilirlik, fiziksel F5 oynanışı, yeni FPS benchmark'ı, export ve başka bilgisayar. Step6 önbellek/performans sınırları geçmiştir; yeni FPS ölçümü iddiası yoktur.

## Güncel — Bölümden tekrar deneme ve bölüm seçimi (18 Ekim 2026, OpenAI Codex)

Kullanıcının aktardığı Claude tasarımı uygulandı. Görev başındaki commit edilmemiş/izlenmeyen hazırlık, öğretici, minimal UI ve cila çalışmaları korundu. Bu görevde commit/push yapılmadı.

- **Yenilgide R:** Her normal/kısayol boss girişinden hemen önce `PhaseCheckpoint` bağımsız değer kopyaları tutar: kampanya ilerlemesi/mod, kart/teklif durumu, üç envanter sayacı, 16 odanın HP/MaxHP/destek ve koruma alanları, eşyaların sabitlik/devrilme/yön/durumları, hazırlık görevleri/gaz/sigorta/çanta, öğretici adımı ve onarım sayısı. Ölüm veya bina çöküşünden sonra R tam canla aynı bölümün Hazırlık evresine döner (15/10 sn); kart ekranı açılmaz. Başarısız denemenin loot/mermi/uyarı/çöküş/sarsıntı ve geçici kart etkileri temizlenir. İlk öğreticide A D/W tekrarlanmaz; görevler serbesttir. F veya süre sonu aynı bossu başlatır ve yeni hazırlığı tekrar kaydeder. Kontrol noktası yalnız oturum belleğindedir.
- **Tam yeni oyun:** Yenilgi dışındaki R, zaferdeki R ve pause menüsündeki Yeniden başla bütün kampanyayı sıfırlar, kontrol noktasını siler.
- **Bölüm seçimi:** Ana menüde Başla/Ayarlar/Çıkış altında dört küçük MenuItem; fare, oklar+Enter veya 1–4 ile taze bölüm. Oyun ve menü sırası `CAMPAIGN`: **1 Deprem, 2 Fırtına, 3 Sel, 4 Afet**. F/R menüden sızmaz; kart açıkken 1/2/3 yalnız kart seçer. Kart kapalı Hazırlıkta alt ortada kısa bölüm satırı, sıradaki bölüm açık renk; savaşta gizli. Tab/H ve pause rehberi Bölüm der.
- **Final:** Görünür ad **AFET**, sinematik başlığı normal TITLE boyutunda; CATACLYSM enum'u, birleşik sanat ve paternler korunur. 4×4 gece dioraması, hareket/2x W yayı, 40 sn savaş ve mevcut hazırlık/onarım/loot dengesi korunur.

### Doğrulama

- **Godot 4.7.2.stable.official.ed1daf0bf ve 4.3.stable.official.77dcf97d8 / Windows:** Her sürümde import/parse ve **21 paket / 1.611 sayaçlı kontrol + Step2Soak tam kampanya**, sıfır başarısız kontrol, SCRIPT ERROR veya son koşu uyarısı. Başlangıçtaki 20 paket/1.387 kontrol korunur; yeni Step10 224 kontrol ekler. Step2Soak ayrıca 11 kampanya koşulunu doğrular.
- Paketler ve sayaçlar: Step1 129, Step2 53, Step25 145, Step3 43, Step27 61, Step3Loot 76, Campaign 59, Step45 73, Marathon 90, Step48 42, Step49 85, Step5 73, Step55 77, Step6 57, Step7 99, Step8 89, FrontEnd 30, MinimalUI 20, Step9 86, **Step10 224**, Step2Soak başarılı. Yalnız değişen kısayol/HUD/isim beklentileri güncellendi; eski regresyon kapsamı silinmedi.
- Step10 dört bölümde de gerçek ölüm ve 4 oda çöküşü, bütün kayıt alanları ve iç içe destek dizilerinin bağımsızlığı, kart sahipliği/geçici mekanik ayrımı, peş peşe tekrar ve son hazırlığın yeniden kaydı, F/süre bitişi, ilk öğreticide PREPARE, normal/zafer/pause tam sıfırlama, menüde dört bölümün gerçek fare/sayı/ok+Enter olayları, F/R izolasyonu, kart seçimi ve HUD metin dikdörtgenlerini sınar.
- **İki motorda native Compatibility / 1920×1080:** Step10 **227/227**, FrontEnd **36/36**. Toplam **14 PNG** açılıp incelendi: menü, ayarlar, Hazırlık bölüm satırı, savaş, ara kart/karne, yenilgi. Yeni yazılarda kırpılma veya üst üste binme yok; Hazırlık satırı ekipman ve üst görev bandından ayrı, savaş/kartta gizlidir. FrontEnd ayrıca gerçek 1280×720 ölçekli fareyi doğrular. En son 4.7.2 ile yeniden import edildi.
- Kanıt dosyaları: `C:/Users/halil/AppData/Local/Temp/siege-step10-validation/` (`report.json`, `native-report.json`, motor/paket logları ve PNG klasörleri). Görev başı kaynak yedeği `C:/Users/halil/AppData/Local/Temp/siege-step10-before.zip`.
- **Denenmeyenler:** İnsan oyuncuyla fiziksel F5/klavye oynanış testi, kulakla ses değerlendirmesi, yeni FPS benchmark'ı, bağımsız export ve başka bilgisayar. Otomatik gerçek renderer/GUI kontrolleri insan playtest'i değildir.

## Güncel — Cila: akış, görev satırı, onarım öğreticisi (18 Ekim 2026, Claude)

Kullanıcı oynadıktan sonra: öğreticide ne yapıldığı anlaşılmıyor (üstte kısa yazı olsun), hasarlı oda ünlemi zor görülüyor ve onarım hiç öğretilmiyor, bölümler yavaş ve "bayık"; loot 6 sn kalsın ve %20 daha sık çıksın. Kararlar Claude'a bırakıldı.

- **Görev satırı (üst orta, tek satır):** Hazırlıkta ilerleme + görev + neden ("Hazırlık 2/6 · Gardırobu sabitle: devrilmesin", bitince "Hazırsın"; öğretici kapalıyken de). Öğreticide "Koş: A D", "Zıpla: W", ilk depremde "Sarsıntı! C basılı tut: Çök-Kapan-Tutun", "Saldırıdan kaç: SHIFT ile takla".
- **Onarım:** Hasarlı odanın tamamına nabız atan çerçeve, büyük uyarı elması (yarıçap 16) + nefes halkası, yeni hasarda genişleyen halka ve `alarm` sesi (onarımda çalmaz). Öğretici açıkken koşudaki ilk onarıma kadar rehber: "Oda hasarlı: kolon kiti topla" + yerdeki kitin üstünde ok → "Hasarlı odaya git: E ile onar" + W W / S / yön oku → odada yalnız E.
- **Akış:** Savaş 50 → 40 sn ve ilk saniyeden 1,00× tempo (0,90× ısınma kaldırıldı; rampa 10–28 sn, doruk 28–40 sn, Nova son 12 sn). Hazırlık 20/15 → 15/10 sn, öğretici görev saati 25 sn, bütün görevler bitince 0,8 sn; görev ve kit kalmayan ara Hazırlık 3 sn'ye iner. Sarsıntı 1,0 sn uyarı + 1,4 sn (eski 1,2 + 1,8), depremde 8 sn, finalde 12 sn arayla. Öğretici depremde desenler ×0,9 (eski ×0,75), ilk mermi 5. saniyede.
- **Malzeme:** Yerde 6 sn (eski 4), 4,6–5,4 sn arayla (eski 5,5–6,5; ortalama %20 daha sık).

### Doğrulama

- **Godot 4.7.2.stable ve 4.3.stable, Windows, headless:** her iki sürümde import/parse ve **20 paket / 1.387 kontrol + Step2Soak tam kampanya**, sıfır başarısız kontrol ve sıfır betik hatası. Step9 68 → 86 (yeni `_polish`: süreler, görev satırı, 6 sn loot, onarım rehberi, çerçeve/işaret/ok, alarm sesi, boş Hazırlık 3 sn). Soak: 4×40 sn savaş, üç 10 sn Hazırlık, 1.095 atış, tepe 46 mermi, en çok 3 onarım uyarısı. Final 40 sn sürücüsü 348 atış.
- Eski testler yeni sürelere uyarlandı (Step2/3Loot/Campaign/45/48/49/5/55/7/8/MinimalUI/Soak); kapsam silinmedi. Loot ömrü artık bir sonraki düşüşle çakıştığı için Campaign'in tek-eşya ömür kontrolünde otomatik düşüş kapatılır.
- **Native 4.7.2 / 1920×1080:** Step9 **96/96**, FrontEnd **36/36**, MinimalUI **30/30**; görev bandı, hasarlı oda çerçevesi/elması/halkası, kit üstü ok ve yön oku, odada E ve normal girişten ilk savaş PNG olarak incelendi.
- **Denenmeyenler:** İnsan oyuncunun yeni akışı yeterince hızlı/akıcı bulması ve öğretici depremin zorluğu (playtest gerekli); 4.3 native görüntü; export ve başka bilgisayar.
- **Bu görevde commit/push yapılmadı.**


## Önceki — Afete hazırlık güncellemesi (18 Ekim 2026, Claude)

Kullanıcı oyunun jam teması "afete hazırlık ve farkındalık"tan uzaklaştığını söyledi; bütün tasarım kararlarını Claude'a bıraktı. Hedef jüri ölçütleri (oynanabilirlik 25, temayla ilişki 25, yaratıcılık 20, görsel/işitsel 15, teknik 15) ve ilk bossun öğretici olması. Jüri sunum sırasında kısa süre oynayacağı için ilk ~90 saniye temayı taşıyacak şekilde kuruldu.

- **Kampanya sırası:** DEPREM → FIRTINA → SEL → final (`DisasterWaveManager.CAMPAIGN`). Mode değerleri ve 1–4 kısayolları değişmedi.
- **Hazırlık:** İlk 20 sn, sonrakiler 15 sn; görevler E ile: 4 uzun eşyayı sabitle, gaz vanası, afet çantası (lobi çıkışı), ikinci Hazırlık'tan 4 kepenk, selden önce ana sigorta. Her birinin savaşta somut karşılığı var (devrilmeyen eşya, kaçaksız gaz, bir kez +35 can, yarı fırtına/sel hasarı ve kırılmayan cam, elektriksiz su). Hepsi bitince afet hemen gelir; F her zaman erken başlatır.
- **Sarsıntı ve Çök-Kapan-Tutun:** Depremde 2. saniyede ve 9,5 sn arayla, finalde 6 sn/14 sn (Nova'da yok). 1,2 sn uyarı (turuncu çerçeve, tavan tozu, ekran kenarı, C tuşu), 1,8 sn sallantı: yavaş adım, kat değişimi yok; sabitlenmemiş eşya devrilir (yanındakine 18), kepenksiz pencere yanında cam (8), tepe anında tavan sıvası (14) yalnız C basılıyken engellenir; gaz açıksa 4 odada kaçak. Sarsıntıda mermi desenleri bekler.
- **Öğretici:** Normal girişte varsayılan açık (Ayarlar'da "Öğretici açık/kapalı"), çıplak MainGame test sahnesinde kapalı. A D → W (görevler bu sırada karanlık, saat bekler) → 30 sn görev saati ve W W / S / ok yönlendirmesi → ilk depremde 2,0 sn uyarılı sarsıntıda C, ilk saldırıda SHIFT. Öğretici depremde oyuncu hasarı ×0,6, desenler ×0,75 sıklıkta, ilk mermi 6. saniyede.
- **Karne:** Kart ekranının üstünde, yenilgi ve "Hayatta kaldın" ekranlarında en çok üç satır; önce kaçırılanlar, her birine tek kısa öneri (AFAD sayfalarının arama özetlerine dayalı, SOURCES.md).
- **Diğer:** Ana menüde "Hazırlık hayat kurtarır" alt başlığı; DOME kartının adı "Sakin Kal"; Tab/H ve pause listesine C. Yeni sesler `tremor`, `topple`, `secure`, `cover`. Yeni kod `scripts/prep/{Preparedness,TutorialGuide,Debrief}.gd`, `scripts/combat/TremorSystem.gd`.
- **Bulunup düzeltilenler:** Sarsıntı boss'un `cue_attack` sinyalini tetikleyip desen sırasını bozuyordu → ayrı `wind_up`. Final Nova'sı sarsıntı beklemesine takılıyordu → Nova kararı beklemeden önce, Nova sarsıntıyı iptal eder. Öğreticinin ilk adımında A D, E ve çanta işareti üst üste biniyordu → görevler yürüme öğrenilince açılır, çanta kapının yanına taşındı.

### Doğrulama

- **Godot 4.7.2.stable ve 4.3.stable, Windows, headless:** her iki sürümde import/parse ve **20 paket / 1.369 kontrol + Step2Soak tam kampanya**, sıfır başarısız kontrol ve sıfır betik hatası. Paketler: Step1 129, Step2 53, Step25 145, Step3 43, Step27 61, Step3Loot 76, Campaign 59, Step45 73, Marathon 90, Step48 42, Step49 85, Step5 73, Step55 77, Step6 57, Step7 99, Step8 89, FrontEnd 30, MinimalUI 20, **Step9 68 (yeni)**, Step2Soak geçti (deprem-önce dört faz, üç 15 sn Hazırlık, 1.356 atış, tepe 47 mermi, en çok 3 onarım uyarısı).
- Eski testler yeni tasarıma uyarlandı, kapsam silinmedi: sıra (Step2/45/49/55/Campaign/Soak), 20/15 sn (Step7/45/49/FrontEnd/Campaign), sonuç ekranları (MinimalUI). Step2'nin çarpışma/havuz koşusunda sarsıntı kapatılır; Marathon'un taban su hasarı kontrolünde sigorta kapalıdır (elektrikli su ×1,5 Step9'da). Final 50 sn sürücüsü sarsıntı beklemeleriyle 479 yerine 439 atış üretir.
- **Native 4.7.2 / Compatibility / 1920×1080:** Step9Smoke **75/75**, FrontEndSmoke **36/36**, MinimalUISmoke **30/30**. Öğretici A D adımı, W W yönlendirmesi, görev işaretleri ve E iş halkası, sarsıntı uyarısı (C, turuncu çerçeve), sallantıda devrilmiş eşyalar ve çömelme pozu, karneli kart ekranı, karneli yenilgi/zafer, menü alt başlığı ve öğretici ayarı PNG olarak açılıp incelendi.
- **Denenmeyenler:** İnsan oyuncunun öğreticiyi ve C/E'yi gerçekten anlaması, öğretici depremin zorluğu ve jüri süresinde ne kadar ilerlendiği (gerçek playtest gerekli); 4.3 ile native görüntü; export ve başka bilgisayar. AFAD sayfaları doğrudan açılamadı (HTTP 500), öneriler resmî alan adındaki arama özetleriyle karşılaştırıldı.
- **Bu görevde commit/push yapılmadı.** Yeni izlenmeyen dosyalar: `scripts/prep/*`, `scripts/combat/TremorSystem.gd`, `tests/Step9Smoke.gd` ve `.uid`'leri (önceki minimal UI dosyalarıyla birlikte); repo `.uid` dosyalarını takip eder.


## Önceki — Minimal arayüz (18 Ekim 2026, Claude)

Kullanıcı tasarım kararlarını Claude'a bıraktı ve arayüzün her yerinde "AI yazmış" hissi veren yazılardan şikâyet etti: boss üstündeki hareket adları, ayar/menü yazıları, kart adı ve açıklamaları, can/kalkan/bina göstergeleri. İstek: olabildiğince minimal, oynanışa odaklı ekran. Taban `296ffd8` (origin ile hızlı ileri alındı).

- **Oyun içi yazı:** Yalnız boss adı (alt ortada küçük), kit sayıları, E tuş başlığı, Tab/H tuş listesi, sinematik boss adı ve yenilgi/zafer başlığı + tek ipucu. Saldırı adları, DODGE/SIYRILDI, loot/kurulum mesajları, yüzde/saniye/x-y sayaçları, köşe ipuçları, oyuncu üstündeki dünya içi can/enerji barları kaldırıldı.
- **HUD:** Sol üst 10 dilimli can (az kalınca nabız), ince enerji çizgisi, 4×4 oda haritası (sağlam/hasarlı/kritik/yıkık renkleri, bulunduğun oda çerçeveli). Sol alt üç kit ikonu + sayı rozeti (boşken karartılmış, kit gelince parlar). Alt orta `Rect2(610,1040,700,6)` boss çizgisi. Sessizde sağ üstte yalnız çarpılı hoparlör.
- **Dünya işaretleri:** Onarım gereken odada koyu kenarlı uyarı elması (kritikte kırmızı, lamba ışığı dışına alındı), E bir işe yarayacaksa oyuncu üstünde E tuşu, güvenli kat ruletinde yeşil çerçeve.
- **Yazı tipi:** Önce denenen Press Start 2P, Türkçe büyük harfleri (Ç Ğ İ Ö Ş Ü) küçük harf boyunda çizdiği için bırakıldı. Yerine projeye özgü 5×7 `PixelFont` çalışma anında `FontFile` olarak üretilir; harici font dosyası yok. Boyutlar 24/36/48/72 (varsayılan 1280×720 pencere 2/3 ölçeklediği için en az 24).
- **Menüler/kartlar:** Ana menü Başla/Ayarlar/Çıkış; ayarlar Ses sürgüsü, Ses açık/kapalı, Tam ekran/Pencere, Geri. Pause Devam/Yeniden başla/Ana menü/Ses + 10 dilimli seviye ve iki satır tuş listesi. Kartlar yalnız ikon, kısa ad, ≤7 kelimelik etki ve seçim tuşu; adlar sadeleşti (ör. Ağır Çekim, Yörünge Küreleri, Çelik Botlar, Uzaktan Vinç). Kart etkileri, A/B/B seçimi ve oyun dengesi değişmedi. `FieldUI.gd` kaldırıldı.
- **4.3 düzeltmesi:** Godot 4.3'te kart altındaki 1/2/3 etiketi 28→48 px büyüyüp kartın dışına taşıyordu (Label, varsayılan font hâlâ yüklüyken boyut alınca minimum boyuta büyüyor, geri küçülmüyor). `UIStyle.label/item` artık boyutu font ve ağaç eklemesinden sonra verir; numara satırı 36 px.
- **Testler:** Yeni `tests/MinimalUISmoke.gd`. Eski metin beklentileri yeni davranışa uyarlandı, kapsam silinmedi: Step2 (DODGE kıvılcımı), Step5 (Ses açık/kapalı, `mute_drawn`), Step7 (sıyrılma yazısız), Step8/48 (kart ad/etki, not yok), Step27 (güvenli kat çerçevesi), Step3Loot (mesaj adı), Step49 (yalnız boss adı, oda haritası rengi, kısa yardım). Step49'un 13 ayrı metin kontrolü daha az ama kapsayıcı kontrole indi (94→85).

### Doğrulama

- **Godot 4.7.2.stable ve 4.3.stable, Windows, headless:** import/parse ve her sürümde **19 paket / 1.297 kontrol + Step2Soak tam kampanya**, sıfır başarısız kontrol, sıfır betik hatası. Paketler: Step1 129, Step2 53, Step25 145, Step3 43, Step27 61, Step3Loot 76, Campaign 59, Step45 73, Marathon 90, Step48 42, Step49 85, Step5 73, Step55 77, Step6 57, Step7 99, Step8 89, FrontEnd 26, MinimalUI 20, Step2Soak geçti. İlk 4.3 koşusunda Campaign ve MinimalUI kart sınırı kontrolleri düştü; yukarıdaki düzeltmeden sonra iki sürümde de tam koşu temiz.
- **Native 4.7.2 / Compatibility / 1920×1080:** MinimalUISmoke **30/30**, FrontEndSmoke **32/32**, Step8Smoke **103/103**, Step48Smoke **67/67**. Ana menü, ayarlar, hazırlık/savaş HUD'u, yardım, E tuşu, rulet çerçevesi, pause, kartlar, boss girişi, yenilgi, zafer ve dokuz kartın tamamı PNG olarak açılıp incelendi; Türkçe harfler doğru, metinler kırpılmıyor.
- **Denenmeyenler:** İnsan oynanışında okunabilirlik/beğeni (özellikle küçük oda haritası ve uyarı elmasının savaş sırasında fark edilmesi), 4.3 ile native görüntü, gerçek 1280×720 pencerede göz kontrolü (yalnız ölçek hesabı ve önceki ölçekli fare testi), farklı GPU/ekran, export. Doğrudan `MainGame.tscn` test sahnesinde ana menü olmadığından pause listesinde "Ana menü" satırı boş kalır; normal `Launch.tscn` girişinde doludur.
- **Bu görevde commit/push yapılmadı.** Yeni dosyalar (PixelFont, UIStyle, MenuItem, MinimalUISmoke ve `.uid`'leri) izlenmeyen durumda; repo `.uid` dosyalarını takip ettiği için commit sırasında onlar da eklenmeli.


## Güncel — Ana menü ve saha ikmali (18 Ekim 2026, Codex)

Adım 8'e geri dönülmüş çalışma ağacı üzerinde kullanıcının yeni arayüz/tempo isteği uygulandı. Adım 8 geri dönüşü `2f045cc` commitinde ayrı kaydedildi. Kullanıcı 18 Ekim 2026'da menü/kart değişikliklerinin de commit edilip `feat/disaster-siege-step1` dalına gönderilmesini istedi.

- **Ana menü:** Normal giriş `scenes/Launch.tscn`: Sahaya Gir / Ayarlar / Çıkış. Aynı apartman dioraması, yağmur ve sıcak oda lambaları; karanlık pencere/metal/kağıt tonları, sınırlı çizik/doku ve klavye odağı. Menüde oyuncu, dalga, loot, mermiler, mekanikler ve oynanış girdisi durur; hava/ışık/müzik sürer. Başlatınca kadraj/HUD/girdi geri gelir. Pause ekranında Ana Menü mevcut koşuyu sıfırlar.
- **Tempo:** İlk hazırlık ve üç dalga arası inşaat artık **4 sn**. Kart seçimi/hazırlık saati birbirini tüketmez. Boss girişleri 2,5 sn (final 2,8), savaşlar 50 sn ve önceki giriş/çıkış/birleşme sinematikleri korunur.
- **Ayarlar:** Master ses sürgüsü, M sessiz, pencere/tam ekran, ESC geri; tercih `user://siege-settings.cfg` içinde saklanır. Testte ayrı geçici dosya kullanılır. Çıkış, ses mikserinin kaynak bırakmasını bekleyerek kapanır.
- **Saha ikmali:** Düz parlak kartların yerine teknik çizim alanlı, kesik köşeli ekipman dosyaları; tamamlanan afete göre başlık, kısa giriş hareketi, sakin yeşil/mavi/mor vurgu. Dokuz kartın etkileri, A/B/B seçimi, kaynaklı bilgi cümleleri ve 1–3/fare seçimi korunur. Metinler küçültülmeden alanına sarılır; farkındalık notu en çok iki satırda tam görünür.
- **Kontrol — Linux / Godot 4.3.stable.official.77dcf97d8:** Import/parse ve **18 paket / 1.297 kontrol**, sıfır başarısız kontrol/betik hatası/son koşu uyarısı. Önceki 17 paket 1.271; yeni FrontEndSmoke 26. Eski 8/5 sn sınırları ilgili testlerde 4/4 sn'ye uyarlandı; regresyon kapsamı kaldırılmadı. Tam dört 50 sn savaş + üç 4 sn inşaat sürücüsü geçer. Native FrontEndSmoke **32/32**, Step8Smoke **103/103**; **11 adet 1920×1080 PNG**. Dokuz kartın gerçek görünür satırları/yatay sınırı; ses/ekran/kalıcılık, menüde girdi izolasyonu, klavye/fare, ölçekli 1280×720 fare, gerçek boss çıkışından kart ve çıkış sınandı. Tekrarlı üç headless kapanış da temizdir.
- **Koruma:** Eski web worktree'sindeki 22 değişiklik ve Godot'un önceki geri dönüşünün içeriği ayrı committe korunur. Yeni harici asset/font/ses/bağımlılık yok. AI katkısı BEYAN.md'de kayıtlıdır. Normal testler doğrudan MainGame.tscn kullanmaya devam eder.
- **Kanıtlar:** [Yerel görseller ve rapor](captures/menu-20261018/README.md) (Git dışında). İnsan beğeni/zorluk/işitsel kalite, Windows, başka GPU ve yeni export bu oturumda değerlendirilmedi.


## Güncel — Adım 8 (18 Ekim 2026, Codex)

Claude'un çalışma ağacındaki Adım 7 değişiklikleri korunarak yeni istek uygulandı. Godot 4.3+ Compatibility, 4×4 gece dioraması, 2x W fizik yayı, mevcut tuşlar, dört adet 50 sn savaş, üç adet 5 sn hazırlık, Fırtına/Sel/Final paternleri ve WAV BGM korunur. Aşağıdaki 19 kart ve eski aktif modüllerle ilgili kayıtlar tarihçedir.

| İş | Sonuç |
| --- | --- |
| Deprem fazını hafifletme | Yalnız faz 2: desen arası bekleme ×1,10; hareketli kaya/şok dalgası hızı ×0,90 ve aynı uç nokta. Dama sütunlarının net kaçış boşluğu ×1,10. 12'li halkada merkezden 200 px referansındaki net kenar aralığı ×1,10; kaya yarıçapı yaklaşık12→8,02. Sabit ROCKFALL alanının hasar süresi değişmez. Fırtına fonksiyon bloğu, Sel/Final desenleri ve karakter sanatı görev başındaki Claude kopyasıyla birebir aynı. Üç katsayı algılanan toplam zorluğun tam %10 azalması iddiası değildir. |
| Dokuz aktif kart | 3 hazırlık +6 aksiyon: Çök-Kapan-Tutun Kalkanı, 72 Saatlik Afet Çantası, L-Demir & Karbon Manto; Sonik Takla, Otonom Onarım Dronu, Zaman Bükücü Sismograf, Hidrolik Kalkan Küreleri, Sismik Çivi Botları, Uzaktan Lazer Vinç. Önceki pasif stat bonusları ve etkisiz eşya-hasarı kartları kaldırıldı. |
| Gerçek etkiler | Kalkan ilk isabeti siler/6sn şarj; çanta <45% can/fazda1/+40can/4sn hız ve tıbbi lootta2sn savma; onarılan odada %45 tek deneme ve enerji×2. Dash gerçek temasta parçalar; drone6,5sn ücretsiz45HP ve loot çekme; graze220px/2,5sn/hız×0,45; iki orbital gerçek süpürme; botlar gerçek inişe kadar koruma/hedef oda temizliği/+20; vinç tek kit/en fazla2uzak oda/45'erHP/1sn tam mermi donması. Ayrıntılar README'dedir. |
| Kısa kartlar | Büyük özgün UpgradeIcon, kısa başlık, en fazla12 kelimelik kalın mekanik metin, tek satır bilgi; kesin yeşil/mavi/mor A/B/B düzeni. Yerel ve ölçekli fare/1–3 girişleri çalışır. İlk native incelemede drone açıklamasının son satırı kesiliyordu; metin alanı132px yapıldı ve tüm9 kart tekrar doğrulandı. |
| Eğitim / ses / kaynak | Yanıltıcı garanti cümleleri yerine AFAD/USGS kısa notları; kalkan adı Çök-Kapan-Tutun. Yeni harici asset/font/ses yok. Var olan block/heal/repair/graze/dash/iniş sesleri yeni olaylara bağlı, sınırlı havuz korunur. |
| Performans sınırları | Oda zırhı mevcut statik destek cache'inde; per-frame oda cache'i yok. Mermi128, efekt parçacığı480, ışın64, halka24, uçan metin32 sınırı. BGM ve atmosfer değişmedi. Bu adımda yeni FPS benchmark'ı yapılmadı. |

### Adım 8 doğrulaması

- **Godot 4.7.2.stable.official.ed1daf0bf ve 4.3.stable.official.77dcf97d8**, Windows: import/parse ve her sürümde **17 paket / 1.271 kontrol / sıfır başarısız kontrol / sıfır betik hatası**. Paket sayıları: Step1 129, Step2 53, Step25 145, Step3 43, Step27 61, Step3Loot76, Campaign59, Step45 73, Marathon90, Step48 42, Step49 94, Step5 73, Step55 77, Step6 57, Step7 99, Step2Soak11, Step8 **89**. Eski kart beklentileri kullanıcı isteğiyle kaldırılan tasarımın yerine geçirildi; değişmeyen oda/loot/hareket/uyarı/ses/faz testleri korunur.
- Step8 her mekanik için gerçek mermi/sağlık/stok davranışını sınar. Örnekler: kubbe0,349'da kapalı/0,350'de açık; ilk mermi yok, ikinci isabet mümkün; çanta ölüm callback'inden önce kurtarır/fazda1; 1.000 zırh denemesinde424 blok, aynı mermi/oda tekrar şans denemez; mermi tek karede kapsülü geçse sonik takla parçalar; drone6,499'da bekler/6,500'de en hasarlı uzak odayı onarır; kubbe içindeki mermi .1sn'de .045sn ilerler/dışarıdaki .1sn; bot gerçek fizik inişinde yalnız odayı temizler ve çarpışma geri gelir; vinç 1kit/2oda, donmuş mermi vuramaz/yaşlanamaz ve tam1sn sonunda devam eder. İlk testte kayan nokta artığı nedeniyle donma bir tik fazla sürüyordu; sayaçlar mikro-saniye eşiğinde sıfırlanarak düzeltildi.
- 300 kampanya seçim örneği ve Step48'in150 seçim örneği A/B/B, farklılık ve tekrar etmeme kurallarını geçer. Step5 yeni heal/repair modül sinyallerini mevcut miks/havuz içinde ayrıca doğrular.
- **Native 4.7.2 / Compatibility / 1920×1080: Step8 103/103.** Üç kart grubu (dokuz kart), tüm aktif savunmalar, karakter/dron yakın planı, iki uzak odaya onarım ışını ve yeni deprem halka boşlukları için **7 PNG** `%TEMP%/siege-step8-native/` altında kaydedilip açılarak incelendi. Bütün metinlerde gerçek satır/alan boyu sığar. Native fare ve klavye1, gerçek E girdisiyle çift onarım,1280×720 ölçekli fare seçimi geçer. Bunlar sentetik girdidir; insan oynanışı iddiası değildir.
- Step7 dört gerçek50sn savaş sürücüsü: fırtına428atış/tepe47 (Adım7 ile aynı), deprem376/40 (önce416/40), sel218/20 ve final479/37 (aynı). Her atış tam uyarılı; 128 havuz taşmadı. Tam kampanya sürücüsü Step2Soak:1.466atış/tepe47, dört faz zafer, en fazla3 onarım uyarısı. Oyuncu canı yalnız bu entegrasyon testinde yükseltilir, toplama/onarım programlıdır; insan denge ölçümü değildir.
- Kanıt logları: `%TEMP%/siege-step8-checks/`, `%TEMP%/siege-step8-checks43/`, `%TEMP%/siege-step8-native.log`. Görev başındaki yerel dosyaların ek güvenlik kopyası `%TEMP%/siege-step8-baseline.zip` içinde; Git geçmişi ve ekip çalışması korunmuştur. Test/görüntü/motor dosyaları repoya eklenmedi.
- **Denenmeyenler:** insan klavye/fare oynanışında eğlence-zorluk dengesi, insan kulakla dinleme, ikinci bilgisayar, yeni export ve teslim paketi. Standart F5 giriş sahnesi kullanılabilir. **Bu görevde commit/push yapılmadı.**


## Güncel — Adım 7 (17 Ekim 2026, Claude)

Kullanıcının “okunabilir, hızlanan bullet-hell” isteği uygulandı. Adım 6'nın 60 FPS önbellekleri, −5 dB WAV BGM, dört faz (FIRTINA → DEPREM → SEL → DEPREM • SEL • FIRTINA), BossCinematic ve alt boss barı korunur. Aşağıdaki Adım 6 ve öncesi kayıtlarındaki 60/7 sn ve 0,55–0,75 sn ifadeleri tarihçedir.

| İş | Uygulama |
| --- | --- |
| Süre | Faz 50 sn (`siege_duration`), kart sonrası inşaat 5 sn (`build_duration`), ilk hazırlık 8 sn. Giriş 2,5/2,8 sn ve çıkış 1 sn savaş saatini tüketmez. |
| Tempo rampası | `DisasterWaveManager.tempo_at`: 0–15 sn 0,90×, 15–35 sn 1,00→1,25× doğrusal, 35–50 sn 1,45×; iki geçiş 1 sn yumuşatılır (kare başı en çok ~0,005 artış). Fırtına/deprem/sel saati ×tempo; final ×(1+(t−1)·0,5), çünkü son 15 sn'de Nova da hızlandırıyor. Mermi hızı `bullet_tempo` = max(1, 1+(t−1)·0,5): dorukta 1,225×, ısınmada yazılan hız; `scale_travel_speed` yolun uç noktasını korur. Dorukta BGM aynı WAV ile 1,05× oynar (0,12/sn yumuşak geçiş; hız ve perde birlikte değişir). |
| Fırtına | Beş koreografi sırayla: **A İkiz Girdap Çarkı** (merkezden saat yönünde 4 kol, 9 adım × 0,1 sn, 11°), **B Güvenli Kat Ruleti** (3 kat koridor, oyuncuya komşu güvenli kat, 0,65 sn; ilk süpürme geçince ona komşu ikinci güvenli kat), **C Sinüs Rüzgâr Tüneli** (iki paralel 9'lu akım, 78 px tünel), **D Çapraz Rüzgâr Makası** (sol üst/sol alt köşeden odaya üçer bıçak, 0,45 sn sonra yarı açılı ikinci X), **E Siklon Halkası & İtme** (%70 itme + alçak / kafa hizası / 4 boşluklu üç halka, oyuncudan iki sütun öte). Her desenden önce 0,3 sn dalış; C/E'de tek kat boyunda kompakt hortum çekirdeği, diğerlerinde tam boy. |
| Deprem | Dört koreografi sırayla: **Dama Tahtası Sütun Çökmesi** (A+C oda sütunları `ROCKFALL`, 0,5 sn sonra B+D), **Yürüyen Sismik Fay Dalgası** (her katta sırayla sağdan sola diken dalgası), **Sismik Merkez Halkaları** (3 × 12 hizalı kaya, aynı koridorlar), **Kat Ezici Balyoz** (oyuncu + komşu kat; alçak 24 px zıpla, yüksek 98 px altında kal; ikinci çift yer değiştirir). Golem odalardan eşya fırlatmaz; wind-up'ta sabitlenmemiş mobilya yalnız görsel titrer. |
| Sel/final | Desenler ve sayısal dengeleri aynı; yeni uyarı/mermi görünümü ve tempo rampası uygulanır. Final ayarı (`CataclysmPatterns.tune`) tam bir kez uygulanmaya devam eder. |
| Görünürlük | Mermi: `#05070a` 4 dünya birimi (~3 ekran px) kontur + boss neonu (fırtına `#00f0ff`, deprem `#ff9500`, sel `#2b7fff`) + beyaz çekirdek; küre/bıçak/kaya/diken siluetleri, 12 önceden pişmiş atlas dokusu (eski 21'in yerine; sol hücre kontur silueti yarıçap+4'e, sağ hücre gövde yarıçapa ölçeklenir, mermi tek doku/tek batch kalır). Uyarı: olağan her tehlike tam 0,55 sn; yol için tek ince lazer, alan/kat için dolgu; son 0,12 sn beyaz. Uzun sınıflar korunur (duvar/taşkın 1,0, mühür 0,8, rulet 0,65; final +0,20, radar +0,25). Rastgele oda eşyası saldırısı bosslardan kaldırıldı. Kuşatmada gevşek mobilya `set_combat_dim` ile koyu/mat tona geçer (kolon/pencere hariç, önbellek yeniden çizilmez). |
| Sıyrılma | Mermi kenarı oyuncu kapsülüne ≤22 px (istenen 18–26 bandı) yaklaşıp değmeden uzaklaşınca bir kez: +25 takla enerjisi (100 sınırı), turkuaz/sarı kıvılcım halkası, “SIYRILDI! +ENERJİ”, yeni `graze` sesi (−12 dB). Koşu/zıplama/taklada çalışır; isabet alan, isabetten hemen önce pencereye giren veya hasar korumasında geçen mermi, kat duvarları ve alanlar sayılmaz; iki ödül arası en az 0,12 sn. |

### Doğrulama

- **Godot 4.7.2.stable.official.ed1daf0bf ve 4.3.stable.official.77dcf97d8:** her motorda **16 paket / 1.247 kontrol geçti**, sıfır başarısız kontrol ve sıfır betik hatası. Paketler: Step1 129, Step2 53, Step25 145, Step3 43, Step27 61, Step3Loot 76, Campaign 69, Step45 103, Marathon 91, Step48 68, Step49 94, Step5 71, Step55 77, Step6 57, **Step7 99**, Step2Soak 11. Step3'teki bir eksilme, fırtına etiket döngüsünün altıdan beşe inmesidir; eski yardımcı paternlerin (girdap, çapraz yaylım, koridor, rüzgâr, eşya) doğrudan testleri korunmuştur. Son koşudan sonra kurulu 4.7.2 ile yeniden import hatasızdır.
- Gerçek 50 sn savaş ölçümleri (Step7, 60 sabit tik/sn): fırtına 428 atış / tepe 47, deprem 416 / 40, sel 218 / 20, final 479 / 37; havuz 128'de büyümedi, reddedilen atış yok, bütün atışlar kendi kuralının tam süresiyle uyarıldı. Doruk/ısınma desen aralığı: fırtına 2,78→1,78 sn (1,56×), deprem 2,26→1,48 (1,53×), sel 2,00→1,24 (1,61×), final 2,87→1,22 (2,35×). Girdap çarkı mermisi 330→404 px/sn. Tam kampanya (Step2Soak): dört gerçek 50 sn savaş + üç 5 sn inşaat, 1.532 atış, tepe 47, bina %88,2, en fazla 3 onarım uyarısı, zafer.
- Step7 dokuz koreografide geometriyi ve gerçek kaçışı ayrıca sınar: rulette zamanında güvenli kata geçen oyuncu iki süpürmeden de hasarsız, kalan oyuncu vurulur; tünel tepesinin altında ayakta durmak güvenli, çukurda vurulur; dama tahtasında temizlenen sütuna geçmek güvenli, B sütununda kalmak ezilir; fay dalgası ve alçak balyoz ayakta vurur, 60 px zıplama aşar; yüksek balyoz ayaktakini ıskalar, zıplayanı vurur. Sıyrılma için 15 px geçiş ödüllü, 30 px ödülsüz, isabet/isabete dönüşen yaklaşma/hasar koruması ödülsüz, eşzamanlı iki geçiş tek ödül, takla ve havada çalışır, 100'de durur.
- **Native 1920×1080 (4.7.2, exclusive fullscreen): Step7 120/120**, 21 PNG `%TEMP%/siege-step7-native/` içinde ve tek tek incelendi: dört kollu çark lazerleri ve mermileri, rulet uyarısı/beyaz flash/süpürme/ikinci rulet ve “▲ GÜVENLİ KAT ▲” plakası, iki akımlı tünel ve kompakt hortum, makas X lazerleri, siklon halkaları, turuncu sütun uyarısı/kaya yağmuru, fay dalgası, 12'li halka koridorları, alçak/yüksek balyozlar, sel ve final neon mermileri, sıyrılma yazısı/halkası. Mobilya karartması aynı bölgenin hazırlık/kuşatma karelerinde ölçüldü: ilk ton (0,75 parlaklık) lamba konilerinin additive ışığı yüzünden ekranda yalnız ~%20 koyulaştırıyordu; ton 0,69'a çekildi ve yatak bölgesi ekranda **%24,5** koyulaştı (oda kırpımının tamamında %8, çünkü duvar/zemin/ışık değişmez).
- Bilinen yan etki: odalardan eşya fırlatma kalktığı için L-Demir Eşya Sabitleme kartının ve barikat kitinin “eşya hasarı/eşya saldırısı” kısmı normal kampanyada artık etkisizdir (panjur ve oda hasarı etkileri sürer). Kart metinleri değiştirilmedi; ayrı bir denge kararı gerekir.
- Yorum: “ŞİMDİ KAÇ!” uyarının son 0,12 sn'deki beyaz parlaması olarak uygulandı; ekrana ayrıca yazı basılmadı (0,12 sn okunamayacak kadar kısa ve dünya içi metin kuralını kalabalıklaştırırdı).
- **Performans (PerformanceBench, aynı makine, 4.7.2, native 1920×1080, VSync kapalı, eşzamanlı başka iş yok):** Adım 6 (HEAD `355d890`, `git archive` ile geçici klasöre çıkarıldı) ve Adım 7 sırayla ikişer kez ölçüldü. İlk Adım 7 sürümünde her mermiye canlı çizilen kontur poligonu yalnız-mermi sahnesini 7,8→9,7 ms yapıyordu (+64 draw call, +4.096 primitif); kontur aynı dokunun ikinci hücresine taşındı. Son sonuçlar:

  | Sahne | Adım 6 (HEAD) ort. ms / FPS | Adım 7 ort. ms / FPS | Draw call (6 → 7) |
  | --- | --- | --- | --- |
  | Hazırlık | 4,67–4,91 / 204–214 | 4,68–4,75 / 210–214 | 471 → 471 |
  | Final + 64 mermi + 24 uyarı | 16,12–16,89 / 59–62 | 13,99–15,28 / 66–72 | 1.373 → 1.205 |
  | Final + 64 mermi, uyarısız | 15,25–16,03 / 62–66 | 14,20–14,65 / 68–70 | 1.157 → 1.157 |
  | 64 mermi, bosssuz | 8,04–8,46 / 118–124 | 8,42–8,92 / 112–119 | 662 → 662 |

  Uyarılar artık daha ucuz (tek lazer polyline); mermi başına iki doku dikdörtgeni yalnız-mermi sahnesinde ~0,4 ms ekler. Bu dizüstü GPU'da en ağır yük Adım 6'dan beri final Titan çizimidir (boss gizlenince ~6 ms düşer). Bütün bilgisayarlarda kilitli 60 FPS iddiası yoktur; p95 değerleri 16,7 ms'yi aşabilir.
- Denenmeyenler: insanın gerçek klavyeyle oynayıp zorluğu/okunabilirliği değerlendirmesi, doruk hızlanmasının ve yeni `graze` sesinin kulakla dinlenmesi, canlı 50 sn fırtına/deprem savaşının FPS örneği (stres sahnesi finaldir), ikinci bilgisayar ve export. Commit/push yapılmadı.

## Güncel — Adım 6 (17 Ekim 2026, Codex)

Kullanıcının performans/BGM/final zorluğu isteği uygulandı. 16 oda kimliği, gece/pixel görünümü, karakter/2x W fizik yayı, mevcut loot/onarım/19 kart/SFX/dört faz ve kontroller korunur. Adım 5.5 ve Claude kayıtları aşağıda tarihçedir.

**Git kayıt paketi (17 Ekim 2026):** Kullanıcının commit/push isteğiyle Claude'un Adım 4.9/5 devri ve Codex'in Adım 5.5/6 çalışmaları birlikte kayda hazırlanmıştır. Gönderim hedefi `origin/feat/disaster-siege-step1`; sürüm kimliği için `git log -1 --oneline`, uzak dal eşitliği için `git fetch origin` ardından `git rev-list --left-right --count HEAD...origin/feat/disaster-siege-step1` kullanılır. Test/görüntü kayıtları ve motor önbellekleri Git dışındadır. Yarışma için export/yayın ayrı ve henüz tamamlanmamıştır.

| Değişiklik | Uygulama |
| --- | --- |
| Statik önbellek | `StaticCanvasCache`: oda duvarı/hasar kademesi, AO, mobilya, cephe, arka plan ve çelik kiriş/kepenk/sabitleme kurulumları ayrı dokularda. Durum/onarım/kurulum/sprite değişimi yalnız ilgili dokuyu kirletir. `UPDATE_ONCE` sunucuda tüketilir; Node özelliğinin ONCE olarak okunması sürekli render anlamına gelmez. ALWAYS/WHEN_VISIBLE cache yok. Lambalar/ışıklar/toz/uyarı etiketleri ayrı; mobilya yalnız sallanırken process açar. |
| Hava/mermi | 260 yağmur +70 kül yerine 40+10, sabit yağmur segment dizisi/tek toplu çizim. İz en fazla dört nokta ve tek halo. 128 havuz girdisi değişmez; pasif girdiler hidden/process off. 21 ortak mermi gövdesi MainGame hazır olurken önceden pişirilir, savaşta yeni cache/mermi düğümü oluşturulmaz. Uyarı yolu bir kez örneklenip kesikli çizgiler toplu çizilir. |
| Boss çizimi | Final girdap 10→6, basınç küresi 5→3, köpük tepesi 14→8; dalga/cephe mikro detayları ve parçacık sıklığı azaltıldı. Kesintisiz kol silueti ve bağımsız baş/çene/kol/dalga animasyonları kalır. Final rig aynı karede yeniden hesaplanmaz. CelArt elipsi 24→14 köşe; piksel ölçeğinde gereksiz kenar yumuşatma maliyeti kaldırıldı. Compatibility ve ana pixel_scale=2 korunur. |
| BGM | `MusicScore` artık saf yardımcı; başlangıçta bir kez 22.050 Hz 16-bit mono WAV besteler. D minör bas (0,32), kick/snare/hat (0,25), üst melodi (0,22), loş akor. `SoundManager.bgm_player`: Master/−5 dB/ALWAYS; LOOP_FORWARD, begin=0, end=352.800 **örnek**, veri=705.600 byte. Watchdog beklenmedik duruşu toparlar, M kasıtlı sessizi korur. Müzik pause/faz/R sırasında kesilmez; her kare sentez/tampon doldurma yok. |
| Süre/tempo tercihi | İstekteki 12,8 sn / 8 ölçü / 120 BPM birlikte mümkün değildi. 120 BPM ve sekiz 4/4 ölçü korundu: 16,0 sn kesintisiz döngü (12,8 sn için 150 BPM gerekirdi). |
| Yalnız final | Skill arası ×1,3; salvo adedi round(base×0,7); hız ×0,8; oyuncu/bina/alan/slam/Nova oda hasarı ×0,7; her uyarı +0,20 sn. Radar +0,25 ayrıca toplanır; eski clamp bonusu yutmaz. Dalga 1–3 sayısal dengesi değişmedi. Hız değişimi uç noktayı koruyacak biçimde yolun bütün zaman parametrelerini ölçekler. Tune donmuş kopyalarda ikinci kez uygulanmaz. |

### Ölçülen performans

Aynı makine / NVIDIA GeForce RTX 4070 Laptop GPU / Compatibility / Godot 4.7.2 / 1920×1080 native, pixel_scale=2, VSync kapalı, editör dışında. `PerformanceBench.gd`: her sahnede 1 sn ısınma + yaklaşık 4 sn örnek. Önce/sonra aynı sabit 64 mermi +24 uyarı yükü; sonuçlar anlık FPS yerine gerçek kare sürelerinden hesaplandı. FPS koşusu sırasında başka test çalıştırılmadı.

| Sahne | Önce ortalama FPS / kare | Sonra ortalama FPS / kare | Sonra p95 |
| --- | --- | --- | --- |
| Hazırlık | 21,6 / 46,22 ms | 221,4 / 4,52 ms | 5,39 ms |
| Final +64 mermi +24 uyarı | 11,2 / 89,04 ms | 69,9 / 14,31 ms | 17,12 ms |
| Canlı final kısa örneği | Ölçülmedi | 69,5 / 14,40 ms | 24,75 ms |
| Canlı Nova kısa örneği | Ölçülmedi | 66,1 / 15,13 ms | 17,61 ms |

Hazırlık çizim çağrıları ~6.965→471, final stresinde ~9.241→1.374; final primitifleri ~340.866→22.953. Dokular dururken tekrar odaları çizmediği gerçek native karede ayrıca 470 çizim çağrısıyla kontrol edildi. Canlı kısa örneklerde oyuncu hasar testi için can yükseltildi; FPS karşılaştırmasının sabit yükünden ayrı raporlandı. Bunlar bütün bilgisayarlarda kilitli 60 FPS garantisi veya insan oynanış dengesi sonucu değildir; p95 bazı karelerin 16,67 ms'yi aşabildiğini gösterir.

### Doğrulama

- **Godot 4.7.2.stable.official.ed1daf0bf ve 4.3.stable.official.77dcf97d8:** her motorda **15 paket / 1.148 kontrol geçti**, sıfır başarısız kontrol ve sıfır çalışma zamanı hatası; tüm paketler çıkış kodu 0. Paketler: Step1 129, Step2 53, Step25 145, Step3 44, Step27 61, Step3Loot 76, Campaign 69, Step45 103, Marathon 91, Step48 68, Step49 94, Step5 70, Step55 77, Step6 57, Step2Soak 11. Son kayıtlar `%TEMP%/step6-verified-<472|43>-<paket>.log` içindedir.
- Native Step6: **4.7.2'de 62/62**, gerçek ses sürücüsünde iki WAV döngü sınırı, kasıtlı 300 ms ana iş parçacığı duruşunda kesintisiz çalma, watchdog/mute/pause ve cache yenileme. **4.3 native 59/59** (uzun ses döngüsü seçeneği olmadan); onun hasar/güçlendirme görüntüsü de incelendi. Master efekt noktasında RMS **0,1039 (−19,7 dBFS)**; bu nokta Master ses seviyesi öncesidir. Varsayılan %80 Master sonrası tahmini RMS ~0,083 (−21,6 dBFS). SFX tarifleri/miks havuzları korunur. Motor geçişleri sırayla yapıldı, sonunda kurulu 4.7.2 ile yeniden import hatasız tamamlandı.
- BGM ham PCM: tepe **0,5951**, RMS **0,1846**, DC yaklaşık 0, ardışık örnek farkı en çok 0,1738; ilk/son örnek farkı <0,003. Bir kez sentez ~465–470 ms; olağan karede ek sentez yok. Step55 native **94/94**, 17 yenilenmiş sinematik/HUD/pause PNG ve tam 16 sn WAV. Güçlendirilmiş/hasarlı oda, final girişi, 64 mermi/uyarı ve canlı Nova görüntüleri incelendi.
- Son gerçek 60 sn final: **489 atış / tepe45 / bina%85,4 / 6 ek ikmal / zafer** (önce 986 /74 /%74,7). Tam kampanya: **1.358 atış / tepe49 / bina%86,8**, dört gerçek 60 sn savaş ve üç 7 sn ara; max3 onarım uyarısı ve 128 havuz korunur. İnsan zorluğu tam %30 olarak ölçülmez; istenen ayrı katsayılar birlikte uygulanır, tam sayı adetleri yuvarlanır.
- Yerel kayıtlar Git dışındadır: `%TEMP%/step6-before-perf.log`, `step6-final-perf.log`, `step6-native.log`, `step6-native-cinematics.log`, `siege-step6-final-perf/`, `siege-step6-native/`, `siege-step6-cinematics/`, `siege-step6-bgm.wav`. Başlangıç kopyası `%TEMP%/siege-step6-baseline-20261017-095809/`.
- Kalan sınırlar: insanın hoparlör/kulaklıkla öznel dinlemesi, insanla zorluk dengesi, ikinci bilgisayar ve bağımsız export/HTTPS teslimi doğrulanmadı. Fiziksel klavye yerine Godot girdi olayları kullanıldı. Harici asset/müzik/bağımlılık eklenmedi; önceki ekip değişiklikleri korundu.

## Adım 5.5 (17 Ekim 2026, Codex)

Claude'un Adım 4.9/5 temelindeki bina, karakter, 19 kart, dört ekipman, onarım/loot, uyarı/havuz, duraklatma ve SFX korundu. Aşağıdaki eski sürüm kayıtlarının altı dalga/yangın/üst bar/müzik nabzı açıklamaları tarihçedir.

| İş | Sonuç |
| --- | --- |
| Dört faz | FIRTINA → DEPREM → SEL → DEPREM • SEL • FIRTINA. 60 sn savaş, üç kez 7 sn inşaat, 8 sn ilk hazırlık. Dördüncü çıkış zaferdir. Çifte faz, yangın bossu/sahne düğümü ve 5/6 kısayolları kaldırıldı; 1/2/3/4 güncellendi. |
| Ateşsiz birleşik final | Üç element kaynağı 0/1/2; su/kaya yağmuru, su-rüzgâr halkaları, sismik gelgit, 28'li mühür ve üç afetli Nova. Çatlayan kaya eli, basınç küreleri, köpük jetleri ve şimşek; alev/lav ve ateşli meteor yok. Eski yangın direnç/tehlike yardımcıları uyumluluk için saklıdır, normal kampanyada çağrılmaz. |
| Sinematik | Normal girişler 2,5 sn, final 2,8 sn. Letterbox, tek büyük kesin boss adı ve hafif kamera odağı. Fırtınada kararma/rüzgâr/şimşek; depremde zemin çatlakları/kayalar/iki yumruk; selde köpüklü dalgalar/ilk su baskını; finalde üç enerjinin birleşmesi. Girişte kontroller kilitli, saldırı ve hasar yok; savaşta kadraj/kontrol geri gelir. |
| Alt boss barı | Rect2(450,1016,1020,22), alt ortada kalın kontur; üstünde boss adı, sağında saniye ve yüzde. Sol alt ekipmanla çakışmaz, üst ortada şerit yok. Sinematikte HUD gizlenir. Yardım ve pause 1–4 der. |
| Gerçek BGM | Özgün 16 ölçü / 88 BPM Re minör bestesi; sıcak bas, stereo akor pedleri, yumuşak davul/hat, yankılı arpej. Açılışta AudioStreamGenerator'a doğrudan sentez; SFX pişirmesini beklemez. Hazırlık/kuşatma/ayrı final akorları 1,1 sn yumuşak geçer; transport resetlenmez, döngüde boşluk yok. BGM −11,5 dB, yağmur −31 dB. M/-/+ ve pause filtresi korunur. |
| Ses kapanışı | 4.3 hızlı headless kapanışında PCM verisi mixer stop komutundan önce bırakıldığında çökme görüldü. Önce sesler durdurulup bir audio block beklendikten sonra PCM bırakılıyor; testler deferred sahne yıkımı sonrasında da audio driver'ı boşaltıyor. Yeniden tam 4.3 kampanya normal çıkışla geçti. |

### Doğrulama

- Godot **4.3.stable.official.77dcf97d8** ve kurulu **4.7.2.stable.official.ed1daf0bf** ile import/parse hatasız; aşağıdaki **14 paketin her iki motorda da 1.089/1.089 kontrolü geçti**. Son 4.3 uzun kampanya ve 4.7.2 tam koşusu normal çıkış kodu 0 ile tamamlandı.

| Paket | Kontrol |
| --- | --- |
| Step1Smoke | 129 |
| Step2Smoke | 53 |
| Step25Smoke | 145 |
| Step3Smoke | 44 |
| Step27Smoke | 61 |
| Step3LootSmoke | 76 |
| CampaignSmoke | 69 |
| Step45Smoke | 103 |
| MarathonSmoke | 91 |
| Step48Smoke | 68 |
| Step49Smoke | 94 |
| Step5Smoke | 70 |
| Step55Smoke | 75 |
| Step2Soak | 11 |

- **Tam kampanya:** 16.999 fizik adımı; 14.400 savaş adımı = 4×60 sn; 1.260 inşaat = 3×7 sn; 618 giriş adımı (3×2,5 + 2,8 sn), 240 çıkış. **1.837 uyarılı mermi, 28 tür, 72/128 tepe, 0 taşma, max 3 onarım uyarısı.** 26 manuel onarım / 35 test toplaması; final bina **%81,4 / 0 yıkık oda**. Oyun içi sayaçlar atlanmadı. Test sürücüsü gerçek loot toplar/onarım için konum ayarlar ve canı yükseltir; insan zorluk değerlendirmesi değildir.
- **Gerçek 60 sn final:** 3.600 savaş adımı; bütün beş birleşik yetenek ve basınç etkileşimi; 986 uyarılı atış, 74/128 tepe, 0 taşma, 6 ek Nova loot'u; final bina %74,7 ve zafer. Yeni test bütün aktif paternleri ve Nova'yı source=3/alev/meteor yokluğu açısından ayrıca denetler.
- **BGM:** Üç düzenlemenin gerçek PCM'inde stereo fark, RMS/tepe/DC, ardışık örnek geçişi ve 16 ölçü döngü sınırı kontrol edildi. Bu makinede 3 sn ses ~0,66–0,77 sn'de sentezlendi; gerçek zamandan hızlıdır. SFX tariflerinin mevcut tepe/tık/DC/filtre, ses havuzu ve olay testleri korunur.
- **Native:** Gerçek sürücü/Compatibility renderer ile Step55 **93/93** geçti: 12 sinematik karesi + 4 savaş/HUD + pause = 17 PNG; üç düzenlemenin 9 sn WAV önizlemesi. Yerel kanıtlar: `C:/Users/halil/AppData/Local/Temp/siege-step55-captures/`, `C:/Users/halil/AppData/Local/Temp/siege-step55-music.wav`. Görsel incelemede sel duvarları zenginleştirildi ve letterbox altında yarım kalan HUD gizlendi; yenilenen sel/final sinematiği, final alt HUD'u ve pause kareleri de incelendi.
- **Sınırlar:** AI kulakla dinlemedi; uzun süreli müzik beğenisi/yorgunluğu, insanla final dengesi, ikinci bilgisayar ve bağımsız export/HTTPS teslimi doğrulanmadı. Fiziksel tuşlar yerine motor giriş olayları kullanıldı.
- Bu adımda yeni harici asset, ses dosyası, font, servis veya bağımlılık eklenmedi. Test çıktıları Git dışındadır. Kullanıcının/Claude'un önceki değişiklikleri korunur; çalışma ağacındaki mevcut yığının üzerine geliştirme yapıldı. Başlangıç yedeği `C:/Users/halil/AppData/Local/Temp/siege-step55-baseline-20261017-092144/`.


## Adım 5 — duraklatma paneli ve prosedürel ses/müzik motoru (17 Ekim 2026, Claude)

Bu bölüm Claude'un Adım 5 teslimindeki tarihsel kayıttır; o sırada Adım 4.9 (minimal HUD, 60 sn, 6 dalga) korunmuştu. O teslimde commit/push yapılmadı. Güncel uygulama ve doğrulama yukarıdaki Adım 5.5 bölümündedir.

| İş | Sonuç |
| --- | --- |
| Duraklatma | `ESC`/`P` → `get_tree().paused`; `PauseMenu` CanvasLayer (katman 40) `PROCESS_MODE_ALWAYS`. Yarı saydam `#0b0e14` karartma, kalın `#111518` konturlu panel, ikonlu 11 satırlık tuş rehberi (tuş kapakları + satır ikonları), alt sırada DEVAM ET / SES: AÇIK-KAPALI / - / 10 kademeli gösterge / + / YENİDEN BAŞLAT düğmeleri; fare, klavye ve odak (ok + Enter) ile çalışır. R panelde kampanyayı yeniden başlatır. Kart ekranının üstünde de duraklatılır, seçim bozulmaz. HUD sağ üstünde küçük `[H] YARDIM  [ESC] DURAKLAT  🔈 [M] SES` ipucu; sessizde çarpılı hoparlör ve `SES KAPALI`. Tab/H kartına ESC/P ve M/-/+ satırları eklendi. |
| Ses ayarı | `M` her yerde sessiz (Master mute). `-`/`+` yazılan karaktere (TR/US düzeni fark etmez) veya numpad'e göre 0–10 seviye; Master seviyesi `linear_to_db(seviye/10)`. Ayar oturum boyunca geçerli, diske yazılmaz. |
| Ses motoru | Ses/müzik dosyası yok. `SoundRecipes` 51 tarif (3 müzik döngüsü + 48 efekt/arayüz); `SoundSynth` ADSR, beyaz/pembe/kahverengi gürültü + durum-değişkenli filtre süpürmesi, ≤3,6 kHz harmonikli sıcak tonlar (Chebyshev yinelemesi), çıtırtı/kabarcık/enkaz katmanları; son aşamada alçak geçiren, DC temizleme, yumuşak doyum, tepe normalizasyonu ve tık önleyici giriş/çıkış. 22,05 kHz 16-bit mono `AudioStreamWAV`; açılışta arka plan thread'inde ~3,3 sn pişirme (oyun donmaz). |
| Müzik | Sürekli yağmur + karanlık bas drone döngüsü; hazırlıkta 40 BPM uzak kalp atışı; kuşatmada gerilim pedi ve endüstriyel nabız (kick + ara tık + 4'te bir yumuşak metal), 86 → 106 BPM dalga başına artar, Nova 116. Duraklatınca müzik 650 Hz alçak geçiren ile boğuklaşır, −5 dB kısılır, nabız durur. |
| Olay sesleri | Beş boss tipi için ayrı giriş/çıkış (çifte kuşatma fırtına+deprem, 3 dB kısık), final %55 birleşme patlaması; boss hazırlığında radar tınısı; element bazlı fırlatma (hava yarılması / balyoz / basınçlı su / ateş topu) + yumuşak savrulma; cam/ahşap/taş/metal/su/ateş çarpma; panjurlu oda ve türbin için metalik BLOKLANDI; zıplama, 2x W süpürmesi, S/sert iniş ayak sesi, takla, DODGE çınlaması, hasar + kalp atışı, loot düşme/toplama/çanta akoru/güvenlik tıslaması, E onarım dizisi, kart açılış/seçim, oda/bina çöküşü, zafer, yenilgi. Bağlantılar mevcut sinyallerle; yeni sinyaller: `Player.jumped/landed`, `LootSystem.landed`, `DisasterBoss.cued`, `SiegeMechanics.blocked`. |
| Miks | Her çalma 0,94–1,06 rastgele perde; anahtar başına kısıtlama (fırlatma 0,12 sn, çarpma türü 0,11 sn, boss sesleri 0,3 sn); mermi fırlatma/çarpma −17 dB = ana efektler (−9 dB) − 8 dB; Music/SFX/UI bus, Master'da sınırlayıcı (−1 dB tavan); 18 efekt + 4 nabız + 4 arayüz sesi sabit havuz. |

### Doğrulama

- **Godot 4.7.2.stable.official.ed1daf0bf (Windows 11):** 13 headless paket sıfır hata — Step1 129, Step2 53, Step25 145, Step3 44, Step27 61, Step3Loot 76, Campaign 71, Step45 135, Marathon 108, Step48 70, Step49 96, **Step5 72**, Step2Soak 11 = **1.071/1.071**.
- **Godot 4.3.stable.official.77dcf97d8 (Windows 11):** import/parse temiz; aynı 13 paket son kodla sıfır hata, aynı kontrol sayıları (**1.071/1.071**).
- **Step5 sentez ölçümleri:** 51 sesin hepsi 16-bit mono 22,05 kHz ve tarif uzunluğunda; tepe −10…−0,6 dBFS, DC ≈ 0; tek seferlik seslerde ilk 0,5 ms ve son 2 ms sessiz (tık yok); parlaklık oranı döngülerde < 0,3, efektlerde < 0,95; üç döngü kesintisiz. Olay testleri gerçek oyuncu zıplama/2x W/S/takla/hasar, loot, E onarımı, kart ekranı, oda/bina çöküşü, zafer ve boss geçişlerinden sesleri doğrular; 20 aynı karede fırlatma tek whoosh üretir; whoosh fire cast'ten tam 8 dB kısık; 60 çalmada ses düğümü sayısı sabit.
- **Native Step5 (4.7.2, gerçek ses sürücüsü, 1920×1080):** **75/75**, 3 PNG (HUD köşe ipuçları, duraklatma paneli, sessiz panel) incelendi; kopyaları yerel `captures/step5/` altında (Git dışında).
- `git diff --check` temiz. Yeni harici asset/ses dosyası/bağımlılık yok.

### Kalan sınırlar

- Sesler **kulakla dinlenmedi**: AI ses çıkışını duyamaz; kalite tepe/tık/DC/parlaklık/döngü ölçümleri ve miks kurallarıyla doğrulandı. Gerçek hoparlör/kulaklıkla dinleyip beğenilmeyen sesler tarif bazında (ör. `SoundRecipes.gd` içindeki tek bir giriş) ayarlanmalıdır.
- Fiziksel klavye/fareyle F5 penceresinde elle deneme yapılmadı; testler Godot giriş olaylarıyla doğrular.
- Ses ayarı kalıcı değildir; oyun kapanınca varsayılan %80 ve açık sese döner.

## Adım 4.9 — minimal HUD, 60 sn dalgalar ve Kataklizma Titanı (17 Ekim 2026, Claude)

Bu bölüm Claude'un Adım 4.9 teslimindeki tarihsel kayıttır; aşağıdaki Adım 4.8 / maraton kayıtları da kendi tarihlerindeki davranışı (5 dalga, 90 sn, F9'lu kısayollar, eski HUD) anlatır. O teslimde commit/push yapılmadı. Güncel uygulama yukarıdaki Adım 5.5 bölümündedir.

| İş | Sonuç |
| --- | --- |
| Minimal HUD | Sol üst başlık, sağ üst durum kutusu ve alt kontrol tablosu/mesaj satırı kaldırıldı. Sol üstte kutusuz, kalın INK konturlu üç bar: piksel kalp + kırmızı→yeşil can (`85/100`), şimşek + ince sarı (dolunca mavi) enerji, kalkan + turkuaz/kehribar bina (`%78`, yıkık odada 4 enkaz noktası). Üst ortada tek satır `DALGA 01 • YIKICI FIRTINA` + ince şerit + `60s` (hazırlıkta `HAZIRLIK • …` ve soluk `[F] HAZIRIM`, Nova'da `• NOVA`). Sol altta üç kare slot KOLON/SABİTLE/GÜVENLİK, `xN` ve tek kelime etiket; E'nin harcayacağı slot parlar. Tab/H basılıyken küçük kontrol kartı; sağ üstte soluk `[H] KONTROLLER`. E istemi oyuncunun üstünde kısa (`[E] ONAR`). Dalga girişi/çıkışı, final adı, Nova, zafer ve yenilgi kısa ortalanmış başlıklardır. |
| 60 sn | `siege_duration` 60; inşaat 7 sn, ilk hazırlık 8 sn değişmedi (istekte "hazırlık evresi yine 7 saniye kalsın" ifadesi dalga arası inşaat süresine uygulandı; ilk 8 sn'ye dokunulmadı). |
| 6. dalga | Yangından sonra kart + 7 sn inşaat ve **Kataklizma Titanı**; zafer altıncı çıkışta, kampanyada 5 kart seçimi. Yeni `Mode.CATACLYSM`, `Kind.CATACLYSM`, sahnede `CataclysmBoss` (BossGroundMask içinde). |
| Birleşme girişi | 2,0 sn: fırtına (sol üst gök), yangın (sağ üst gök), sel (soldan), deprem (sağdan) küreleri hızlanarak cepheye çekilir, gökten şimşek iner; %55'te çarpışma, beyaz patlama, dört renkli şok halkası, 22 güçte sarsıntı ve gök flaşı (`fusion_burst` bir kez); ardından enerji akıntıları gövdeyi besler, Titan belirir. Giriş savaş süresi harcamaz, saldırı yoktur. |
| Titan sanatı | Gövde binanın arkasında (z −1); çatı üstünde boynuzlu, V kaşlı, magma çatlaklı bazalt kafa, şimşek/lav gözler, kükreyen çene ve alev/şimşek tacı (z 7, mermilerin altında); sol omuz fırtına bulutlu, sağ omuz alevli zırh. Sol kol 10 halkalı hortum + şimşek bıçakları, sağ kol kor damarlı kalın bazalt kol + dört pençe + beş lav topu. Cephenin iki yanında rim ışıklı bazalt gövde kanatları; iki yanda kabarıp alçalan tsunami, köpük tepeleri, girdaplar, çatı arkası serpinti ve kaide köpüğü (binaya sabit). Wind-up çeneyi açar, vuruş iki elden şimşek/lav/kaya saçar; çıkışta Titan kendi dalgasına gömülüp solar (kafa da cephe arkasına iner). |
| Beş yetenek | (1) Kat 00/01 taşkını + çatıdan 4 gecikmeli meteor; canlı suya düşen meteor 0,55 sn uyarılı buhar sütunu + altı yöne 3 su/3 ateş küresi (döşemeye doğru asla), kuru zeminde normal dört kıvılcım. (2) Hortum koluna doğru uyarılı rüzgâr çekimi + iki ateş hortumu halkası (20 alev topu) + çapraz iki alev bıçağı. (3) Kaya yumruğu sarsıntısı, iki yandan zıplanabilir sismik dalga, iki kat üstte 1,0 sn tsunami duvarı, pencereden giren üç sekmeli/altıya bölünen basınç küreleri, tavan betonu/tuğlası. (4) Sol üst fırtına / sağ üst yangın / sol alt sel / sağ alt deprem küresi, tam **0,8 sn** halka, merkezde kesişen 28 mermilik ağ. (5) Son 15 sn Nova: 1,15 sn tempo, Titan bina çevresinde 5 noktaya ışınlanır, dört elementli 2×16 halka, halka çıkışında odası çatlar; başta kolon kiti + afet çantası, sonra her 3,5 sn dönüşümlü ek loot (max 3 korunur, en eski yer açar). Saldırılar element kaynağını taşır; panjur, kolon, sprinkler/drenaj ve yapı kartları doğal olarak çalışır. |
| Kısayollar | Modal dışında `1`–`6` F9 olmadan doğrudan boss (taze dünya); kart modalında 1/2/3 yalnız kart seçer, 6 yutulur. `U` hâlâ F9 ister. Eski "1–5 yalnız F9" testleri yeni davranışa çevrildi; kapsam silinmedi. |
| Korunan sistemler | 4×4 karanlık apartman, karakter/2xW fizik yayı, dört ekipman, max3 hasarlı oda/10 sn koruma, 19 kart + 1 hazırlık/2 aksiyon, 128'lik sabit havuz, dondurulmuş uyarı yolu ve `is_armed` reddi. |

### Doğrulama

- **Godot 4.3.stable.official.77dcf97d8 (Windows 11, Compatibility):** import/parse temiz; 12 headless paketin tamamı sıfır hata — Step1 129, Step2 53, Step25 145, Step3 44, Step27 61, Step3Loot 76, Campaign 71, Step45 135, Marathon 108, Step48 70, **Step49 96**, Step2Soak 11 kontrol = **999/999**.
- **Godot 4.7.2.stable.official.ed1daf0bf (Windows 11, Compatibility):** aynı 12 paket sıfır hatayla geçti (tam koşuda Step49 94/94; geri çekilme düzeltmesinden sonra Step49 tek başına 96/96).
- **Native Step49 (4.7.2, exclusive fullscreen, sabit 1920×1080 viewport):** **116/116**, 20 adet 1920×1080 PNG: hazırlık HUD'u, fırtına kuşatma HUD'u, Tab/H yardımı, birleşmenin %20/45/57/80 kareleri, Titan bekleme, dört yeteneğin uyarı/aktif hâli, Nova uyarı/aktif, geri çekilme ve zafer. Kopyaları yerel `captures/step49/` altında (Git dışında). Kareler incelendi; incelemede bulunan iki sorun (Nova'da gövde kanadının düz blok gibi görünmesi/sağ kenarda dalga boşluğu, geri çekilmede kafanın odaların önünde kalması ve son saldırı etiketinin asılı kalması) düzeltilip testlere eklendi.
- **Gerçek 60 sn final** (Step49, 60 Hz, test oyuncusunun canı yükseltilmiş): 3.600 savaş adımı, 986 uyarılı atış, bütün yetenekler + buhar sütunu gerçek zamanlamada oluştu, uyarı ihlali 0, tepe **72/128**, taşma 0, 6 Nova loot'u, final bina %75,1 ve zafer.
- **Tam kampanya** (Step2Soak, 4.7.2): 25.021 adım; **21.600 savaş adımı = 6×60 sn**, **2.100 inşaat adımı = 5×7 sn**; 3.345 uyarılı mermi, **34/34 tür** (yeni `STEAM_COLUMN` dahil), tepe 71/128, 0 taşma, en fazla 3 onarım uyarısı, 39 onarım/44 toplama, final bina %80,9 ve 0 yıkık oda. Otomatik sürücü insan oynayışı değildir.
- `git diff --check` temiz. Yeni harici asset/ses/font/bağımlılık yok.

### Kalan sınırlar

- İnsan oynayışıyla final bossun zorluğu (özellikle 0,8 sn mühür ve Nova halkaları) ve 60 sn tempo dengesi ölçülmedi.
- Gerçek F5 penceresinde fiziksel klavyeyle 1–6 ve Tab/H elle denenmedi; testler Godot giriş olaylarıyla doğrular.
- Ses, bağımsız export ve Linux/farklı GPU doğrulaması bu adımda yapılmadı.

## Git teslimi ve Claude devri — 17 Ekim 2026

Kullanıcı bu sürüm için commit/push ve Claude'a devir istedi. Beş dalgalı maraton ve Adım4.8 aynı teslim commitinde `feat/disaster-siege-step1` dalında yer alır. Devir belgesi [CLAUDE_DEVIR.md](CLAUDE_DEVIR.md); güncel commit `git log -1 --oneline`, uzak eşitliği `git rev-parse HEAD` / `git rev-parse origin/feat/disaster-siege-step1` ile kontrol edilir. Eski `main` çalışma ağacı ve kullanıcı değişiklikleri korunur; main birleştirmesi yapılmaz. Görsel/test kanıtları Git dışında kalır, yeniden üretme komutları devir notundadır.

Bu devirde oyun kodu değişmedi; proje açıklamasındaki kart sayısı19 olarak düzeltildi. Geliştirmede alınan aşağıdaki test sonuçları korundu; devir için belge/bağlantı kontrolleri, `git diff --check` ve Godot4.3 import/parse hatasız geçti. 11 paketin tamamı bu belge görevinde yeniden çalıştırılmadı. Teslim commitinin arşivinden oluşturulan temiz klasörde, önceki `.godot` önbelleği olmadan import ve Step48Smoke **68/68** yeniden geçti. GitHub tarayıcı girişi kullanıcı tarafından tamamlandı; yazma yetkisi doğrulandı ve Git kimliği/credential helper yalnız bu repo için eşlendi.

## Adım 4.8 — karakter, dört boss ve farkındalık/aksiyon revizyonu (17 Ekim 2026)

Bu bölüm güncel uygulamadır; aşağıdaki maraton/4.5/önceki sürüm kayıtları kendi tarihlerindeki davranışı anlatır.

| İş | Sonuç |
| --- | --- |
| Kurtarma uzmanı | Üç tonlu lacivert mont, reflektör, gözlüklü baret/fener, ilk yardım işaretli çanta/matara, alet kemeri, eldiven/bot. Sönümlü çanta ve mont etekleri koşu/hava/taklaya bağlı; ayak pivotu ve temel hareket/hitbox korundu. |
| Dört boss | Bulut katmanı/elektrik gözü/çatallı damar/kiremit; bazaltın üç yüzeyi/fay dalları/rebar/çakıl/çene; lacivert hidra/turkuaz akıntı/beyaz köpük tacı/varil; kömür zırh/magma çekirdeği/alev örtüsü/boynuz/sarmal kor. Golem ara hazırlık dirseği ve sel görsel dayanağı ekran içine alındı; saldırı yolları değişmedi. |
| Dört ekipman | Kolon: E +45 ve STEEL/FRP, deprem/yapısal oda hasarı yarı. Birleşik sabitleme/barikat: ANCHOR+SHUTTER, fırtına/sel/yangın oyuncu/oda mermi hasarı yarı. Çanta: +25 can/tam enerji. Güvenlik: loot'un ilk odasında anlık, kalıcı yerel zemin alevi/su/ısı/utility koruması; komşuları etkilemez. |
| Kart dengesi | 19 kart: eski11 korunup drone yenilendi, 5 hazırlık +3 aksiyon eklendi. Solda kesin bir hazırlık, diğer iki yuvada farklı alınmamış aksiyonlar. Her kart etki + kısa kaynaklı not içerir. Normal kampanya4 seçim yapar; 5 hazırlık kartı tükenmez. |
| Gerçek etkiler | Çanta maxcan+30/tamcan/dalga+15; dört oda anchor/eşya−%40; maxodaHP+30/hasar+35/deprem-yapısal−%35; utility/zemin alevi−%45; su yavaşlatması0/panjur storm-flood50→70; drone7sn/erişim×2,5; bot koşu+%18/cooldown−%30/dash0,35; E85/kalkan2,5; radar uyarı+0,25/mermi saat×0,88/dalga+iki kit. Kaynak korumaları çarpılır, aynı kart tekrarlanmaz, R temizler. |
| Korunan akış | Beş dalga / 90 sn savaş / dört7sn inşaat /1,2sn giriş/1sn çıkış; ilk hazırlık8sn;16 oda/karanlık atmosfer/2xW fiziği/128 havuz/ortak3 oda hasar sınırı ve10sn onarım payı. Standart loot4sn (drone7; eski mıknatıs8, birlikte8); kuşatmada E hâlâ yalnız görünür hasar uyarısında. |
| HUD ve notlar | ONARIM/SABİTLEME KİTİ + kısa işlev, anlık çanta ve korunan oda sayısı. Uzun boss başlıkları kenarda tutulur; hızlı toplama/kurulum mesajları ekran metin sınırlarıyla ayrılır. AFAD/USGS ve meslek kuruluşu başvuruları SOURCES'ta; yapı güvenliği garantisi/yaşam üçgeni standardı öğretisi yok. |

### Doğrulama

- **Godot 4.3.stable.official.77dcf97d8 / Linux**, Compatibility/OpenGL, Mesa Intel UHD Graphics (CML GT2). Godot import/parse ve ana sahne çalışma kontrolü; yeni bağımlılık, bitmap, font veya ses eklenmedi.
- **11 headless paket: 884/884, sıfır hata.** Step1 129; Step2 53; Step25 145; Step3 44; Step27 61; Step3Loot76; Campaign70; Step45 119; Marathon108; Step48 68; Step2Soak11. Regresyon kapsamı silinmedi; değişen dört ekipman davranışına uyarlandı.
- **Native Step48: 101/101, sıfır hata.** 200 seçim/50 koşuda1+2 kuralı; gerçek hasar yüzdeleri, iframe/onarım/ödül,4/7sn sınırı, mevcut8sn mıknatıs uyumu, tek odalık alan kesimi/derin kopya, bütün modifier reseti ve sürekli hazırlık pozunda boss çerçevesi. 19 kartın bütün metinleri yedi ekran düzeninde sığıyor; hızlı kurulum mesajları çakışmıyor. Klavye ve gerçek pencere ölçek dönüşümünden geçen sentetik mouse hit-testing geçti.
- **22 PNG'nin tamamı 1920×1080:** dört boss×bekleme/hazırlık=8, dört karakter pozu=4, loot/HUD=2, yedi kart grubu=7, ölçekli pencere düzeni=1. Native render viewport'u1920×1080 sabittir; pencere yöneticisinin950×1033 yaptığı küçük pencerede de mouse dönüşümü doğrulandı (tasarım görüntüsü1920×1080). Karakter yakın planlarında yalnız test kamerası büyütülür. Kareler görsel olarak incelendi.
- Tam kampanya **29.821 adım**: **27.000 savaş adımı=450sn**, dört inşaat toplam**1.680 adım=28sn**. **3.552 uyarılı mermi,33/33 tür,tepe71/128,0 taşma**. Kazanılan loot ile50 onarım/55 toplama; en fazla3 onarım uyarısı; final bina**%75,8,0 yıkık oda**. Test karakterinin canı yükseltilmiştir; insan başarı oranı değildir.
- Kanıtlar: [captures/step48](captures/step48/README.md) (Git dışında), test logları aynı dizinin `logs/` altı ve `/tmp/siege48-final-*.log`; özgün görüntüler `/tmp/siege48-captures/`, native log `/tmp/siege48-native.log`. `git diff --check` ve değişen belgelerin yerel bağlantı kontrolleri geçti.
- Çalışma yolu `/home/asd/Desktop/helloworld/helloworld-jam-godot`, dal `feat/disaster-siege-step1`. Önceki yerel maraton değişiklikleri korundu; asıl `helloworld-jam/main` çalışma ağacına dokunulmadı. Geliştirme sırasında commit/push yapılmamıştı; sonraki kullanıcı isteğiyle Git teslimi ve Claude devri yukarıda kaydedildi.

### Kalan sınırlar

- İnsanla oynayarak zorluk/eğlence ve kart/loot dengesi ölçülmedi. Otomatik sürücü envanter toplar/onarır; insan refleksini temsil etmez.
- Yeni ses, bağımsız export/dağıtım ve farklı donanım/4.7.2 doğrulaması bu adımda yapılmadı. Tam belge erişimi kısıtlı kaynakların kontrol kapsamı SOURCES'ta açıklandı.


17 Ekim 2026 · Beş dalgalı boss maratonu / 90–7 sn · Godot / GDScript

Aktif oyun Godot AFET KUŞATMASI'dır. İş dalı `feat/disaster-siege-step1`; temel sürüm `3c6ae04`. Bu paragraf maraton geliştirmesinin commit öncesi kaydıdır; güncel Git teslimi ve Adım4.8 kaydı yukarıdadır. Eski web sürümünün `main` çalışma ağacı ve yerel değişiklikleri korundu.

## Güncel sürüm — Beş dalgalı boss maratonu / 17 Ekim 2026

| İş | Durum / sonuç |
| --- | --- |
| Kampanya | Tamamlandı. Fırtına → Deprem → Çifte Felaket → Abisal Taşkın Hidrası → Piroklastik Kor Titanı. Her savaş 90 sn; 1,2 sn giriş / 1,0 sn çıkış savaş süresinden ayrıdır. İlk dört dalgadan sonra kart ve tam 7 sn hazırlık; F erken bitirir. Beşinci dalga sonunda yeni zafer ekranı, altıncı dalga yok. |
| Boss hareketi / sunumu | Tamamlandı. Eski çok parçalı rigler korunarak kat hedefi, hamle ve geri çekilme eklendi. Hidra iki cephede kabarır; titan iki cephe ve çatı arkasında yer değiştirir. Çatı pozunda tam boy modelin alt kısmını bina örter. Su/köpük, toz, kor, alev sütunu ve parçalanan çıkışlar prosedüreldir. |
| Sel | Tamamlandı. Beş saldırı döngüsü: 3,5 sn taşkın, çift cephe gelgit/bıçak, üç sınır sekmesi + altı ayrı uyarılı parça, gerçek yatay çekim + zıpkın, sinüs yolunda varil/kütük/kablo. Aralık 1,8 sn; oyun içi zemin yavaşlatması %35. |
| Yangın | Tamamlandı. Altı saldırı: katları kesen çatı/çapraz meteor ve kıvılcım, 3 sn kalıcı napalm, çift sarmal, beş adet 8 yönlü kor çekirdeği (tam 1 sn halka), çekimden sonra kat alev duvarı + alçak dalgalar, çift cephe ateş hücumu. Oda ısısı/HP hasarı gerçek modele bağlı. Aralık 1,6 sn; son 10 sn %25 hız artışı (1,28 sn), kızıl duman ve beyaz/kırmızı kor. |
| Kartlar / girişler | Tamamlandı. Dokuz aktif kart korunup sprinkler ve drenaj eklendi (11 kart). Hasarı %40 azaltırlar; sprinkler alev süresini 3 → 1,8 sn, drenaj yavaşlatmayı %35 → %21 yapar. F9 açıkken 1–5 boss; U kart, F başlat, R temiz sıfırlama. Modalda 1/2/3 yalnız kart seçer. |
| Korunan kurallar | 16 odalı gece/pixel-art, 2x W fizik yayı, 4 sn standart loot, yalnız ONAR uyarılı odada E, ortak üç hasarlı oda sınırı ve 10 sn onarım payı korundu. Yeni alanlar/ikincil saldırılar uyarıdan geçer; 128 mermilik havuz büyümez. |
| Belgeler | README, AGENTS ve BEYAN güncellendi. Yeni görsel/ses/font/eklenti/oyun motoru bağımlılığı yok; yeni ses eklenmedi. |

### Bu oturumun doğrulaması

- Motor **Godot 4.3.stable.official.77dcf97d8 / Linux**, Compatibility/OpenGL, **Mesa Intel UHD Graphics (CML GT2)**. Resmî motor test için `/tmp/siege-tools/` içine indirildi. Bu bilgisayarda 4.7.2 doğrulaması yapılmadı; aşağıdaki tarihli eski 4.7.2 kayıtları önceki bilgisayarın sonuçlarıdır.
- Headless paketler: Step1 **129**, Step2 **53**, Step25 **145**, Step3 **44**, Step27 **61**, Step3Loot **75**, Campaign **64**, Step45 **119**, Marathon **108**. Step2Soak **11**. Toplam **809/809 kontrol, sıfır hata**; on paketin tamamı geçti.
- Native `MarathonSmoke`: **149/149 kontrol, sıfır hata**. 38 adet **1920×1080** ve bir ölçeklenmiş pencere karesi kaydedilip incelendi; kartların klavye/fare seçimi, metin yerleşimi, tüm boss giriş/çıkışları, yeni paternlerin uyarı/aktif halleri, cinnet ve zafer.
- Tam kampanya: **29.821 fizik adımı**, **27.000 savaş adımı = 450 sn**, **1.680 inşaat adımı = 28 sn**, 360 giriş / 300 çıkış adımı. **3.565 uyarılı mermi, 33/33 tür, tepe 71/128 aktif, 0 taşma**; en fazla 3 onarım uyarısı. Sadece gerçek düşen malzemelerle 44 manuel onarım / 52 toplama; final bina **%73,7**, **0 yıkık oda**. Kartlar ve hasar dalgalar arasında sıfırlanmadı. Test oyuncusunun canı yükseltilmiştir.
- Son Godot import/parse ve ana sahnenin otomatik hazırlık/giriş/ilk savaş başlangıcı (900 adım) hatasız; `git diff --check` ve değişen belgelerin yerel bağlantıları geçti.
- Yeni sınır testleri: derin kopyalanmış sekme köşeleri; üç sürekli yansıma / altı parça; 3,5 sn taşkın, zıplayarak zemin alanından kurtulma ve tekrar isabet bağışıklığı; girdap çekimi; napalm odasında gerçek ısı/hasar; iki kartın oyuncu/oda ve süre/yavaşlatma etkileri; beş kor çekirdeğinin 0,999/1,000 sn sınırı ve 40 gerçek mermi; 1,9 sn termal çekim/alev sırası; çatı meteorlarının dört katı kesmesi; dört bossun Y hareketi, iki cephe/çatı konumu; son 10 sn cinnet ve terminal zafer temizliği.
- Görseller `/tmp/siege-marathon-captures/`, test logları `/tmp/siege-final-*.log`, native log `/tmp/siege-native-marathon.log`. Bunlar yerel doğrulama kanıtı; repo asseti değildir. İlk pencere kaydı masaüstü döşeme yöneticisinin boyutlandırması nedeniyle hedef boyutta değildi; 1920×1080 kayıtlar exclusive fullscreen ile yeniden alındı. Ölçekli gerçek pencere bu masaüstünde **950×534** oldu ve fareyle kart seçimi çalıştı.
- Çalışma klasörü `/home/asd/Desktop/helloworld/helloworld-jam-godot`; `project.godot` buradan açılır. Asıl `/home/asd/Desktop/helloworld/helloworld-jam` klasöründe `main` ve kullanıcının görev dışı yerel değişiklikleri duruyor. Commit/push/main birleştirmesi yapılmadı.

### Kalan işler / sınırlar

- İnsanla oynanış, özellikle iki son bossun algılanan zorluğu ve 4 sn loot rotası için playtest gerekli. Otomasyonun yüksek canlı karakteri malzeme toplar/onarım yapar; insan kazanma oranı veya adillik kanıtı değildir.
- Ses, bağımsız export/teslim paketi ve farklı donanım performans ölçümü bu görevde eklenmedi/yapılmadı. Kaynak proje çalıştırması ve oyun testleri export doğrulaması değildir.

## Devralma notu (ikinci bilgisayar / ikinci Codex hesabı)

1. `git fetch origin` → `git switch feat/disaster-siege-step1` (ilk sefer: `git switch -c feat/disaster-siege-step1 --track origin/feat/disaster-siege-step1`).
2. Godot **4.3 veya üstü** (standart, .NET değil) ile `project.godot` dosyasını aç; ilk açılışta içe aktarma birkaç saniye sürer. `.godot/` önbelleği repoda yoktur, her bilgisayar kendi üretir.
3. Yeni işe başlamadan **AGENTS.md**, bu dosya ve README'yi okut; Codex'e "AGENTS.md kurallarına uy" de.
4. Değişiklikten sonra README'deki test komutlarını çalıştır (11 paket). Farklı Godot sürümüne geçildiyse önce `--headless --path . --editor --quit`.
5. Aynı anda iki bilgisayarda aynı dosyayı düzenlemeyin; bitince commit edip aynı dala pushlayın, diğer taraf `git pull` yapsın. `main`'e birleştirme ayrı ve bilinçli bir adımdır; force push kullanmayın.

## Önceki sürüm — Adım 4.5 / 17 Ekim 2026

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
- Güncel loot: standart4sn, max3, +45 kolon onarımı; tür ağırlıkları44/27/17/12. Değerler insanla oynanarak ayarlanmadı.
- Dünya 960×540 çizilip büyütülür. 1920×1080'de pikseller tam 2×2'dir; varsayılan 1280×720 pencerede oran 1,33 olduğundan pikseller eşit boyutta görünmez. Gerekirse `MainGame.pixel_scale = 1` ile tam çözünürlüğe dönülür.
- Harici görsel, müzik veya font dosyası kullanılmıyor; prosedürel çizim AI yardımıyla yazıldı.
- F5 çalıştırması bağımsız EXE/web export doğrulaması değildir.
