# C-Wear Flutter — Kurulum ve Kullanım

Proje, sağlanan dört PDF tasarımına göre Flutter ile hazırlanmıştır. **QR kamera taraması gerçektir; sensör bağlantısı ve solunum ölçümleri simülasyondur.** Bluetooth, sunucu ya da veritabanı gerektirmez.

## Çalışma akışı

- **Connect**: Telefonun kamerasıyla gerçek QR kodu tarar. Herhangi bir QR kodu okutulunca bağlantı simülasyonu açılır ve otomatik olarak Live ekranına gider. İsterseniz kodu elle girebilirsiniz.
- **Live**: Bağlanmadan önce BPM, grafik ve solunum durum kartları boş ve yarı saydamdır. QR sonrası 16 BPM, 15 saniyelik animasyonlu solunum eğrisi, Normal durumu ve DEMO bağlantı etiketi görünür.
- **History**: Bağlantı öncesinde grafik ve özet veriler boş/pasiftir. Bağlandıktan sonra örnek geçmiş verileri; gün, hafta, ay seçimleri ve tarih gezintisi çalışır. Bunlar gerçek kayıtlardan gelmez.
- **Profile**: Ad, yaş ve profil fotoğrafı değiştirilebilir. **Save changes** veya üstteki **geri oku** değişiklikleri kaydedip Live ekranına döner. **Cancel** değişiklikleri kaydetmeden döner. Ad/yaş ve fotoğraf telefon üzerinde hatırlanır.
- **Disconnect demo sensor**: Bağlantıyı kapatarak grafik ve verileri tekrar boş hâle getirir.

## Windows + Android

Flutter **3.35+**, Android Studio / Android SDK ve **JDK 17** kurun. Flutter komutunu terminalde çalıştırabiliyor olmalısınız.

ZIP'i çıkartın ve PowerShell'i proje klasöründe açın:

```powershell
flutter doctor -v
Set-ExecutionPolicy -Scope Process Bypass
.\setup.ps1
flutter devices
flutter run
```

Bir Android telefonu USB ile bağlayıp USB hata ayıklamayı açmanız önerilir. Örnek QR: `demo_qr/CWear_Demo_Sensor_QR.png` (başka bir ekranda açın). Emülatörde **Enter sensor code manually** kullanılabilir.

APK oluşturmak için:

```powershell
flutter build apk --release
```

## macOS + iOS

Mac'te Flutter, Xcode ve CocoaPods kurun, sonra proje klasöründe:

```bash
./setup.sh
flutter devices
flutter run
```

iPhone'a yüklemede Xcode içerisinden Apple geliştirici hesabı / Signing seçilmelidir. iOS için minimum hedef sürüm **15.0** olarak ayarlanır. Windows bilgisayarda iOS IPA derlemesi yapılamaz.

## Paket ve izinler

`setup.ps1` ve `setup.sh`, bilgisayarınızdaki Flutter SDK ile güncel Android/iOS proje iskeletini oluşturur; otomatik olarak kamera izni, iOS fotoğraf izni ve platform sürümlerini ayarlar. Paketler `pubspec.yaml` dosyasında sabit sürümlüdür. Node.js / Expo gerekli değildir.

Projeyi kontrol edin:

```bash
flutter analyze
flutter test
```

**Önemli:** Bu çalışma ortamında Flutter SDK yüklü olmadığı için kaynak kod hazırlanmış ve statik olarak kontrol edilmiş, ancak gerçek telefon üzerinde derleme ve çalışma testi yapılamamıştır. Arşivde önceden derlenmiş APK/IPA bulunmaz. Gerçek sensör bağlantısı ve tıbbi ölçüm yapılmaz.
