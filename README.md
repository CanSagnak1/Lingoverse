<div align="center">

# Lingoverse

<img src="https://github.com/CanSagnak1/TGY-HOMEWORK/raw/main/%C3%96devler/Lingoverse/Lingoverse/Sources/DesignSystem/Assets.xcassets/AppIcon.appiconset/180.png" alt="Lingoverse Icon" width="160"/>

**Lingoverse**, Swift ve VIPER mimarisi kullanılarak geliştirilmiş, `WordKit` kütüphanesini temel alan modern ve modüler bir iOS sözlük uygulamasıdır.

</div>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Language-Swift_5-orange.svg" alt="Language">
  <img src="https://img.shields.io/badge/Architecture-VIPER-purple.svg" alt="Architecture">
  <img src="https://img.shields.io/badge/UI-UIKit_(Programmatic)-green.svg" alt="UI">
  <img src="https://img.shields.io/badge/Dependencies-SPM-brightgreen.svg" alt="SPM">
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

  * Bağlantı varsa: `SplashRouter` üzerinden Search modülüne geçilir.
  * Bağlantı yoksa: Hata mesajı gösterilir, akış durdurulur.

---

### 2. Arama (Search) Ekranı

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
* **Navigasyon:**

  * `SearchRouter` ile SearchDetail veya Favorites ekranlarına geçiş.

---

### 3. Favoriler (Favorites) Ekranı

* **Favori Listesi:**
  `FavoritesRepository` ile `UserDefaults` üzerinden okunan favori kelimeleri gösterir.
* **Favori Yönetimi:**

  * Trailing swipe ile favoriden çıkarma.
* **Detay Görüntüleme:**

  * Seçilen kelime için `FavoritesInteractor`, `WordKitClient` üzerinden güncel veriyi çekerek SearchDetail ekranına yönlendirir.

---

### 4. Kelime Detayı (Search Detail) Ekranı

* **Gösterilen Bilgiler:**

  * Kelime: `WKWord.term`
  * Fonetik: `WKWord.phonetic`
  * Anlamlar: `meanings`
* **Sesli Okunuş:**

  * `audioURL` mevcutsa `AVPlayer` ile telaffuz oynatılır.
* **Çoklu Anlam ve Tür (Part of Speech):**

  * İsim, fiil vb. türler için `UISegmentedControl` ile segment geçişleri.
  * `SearchDetailPresenter`, `WKWord` modelini `SearchDetailMeaningVM` gibi ViewModel yapılarına dönüştürerek gösterim yapar.
* **Eş Anlamlılar (Synonyms):**

  * Varsa, `SynonymPillContainerView` içinde "pill" bileşenleri ile gösterilir.

---

### 5. Durum Yönetimi (State Handling)

Uygulama boyunca kullanıcı deneyimini güçlendiren standart durum bileşenleri kullanılır:

* **Boş Durum:**
  Son arama veya favori yoksa `DSListEmptyView` gösterilir.
* **Hata Durumu:**
  Ağ hatası veya sonuç bulunamadığında `DSErrorView` ile "Tekrar Dene" aksiyonlu hata ekranı.
* **Yükleme Durumu:**
  Ağ istekleri sırasında `UIActivityIndicatorView` (spinner) gösterilir.

---

## Mimari: VIPER

Her modül (Search, Favorites, Splash, SearchDetail), VIPER prensiplerine uygun şekilde yapılandırılmıştır.

* **View:**
  `UIViewController` alt sınıfları. Yalnızca UI güncelleme ve kullanıcı etkileşimlerinin iletiminden sorumludur.
* **Interactor:**
  İş kurallarını ve veri akışını yönetir.
  Örneğin `SearchInteractor`, `WordKitClient`, `FavoritesRepository` vb. servislerle konuşur.
* **Presenter:**
  View ve Interactor arasındaki köprüdür.
  Ham veriyi ViewModel'lere dönüştürerek View'a iletir.
* **Entity:**
  `WKWord`, `WKMeaning` gibi veri modelleri.
* **Router:**
  Modülün oluşturulması (`createModule`), bağımlılık enjeksiyonu ve ekranlar arası geçişten sorumludur.

Bu yapı:

* Sıkı bağlılığı azaltır,
* Test edilebilirliği artırır,
* Modül bazlı geliştirme ve bakım maliyetini düşürür.

---

## Tasarım Sistemi

`Sources/DesignSystem` altında merkezi bir tasarım dili uygulanır:

* **Tokenlar:**

  * `DSColor` — Renk paleti
  * `DSSpacing` — Boşluk/spacing değerleri
  * `DSTypo` — Tipografi stilleri
  * `Strings` — Metin sabitleri
* **Bileşenler:**

  * `DSErrorView`, `DSListEmptyView` gibi tekrar kullanılabilir UI komponentleri.
* **Mod:**

  * `Info.plist` üzerinden `UIUserInterfaceStyle` ayarı ile varsayılan **Dark Mode**.

Bu yapı, tüm ekranlarda tutarlı ve ölçeklenebilir bir görünüm sağlar.

---

## Bağımlılıklar

Uygulama, Swift Package Manager (SPM) ile yönetilen minimal ve odaklı bir bağımlılık seti kullanır:

* **WordKit**
  Harici kelime API'si ile entegrasyon sağlayan kütüphane.
  `WordKitClient` adaptörü üzerinden soyutlanır; böylece:

  * Uygulama doğrudan WordKit'e sıkı bağlı değildir,
  * Ağ katmanı gerektiğinde kolayca değiştirilebilir.

---

## Test Altyapısı

Lingoverse; birim testler ve UI testleri ile desteklenmektedir.

### Birim Testleri (`LingoverseTests`)

* **RecentSearchRepositoryTests**

  * Arama terimlerinin küçük harfe çevrilmesini,
  * Tekrar eden kayıtların yönetimini,
  * Silme işlemlerinin doğruluğunu test eder.
* **FavoritesRepositoryTests**

  * Favoriye ekleme, silme,
  * `isFavorite` kontrollerini doğrular.
* **SearchPresenterTests**

  * `MockSearchInteractor`, `MockSearchView` kullanarak:

    * Presenter'ın durum yönetimini,
    * Doğru state'in doğru senaryoda View'a iletilmesini test eder.

### UI Testleri (`LingoverseUITests`)

Kritik kullanıcı akışları otomasyona bağlanmıştır:

* `testSearchIdleEmptyState`
* `testNavigationToFavorites`
* `testFavoritesEmptyState`
* `testSearchBarIsTypable`

### Launch Testi

* `LingoverseUITestsLaunchTests`, uygulamanın başarıyla başlatılabildiğini doğrular.


