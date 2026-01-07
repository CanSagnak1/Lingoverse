<div align="center">

# Lingoverse

<img src="https://github.com/CanSagnak1/TGY-HOMEWORK/raw/main/%C3%96devler/Lingoverse/Lingoverse/Sources/DesignSystem/Assets.xcassets/AppIcon.appiconset/180.png" alt="Lingoverse Icon" width="160"/>

**Lingoverse**, Swift ve VIPER mimarisi kullanılarak geliştirilmiş, `WordKit` kütüphanesini temel alan modern ve modüler bir iOS sözlük uygulamasıdır.

</div>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS_16.6+-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Language-Swift_5-orange.svg" alt="Language">
  <img src="https://img.shields.io/badge/Architecture-VIPER-purple.svg" alt="Architecture">
  <img src="https://img.shields.io/badge/UI-UIKit_(Programmatic)-green.svg" alt="UI">
  <img src="https://img.shields.io/badge/Dependencies-SPM-brightgreen.svg" alt="SPM">
  <img src="https://img.shields.io/badge/Version-1.1-red.svg" alt="Version">
</p>

---

## Genel Bakış

Lingoverse, temiz kod prensipleri ve katmanlı mimariyi merkezine alan bir iOS sözlük uygulamasıdır.
VIPER tabanlı modüler yapısı sayesinde:

* Sorumluluklar net biçimde ayrılır.
* Kod tekrar kullanılabilirliği artırılır.
* Test edilebilirlik ve sürdürülebilirlik güçlendirilir.

Uygulama, harici kelime servislerinden beslenen `WordKit` kütüphanesi üzerinden kelime arama, favorilere ekleme ve son aramaları yönetme gibi temel sözlük fonksiyonlarını sağlar.

---

## Temel Özellikler

### 1. Splash Ekranı

* **Açılış Animasyonu:** Uygulama başlarken `splashVideo.mov`, `AVPlayer` aracılığıyla oynatılır.
* **İnternet Kontrolü:** `SplashInteractor`, `Reachability` servisini (SystemConfiguration) kullanarak ağ bağlantısını kontrol eder.
* **Yönlendirme:**
  * Bağlantı varsa: Ana ekrana geçilir.
  * Bağlantı yoksa: Hata mesajı gösterilir.

---

### 2. Onboarding Ekranı (YENİ v1.1)

* **Akıcı Sayfa Geçişleri:** Spring animasyonlu swipe gestureları
* **Özellik Tanıtımı:** 5 sayfalık uygulama tanıtımı
* **Atlanabilir:** "Skip" butonu ile hızlı geçiş
* **İlk Açılış:** Sadece ilk açılışta gösterilir

---

### 3. Arama (Search) Ekranı

* **Kelime Arama:**
  * `UISearchController` ile gerçek zamanlı arama veya "Search" aksiyonu ile istek.
  * İstekler `SearchInteractor` üzerinden `WordKitClient`'a iletilir.
* **Son Aramalar (Recent Searches):**
  * Arama yapılmadığında `UITableView` içerisinde son aranan kelimeler listelenir.
  * `RecentSearchRepository` ile `UserDefaults` üzerinde kalıcı olarak tutulur.
  * Liste maksimum **15** kayıt içerir; tekrar edilen kelimeler listenin başına taşınır.
* **Son Aramaları Yönetme:**
  * **Silme:** Trailing swipe ile kayıt silme.
  * **Favoriye Ekleme:** Leading swipe ile hızlı favori ekleme.
* **Swipe Tutorial (YENİ v1.1):** İlk kullanımda animasyonlu swipe eğitimi

---

### 4. Favoriler (Favorites) Ekranı

* **Profesyonel UI (YENİ v1.1):**
  * Özel tasarım hücreleri
  * Renkli yıldız ikon containerları
  * "Tap to view definition" alt başlığı
  * Kelime sayısı header'ı
* **Favori Yönetimi:**
  * Trailing swipe ile favoriden çıkarma
  * Haptic feedback desteği
* **Detay Görüntüleme:**
  * Seçilen kelime için güncel veri çekilerek SearchDetail ekranına yönlendirme

---

### 5. Kelime Detayı (Search Detail) Ekranı

* **Gösterilen Bilgiler:**
  * Kelime: `WKWord.term`
  * Fonetik: `WKWord.phonetic`
  * Anlamlar: `meanings`
* **Sesli Okunuş:**
  * `audioURL` mevcutsa `AVPlayer` ile telaffuz oynatılır.
* **Çoklu Anlam ve Tür (Part of Speech):**
  * İsim, fiil vb. türler için `UISegmentedControl` ile segment geçişleri.
* **Eş Anlamlılar (Synonyms):**
  * `SynonymPillContainerView` içinde "pill" bileşenleri ile gösterilir.

---

### 6. Öğrenme (Learn) Modülü (YENİ v1.1)

#### Flashcard Modu
* **Kelime Kartları:** Favori kelimelerden oluşturulan flip kartları
* **Çevirme Animasyonu:** 3D flip efekti ile ön/arka geçişi
* **Swipe Navigasyon:** Sola/sağa kaydırma ile kart değiştirme
* **Tanım Yükleme:** Otomatik tanım çekme ve cache'leme

#### Quiz Modu
* **Çoktan Seçmeli:** 4 seçenekli sorular
* **Anlık Geri Bildirim:** Doğru/yanlış renk animasyonları
* **Skor Takibi:** Anlık skor gösterimi
* **Sonuç Ekranı:** Quiz bitiminde detaylı sonuç

#### İstatistikler
* **Progress Dashboard:** Öğrenme ilerlemesi
* **Quiz Doğruluk Oranı:** Yüzdelik başarı
* **Streak Takibi:** Ardışık günler
* **Motivasyon Mesajları:** Performansa göre kişiselleştirilmiş mesajlar

---

### 7. Ayarlar (Settings) Ekranı (YENİ v1.1)

* **Tema Seçimi:** Light/Dark/System tema desteği
* **Onboarding Gösterimi:** Onboarding'i tekrar izleme
* **Cache Temizleme:** Önbellek temizleme
* **Yasal Belgeler:** Gizlilik Politikası, Kullanım Şartları
* **Versiyon Bilgisi:** Uygulama versiyonu

---

### 8. Durum Yönetimi (State Handling)

Uygulama boyunca kullanıcı deneyimini güçlendiren standart durum bileşenleri kullanılır:

* **Boş Durum:** `DSListEmptyView` ile başlık + açıklama + ikon desteği
* **Hata Durumu:** `DSErrorView` ile "Tekrar Dene" aksiyonlu hata ekranı
* **Yükleme Durumu:** `UIActivityIndicatorView` (spinner)

---

## Mimari: VIPER

Her modül (Search, Favorites, Splash, SearchDetail, Learn, Settings), VIPER prensiplerine uygun şekilde yapılandırılmıştır.

* **View:** `UIViewController` alt sınıfları. Yalnızca UI güncelleme ve kullanıcı etkileşimlerinin iletiminden sorumludur.
* **Interactor:** İş kurallarını ve veri akışını yönetir.
* **Presenter:** View ve Interactor arasındaki köprüdür. Ham veriyi ViewModel'lere dönüştürerek View'a iletir.
* **Entity:** `WKWord`, `WKMeaning` gibi veri modelleri.
* **Router:** Modülün oluşturulması (`createModule`), bağımlılık enjeksiyonu ve ekranlar arası geçişten sorumludur.

---

## Tasarım Sistemi

`Sources/DesignSystem` altında merkezi bir tasarım dili uygulanır:

* **Tokenlar:**
  * `DSColor` — Renk paleti (Dark/Light mode desteği)
  * `DSSpacing` — Boşluk/spacing değerleri
  * `DSTypo` — Tipografi stilleri
  * `Strings` — Metin sabitleri
* **Bileşenler:**
  * `DSErrorView`, `DSListEmptyView` — Tekrar kullanılabilir UI komponentleri
* **Tema Desteği (YENİ v1.1):**
  * `ThemeManager` ile Light/Dark/System tema yönetimi

---

## Bağımlılıklar

* **WordKit** — Harici kelime API'si ile entegrasyon sağlayan kütüphane.

---

## Test Altyapısı

### Birim Testleri (`LingoverseTests`)

* **RecentSearchRepositoryTests** — Arama terimlerinin yönetimi
* **FavoritesRepositoryTests** — Favori ekleme/silme
* **SearchPresenterTests** — Presenter durum yönetimi

### UI Testleri (`LingoverseUITests`)

* `testSearchIdleEmptyState`
* `testNavigationToFavorites`
* `testFavoritesEmptyState`
* `testSearchBarIsTypable`

---

## Gereksinimler

* iOS 16.6+
* Xcode 15.0+
* Swift 5.9+

---

## Kurulum

```bash
git clone https://github.com/CanSagnak1/Lingoverse.git
cd Lingoverse
open Lingoverse.xcodeproj
```

---

## Lisans

MIT License

