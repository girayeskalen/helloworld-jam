# Başka hesaba devir: son iki isteği geri alma

Kullanıcı mevcut durumu GitHub'a kaydetmemizi, geri alma işlemini diğer hesapta yapmamızı istedi. **Bu çalışma ağacında henüz geri alma yapılmadı.**

## Kesin hedef

- Referans dalı: `origin/reference/pre-step9-20261018`
- Referans commit: `55203269c1fb79252dbd2f7e66e041ec89320a27`
- Referans ağaç: `012b76013966a90bb5eedf300d3ec31fd93c0fc2` (134 dosya)
- Kaynak: Adım 9 başlamadan hemen önce alınmış `siege-step9-baseline.zip` yedeği.
- Yedek SHA-256: `190dcb11509f5a8a2076e792c1073a5bcf4e74e14b1b0c429680d5541c61f1bb`

Bu referans o sırada commit edilmemiş Adım 7 ve Adım 8 çalışmalarını da içerir. Eski `355d890` commit'i yalnız Adım 6'dır ve istenen hedef değildir. **İki kullanıcı isteği, iki Git commit'i anlamına gelmez; HEAD~2 kullanma.**

## Geri alınacak istekler

1. Adım 9: üniversite/mezuniyet, diploma/koltuk çizimleri ve hikâye sinematikleri.
2. Sonraki video-intro temizliği: eski boss sinematiklerinin kaldırılması, yeni IntroOverlay/VideoStreamPlayer ve piksel fontlu açılış.

Hedefte Adım 8'in 16 odalı gece görünümü, 2x W parabolik geçişi, dokuz aktif kartı, deprem kolaylaştırması, dört adet 50 saniyelik savaş ve 5 saniyelik inşaat evreleri korunur. **Adım 9 öncesinde zaten var olan BossCinematic, boss giriş/çıkışı ve final birleşmesi geri gelir.** Yeni açılış/hikâye sistemleri hedefte yoktur. Güncel AGENTS.md içindeki bunları geri getirmeme kuralı, kullanıcının daha yeni ve açık geri alma isteğiyle geçersizdir; hedefteki AGENTS.md de geri yüklenir.

## Uygulama

Önce `git status`, dal ve uzak depo durumunu incele. Sonradan eklenen yerel veya ekip arkadaşına ait işleri kaybetme; gerekiyorsa ayrı kaydet. Mevcut HEAD için yedek dal oluştur. Temiz çalışma ağacında referansı fetch edip doğrula:

```powershell
git fetch origin
git show --stat 55203269c1fb79252dbd2f7e66e041ec89320a27
git restore --source=55203269c1fb79252dbd2f7e66e041ec89320a27 --staged --worktree -- .
git write-tree
```

Ek bir değişiklik yapılmadan `git write-tree` çıktısı yukarıdaki referans ağaç kimliğiyle aynı olmalıdır. Bu yöntem referansta olmayan takipli intro/font/test dosyalarını da kaldırır; bu devir dosyasının kaldırılması da beklenir. Takipsiz sonradan eklenmiş dosyalar için körlemesine clean/silme yapma. Reset, force push veya yeniden clone kullanma. Geçmişi silmek yerine geri alma daha sonra yeni commit olabilir; commit/push yalnız kullanıcı isterse.

Hedef sürümün README/AGENTS/STATUS dosyalarını oku. Godot import/parse, ilgili hareket/kart/faz testleri ve gerçek renderer ile F5/görüntü kontrolü yap. Hedefte kayıtlı önceki doğrulama 17 paket/1.271 kontroldür; bu devir sırasında yeniden çalıştırılmadı. Sonuçları ve varsa eksikleri kullanıcıya açıkla; yeni mekanik veya tasarım ekleme.
