# helloworld-jam
HelloWorld oyun projemiz.

İki kişilik ekibimizin ortak deposu: [girayeskalen/helloworld-jam](https://github.com/girayeskalen/helloworld-jam).

Henüz oyun motoru seçmedik. Motor ve proje yapısı belirlendiğinde kurulum ve çalıştırma adımlarını buraya ekleyeceğiz.

## Ortak çalışma düzeni

- Herkes kendi bilgisayarındaki proje kopyasında, kendi GitHub ve Codex hesabıyla çalışır.
- Değişiklikleri GitHub üzerinden paylaşırız. Bir kişinin Codex sohbeti diğer kişinin sohbetine aktarılmaz; ortak kararları ve görev durumlarını dosyalara yazarız.
- Başlangıçta ortak `main` dalında çalışıyoruz. Aynı dosyayı aynı anda değiştirmeden önce haberleşiriz; görev sahiplerini `STATUS.md` içinde belirtiriz.
- **Kaydetmek** dosyayı bilgisayarında günceller. **Commit** değişikliklerin yerel Git kaydını oluşturur. **Push** commitleri GitHub'a gönderir. **Pull** GitHub'daki değişiklikleri bilgisayarına alır.

## 1. Projeyi aç

VS Code'da **Dosya → Klasör Aç** menüsünden mevcut `helloworld-jam` klasörünü seç. Windows'ta kısayol: önce `Ctrl+K`, sonra `Ctrl+O`. Zaten indirilmiş projeyi yeniden clone etmene gerek yok.

**Terminal → Yeni Terminal** menüsünü aç. Aşağıdaki komutları proje klasöründeki terminalde çalıştır:

```powershell
git status
git remote -v
```

`git status` bu klasörün Git durumunu gösterir. `origin` adresinin `https://github.com/girayeskalen/helloworld-jam` olması gerekir; adresin sonunda `.git` bulunması da normaldir.

## 2. Kendi Git kimliğini kontrol et

Her bilgisayarda bir kez kontrol et:

```powershell
git config user.name
git config user.email
```

Bir değer eksik veya sana ait değilse aşağıdaki örneklerdeki adı ve e-postayı kendi bilgilerinle değiştir. `--local` yalnızca bu projeyi etkiler:

```powershell
git config --local user.name "Ad Soyad"
git config --local user.email "GitHub e-postan"
```

Ad, commitlerde görünen isimdir; GitHub kullanıcı adın olmak zorunda değildir. E-posta için GitHub hesabına eklediğin adresi veya GitHub **Settings → Emails** sayfasındaki gizlilik amaçlı `noreply` adresini kullanabilirsin. Bunlar GitHub'a giriş yapmanın yerine geçmez.

## 3. İşe başlamadan arkadaşının değişikliklerini al

Önce durumu kontrol et:

```powershell
git status
```

Kaydedilecek yerel değişiklik yoksa (`working tree clean`) güncelle:

```powershell
git pull --ff-only
```

Bu komut ortak geçmişi otomatik birleştirme commiti oluşturmadan günceller. Yerel değişikliklerin varsa önce dosyaları kaydet ve aşağıdaki adımlarla commit oluştur. Pull hata verirse çalışmaya devam etmeden önce aşağıdaki hata bölümüne bak.

## 4. Değişiklikleri kaydet ve kontrol et

Dosyaları düzenledikten sonra `Ctrl+S` ile kaydet. Birden fazla açık dosya için **Dosya → Tümünü Kaydet** menüsünü kullan. Kaydetmek tek başına commit veya push yapmaz.

```powershell
git status
git diff
```

`git status` değişen ve yeni dosyaları listeler. `git diff` henüz commit için seçilmemiş, Git'in zaten takip ettiği dosyalardaki değişiklikleri gösterir; yeni dosyaların içeriğini VS Code'da da incele.

## 5. Açıklayıcı bir commit oluştur

Yalnızca bu görevde değiştirdiğin dosyaları commit için seç. Örneğin görev durumu için sadece `STATUS.md` değiştiyse:

```powershell
git add -- STATUS.md
git diff --cached
git status
git commit -m "Görev durumunu güncelle"
```

Başka dosyaları değiştirdiysen `git add --` sonrasına onların gerçek yollarını yaz. VS Code'un **Kaynak Denetimi** bölümünde ilgili dosyaların yanındaki **+** düğmesi de aynı seçimi yapar. `git diff --cached` ve `git status` ile commitin içeriğini kontrol et; mesajı yaptığın işi anlatacak şekilde değiştir.

Küçük ve tek bir işi anlatan commitler oluştur. Ekip arkadaşının veya başka bir görevin değişikliklerini kendi commitine katma. Şifreleri, erişim anahtarlarını ve kişisel ayar dosyalarını ekleme.

## 6. GitHub'a gönder

```powershell
git push
git status
```

Push başarılı olunca GitHub depo sayfasında son commit görünür. `git status` yerel dalın `origin/main` ile güncel olduğunu ve çalışma alanının temiz olduğunu göstermelidir.

GitHub oturum açma ekranı çıkarsa **Sign in with your browser** düğmesine tıkla, tarayıcıda kendi hesabına giriş yap ve gösterilen yetkilendirmeyi tamamla. Şifreni veya erişim anahtarını README'ye ya da sohbete yazma.

## Pull veya push hata verirse

- Push reddedildiyse arkadaşın senden önce yeni bir commit göndermiş olabilir. Yerel değişikliklerini önce kaydet ve commit et, sonra `git pull --ff-only` dene. Başarılı olursa yeniden `git push` çalıştır.
- `Not possible to fast-forward`, `divergent branches` veya bir çatışma mesajı görürsen dur. Çıktıyı Codex'e göster ve "Yerel çalışmalarımı ve ekip arkadaşımın değişikliklerini koruyarak bunu çöz" de. Yerel ve uzak commitler ayrıştıysa birleştirme gerekebilir.
- **Force push kullanma.** Sorunu aşmak için dosya silme, `git reset --hard` veya `git clean` çalıştırma.

## Arkadaşın bu dosyaları nasıl alır?

Arkadaşının bilgisayarında proje zaten varsa VS Code'da o klasörü açıp, yerel değişikliği olmadığını kontrol ettikten sonra `git pull --ff-only` çalıştırması yeterli.

Henüz kendi bilgisayarına indirmediyse VS Code'da `Ctrl+Shift+P` → **Git: Clone** seçeneğine tıklayıp `https://github.com/girayeskalen/helloworld-jam` adresini girebilir. Yerel klasörü seçip indirme tamamlandıktan sonra **Open / Aç** düğmesine tıklar. Ardından kendi Git kimliğini yukarıdaki adımlarla kontrol eder.

## Ortak kayıtlar

- `STATUS.md`: görevler, görev sahipleri ve bilinen sorunlar.
- `AGENTS.md`: Codex'in bu depoda çalışırken uyması gereken kurallar.
