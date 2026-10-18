# 4 GÜN

*Dört gün, dört afet.* (Eski çalışma adı: AFET KUŞATMASI / Disaster Siege; 18 Ekim 2026'da ekip kararıyla **4 GÜN** oldu. Final bossun adı hâlâ **AFET**.)

Afete hazırlık ve farkındalık temalı Godot oyunu: **ne kadar hazırlanırsan o kadar hayatta kalırsın.** Fallout Shelter esinli 4 kat × 4 odalı apartman kesitinde her afetten önce kısa bir **Hazırlık** evresi vardır: dolapları duvara sabitle, gazı ve sigortaları kapat, kepenkleri indir, afet çantanı hazırla. Afet gelince doğru davranış kazandırır: depremde **Çök-Kapan-Tutun** (C), pencerelerden uzak dur, sarsıntıda merdivene koşma; selde yükseğe çık. Sıra **DEPREM → FIRTINA → SEL → AFET**; her afetten sonra kısa bir **karne** neyin işe yaradığını ve AFAD önerisine dayanan bir alışkanlığı gösterir. Hareket ve kaçış bullet-hell hızındadır (çift zıplama ile üst kat, S ile alt kat, sekiz yönlü takla).

**18 Ekim — teslim düzeltmeleri (Adım 14):** Başarıyla biten ilk üç fazın çıkışında, karne/kart ekranı açılırken oyuncunun canı ve enerjisi tamamen dolar; bir yeşil parıltı ve iyileşme sesi gelir. Oda hasarı, güçlendirmeler, kitler, kartlar ve hazırlık görevleri taşınır. Zafer ve bölümden tekrar deneme akışı korunur. Ölümcül su isabetinde havuz temizlense de isabet kaydı güvenle tamamlanır.

Görev bandında cümle büyütüldü, sayaç küçük ve görev renginde kaldı. Her fazda karakter yanındaki tek yön işareti görev/onarım/kolon kitine götürür; erişimde, sarsıntıda ve taklada çekilir. Hazırlıkta seçili hedef daha büyük ve halkalıdır; ilerleme yoksa en çok üç sessiz hatırlatma gelir. Onarım odalarının köşe braketleri, beyaz ünlem glifi ve mini harita nabzı mermilerden ayrılır. Savaşın kısa onarım satırı 4 sn sürer, en sık 15 sn'de bir açılır. Sinematik/kart/pause/sonuçta rehber gizlidir; dünya içine yeni yazı eklenmedi.

**18 Ekim — karne "neden önemli" ve fragman (Adım 15):** Karnede artık ✓ satırlar da nedenini söyler: "Gaz vanası kapalıydı — Gaz kaçağı ve yangın riski azalır.", "Çök-Kapan-Tutun 3/3 — Düşen eşyalardan başını korur.", "Eşyalar sabitti — Devrilme ve yaralanma riski azalır." gibi; ✗ satırlar eskisi gibi ne yapılması gerektiğini söyler. Her satır iki satırlıdır (olgu büyük, neden/öneri küçük) ve blok ortalanır; kart ekranında "Güçlendirme seç" ve kartlar karnenin altına kayar. Cümleler AFAD kaynaklıdır ve "risk azalır" dilindedir; gerçek güvenlik garantisi değildir ([SOURCES](SOURCES.md)). Jüri için 55,6 sn'lik tanıtım fragmanı tamamen oyun içi görüntüyle üretildi ([Fragman](#fragman-556-sn)).

**18 Ekim — bölüm seçimi ve tekrar deneme:** Ana menüde Başla/Ayarlar/Çıkış altında **Bölüm seç** bulunur: fare, oklar + Enter veya 1–4 ile **Deprem / Fırtına / Sel / Afet** başlatılır. Aynı sıra oyundaki kısayollarda da geçerlidir. Hazırlıkta alt ortada küçük bölüm satırı görünür; savaşta ve kart seçiminde gizlenir. Final bossunun adı **AFET**'tir; deprem, sel ve fırtınanın birleşik mekanikleri korunur.

Yenilgi ekranında **R — Bölümü tekrar dene**: savaşın başındaki oda durumları, seçilmiş kartlar, kitler ve tamamlanmış hazırlık görevleri geri gelir. Oyuncu tam canla aynı bölümün Hazırlık evresine döner (ilk bölüm 15 sn, diğerleri 10 sn); yeniden kart seçilmez. Karneye bakıp eksik hazırlıkları tamamla, F ile veya süre bitince aynı bossa gir. İlk bölüm öğreticisi A D/W'yi yeniden zorlamaz. Yenilgi dışındaki R, zaferdeki R ve pause menüsündeki **Yeniden başla** tam yeni oyundur. Kontrol noktası yalnız bu oyun oturumunda tutulur.

**18 Ekim — cila: akış, görev satırı ve onarım öğreticisi:**
- **Görev satırı:** Ekranın üstünde tek kısa satır ne yaptığını söyler. Hazırlıkta ilerleme ve elindeki görev ("Hazırlık 2/6 · Gardırobu sabitle: devrilmesin", bitince "Hazırsın"), öğreticide adım ("Koş: A D", "Zıpla: W", "Sarsıntı! C basılı tut: Çök-Kapan-Tutun", "Saldırıdan kaç: SHIFT ile takla").
- **Onarım görünür ve öğretilir:** Hasarlı odanın tamamı nabız atan bir çerçeve alır; büyük uyarı elması etrafında halka döner, oda yeni hasarlanınca genişleyen bir halka ve kısa uyarı sesi çıkar. Öğretici açıkken ilk onarıma kadar: "Oda hasarlı: kolon kiti topla" (yerdeki kitin üstünde ok), kit alınınca "Hasarlı odaya git: E ile onar" (W W / S / yön oku).
- **Daha hızlı akış:** Savaşlar 40 sn ve ilk saniyeden tam tempo (eski 0,90× ısınma yok); Hazırlık 15/10 sn, öğretici görev saati 25 sn; yapacak işi kalmayan ara Hazırlık 3 sn'ye iner; sarsıntılar daha kısa (1,0 sn uyarı + 1,4 sn) ve 8 sn arayla; öğretici depremde desenler yalnız %10 seyrek, ilk mermi 5. saniyede.
- **Malzeme:** Yerde **6 sn** kalır ve **%20 daha sık** düşer (4,6–5,4 sn arayla); oyuncu sürekli koşturur.

**18 Ekim — afete hazırlık güncellemesi (jüri ölçütlerine göre):**
- **Deprem ilk afet ve öğretici:** Türkiye'nin başlıca riski ve Çök-Kapan-Tutun ilk dakikada öğrenilir. Öğretici yazısızdır: oyuncunun üstünde tuş başlıkları (A D → W → W W / S → E), ilk sarsıntıda C, ilk saldırıda SHIFT. Öğretici depremde hasar %60, desenler %10 seyrek ve ilk sarsıntıdan önce mermi yok. Ayarlardan kapatılabilir (varsayılan açık).
- **Hazırlık evresi:** İlk hazırlık 15 sn (öğreticide oyuncu yürümeyi öğrenene kadar bekler, sonra 25 sn), sonrakiler 10 sn. Görev nesnelerinin üstünde yanıp sönen işaretler, yanında E tuşu çıkar; hepsi bitince afet hemen gelir, F her zaman erken başlatır.
- **Sarsıntı:** Depremde (ve finalde) bina aralıklarla sallanır; 1,0 sn önce turuncu çerçeve ve C tuşu uyarır. Sallantıda adımlar yavaş, kat değişimi kapalıdır. Sabitlenmemiş uzun eşya devrilir, yanında duranı çarpar; kepenksiz pencere yanında cam yağar; tavandan düşen sıvadan yalnız Çök-Kapan-Tutun korur; gaz açıksa mutfak/kazan/çamaşır/banyo hasar alır. Sarsıntı sürerken mermi desenleri bekler.
- **Karne:** Kart ekranının üstünde, yenilgi ve hayatta kalma ekranlarında en çok üç satır: ✓/✗, olgu ve kaçırılan alışkanlık için tek kısa öneri.
- Çök-Kapan-Tutun artık temel mekanik olduğu için aynı adlı kart **Sakin Kal** oldu. Zafer başlığı **Hayatta kaldın**.

**18 Ekim — minimal arayüz:** Oyun sırasında ekranda neredeyse hiç yazı yok. Sol üstte 10 dilimli can barı, altında ince takla enerjisi çizgisi ve binanın 4×4 oda haritası (yeşil sağlam, kehribar hasarlı, yanıp sönen kırmızı kritik, koyu yıkık; bulunduğun oda çerçeveli) durur. Sol altta üç ekipman ikonu ve yalnız sayı rozeti, alt ortada ince boss çizgisi ve üstünde küçük boss adı vardır. Saldırı adları, DODGE/SIYRILDI yazıları, yüzde/saniye sayaçları, köşe ipuçları ve loot mesajları kaldırıldı. Onarım gereken odada küçük bir uyarı elması, E bir işe yarayacaksa oyuncunun üstünde E tuşu, güvenli kat ruletinde yeşil çerçeve görünür. Bütün yazılar oyunun kendi 5×7 piksel yazı tipidir (`PixelFont`, Türkçe büyük harfler aksanlı). Menüler, ayarlar, duraklatma ve kartlar kısa, kutusuz yazılardır; kartta yalnız ikon, ad ve tek satırlık etki bulunur.

**18 Ekim — ana menü ve saha ikmali:** F5/normal açılışta canlı yağmurlu apartman üstünde **Başla / Ayarlar / Çıkış** menüsü gelir. Menüde savaş/oyuncu durur; hava, oda ışıkları ve müzik sürer. Hazırlık evreleri 15/10 sn'dir (aşağıya bakın); 2,5 sn boss girişleri (final 2,8) ayrıca korunur. Kartlar dokuz mevcut mekanik ve A/B/B seçimiyle sunulur. Ayarlarda ana ses, sessiz ve pencere/tam ekran; tuşlar, Enter/fare seçimi ve ESC geri dönüşü vardır. Ayarlar `user://siege-settings.cfg` içinde saklanır. Pause ekranındaki **Ana menü** mevcut koşuyu sıfırlayıp açılışa döner.

**Adım 2.7 — karanlık afet gecesi:** Oyun artık kasvetli bir pixel-art gecesinde geçer. Yağmur, kül ve soğuk şimşekler; elektrik kesintisinde karanlık odalar, titreyen amber/acil kırmızı lambalar, baret feneri, yazısız sade bina, çok parçalı canlı bosslar, neon parlayan mermiler ve daha hızlı, tok bir karakter hareketi.

**Karakter ve ekipman:** Reflektörlü kurtarma uzmanı, ağırlıklı çanta/ceket animasyonu ve dört boss için üç tonlu yüzeyler; dört anlaşılır ekipman. Adım 8 ile dokuz aktif kart ve her seçimde solda bir hazırlık + iki aksiyon kartı.

**Adım 5.5:** Dört faz, özgün ve kesintisiz Re minör oyun müziği, her bossa ayrı 2,5 sn sinematik giriş (final 2,8 sn), alt ortada geniş boss HP/süre barı. `ESC/P` duraklatır, `M` sesi kapatır, `-/+` seviyeyi ayarlar.

**Adım 6:** Statik oda/eşya/gölge/güçlendirme/arka plan önbellekleri, 50 hava parçacığı, dört noktalı mermi izleri ve ortak mermi dokuları. Her kare canlı müzik sentezinin yerini ayrı −5 dB WAV döngüsü aldı. Yalnız finalde saldırı arası ×1,3; mermi adedi yaklaşık ×0,7 (tam sayıya yuvarlanır), hız ×0,8, oyuncu/bina hasarı ×0,7, uyarı +0,20 sn. Bu katsayılar beraber uygulanır; toplam insan zorluğunun tek başına tam %30 değiştiği iddia edilmez.

**Adım 8:** Dokuz aktif mekanik ve ikon odaklı kısa kartlar; yalnız depremde bekleme/kaçış boşluğu +%10, hareketli mermi hızı −%10. [Yeni kart etkileri](#afet-hazırlık-bülteni-9-aktif-mekanik-adım-8) aşağıda.

**Adım 7 — okunabilir hızlanan bullet-hell:** Fazlar 40 sn, kart sonrası Hazırlık 10 sn (18 Ekim cilası). Her savaş 0–10 sn 1,00×, 10–28 sn 1,00×→1,25× doğrusal artış ve 28–40 sn 1,45× doruk temposuyla ilerler; dorukta müzik ~%5 hızlanır. Fırtınanın beş, depremin dört yeni geometrik koreografisi var; odalardan rastgele eşya fırlatılmaz. Mermiler siyah konturlu, boss neonlu ve beyaz çekirdekli; bütün olağan uyarılar tam 0,55 sn sürer ve son 0,12 sn beyaz parlar. Kuşatmada mobilyalar ~%25 kararır. Mermiye çok yakından değmeden geçmek (**sıyrılma**) +25 takla enerjisi verir.

**Güncel HUD:** Sol üstte can dilimleri, enerji çizgisi ve oda haritası; sol altta üç ekipman ikonu; boss adı ve 40 sn kuşatma çizgisi alt ortadadır. Girişte sinematik siyah şeritler ve tek büyük boss adı görünür. `1/2/3/4` doğrudan boss testi; `5/6` kaldırıldı.

Codex ile devam için önce [kısa devir notunu](CODEX_DEVIR.md), Claude için [Claude devir notunu](CLAUDE_DEVIR.md) oku.

## Teslim ZIP’lerini çalıştır

`exports/4GUN_Windows.zip` veya `exports/4GUN_Linux.zip` dosyasını tamamen bir klasöre çıkar. Windows'ta `4GUN.exe` dosyasına çift tıkla; kendi indirdiğin bu build için SmartScreen çıkarsa **Ek bilgi → Yine de çalıştır**. Linux'ta `chmod +x 4GUN.x86_64` ardından `./4GUN.x86_64` çalıştır. Godot editörü gerekmez. Açılış testi sonuçları ve boyutlar STATUS'tadır; ZIP içindeki `OYNA_BENI.txt` aynı kısa rehberi içerir.

Amaç: apartmanı afetlere hazırlayıp Deprem, Fırtına, Sel ve Afet kuşatmalarından sağ çıkmak. **A D** koş, **W** zıpla, **W W** üst kat, **S** alt kat, **SHIFT/Space** takla, **C** Çök-Kapan-Tutun, **E** kullan/onar, **F** başlat, **R** yeniden/bölümü tekrar dene, **1–4** bölüm seç, **ESC** duraklat, **M** ses. Windows build ayrıca ekip tarafından Windows'ta menü ve ilk savaşla sınanmalıdır.

**Ses dosyaları ve repo:** Ovani Sound efektleri (48 işlenmiş WAV) public repoda tutulmaz; yalnız build'in içine gömülüdür. Repodan açılan proje bu seslerin yerine kendi prosedürel seslerini çalar. Sesleri geri eklemek için [assets/audio/LICENSE.md](assets/audio/LICENSE.md) adımlarını izleyin (`tools/audio/build_sfx.py`). CC0 müzikler ve fragman müziği (CC BY 4.0) repodadır.

ZIP'leri yeniden üretmek için (kurulu export şablonlarıyla): `python tools/package/package.py --godot <Godot yolu>`; betik iki build'i export eder ve her ZIP'e `tools/package/OYNA_BENI.txt` ile motorun lisans metnini (`GODOT_LISANS.txt`) koyar.

Export ön ayarları `export_presets.cfg` içindedir: Windows Desktop ve Linux, x86_64, gömülü PCK. Testler, araçlar, captures, exports, Markdown, varsa fragman ve ham kaynak dizinleri build dışında kalır; oyun sesleri/müzikleri ve ses manifest'i dahildir. Build/ZIP/captures Git'e alınmaz.

## Fragman (55,6 sn)

`exports/trailer/4GUN_Fragman.mp4` (1920×1080, 60 fps, H.264 + AAC, −14 LUFS), yükleme sınırına karşı `4GUN_Fragman_kucuk.mp4` ve kendi müziğini eklemek isteyenler için yalnız oyun sesli `4GUN_Fragman_muziksiz.mp4`; hepsi Git dışıdır. Müzik: Gregor Quendel — *Cinematic Epic Trailer (With SFX)* ([CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), düzenlendi; `tools/trailer/music/KAYNAK.md`). Kurgu, parçanın ölçülen vuruşlarına göre yapılır: açılış montajı doruk bölümüyle, büyük patlama "1. GÜN"e, ikinci bölüm "4. GÜN"e, en güçlü vuruş "Ve hepsi birden"e, final vuruşu zafer karnesine denk gelir. Çekimlerde oyunun ortam döngüleri ve gürültü benzeri tek seferlik sesler (bossların giriş/çıkış süpürmeleri `*_in`/`*_out`, birleşme patlaması, boss hazırlık `cast_*`, `whoosh`, `siren`, takla) susturulur; hızlı kesmelerde "kanal değiştirme" gibi tıslıyorlardı. Kalan oyun olay sesleri 7 kHz üstü kesilerek müziğin ~5 dB altına konur. Akış "dört gün" yapısındadır: dört afetin en yoğun anlarından açılış montajı → "4 gün. 4 afet." → "Hazırlık hayat kurtarır." → **1. gün** hazırlığı (eşyaları sabitle, gazı kapat, afet çantası) → DEPREM girişi → sabitlenmeyen kitaplık devrilirken Çök-Kapan-Tutun → doruk tempoda kaya yağmuru ve halkalar (yakın plan ağır çekim takla) → kit ile onarım → **karne** (✗ 1 eşya devrildi, ✓ Çök-Kapan-Tutun, ✓ gaz; her birinin nedeni) ve kart → **2. gün** kepenk + fırtına (makas, siklon, güvenli kat) → **3. gün** sigorta + sel (gelgit, basınç küreleri) → **4. gün** AFET doğuşu ve Nova → tamamı ✓ zafer karnesi → "4 GÜN" başlığı. Kesmelerin anahtar noktaları fragman müziğinin vuruşlarına oturur; aksiyon planlarında bosslar doruk temposundadır ve pilot mermileri dondurulmuş yollarından okuyup son anda taklayla kaçan, sürekli hareket eden bir oyuncu gibi oynar.

Yeniden üretmek için (Godot'un Movie Maker'ı, ffmpeg ve numpy gerekir):

```bash
python tools/trailer/render.py --godot <Godot konsol/çalıştırılabilir yolu>          # ~6 dk, ~3 GB AVI: captures/trailer/raw
python tools/trailer/assemble.py --ffmpeg <ffmpeg yolu> --raw captures/trailer/raw   # exports/trailer/*.mp4 + qa/contact.png
```

Plan süreleri ve preroll'lar `tools/trailer/shots.json`'dadır; tek plan için sonuna kimliğini yaz (`... S06`), `--debug` köşeye plan/kare damgası basar. Çekim, `scenes/Trailer.tscn` içindeki `TrailerDirector`'ın gerçek `MainGame` içinde planı kurup `TrailerPilot` ile gerçek girdi eylemleri (koş, W W, S, SHIFT, C, E) vermesiyle olur; aksiyon planlarında pilot `auto` modundadır (canlı mermilerin `HazardAttack.point_at` yolunu ve bekleyen alan uyarılarını okur, temastan hemen önce en açık yöne takla atar, alçak mermiyi zıplar, işaretli oda/kattan çıkar, boşta koşar, zıplar ve kat değiştirir; takla enerjisi fragmanda dolu tutulur); kurulum yalnız kesilip atılan preroll'dadır. Altyazılar `TrailerCaptions` ile oyunun PixelFont'uyla çizilir. Tek oyun kodu eki `SiegePlayer.trailer_guard`'dır (varsayılan kapalı; yalnız yönetmen açar). A2 ve X3'teki kısa ağır çekimler ve takip kamerası kurgu efektidir. `render.py` çekim sırasında geçici `override.cfg` ile pencereyi 1920×1080 yapar ve sonra siler. Fragman dosyaları build'e girmez.

## Oyunu aç

1. Standart **Godot 4.3 veya üstünü** aç. .NET sürümü gerekmez.
2. Proje yöneticisinde **İçe Aktar** seçip bu klasördeki `project.godot` dosyasını seç.
3. **İçe Aktar ve Düzenle** ile aç; **F5** ile oyna. Ana sahne hazırdır; sprite atama veya sahne kurma gerekmez.

Windows'ta **`Oyunu-Ac.cmd` dosyasına çift tıklayarak** da çalıştırabilirsin. Başlatıcı önce `GODOT_BIN` ortam değişkenine, ardından masaüstü/Downloads içindeki standart Godot klasörlerine bakar. Bulamazsa Godot'tan `project.godot` dosyasını aç.

Linux terminalinde proje klasöründen `godot --path .` ile oynat, `godot --editor --path .` ile editörü aç (Godot komutu PATH içinde olmalı). Bu oturumda `/tmp/godot-current/Godot_v4.7.2-stable_linux.x86_64` ve `/tmp/godot43/godot` kullanıldı; geçici klasörler yeniden başlatmada silinebilir.

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
| C (basılı tut) | **Çök-Kapan-Tutun:** yerde çömel, kollar başın üstünde, kımıldama. Sarsıntıda tavandan düşen sıvaya karşı korur; devrilen eşyaya ve cama karşı korumaz |
| T | Kamera sarsıntısını test et |
| F | Hazırlık süresini atlayıp sıradaki dalgayı başlat |
| 1 / 2 / 3 | Kart ekranında seçim (kart ekranı açıkken boss kısayolu çalışmaz) |
| 1 – 4 | Bölüm seçimi, taze dünya: `1` Deprem, `2` Fırtına, `3` Sel, `4` Afet. Menüde de çalışır. Kart ekranında 1/2/3 yalnız seçim yapar. |
| Tab veya H (basılı tut) | Sol altta kısa tuş listesi; bırakınca kaybolur |
| ESC veya P | Oyunu duraklat / devam et (duraklatma paneli ve tuş rehberi) |
| M | Sesi kapat / aç (oyunda ve duraklatma panelinde) |
| - / + | Ses seviyesi (10 kademe; klavye düzeninden bağımsız, sayısal tuş takımı da olur) |
| F9 | Test modunu aç/kapat (yalnız `U` kart denemesi için gerekir) |
| E | Hazırlıkta işaretli göreve yakınken işi yap (sabitle, kapat, indir, al); kuşatmada yalnız uyarı elması görünen odada (oyuncunun üstünde E tuşu çıkar) kolon kitiyle onarım veya sabitleme/barikat kurulumu; inşaat evresinde onarım veya bir güçlendirme kiti kurma |
| U (F9 açıkken) | Kart + inşaat denemesi; normal kampanyada etkisiz |
| R | Yenilgide **Bölümü tekrar dene**; diğer durumlarda (zafer dahil) tam yeni oyun |

**Adım 3'te Space yeniden takladır** (kullanıcı isteği); zıplama W/↑'dır. A/D ile yatay, W/S ile dikey takla yönünü seç; örneğin W+D+Shift sağ üst çapraza atılır. Yön basmazsan bakış yönüne atılırsın. Havada bir takla ve bir ikinci zıplama hakkı vardır; yere inince yenilenir. Her takla 32 enerji tüketir; enerji kısa gecikmeden sonra dolar.

**Minimal HUD (18 Ekim):** Sol üstte 10 dilimli can (az kalınca nabız atar), 227×4 px enerji çizgisi (doluyken açık mavi) ve 4×4 oda haritası. Alt ortada 700×6 px boss çizgisi; üstünde yalnız boss adı. Hazırlıkta çizgi gri, savaşta boss neonu, Nova'da nabızlı. Sol altta kolon / barikat / güvenlik ikonları; boşken kararır, yalnız sayı rozeti taşır, kit gelince kısa parlar. Sağ üstte yalnız sessizdeyken çarpı işaretli hoparlör. Tab/H tuş listesi açar. Sinematik girişte HUD gizlenir; başlık ve letterbox görünür. Ekranın üstünde yalnız tek görev satırı (Hazırlık ve öğretici). Yenilgi ve "Hayatta kaldın" ekranları başlık, en çok üç karne satırı ve tek ipucu taşır.

**Merdiven yoktur.** Kat geçişi her X konumunda çalışır. **Yukarı (2x W, Adım 3-B):** karakter güçlü bir dikey hızla fırlar; yükselirken yalnızca üst katın döşemesi onu yok sayar (duvarlar çarpışmaya devam eder). Döşeme hizasında yapışmaz: yaklaşık 32 px daha yükselip tepe noktasına çıkar, orada dikey hızı sıfırlanır, döşeme çarpışması geri açılır ve normal yerçekimiyle alçalarak yumuşak bir basılma (squash) ve tozla iner. Tepeye varış ~0,35 sn sürer. **Aşağı (S):** 0,11 sn'lik ease-out fazlama döşemeden süzülür. Geçişte rüzgâr izi, hayalet iz ve döşeme tozu çıkar; yükselirken takla başlatılamaz, tepe noktasından sonra hava taklası kullanılabilir. A/D ile yatay kontrol sürer. Tek zıplama yerçekimi, değişken yükseklik, 0,1 sn coyote time ve kısa giriş tamponu kullanır; yukarı takla da tavanın altında durur.

Karakter zıplarken dikey uzar, yere veya yeni kata inince basılır (squash & stretch), koşarken hareket yönüne eğilir; havada bacaklarını toplar, mont etekleri, detaylı afet çantası ve baret kayışı hıza göre gecikerek hareket eder. Bunlar yalnızca görseldir; çarpışma kutusu değişmez. Baretin feneri baktığın yöne sıcak bir ışık konisi uzatır ve karanlık odaları aydınlatır (koni bulunduğun odanın duvarlarında kesilir).

## Oyun hissi (Adım 11)

Hazırlık görevi tamamlanınca nesnede ışınlar ve tik, görev satırında kısa yeşil nabız görünür. Hasarlı oda toparlanınca çerçevesi yeşil yanar ve küçük artılar yükselir; kolon kiti, dron ve vinç aynı geri bildirimi kullanır. Sarsıntıda doğru Çök-Kapan-Tutun yeşil halka ve yumuşak iki notayla karşılık verir. Kit ikonları toplandıkları yerden ilgili ekipman slotuna, çanta can barına uçar; varışta kısa bir zıplama/parıltı olur.

İsabet ekran kenarını kızartır, can barını hafif sarsar ve kaybedilen canı kısa bir beyaz iz olarak gösterir; iyileşme yeşil parlar. Yalnız normal menülü girişte ölümcül olmayan isabete 0,06 saniyelik kısa vuruş donması eşlik eder; duraklatma, sıfırlama, faz sonu ve çıkış bunu temizler. Karne satırları sırayla kayarak, doğru/eksik işaretine uygun yumuşak sesle görünür. Dorukta, son 10 saniyede ve final Nova'da mevcut müziğe senkron ek katman açılır. Yeni oyun içi yazı veya yeni oynanış bonusu yoktur; süre/hasar/loot dengesi korunur.

## Ses / Müzik ve duraklatma — Adım 12–13

ESC/P oyunu durdurur; M ve -/+ bütün sesi Master üzerinden kontrol eder. Menü ayarları `user://siege-settings.cfg` içinde saklanır. Pause sırasında dünya efektleri durur, müzik ve ortam sürer; iki yatak alçak geçirenle yumuşar. Dönüşte filtre açılır.

**Gerçek kayıtlar + sentez yedeği:** Ovani Sound **Sound FX Starter Pack Vol. 1** kayıtlarından oyuna özel 48 türev kullanılır. SampleLibrary önce bu dosyalara bakar; eksik/yüklenemeyen anahtar için eski SoundRecipes/SoundSynth akışı çalar. Ham dosyalar dağıtılmaz, yalnız işlenmiş türevler yerel oyun içeriğine alınır. Türevler de [Ovani lisansına](https://ovanisound.com/policies/terms-of-service) tabidir; oyundan ayrı dağıtım veya yeniden lisanslama izni verilmez. Kırpma/mono/fade işlemi, public kaynak deposunda ayrı WAV dağıtma hakkını kendiliğinden sağlamaz. Public paylaşım öncesi sağlayıcının buna izin verdiği ayrıca doğrulanmalıdır. Kullanılan kaynak/işlem listesi [manifest](assets/audio/manifest.json), kapsam [SOURCES](SOURCES.md) ve [BEYAN](BEYAN.md) içindedir.

- **Ortam:** Menü yağmur −18/interior −26; Hazırlık −16/−24; Fırtına yağmur −12/rüzgâr −14, dorukta dolu −16; Deprem yağmur −16/sarsıntı −24; Sel yağmur/su −14; Final rüzgâr/su/sarsıntı −18; sonuçta hepsi −30 dB. Geçiş 1,5 sn. Sel yatağı 1,5 kHz filtrelidir. Şimşekten .2–1.2 sn sonra, en az4sn aralıkla ve flaş gücüne bağlı gök gürültüsü duyulur.
- **Uyarlanabilir beste:** MusicScore açılışta bir kez `pad_bass`, `drums`, `lead_arp`, `climax`, `tension` üretir. Her biri 120 BPM/8 ölçü/16 sn/22.050 Hz mono; tek AudioStreamSynchronized aynı örnek saati ve pitch'i paylaşır. Yeni kayıtlara ayrılan menü/final/zafer dışında, Hazırlıkta pad+tension; savaş0–10sn pad+drums,10sn'de arpej,28sn'de climax,son10sn tam climax. Depremde ritim, Fırtınada arpej, Selde pad öne çıkar. Değişimler iki saniyelik ölçü sınırında yumuşar; dorukta bütün stem'ler1,05 pitch'e çıkar. Yenilgi ölçüde söner ve mevcut yenilgi efekti gelir; karneye kısık pad döner. Yeni menü/final/zafer katmanı bu oynatıcıyı durdurmadan sessize alır; kayıt eksikse önceki kod müziği ve zafer efekti yedektir.
- **Büyük anlar:** İsabette Music/Ambience −6 dB (.05/.15/.4 sn), devrilme/boss vuruşu −4, çöküş −10. Sarsıntıda −8 dB ve Music600Hz; davul/arpej çekilir, tension ve sarsıntı yatağı yükselir. Bitişte filtre .6sn'de açılır; davul sonraki vuruşta tek slam ile döner. SFX/UI duck'tan etkilenmez. Son4sn geri sayım, fazda ilk <%30 cana düşüşte uyarı; düşük canda tension ve hafif LP vardır.
- **Miks:** Master limiter; Music/SFX/UI/Ambience bus'ları, SFX üzerinde room.3/wet.1 yankı. Dünya darbeleri/onarım ekran X'ine göre WorldLeft/Right üzerinden ±.5 pan alır; UI/müzik merkezde kalır. Cast −14 dB ve kısıtlamalı; sıradan mermi fırlatma/çarpma bunun8dB altında. Sabit18 SFX+4 eski ritim+4 UI havuzu ve history korunur; altı ortam, tek senkron kod müziği oynatıcısı ve beş kayıt için on sabit A/B oynatıcı açılışta oluşturulur.
- **Başarı sesi:** Sıyrılma, kit toplama, görev ve doğru örtünmeye önceden pişmiş Re minör pentatonik nota eklenir. İki saniye içindeki olaylar bir derece yükselir; sessizlikte başa döner. İlk altı hazırlık görevi sırayla yükselir. Kayıt efektlerindeki0,94–1,06 perde çeşidi korunur; müzikal notalar doğru perdede çalar.


**Kesintisiz kayıt katmanı:** `MusicDirector.gd`, mevcut AdaptiveMusic/SoundManager üzerine eklenir. Kod müziği yeniden yazılmaz, pentatonik geri bildirim ve ducking korunur. MusicDirector başındaki sabitler bütün yeni seviyeleri, perdeyi ve döngü noktalarını toplar.

| Durum | Sürekli müzik (Music bus içi dB) |
| --- | --- |
| Ana menü | Yalnız Blackout −10; ilk açılışta 0 sn'den. Zemin/kod stem'leri sessiz. |
| Başla / bölüm seçimi | Blackout 2,5 sn'de söner; aynı anda zemin −16 ve Sector −20 açılır. |
| Hazırlık / karne / kart | Dark Place zemini + Sector + mevcut hazırlık/karne kod müziği. |
| Boss girişi / normal savaş | Sector 1,5 sn'de −40'a; zemin + mevcut uyarlanabilir savaş stem'leri. |
| Final girişi son 1 sn / AFET | Urgent −11 başlar; bütün kod stem'leri ve Sector sessiz. Yalnız zemin + Urgent. |
| Nova (son 12 sn) | Urgent −8; zemin ve Urgent ortak 1,05 çarpanını alır. |
| Sarsıntı | Zemin +4 dB kabarır; mevcut Music −8 dB / 600 Hz ve Ambience duck sürer, bitince zemin .6 sn'de döner. |
| Yenilgi / bölümü tekrar dene | Zemin −30'a iner; tekrar denemede aynı konumdan −16'ya döner. Mevcut yenilgi efekti korunur. |
| Zafer | Diğer müzik 1 sn'de söner, CC0 Victory bir kez çalar; ardından Blackout 42 sn'den −16'ya 4 sn fade-in yapar. |
| Pause / ana menüye dönüş | Pause'ta müzik saati sürer, Music alçak geçirilir; menüye dönüş 2,5 sn ters geçiştir. |

Kaynak saniyeleriyle A/B döngüler: **Dark Place 14–54,5 / 3 sn**, **Blackout 42–170 / 4 sn**, **Sector 2–54,5 / 3 sn**, **Urgent 1–56 / 2 sn**. Kazançlar `cos/sin` ile eşit güçlüdür. Yeni oynatıcı döngü başından geçiş sırasında ilerler; geçiş bitince bu baş kısmı yeniden oynatılmaz. Gerçek süre kaynak süresi / pitch'tir. Dark Place Do→Re için **1,122462 × ortak pitch**; Urgent ve Sector ortak pitch; Blackout/Victory 1,0 kullanır. Yerel kaynak saati Dummy sürücüde de ilerler; gerçek oyunda monoton duvar zamanı, hitstop/pause sırasında müzik saatini korur. Donanım saatiyle küçük farklar yumuşakça düzeltilir; geçiş eşiğini aşan bir karede yeni oynatıcı o karenin kaynak zamanı farkını da hesaba katar. Başlamış zemin tekrar deneme, faz ve kart değişiminde yeniden başlatılmaz; menü/zaferde yalnız sessize alınır. Dosya eksikse ilgili kayıt sessizce atlanır ve kod müziği kullanılabilir kalır.

Krediler: **SkyleTheFrench** — [Blackout](https://opengameart.org/content/blackout), [Dark Place (loop)](https://opengameart.org/node/159643); **SRG774** — Sector/Urgent/Victory, [Dark Sci-Fi Audio Pack](https://opengameart.org/content/dark-sci-fi-audio-pack). Beşi de **CC0**, içerikleri değiştirilmedi; hash/byte kayıtları [SOURCES.md](SOURCES.md). Bunlar Ovani efektlerinden ayrı lisanslıdır.

Ovani efekt üretimi Windows/Linux'ta Python standart kütüphanesiyle çalışır; numpy/ffmpeg/sox gerekmez. ZIP doğrudan okunur, `__MACOSX`/`.DS_Store` atlanır. Yol verilmezse xdg masaüstü, `~/Masaüstü`, `~/Desktop` aranır:

```sh
python tools/audio/build_sfx.py --zip /tam/yol/Sound_FX_Starter_Pack_Vol._1.zip
godot --headless --path . --editor --quit
godot --headless --fixed-fps 60 --path . --script res://tests/Step12Smoke.gd
godot --headless --fixed-fps 60 --path . --script res://tests/Step13Smoke.gd
# Gerçek masaüstü ve ses sürücüsü; headless/fixed-fps kullanma:
godot --path . -- --audio-preview=/tmp/afet-audio-preview.wav
godot --path . --script res://tests/Step12Smoke.gd -- --capture=/tmp/afet-audio-native
```

Tek atışlar−50dBFS kırpma, RMS penceresi, DC düzeltme,4ms/80ms fade ve−1dBFS tepeyle mono44,1kHz'dir (kısa sesin son fade'i süreye göre küçülür). Döngüler stereo32kHz,1sn eşit güçlü dikiş ve yaklaşık−24dBFS RMS'tir; yağmurun tekil yüksek darbeleri yumuşatılır. Toplam19,78MB. QOA importu ve döngü sınırları `.wav.import` dosyalarında kayıtlıdır; SampleLibrary bunları ayrıca zorlar. Önizleme gerçek Master çıkışını 75 sn kaydeder (10 sn menü, 12 sn Hazırlık, 2 sn test girişi, 40 sn deprem, 1 sn çıkış, 10 sn kart; yalnız önizlemede girişin ilk .5 sn'si atlanır); kulakla son kalite değerlendirmesi ekibe aittir.

## Oda hasarı, malzeme ve güçlendirme

Odalar başlangıçta 100 HP'dir. Sağlam: en az %70; hasarlı: %35–70 arası; kritik: %0–35 arası; yıkık: 0 HP. Güçlendirmeler hasar alınca kaybolmaz. Bina barı, 16 odanın kalan HP yüzdelerinin ortalamasıdır. **4 oda yıkılırsa veya bina barı sıfırlanırsa kaybedersin.** Yıkık odalar yeniden kurulamaz.

**Kuşatmada E:** Yalnız hasarlı/kritik odalarda görünen **uyarı elması** onarım iznidir (kritikte kırmızı). Bir kolon kitiyle +45 HP onarılır ve çelik/FRP desteği kurulur. Yalnız sabitleme kitin varsa bu odayı sabitleyip barikat kurabilirsin; HP onarılmaz. Sağlam odada E sessizce hiçbir şey yapmaz ve etkileşim ipucu çıkmaz. Kolon kitin yoksa elmas görünmeye devam eder ama oyuncunun üstündeki E tuşu çıkmaz; E yalnız bir işe yarayacaksa görünür. Bütün mermi, sarsıntı ve aşınma hasarı ortak denge kontrolünden geçer: aynı anda en fazla **3 hasarlı/kritik oda**. Yeni uyarı alan oda **10 saniye** ek hasardan korunur; sonra en fazla 1,3 HP/sn kaybeder (kısa darbe bütçesi 1,5 HP). Fırtınada da odalar kademeli aşınır; onarım bekleyen oda sayısı arttıkça sağlam odalara odaklanan aşınma yavaşlar. Onarmadan uzun süre beklersen oda yine yıkılır. Mermi hasarı, türüne göre çarptığı odada hesaplanır; kat süpürmesi o kattaki dört odayı etkiler.

**Malzemeler yalnız kuşatmada düşer:** İlk düşüş dahil her **4,6–5,4 saniyede** (18 Ekim: %20 daha sık), oyuncunun bulunmadığı, yıkılmamış ve başka loot olmayan rastgele bir odaya. Oda havuzu mevcut konumdan koşu + kat geçişiyle tahmini ulaşım süresine göre süzülür; en az 0,5 sn toplama payı bırakılır (saldırılardan kaçınma süresi bu tahmine dahil değildir). Art arda aynı oda seçilmez. Aynı anda en fazla **3** eşya bulunabilir. 0,45 sn düşüş animasyonundan sonra **yerde tam 6,0 saniye** bekler; halka küçülür ve son 1,5 sn yanıp söner. Süresi dolunca yazısız söner. Aynı kattaki eşyanın yanına giderek otomatik toplarsın. Dalga bitişi yerdeki malzemenin ömrünü kısaltmaz: kart ekranında sayaç durur, inşaatta kalan süreden devam eder. Kolon kiti yokken ve onarım beklerken her ikinci düşüş kolon kiti olur; rastlantı uzun süre onarım malzemesiz bırakmaz. Topladıkların sonraki evreye taşınır. Ölüm, zafer ve sıfırlamada yerdekiler temizlenir.

| Ekipman | Halka | Oyun etkisi |
| --- | --- | --- |
| Kolon Güçlendirme Kiti (`COLUMN_KIT`) | Kehribar | E ile +45 oda HP ve çelik X/karbon sargı; deprem ve yapısal oda hasarı %50 azalır |
| Eşya Sabitleme & Barikat Kiti (`BARRICADE_KIT`) | Mavi | Tek E ile ANCHOR + SHUTTER: eşya sabitleme görselleri, panjur/kum torbası kurar; fırtına/sel/yangın mermisinin oyuncu ve oda hasarını %50 azaltır |
| Afet & İlk Yardım Çantası (`EMERGENCY_BAG`) | Yeşil | Anında +25 can ve tam takla enerjisi; su, kuru gıda, sargı bezi, düdük etiketi |
| Yangın Tüpü & Gaz Kesici Vana (`SAFETY_KIT`) | Kırmızı/turuncu | Toplandığı odaya otomatik kurulur: aktif/uyarıdaki/gelecek zemin suyu ve alevi engeller, ısıyı temizler, gaz/elektrik kaynaklı ikincil oda hasarını keser |

Sol alttaki **KOLON / SABİTLE / GÜVENLİK** slotları adetleri gösterir. Çanta anında tüketilir; güvenlik sayacı korunan benzersiz odaları gösterir. Drone uzaktan toplasa da güvenlik sistemi loot'un **ilk düştüğü odada** kurulur; komşu odayı temizlemez. Kit, zemin alanını oda sınırlarından böler; çizim ve gerçek kapsül çarpışması aynı parçaları kullanır. Girdap çekimi ve havadaki mermiler güvenlik kitinden etkilenmez.

**İnşaat evresinde E:** Eksik HP varsa kolon kitiyle onarır. Sonra henüz kurulmayan kolon veya birleşik sabitleme/barikat kitini takar. Kolon bir, birleşik kit iki mevcut destek bileşenini doldurur; üç LED ve “TAM ODA DESTEĞİ” bunları gösterir. Aynı bileşen tekrar satın alınmaz. Bu bir gerçek bina güvenliği belgesi değildir. Kuşatmada sağlam odada E sessiz kalır; yıkık odalar kurulamaz.

## Afet hazırlık bülteni: 9 aktif mekanik (Adım 8)

İlk üç faz sonunda solda **yeşil bir hazırlık kartı**, orta ve sağda **mavi/mor iki farklı aksiyon kartı** sunulur. Alınmış kart tekrar gelmez. **1/2/3 veya fare** ile birini seç; seçimde süre ve hareket durur. Kartta yalnız büyük özgün piksel ikon, kısa ad, en fazla yedi kelimelik tek etki satırı ve seçim tuşu vardır. Sayısal ayrıntılar aşağıdadır; kart yüzünde istatistik ve bilgi notu yoktur.

| Grup | Kart | Gerçek oyun etkisi |
| --- | --- | --- |
| A | Sakin Kal | İlk kalkan 0,35 sn sabit durunca açılır; ilk isabet mermisini yok eder. Tüketilince 6 sn sonra otomatik yeniden dolar. |
| A | Afet Çantası | Can %45'in altına düşünce fazda bir kez aktif mermileri temizler, +40 can ve 4 sn hız verir. Ölüm kararı öncesinde işler. Tıbbi loot ayrıca 2 sn, 105 px mermi itme/dağıtma çevresi açar. |
| A | Güçlü Oda | Karttan sonra onarılan/güçlendirilen odada mavi-kehribar zırh görünür. Odaya giren hareketli mermi başına bir kez %45 bloklama denenir; o odada enerji yenilenmesi iki kat olur. |
| B | Sonik Takla | Takla sırasında gerçek kapsüle değen mermileri, yüksek hızlı kesişmeler dahil parçalar; bitişte şok halkası çizer. |
| B | Onarım Dronu | Omuz üzerinde uçar; 580 px içindeki yerdeki loot'u oyuncuya çeker. Her 6,5 sn en hasarlı ayakta odaya ücretsiz +45 HP onarım ışını gönderir. Loot'un temel yerde kalma süresi 6 sn'dir. |
| B | Ağır Çekim | Ödül veren sıyrılma (graze), oyuncu merkezinde 220 px / 2,5 sn kubbe açar; içindeki hareketli mermiler %55 yavaşlar. Oyuncu, savaş saati ve sabit zemin alanı süreleri yavaşlamaz. |
| B | Yörünge Küreleri | Zıt konumda dönen iki çelik uydu, kendilerine temas eden hareketli mermileri süpürülmüş çarpışma kontrolüyle dağıtır. Aralarından mermi geçebilir. |
| B | Çelik Botlar | 2x W üst kat yayı ve S inişi boyunca dokunulmazlık; gerçek inişte yalnız hedef odanın mevcut mermileri temizlenir ve +20 HP onarılır. Komşu odalar ve uyarılar korunur. |
| B | Uzaktan Vinç | Herhangi bir odada E: bir inşaat kiti karşılığında en hasarlı en fazla iki ayakta odaya +45'er HP; bütün aktif mermilerin hareket/ömür/çarpışması 1 sn durur. Yıkık oda dirilmez, gereksiz işlem malzeme harcamaz. |

Kuşatmada normal E hâlâ yalnız görünür onarım uyarısında işler; **Uzaktan Vinç bu kurala açık istisnadır**. Üç seçimde üç kart edinilir. Tam yeni oyun bütün kartları, oda enerji zırhını, zaman etkilerini ve faz haklarını temizler; yenilgideki R savaş başındaki kartları geri getirir. Önceki 19 kartlık havuz ve pasif istatistik bonusları kaldırıldı; standart kit/oda korumaları korunur. Mobilya saldırısı normal kampanyada yoktur; oda eşyaları görsel kimlik/sabitleme detayıdır.

Deprem fazında desen arası bekleme ×1,10; hareketli kaya/şok hızı ×0,90. Sütunlar arası net kaçış boşluğu ×1,10; 12'li merkez halkalarının net kenar boşluğu merkezden 200 px referansında ×1,10'dur (daha küçük kaya hitbox'ı). Uç noktalar, uyarılar, hasar değerleri, fırtına/sel/final desenleri korunur. Bu üç katsayı insanın algıladığı toplam zorluğun tam %10 azalmasını garanti etmez.

[AFAD/USGS bilgi kaynakları](SOURCES.md) oyun etkilerinden ayrıdır: kurgusal kubbe, mermi temizleme, anlık onarım ve kat değiştirme gerçek afet davranışı değildir. Çök-Kapan-Tutun 18 Ekim'den beri temel C mekaniğidir; aynı fikirden gelen kalkan kartı **Sakin Kal** adını aldı. L-demir/karbon uygulaması için yıkımı önleme garantisi verilmez.

## Atmosfer ve görünüm (Adım 2.7)

- **Pixel-art render:** Dünya 960×540 çözünürlükte çizilip en yakın komşu filtresiyle 2× büyütülür; tüm prosedürel çizim gerçek bir piksel ızgarasına oturur. `MainGame` düğümündeki **Pixel Scale** 1 yapılırsa tam çözünürlüğe döner. Onarım elması, E tuşu ve güvenli kat çerçevesi keskin kalsın diye ayrı ekran katmanında (`WorldLabels`) çizilir; dünyada başka yazı yoktur.
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

Menüde Başla seçildiğinde oyun **ilk Hazırlık** ile başlar (öğretici açıksa önce A D ve W, sonra 25 sn; kapalıysa 15 sn). Bütün görevler bitince ya da F ile afet hemen gelir. Sonlu akış şöyledir:

1. **DEPREM:** 2,5 sn zemin çatlağı, yükselen kayalar ve iki yumruk sinematiği → 40 sn savaş (sarsıntılar) → 1 sn çıkış.
2. Karne + kart seçimi + 10 sn Hazırlık (kepenkler açılır) → **FIRTINA:** 2,5 sn rüzgâr/şimşek sinematiği → 40 sn savaş.
3. Karne + kart + 10 sn Hazırlık (sigorta paneli açılır) → **SEL:** 2,5 sn yükselen köpüklü su ve iki cephe tsunami sinematiği → 40 sn savaş.
4. Karne + son kart + 10 sn Hazırlık → **AFET:** 2,8 sn üç afetin birleşme sinematiği → 40 sn final (sarsıntılar, son 12 sn Nova) → çıkış ve **Hayatta kaldın**. Beşinci faz yoktur.

Ara Hazırlık'ta yapılacak görev ve harcanacak kit kalmadıysa saat 3 sn'ye iner.

Girişte oyuncu hareketi kilitlenir, saldırı veya hasar üretilmez; kamera hafif odaklanır, üst/alt siyah şeritler ve büyük boss adı görünür. Savaş başlayınca eski kadraj ve kontroller geri gelir. Giriş/çıkış 50 saniyeyi, kart seçimi Hazırlık süresini tüketmez. `1/2/3/4` bölüm kısayolları kampanya sırasını izler: `1` Deprem, `2` Fırtına, `3` Sel, `4` Afet.

## Hazırlık ve afet davranışı (18 Ekim)

Görevler bir kez yapılınca koşu boyunca kalır; R hepsini sıfırlar. Görev ancak Hazırlık evresinde yapılır (afet sırasında değil).

| Görev | Nerede / ne zaman | Oyundaki karşılığı |
| --- | --- | --- |
| Uzun eşyayı sabitle (gardırop, kitaplık, vitrin, buzdolabı) | 4 oda, ilk Hazırlık'tan itibaren | Sabit eşya L-demirle durur. Sabitlenmemiş olan ilk sarsıntıda devrilir: odaya 6 HP, devrilme yayındaki oyuncuya 18 hasar (Çök-Kapan-Tutun korumaz). Devrilen eşya sonraki Hazırlık'ta kaldırılıp sabitlenebilir. |
| Gaz vanasını kapat | Çamaşırhane, ilk Hazırlık'tan itibaren | Bütün odalarda tesisat yalıtılır (hasarlı odalarda ikincil gaz/elektrik hasarı biter); sarsıntılarda gaz kaçağı (4 odada 3 HP) olmaz. |
| Afet çantasını hazırla | Lobi, çıkış kapısının yanı | Her savaşta bir kez, can %35'in altına inince +35 can. |
| Kepenkleri indir | Mutfak, salon, yatak odası, resim atölyesi; ikinci Hazırlık'tan itibaren | O odaya gelen fırtına/sel mermisi hasarı yarıya iner (oyuncu ve oda). Kepenksiz pencerenin yanında sarsıntı veya fırtına rüzgârı cam yağdırır (8 hasar). |
| Sigortaları kapat | Lobi ana panosu; selden önceki Hazırlık'tan itibaren | Kapalı değilse taşkın suyu ve su duvarı elektrikli sayılır: oyuncuya 1,5× hasar. |

**Sarsıntı kuralları:** Depremde ilki 2. saniyede, sonra 8 sn arayla; finalde 5. saniyede ve 12 sn arayla (Nova'da yok). Uyarı 1,0 sn (öğreticide 1,8 sn), sallantı 1,4 sn. Sallantıda koşu ×0,45, kat değişimi kapalı (deneme karneye yazılır). Devrilme 0,35 s'de, tavan sıvası 0,8 s'de; Çök-Kapan-Tutun yapmayan 14 hasar alır. Her sarsıntıda bütün odalar 1,5 HP aşınır (çelik kolon yarılar). Uyarı ve sallantı boyunca mermi desenleri bekler.

**Karne satırları (en çok üç, önce kaçırılanlar):** `Çök-Kapan-Tutun 2/3`, `1 eşya devrildi`, `Gaz kaçağı oldu` / `Gaz vanası kapalıydı`, `Cam kırıkları geldi`, `Sarsıntıda kaçmaya çalıştın`, `Kepenkler 2/4`, `Sigortalar açık kaldı` / `Sigortalar kapalıydı`, `Su seni yakaladı`, `Afet çantan hazır değildi` / `Afet çantan işe yaradı`. Kaçırılan satırın yanında tek kısa öneri vardır (ör. "Ağır eşyaları duvara sabitle.", "Sel öncesi sigortaları kapat."); kaynaklar [SOURCES.md](SOURCES.md) içindedir.

Sayılar oyun dengesidir; gerçek hayatta güvenlik garantisi veya mühendislik talimatı değildir. Kurgusal boss saldırıları, anlık onarım, takla ve kartlar gerçek afet davranışı olarak sunulmaz.

**Tempo rampası (Adım 7, 18 Ekim cilası):** Her savaşın kendi saati vardır. 0–10 sn saldırı temposu **1,00×** (eski 0,90× ısınma ağır geliyordu); 10–28 sn **1,00× → 1,25×** doğrusal; 28–40 sn **1,45×** doruk. Geçişler 1 sn yumuşatılır, tempo kare içinde sıçramaz. Saldırı saati tempoyla çarpılır, bu yüzden dorukta boss desen değiştirmeyi ~1,6 kat sıklaştırır. Mermi hızı tempo fazlasının yarısı kadar artar (dorukta 1,225×) ve yolun uç noktası değişmez; ısınmada mermiler yazıldığı hızdadır. Final, Nova'sının üstüne rampanın yarısını alır. Dorukta BGM 1,05× oynar (yavaşça geçer, aynı WAV).

**Selin beş şeması:** Zemin taşkını, iki cepheden su duvarları, gerçek üç sekmeli basınç küreleri, girdap/zıpkın ve sinüs yolunda varil/kütük. Uyarı, yerel güvenlik kitleri ve kaçınma yolları korunur.

**Finalin birleşik saldırıları — ateş elementi yoktur:**

- Alt iki kata taşkın + üç gecikmeli çatı kayası. Canlı suya çarpan beton, 0,75 sn ayrı uyarıyla basınç sütunu + iki su/iki kaya parçası saçar; kuru zeminde iki kaya parçası.
- Rüzgâr çekimi + iki yedi mermilik su/rüzgâr girdap halkası ve bir çapraz rüzgâr bıçağı.
- Bir sismik zemin şoku + tsunami duvarı + üç kez seken bir basınç küresi + tavan enkazı.
- Dört köşedeki üç afet kaynağından **1,0 sn uyarılı 20 mermi**; daha geniş kaçış aralıkları.
- Son 12 sn Nova: üç afetli **iki 11'lik halka**, yer değiştirme, ortak sınırdan geçen oda hasarı ve ek kolon/çanta loot'u.

Birleşik bossun bazalt/kaya gövdesi, hortum kolu, su kaplı kaya eli, köpük taçları, girdapları ve şimşekleri binayı çevreler. Alev/lav çizimleri, yangın bossu ve eski çifte faz oyun akışından kaldırıldı. Korunmuş eski yangın tehlikesi yardımcıları ve ekipman direnç verileri normal kampanyada çağrılmaz.

Her saldırı aynı dondurulmuş uyarı/hitbox yolunu kullanır; havuz 128 ile sınırlıdır. Fazlar arasında oda hasarı, envanter ve kartlar korunur; boss testleri taze dünya kurar. `1/2/3/4` bölüm, kartta `1/2/3` seçim; `F9+U` kart denemesi, `F` hazırım; yenilgide `R` aynı bölümü dener, diğer durumlarda yeni oyun açar.

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
- **Sıyrılma (graze, Adım 7):** Bir mermi gövdene değmeden kenardan kenara ~22 px yakınından geçerse (koşarken, zıplarken veya taklada) turkuaz/sarı kıvılcım halkası ve yumuşak elektrik tıkırtısıyla takla enerjisi anında +25 olur. Her mermi bir kez sayılır, iki ödül arasında en az 0,12 sn vardır; isabet alan, isabetten hemen önce pencereye giren veya hasar korumasında geçen mermi ödül vermez. Kat duvarları ve alanlar sıyrılma sayılmaz.
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
scripts/ui/              Minimal HUD, yazısız dünya işaretleri (WorldLabels), PixelFont/UIStyle/MenuItem
scripts/bosses/          Dört çok parçalı, üç tonlu boss + final Titan (CataclysmArt.gd)
assets/sprites/          İsteğe bağlı el yapımı sprite klasörü
scripts/combat/          Dalga, oda hasar tablosu, çöküş kuralı, telgraf, sabit havuz, mermi ve DODGE
scripts/loot/LootSystem.gd Süreli 4 ekipman, toplama, faza bağlı E onarımı/inşaat
scripts/combat/SiegeUpgrades.gd Dokuz kartın kataloğu ve A/B/B seçimi
scripts/combat/SiegeMechanics.gd Dron, kule, türbin, zincir, manyetizma ve zaman bükme
scripts/ui/UpgradeOverlay.gd Fare/klavye ile üç kart seçimi
scripts/ui/PauseMenu.gd   ESC/P duraklatma paneli, tuş rehberi, ses düğmeleri
scripts/audio/            SoundManager (olaylar/miks), SoundSynth/SoundRecipes (SFX), MusicScore (bir kez pişen BGM)
scripts/combat/BossPatterns.gd Adım 7 fırtına (5) ve deprem (4) koreografileri; eski yardımcılar uyumluluk testleri için
scripts/art/FurnitureArt.gd 16 odaya özgü detaylı prosedürel mobilya çizimleri
resources/VisualAssets.tres Kalıcı sprite atama alanları
tests/FrontEndSmoke.gd   Normal giriş, menü/ayarlar/öğretici kalıcılığı, gerçek GUI, öğretici Hazırlık, ara kart ve çıkış
tests/Step1Smoke.gd      Godot içinde giriş/fizik/durum kontrolleri
tests/Step2Smoke.gd      Kuşatma/uyarı/çarpışma/havuz kontrolleri ve görsel yakalama
tests/Step2Soak.gd       Dört tam 40 sn savaş (deprem önce), üç 10 sn Hazırlık, gerçek malzeme/onarım
tests/Step25Smoke.gd     16 oda, gerçek jump/2x W/S/air-dash, paternler ve PNG kaydı
tests/Step3Smoke.gd      Ekrana sığma, fırtına bullet-hell paternleri, rüzgâr ve PNG kaydı
tests/Step27Smoke.gd     Karanlık atmosfer, ışıklar, sprite yükleyici, akıcı hareket, boss iskeletleri, 1920×1080 PNG
tests/Step3LootSmoke.gd  2x W yayı, oda HP/durumları, çöküş, loot ve E onarımı, 1920×1080 PNG
tests/CampaignSmoke.gd   6 sn ömür, inşaat, kart modal input, 4 faz, zafer, görsel kayıtlar
tests/Step45Smoke.gd     40/10 sn, giriş/çıkış (final 2,8 sn), hasar sınırı, aktif kartlar ve görsel kayıtlar
scripts/combat/MarathonPatterns.gd Sel/yangın paternleri, kalıcı alanlar, ikincil saldırılar
scripts/bosses/MarathonArt.gd Çok parçalı hidra/titan ve su/ateş çizimleri
tests/MarathonSmoke.gd    Yeni paternler, sekmeler, alan hasarı, kartlar, hareket, cinnet, native PNG
tests/Step48Smoke.gd      Dört kit, yerel güvenlik, 9 aktif kart, 150 seçim ve native PNG
scripts/combat/CataclysmPatterns.gd Final Titan'ın beş birleşik yeteneği, buhar etkileşimi ve nova
tests/Step49Smoke.gd      Minimal HUD, 40 sn, 1–4 kısayolları, birleşme girişi, beş yetenek, nova, gerçek 40 sn final ve native PNG
tests/Step5Smoke.gd       Duraklatma (klavye/fare), M/-/+, sentez kalitesi, miks kuralları, olay sesleri (sıyrılma dahil), kesintisiz PCM müziği ve native PNG
tests/Step55Smoke.gd      Dört faz, sinematikler, alt HUD, ateşsiz paternler ve müzik ölçümleri
tests/Step6Smoke.gd       Statik önbellek, 128 havuz, final ayarı, BGM döngüsü/watchdog
tests/Step8Smoke.gd       Deprem katsayıları, 9 gerçek mekanik, 300 kart seçimi, sıfırlama ve native kart/efekt/input kanıtı
tests/MinimalUISmoke.gd   Yazısız HUD/dünya işaretleri, piksel yazı tipi, kısa menü/kart/sonuç yazıları ve native PNG
tests/Step9Smoke.gd       Deprem önce kampanya, Hazırlık görevleri ve etkileri, sarsıntı/Çök-Kapan-Tutun, öğretici, karne, sesler ve native PNG
tests/Step10Smoke.gd      Bölüm kontrol noktası, ölüm/çöküşten tekrar, 1–4 kampanya sırası, menü fare/klavye, Hazırlık satırı ve native PNG
tests/Step13Smoke.gd      CC0 müzik kimliği, A/B döngüler, kesintisiz zemin, durum/perde/eksik dosya ve native mixer
tests/Step14Smoke.gd      Faz sonu tam can, ölümcül su isabeti, görev/onarım rehberi ve native 1080p/720p
tests/Step11Smoke.gd      Başarı efektleri/havuzlar, onarım/sarsıntı, hitstop temizliği, can izi/loot uçuşu, kademeli karne, ek müzik PCM'i ve native PNG
tests/Step7Smoke.gd       40/10 sn, tempo rampası, 5 fırtına + 4 deprem koreografisi (geometri ve gerçek kaçış), 0,55 sn uyarı/flash, mermi paleti, mobilya karartması, sıyrılma, BGM doruğu, dört gerçek 40 sn savaş ve native PNG
```

Görünür bileşenlerde Inspector'daki **Custom Sprite** alanına Texture2D sürüklenebilir; atanmazsa detaylı prosedürel çizim kullanılır. Bina bütünü için sprite atanırsa oda/eşya çizimleri gizlenir, fizik ve durum verisi korunur. Eşyalar `UNSECURED`, `REINFORCED`, `DAMAGED` durumlarını tutar; oda durumu değişince pencere kırılır/kepenk alır, eşyalar eğilir veya L-demirle sabitlenir; Tam yeni oyun yazılmış ilk durumlara döndürür; yenilgide R bölüm başındaki durumları geri yükler.

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
for suite in Step1Smoke Step2Smoke; do
  godot --headless --path . --script "res://tests/$suite.gd" || break
done
for suite in Step25Smoke Step3Smoke Step27Smoke Step3LootSmoke CampaignSmoke Step45Smoke MarathonSmoke Step48Smoke Step49Smoke Step5Smoke Step55Smoke Step6Smoke Step7Smoke Step8Smoke FrontEndSmoke MinimalUISmoke Step9Smoke Step10Smoke Step11Smoke Step12Smoke Step13Smoke Step14Smoke Step2Soak; do
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

Bölüm seçimi/tekrar deneme native kontrolü: `godot --path . --fixed-fps 60 --script res://tests/Step10Smoke.gd -- --capture=C:/Users/halil/AppData/Local/Temp/siege-step10-native`.
