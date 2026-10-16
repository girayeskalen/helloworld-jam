# Oyun motoru kararı

> **Arşiv / ARTÇI öncesi karar:** Kullanıcı 16 Ekim 2026'da ARTÇI için **Vite + TypeScript + Canvas 2D + Web Audio API** yığınını seçti. Aşağıdaki Godot kararı önceki araştırmanın tarihli kaydıdır. Güncel kurulum ve mimari [README.md](README.md), görevler [STATUS.md](STATUS.md) içindedir.

Araştırma ve yerel kontrol tarihi: **11 Ekim 2026**. Yarışma ve teslim yönergeleri **16 Ekim 2026 tarihli güncel v09 kurallarıyla** yeniden karşılaştırıldı; bu kontrol motorların teknik özelliklerinin yeniden araştırıldığı anlamına gelmez.

Bu belge tarihli motor araştırmasının kaydıdır. Başvuru, tema bekleme ve hazırlık sırası gibi geçmiş önerileri güncel görev olarak uygulamayın; ekibin bugünkü durumu ve yeni fikre geçiş [STATUS.md](STATUS.md) içinde takip edilir.

**Karar: standart Godot 4.7.2 + GDScript ile devam ediyoruz.** Yeni bir motor indirmeye gerek yok. Başlangıç yaklaşımımız küçük bir 2D oyun, Compatibility renderer ve ilk teslim hedefi Windows x86_64. Web sürümü, ayrıca test edilirse ikinci teslim seçeneği olabilir. Bunlar ekibimizin risk tercihleri; yarışma 2D veya Windows zorunluluğu koymuyor. Oyunun türü, fikri ve mekanikleri tema açıklandıktan sonra belirlenecek.

Bu karar, Godot'un bütün projelerde en iyi olduğu veya ödül kazandıracağı anlamına gelmez. Sizin iki kişilik, sıfır deneyimli ekibinizde teknik üretimin Codex tarafından yapılması, iki bilgisayarda Git kullanımı ve 48 saat içinde teslim edilebilir bir sonuç üretme ihtimali için yaptığımız değerlendirmedir.

## 1. Yarışmanın karara etkisi

[Resmî kuralların](https://game.ktimo.com.tr/kurallar) 3.1 ve 3.2 maddelerine göre motor seçimi serbest; oyun Windows bilgisayarda veya masaüstü tarayıcıda çalışmalı. Motor ve genel araç hazırlığı önceden yapılabilir; oyuna özgü geliştirme 16 Ekim saat 18.00'de tema açıklamasıyla başlayan 48 saatte yapılır. 4. madde AI kullanımına izin verir ve gerçek kullanımın beyanını ister.

Dolayısıyla araştırma, dokümantasyon ve motorun sürümünü kontrol etmek genel hazırlık kapsamında değerlendirmemizdir. Yarışma için hareket sistemi, menü, puan sistemi, prototip veya özel asset hazırlamıyoruz. AI izni bu zaman sınırını kaldırmaz. Mevcut çalışmalarımızda oyun dosyası bulunmadığını kontrol ettik; bunun dışındaki çalışmalar hakkında varsayım yapmıyoruz.

Jüri dağılımı oynanabilirlik 25, temayla ilişki 25, yaratıcılık 20, görsel/işitsel bütünlük 15 ve teknik bütünlük 15 puan. Motor adına veya AI kullanmanın kendisine ayrı bir puan yok. Güncel madde 4.3'e göre AI kullanımına otomatik ceza veya yüzde eşiği uygulanmıyor; kullanımın yoğunluğu, yaratıcılık ve görsel/sanatsal değerlendirmede jürinin kanaatini etkileyebilir. Bu yüzden önceliğimiz hızlıca doğrulanabilen, anlaşılır ve tamamlanmış bir oyun. Büyük 3D üretimini baştan hedeflememek bu puanlamadan ve deneyim durumumuzdan çıkardığımız stratejidir.

Başvuru son tarihi **11 Ekim 2026, 23.59 (UTC+3)**. Motor araştırması başvurunun yerine geçmez. [Başvuru sayfası](https://game.ktimo.com.tr/basvuru).

## 2. Nasıl karşılaştırdık?

Üç araştırma ajanı ayrı grupları inceledi: Godot ve hafif kod motorları; Unity ve büyük 3D motorları; web ve görsel olay düzenleyicileri. Sonra birbirlerine doğrudan itiraz gönderip önerilerini yeniden değerlendirdiler. Ana ajan ayrıca resmî belgeleri, güncel yarışma sayfasını ve yerel Godot komutlarını kontrol etti.

Toplam **27 motor, framework veya grafik kütüphanesi** karşılaştırma kapsamına alındı; Godot'un C# seçeneği ayrıca değerlendirildi. Dünyadaki bütün motorların eksiksiz envanterini çıkarmadık ve bütün adayları bu bilgisayara kurup karşılaştırmalı performans testi yapmadık. Dört güçlü adayı daha derin inceledik. Aşağıdaki özellikler resmî belgelerden; bu ekibe uygunluk sonuçları bizim değerlendirmemizdir.

Karar ölçütlerimiz:

| Ölçüt | Bizim için anlamı |
| --- | --- |
| Dosyalardan üretim | Kod, sahne, ayar ve varlık bağlantılarını Codex yazıp inceleyebilsin. |
| Hızlı hata kontrolü | Import, derleme, mantık, çalışma ve paketleme hataları kısa döngüyle görülebilsin. |
| Gerçek görüntü ve oynama kontrolü | Başarılı derlemeyi görsel kalite veya eğlenceyle karıştırmayalım. |
| Bağımsız teslim | Jüri oyunu belirtilen platformda çalıştırabilsin; build ve kaynak commit eşleşsin. |
| Az hazırlık bağımlılığı | Hesap, lisans aktivasyonu, SDK, özel eklenti veya bulut servisi eklemek somut fayda sağlasın. |
| İki kişilik Git düzeni | Değişiklikler incelenebilsin; dosya sahipliğiyle çatışmalar azaltılsın. |
| Lisans ve public kaynak | Oyun kodu açık depoda bulunabilsin; kaynak hakları ve bildirimleri doğru kaydedilsin. |

Sayısal motor puanları veya kazanma yüzdeleri vermedik; bunları destekleyen ölçümümüz yok. Önceden Godot indirmiş olmak tek başına seçim gerekçesi değil.

## 3. Dört güçlü aday

### Godot + GDScript — seçilen motor

Godot'un sahne, fizik, animasyon, ses ve arayüz araçlarını aynı proje içinde kullanabiliriz. GDScript kodu ile metin sahne/kaynak dosyalarını ben oluşturup düzenleyebilirim. Metin biçimi Git incelemesini kolaylaştırır; aynı sahneyi iki kişinin eşzamanlı düzenlemesi yine çatışabilir. Üretilen `.godot/` önbelleği kaynak depoya eklenmez. [Git ve dosya düzeni](https://docs.godotengine.org/en/stable/tutorials/best_practices/version_control_systems.html).

Resmî CLI; import, script parse kontrolü, sınırlı çalıştırma ve export sunuyor. Bunlar için editörde sürekli menülere tıklamanız gerekmiyor. Seçili bir scriptin `--check-only` kontrolü, bütün oyunun test edilmesi anlamına gelmez. Export için sürüme uygun şablonlar ve gerçek platform ayarları gerekir. [Komut satırı belgeleri](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html), [export hazırlığı](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html).

Standart sürüm ayrı .NET SDK veya lisans aktivasyonu gerektirmiyor. Motor MIT lisanslı; dağıtıma gerekli motor ve üçüncü taraf bildirimlerini ekleyeceğiz. [Resmî Windows indirme sayfası](https://godotengine.org/download/windows/), [lisans yükümlülükleri](https://docs.godotengine.org/en/stable/about/complying_with_licenses.html).

Zayıf yanı: Unity'deki hazır canlı editör kontrolünü veya Defold'un hazır runtime inceleme arayüzünü burada kurulu ve doğrulanmış olarak gösteremiyoruz. Godot'ta gerektiğinde görev için motor içi test desteği yazmak gerekir. Input olayları, viewport görüntüsü ve Movie Maker gibi motor API'leri buna olanak sağlar; bu destek henüz hazırlanmadı. [Input API](https://docs.godotengine.org/en/stable/classes/class_input.html#class-input-method-parse-input-event), [Movie Maker](https://docs.godotengine.org/en/stable/tutorials/animation/creating_movies.html).

Headless modda başarılı çalışma, sesin veya ekrandaki düzenin doğru olduğunu kanıtlamaz. Windows paketi ayrıca çalıştırılacak; iki üye de oynayacak. Web için Compatibility/WebGL 2 ve WebAssembly gerekiyor. Güncel belgede Godot 4 C# web export desteklenmiyor; bu yüzden standart GDScript seçiyoruz. [Web koşulları](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).

**Neden seçtik?** Koddan üretim ile bütünleşik oyun araçlarını birleştiriyor; bağımsız Windows teslimi için ek uygulama paketleyicisi gerektirmiyor. Tema bilinmezken az sayıda dış bağımlılıkla 2D ve gerektiğinde sınırlı 3D seçeneklerini açık tutuyor. Bu avantajlar, hazır canlı kontrol eksikliğine rağmen bu ekip için yeterli.

### Phaser + TypeScript + Vite — en güçlü alternatif

Phaser yalnız bir çizim kütüphanesi değil; sahne, kamera, fizik, input, ses, animasyon ve parçacık sistemleri sunuyor. Oyun dosyalarını tamamen koddan üretebilir, Vite ile web paketi hazırlayabiliriz. Framework için ücretli Phaser editörünü veya ayrı AI hizmetini satın almak şart değil. [Phaser 4](https://phaser.io/phaser4), [resmî TypeScript/Vite şablonu](https://github.com/phaserjs/template-vite-ts).

Kullanıcı kod yazmayacaksa TypeScript kullanmak bir dezavantaj değildir; kodu Codex yazacak. Tarayıcı erişimi olduğunda input, console, görüntü ve yükleme hatalarını aynı ortamda incelemek güçlü bir iş akışı sağlar. Web hedefi kesinleşirse Godot'un export ve WebAssembly katmanına göre daha doğrudan olabilir. Bu bizim teknik çıkarımımız; bu bilgisayarda ölçülmüş hız veya paket boyutu karşılaştırması değil.

Zayıf yanı: gerçek tarayıcı test aracı bu oturumda kullanılabilir değil. Phaser'ın HEADLESS modu bile DOM gerektiriyor; saf Node testi veya görsel doğrulama diye sunamayız. Bağımsız Windows uygulaması istenirse ayrıca bir paketleme yolu gerekir; yarışma yalnız web teslimini de kabul ettiği için bu bir zorunluluk değildir. [HEADLESS tanımı](https://docs.phaser.io/api-documentation/constant/phaser).

Araştırma sırasında güncel Phaser 4 ile eski 3.x örneklerinin karıştırılmaması gerektiği görüldü. Seçilseydi API belgeleri, sürüm ve bağımlılık kilidi birlikte sabitlenecekti. [Sürüm arşivi](https://phaser.io/download/archive), [Phaser 4 API](https://docs.phaser.io/api-documentation/4.0.0/function/core).

**Neden şu anda geçmiyoruz?** Tarayıcı otomasyon avantajını yerelde kullanamıyoruz. Godot, web yanında Windows teslimi ve bütünleşik editör araçları sunuyor. İndirme maliyetini değil, erişilebilir üretim ve test yollarını karşılaştırıyoruz.

### Unity 6 + C# — hazır editör otomasyonunda güçlü

Unity'nin resmî CLI/Pipeline araçları açık editörde sahne, nesne ve asset işlemleri; Play Mode; C# değerlendirme ve oyun/sahne görüntüsü almayı belgeliyor. Bu yüzden "Unity'yi Codex kullanamaz" sonucu yanlış olur. CLI beta kanaldan dağıtılıyor; üreticinin belgesi canlı editör komutlarının `0.1.0-beta.8` sürümünde üretim kullanımı için açıldığını söylüyor. Bu bilgisayarlarda kurulup denenmedi. [Resmî CLI](https://github.com/Unity-Technologies/skills/blob/main/skills/unity-cli/SKILL.md), [canlı entegrasyon](https://github.com/Unity-Technologies/skills/blob/main/skills/unity-cli/references/integration-advanced.md).

Test ve build otomasyonu ayrıca mevcut. C# kodu ve metin sahne/prefab dosyaları Git'e alınabilir; `.meta` kimlikleri ve referansları doğru tutulmalı. [Test/build araçları](https://github.com/Unity-Technologies/skills/blob/main/skills/unity-cli/references/build-run-test.md), [metin sahne biçimi](https://docs.unity.com/en-us/engine/6000.7/manual/working-with-scenes/text-scene-format).

Unity Personal uygun gelir/fonlama koşullarında ücretsiz, fakat hesap ve lisans aktivasyonu gerekiyor. Editör, platform modülleri ve Pipeline entegrasyonu iki bilgisayarda hazırlanmalı. [Personal koşulları](https://unity.com/products/unity-personal), [CLI giriş/lisans akışı](https://github.com/Unity-Technologies/skills/blob/main/skills/unity-cli/references/auth-license-cloud.md).

**Neden seçmedik?** Hazır canlı otomasyon gerçek bir avantaj; buna rağmen tema bilinmezken ek kurulum hattına geçmenin 48 saatlik küçük kapsam için net getirisi gösterilmedi. İki bilgisayarda bu hat doğrulanır ve somut 3D ihtiyacı ortaya çıkarsa karar değişebilir. Unity'nin 2D de yapabildiğini göz ardı etmiyoruz.

### Defold + Lua — gözden kaçırılmaması gereken aday

Defold'un metin proje kaynakları, Bob komut satırı build/bundle aracı ve AI ajanları için resmî belgeleri var. Bob'un güncel belgesi OpenJDK 25 istiyor. Editor HTTP API, derleme/çalıştırma, hata çıktısı ve sahne önizlemesi sunuyor; API deneysel. Önizleme, çalışan oyunun görüntüsüyle aynı şey değil. [Bob](https://defold.com/manuals/bob/), [Editor HTTP API](https://defold.com/manuals/editor-http-api/).

Automation Bridge, debug native extension üzerinden input, ekran görüntüsü ve oyun durumu incelemesi sağlayabiliyor. Release sürümünde bu arayüz yok. Native extension build'i ilk seferde bulut build servisine bağımlılık getirebilir; sıradan eklentisiz projelerin offline çalışması ayrı bir konu. [Runtime otomasyonu](https://defold.com/manuals/engine-service/), [offline çalışma](https://defold.com/manuals/working-offline/).

Oyun dağıtımı ve ticari kullanım mümkün; motorun lisansı MIT değil, kendine özgü koşullar içeriyor. [Lisans](https://defold.com/license/).

**Neden seçmedik?** Otomasyon avantajı somut, fakat yeni motor, Java build hattı ve debug entegrasyonu henüz doğrulanmadı. Godot'a göre daha iyi sonuç vereceğine ilişkin yerel kanıt olmadan bu hazırlık maliyetini üstlenmiyoruz.

## 4. Diğer adayların karşılaştırması

"Seçmedik" bu araçla iyi bir oyun yapılamayacağı anlamına gelmez. Aşağıdaki sonuçlar mevcut ekip ve bilinmeyen tema için geçerlidir.

| Aday | Üretim ve teslim olanağı | Bu ekipte seçmeme gerekçemiz |
| --- | --- | --- |
| Godot + C# | Metin kod/sahne; .NET araçları | Ayrı SDK; Godot 4'te resmî web export yok. GDScript'e göre bugün gerekli bir fayda yok. [C#](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/c_sharp_basics.html). |
| Unreal Engine | C++, editör Python API, UAT paketleme | Blueprint/asset binary düzeni ve C++ araç zinciri ek yük. Resmî 32 GB RAM önerisi, bu bilgisayarın yaklaşık 15,2 GB görünen RAM'inden yüksek; bu "açılmaz" demek değil. [Python](https://dev.epicgames.com/documentation/en-us/unreal-engine/scripting-the-unreal-editor-using-python), [gereksinimler](https://dev.epicgames.com/documentation/en-us/unreal-engine/hardware-and-software-specifications-for-unreal-engine). |
| Stride | C#, YAML assetler, `dotnet publish`, MIT | Otomasyona uygun; yeni SDK/asset hattına geçmek için somut üstünlük yok. [Build](https://doc.stride3d.net/4.3/en/manual/files-and-folders/building-the-game/building.html), [asset yapısı](https://doc.stride3d.net/latest/en/manual/engine/build-pipeline.html). |
| Flax | C#/C++, JSON sahneler, headless CLI | Yeni SDK/export hazırlığı ve 3D araç hattı. Küçük 2D hedefinde ek fayda gösterilmedi. [CLI](https://docs.flaxengine.com/manual/editor/advanced/command-line-access.html), [gereksinimler](https://docs.flaxengine.com/manual/get-started/requirements.html). |
| O3DE | C++/Python, CMake ve Gems | Resmî minimum kurulum alanı 40 GB; önerilen RAM 32 GB. Bu ekibe ağır hazırlık zinciri. [Gereksinimler](https://docs.o3de.org/docs/welcome-guide/requirements/), [build](https://www.docs.o3de.org/docs/user-guide/build/configure-and-build/). |
| GDevelop | JSON proje, görsel olaylar; gerçek headless HTML5 export CLI | "Codex export yapamaz" diye elenmiyor. İnsan olay editörünü kullanacaksa avantajlı; bütün teknik üretim Codex'teyken yeni olay şemasının Godot/TS'ye üstünlüğü gösterilmedi. [Resmî CLI](https://github.com/4ian/GDevelop/blob/master/newIDE/README.md). |
| Construct 3 | JSON klasör projeleri, web/desktop export | Ücretsiz sürüm sınırları ve editör/publish akışı ek hazırlık. Görsel olay sisteminin faydası kullanıcı onu yönetecekse daha belirgin. [Git](https://www.construct.net/en/make-games/manuals/construct-3/overview/collaborating-projects), [export](https://www.construct.net/en/make-games/manuals/construct-3/overview/publishing-projects), [planlar](https://www.construct.net/en/make-games/buy-construct). |
| GameMaker | GML, metin proje dosyaları, Igor CLI | Komut satırı için önce IDE giriş/runtime/target kurulumu gerekiyor. Otomasyon mümkün, fakat mevcut durumda daha sade değil. [CLI](https://manual.gamemaker.io/lts/en/Settings/Building_via_Command_Line.htm), [lisans seçenekleri](https://gamemaker.io/en/get). |
| PlayCanvas | Standalone JS/TS motoru; npm/Vite; cloud editörü şart değil | 3D web için ciddi aday. Bugün 3D ihtiyacı ve gerçek tarayıcı test yolu yok. [Standalone](https://developer.playcanvas.com/user-manual/engine/standalone/), [AI iş akışı](https://developer.playcanvas.com/user-manual/engine/developing-with-ai/). |
| Babylon.js | JS/TS 3D, Node NullEngine testleri | 3D web için güçlü; NullEngine görüntü doğrulaması değil. Tema öncesi 3D içerik yükünü seçmek istemiyoruz. [Kaynak](https://github.com/BabylonJS/Babylon.js), [Node/NullEngine](https://github.com/BabylonJS/Documentation/blob/master/content/setup/support/serverSide.md). |
| PixiJS | 2D render kütüphanesi | Tam oyun altyapısının daha fazlasını ayrıca kurmak gerekir; Phaser daha bütünleşik web adayı. [FAQ](https://pixijs.com/faq). |
| Three.js | Koddan 3D sahne/render | Tam oyun motoru değil; fizik ve oyun sistemlerinin kurulumu ayrıca gerekir. [Oyun geliştirme belgesi](https://threejs.org/manual/pages/game.html). |
| LÖVE | Lua 2D; Windows dağıtımı; web için ek topluluk yolu | Tam kod akışı iyi; Godot'un sahne/UI/animasyon araçlarını değiştirmek için belirgin teslim avantajı yok. [Motor](https://love2d.org/), [dağıtım](https://love2d.org/wiki/Game_Distribution). |
| raylib | C/C++ veya binding; Windows ve Emscripten/web | Koddan üretime uygun; compiler, build ve daha fazla oyun altyapısı işi getiriyor. [Özellikler](https://www.raylib.com/), [web build](https://github.com/raysan5/raylib/wiki/Working-for-Web-(HTML5)). |
| pygame | Python/SDL; Windows paketleyici, web için pygbag | Mantık testleri kolay; paketleme ve içerik araçlarının daha fazlası ayrıca hazırlanır. [Resmî kaynak](https://github.com/pygame/pygame), [paketleyici](https://pyinstaller.org/en/stable/operating-mode.html), [pygbag](https://pygame-web.github.io/wiki/pygbag/). |
| Bevy | Rust/Cargo, ECS; Windows ve wasm build | Tam kod üretimi güçlü. Rust ve Windows build araçlarıyla yeni derleme hattı; hızlı tekrar için ayrıca compile ayarları gerekiyor. [Resmî kurulum](https://bevy.org/learn/quick-start/getting-started/setup/). |
| MonoGame | C# framework, .NET ve içerik pipeline'ı, Windows | Koddan üretilebilir; sahne/oyun altyapısının daha fazlasını kurmak gerekiyor. Godot'tan geçmek için kazanç görülmedi. [Başlangıç](https://docs.monogame.net/articles/getting_started/), [Windows araçları](https://docs.monogame.net/articles/getting_started/1_setting_up_your_os_for_development_windows.html). |
| libGDX | Java/Gradle, desktop paketleme ve GWT/web | Otomasyon mümkün; JDK/Gradle, dağıtımda JVM paketleme ve web farkları ek iş. [Resmî dağıtım](https://libgdx.com/wiki/deployment/deploying-your-application). |
| Panda3D | Python/C++, bağımsız executable için paketleme araçları | CLI açısından uygun; genel 3D üretim için yeni içerik hattına geçmenin avantajı yok. [Giriş](https://docs.panda3d.org/1.10/python/introduction/index), [dağıtım](https://docs.panda3d.org/1.10/python/distribution/index). |
| Solar2D | Lua, MIT, Windows/HTML5 dahil platformlar | Hafif 2D için geçerli seçenek; bu ekipte Godot yerine yeni simulator/build hattı hazırlamanın üstünlüğü gösterilmedi. [Resmî özellikler](https://solar2d.com/). |
| Ren'Py | Metin senaryo/Python; görsel roman araçları | Tema sonrası bilinçli anlatı tercihi olursa iyi aday. Şimdi türü görsel romana bağlamak istemiyoruz. [Resmî başlangıç](https://www.renpy.org/doc/html/quickstart.html). |
| RPG Maker MZ | RPG araçları, JavaScript pluginler | Türü RPG'ye yöneltiyor; ücret/lisans ve paketli assetlerin public ham paylaşımı ayrıca kontrol edilmeli. [Pluginler](https://www.rpgmakerweb.com/blog/using-plugins-in-mz), [EULA](https://www.rpgmakerweb.com/eula). |
| GB Studio | MIT; Game Boy ROM ve web export | Retro donanım sınırları özel bir tür/sanat kararı gerektiriyor; genel başlangıç seçimi değil. [Resmî kaynak](https://github.com/chrismaltby/gb-studio). |
| Cocos Creator | TypeScript, asset/meta dosyaları, CLI build | CLI için GUI ortamı da gerekiyor; yeni editor ve asset hattına geçmenin getirisi kanıtlanmadı. [CLI](https://docs.cocos.com/creator/3.8/manual/en/editor/publish/publish-in-command-line.html), [proje yapısı](https://docs.cocos.com/creator/3.8/manual/en/getting-started/project-structure/). |

## 5. Ajanlar hangi noktalarda birbirlerine itiraz etti?

| İtiraz | Tartışma sonucu |
| --- | --- |
| "Codex bütün kodu yazacaksa Phaser daha uygun olabilir." | Kabul edildi. Gerçek tarayıcı otomasyonu ve kesin web hedefi varsa Phaser öne geçebilir. Şu oturumda bu araç erişimi yok. |
| "Unity'yi fare gerektirdiği için elemek yanlış." | Kabul edildi. Resmî CLI/Pipeline somut avantaj; yerel kurulum ve iki bilgisayar testi yapılmış değil. |
| "Defold doğrudan AI/runtime arayüzleri sunuyor." | Kabul edildi. Deneysel editor API ve debug bridge güçlü; ek Java/native extension hazırlığı var. |
| "GDevelop'da komut satırı export yok." | Güncel resmî kaynak bunu çürüttü. GDevelop otomasyonsuz diye elenmedi. |
| "Godot zaten indirildi, o yüzden kalsın." | Yeterli gerekçe olmadığı konusunda uzlaşıldı. Karar dosyadan üretim, bütünleşik araçlar, teslim ve bağımlılıklara dayanıyor. |
| "AI işi yapıyorsa insanların test etmesi gerekmez." | Reddedildi. Hatasız build, anlaşılır kontrolleri, ses uyumunu veya eğlenceyi kanıtlamaz. |

Son turda üç ajan da mevcut koşullarda Godot'u seçti. Bu uzlaşma tek başına doğruluk kanıtı değil; dayanaklar ve kararın değişeceği koşullar yukarıda açıklandı.

## 6. Bu bilgisayarda gerçekten ne doğrulandı?

| Kontrol | Sonuç |
| --- | --- |
| Git deposu | Mevcut `helloworld-jam`; `origin` adresi `girayeskalen/helloworld-jam`. Yeniden clone yapılmadı. |
| Mevcut içerik | README, AGENTS, STATUS, PREPARATION, SOURCES ve SUBMISSION hazırlık dokümanları vardı. Oyun projesi/kodu yoktu. |
| Godot'un açılması | Kullanıcının görüntüsünde boş proje yöneticisi; yerel çalışan EXE yolu da doğrulandı. |
| Godot CLI | `--headless --version` çıktısı: `4.7.2.stable.official.ed1daf0bf`. |
| CLI araçları | Yerel `--help` import, parse, sınırlı çalıştırma, export ve movie seçeneklerini gösterdi. |
| Export şablonları | Standart `%APPDATA%/Godot/export_templates` klasöründe dosya yok. Henüz kurulmadı. |
| Import, runtime, final export | Proje olmadığı için yapılmadı. Yardım çıktısı bunların başarıyla denendiği anlamına gelmez. |
| UI otomasyonu | Mevcut araç envanteri `apps: []`, `browsers: []`. Native editör ve gerçek tarayıcı kontrolü bu oturumda kullanılamıyor. |
| Diğer bilgisayar | Godot sürümü, Git düzeni ve export sonucu henüz teyit edilmedi. |
| Alternatif motorlar | Resmî doküman ve kaynak araştırması; yerel kurulum/benchmark yapılmadı. |

Bu kontrolde oyun projesi, oyun kodu veya asset üretilmedi. Diğer motorlar kurulmadı. Mevcut hazırlık değişiklikleri korundu; bu araştırma için commit/push yapılmadı.

Hata taramasında 4.7.2'nin Windows editöründen web export'u hakkında [#124197 bildirimi](https://github.com/godotengine/godot/issues/124197) bulundu. Bakımcı, uygun doldurulmadığı için bildirimi kapatmış; doğrulanmış genel hata veya yapılmış düzeltme olarak değerlendirmiyoruz. Bu rapor native Windows export'un bozuk olduğunu göstermiyor. Web sürümünü teslim seçeneği saymadan önce gerçek çıktının açılmasını ayrıca kontrol etmek gerekiyor.

## 7. Teknik işi nasıl üstleneceğiz?

Tema açıklandıktan sonra kod, metin sahneleri, proje ayarları, dosya düzeni, build hazırlığı ve göreve uygun otomatik kontrolleri Codex üstlenecek. Önce küçük bir çalışan sonuç, sonra iyileştirme; iki ayrı Codex'e aynı dosya için eşzamanlı görev vermeyeceğiz. Ortak kararlar dosyalara yazılacak; sohbetler kendiliğinden paylaşılmıyor.

Kontrol sırası: ilgili kod/ayar incelemesi, import çıktısı, gerekli script kontrolleri, oyun durumları ve sahne çalışma kontrolleri, export, gerçek platformda açma ve insan oynayışı. Yeni her değişiklik için ölçülü ve ilgili kontroller yapılacak. Tek bir headless komutunu bütün testlerin yerine kullanmayacağız.

Godot'un input ve görüntü API'leriyle gereken ölçüde otomatik doğrulama desteği yarışma sırasında eklenebilir. Böyle bir destek henüz yok. Erişilemeyen UI işlemleri veya doğrulanamayan sonuçlar açıkça bildirilecek; yapılmış gibi kaydedilmeyecek.

İki kişinin sorumluluğu: başvuru ve gerekli hesap/giriş onayları, fiziksel katılım, oyunu oynayıp anlaşılır/eğlenceli olup olmadığını söyleme, kapsam kararları ve güncel madde 7.3'e göre video dahil toplam 3 dakikalık sunum. "Her teknik dosyayı ben hazırlayabilirim" ile "siz hiç işlem yapmayacaksınız" aynı taahhüt değil. Ödül garantisi vermiyoruz.

## 8. Şimdi uygulanacak sıra ve kararı değiştirme koşulları

1. Yapılmadıysa bugün başvuruyu gönderin; kayıt numarası ve organizasyon onayını ayrı takip edin.
2. Bu bilgisayarda açık olan standart Godot 4.7.2 kalsın. Arkadaşın da işletim sistemine uygun aynı sürümü açsın.
3. Windows x86_64 export şablonlarını hazırlayın. Ayrı boş eğitim alanında export denemesi genel araç öğrenimi olarak yorumumuzdur; yarışma repo/projesiyle karıştırılmayacak ve yarışmaya taşınmayacak. Ayrıntılar [PREPARATION.md](PREPARATION.md) içinde.
4. İki bilgisayarın gerçek kurulum sonuçlarını [STATUS.md](STATUS.md) içine yazın. Açılmayan veya test edilmemiş adımı tamamlandı saymayın.
5. Oyuna özgü proje, tasarım ve kod için tema açıklamasını bekleyin. AI ve hazır kaynak kullanımını [SOURCES.md](SOURCES.md) içinde gerçek kapsamıyla kaydedin.

Godot'ta iki bilgisayarı etkileyen çözülemeyen bir export/çalışma sorunu, doğrulanmış ve belirgin şekilde daha iyi bir Phaser tarayıcı test/teslim yolu veya temadan sonra ortaya çıkan somut Unity 3D ihtiyacı varsa motor kararı yeniden değerlendirilebilir. Yalnız daha gösterişli görünmesi veya yeni bir AI etiketi taşıması motor değiştirme sebebi olmayacak. Şu andaki uygulanacak karar **Godot ile devam etmek**.
