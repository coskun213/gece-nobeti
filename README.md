# Gece Nöbeti

Tarayıcıda, iPhone'da ve Android'de oynanan 3D zombi hayatta kalma oyunu.

- **Oyna:** https://coskun213.github.io/gece-nobeti/
- **Android APK:** https://github.com/coskun213/gece-nobeti/releases/latest/download/GeceNobeti.apk

## Yapı

- `index.html`: oyunun tamamı (three.js r128 ile)
- `js/`, `fonts/`: çevrimdışı çalışsın diye yerel kopyalar
- `sw.js`: çevrimdışı önbellek (önce internet, bağlantı yoksa önbellek)
- `android/`: WebView uygulaması ve derleme betiği (`build.ps1`)

Tek kaynak bu depodur. `main` dalına gönderilen her değişiklik GitHub Pages'te yayınlanır.
Android uygulaması açılışta yayındaki sürümü yüklediği için APK'yı yeniden derlemek
yalnızca uygulamanın kendisi (simge, izinler, Java kodu) değiştiğinde gerekir.
