<div align="center">

# Lingoverse

<img src="https://github.com/CanSagnak1/TGY-HOMEWORK/raw/main/%C3%96devler/Lingoverse/Lingoverse/Sources/DesignSystem/Assets.xcassets/AppIcon.appiconset/180.png" alt="Lingoverse Icon" width="160"/>

**Lingoverse**, yapay zeka destekli AR teknolojisi, oyunlaştırılmış öğrenme modülleri ve hibrit sözlük yapısı ile zenginleştirilmiş, VIPER mimarisi üzerine kurulu modern bir iOS dil öğrenme asistanıdır.

</div>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS_16.0+-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Language-Swift_5-orange.svg" alt="Language">
  <img src="https://img.shields.io/badge/Architecture-VIPER-purple.svg" alt="Architecture">
  <img src="https://img.shields.io/badge/Framework-ARKit_&_CoreML-red.svg" alt="ARKit">
  <img src="https://img.shields.io/badge/UI-UIKit_(Programmatic)-green.svg" alt="UI">
  <img src="https://img.shields.io/badge/Dependencies-SPM_&_LFS-brightgreen.svg" alt="SPM">
  <img src="https://img.shields.io/badge/Version-2.0-red.svg" alt="Version">
</p>

---

## 🌟 Genel Bakış

Lingoverse, klasik sözlük deneyimini modern teknolojilerle birleştirir. Sadece kelime aramakla kalmaz, çevrenizdeki nesneleri **AR (Artırılmış Gerçeklik)** ile tarayıp öğrenmenizi, 5 farklı **Mini Oyun** ile eğlenerek pekiştirmenizi ve **Yapay Zeka** destekli çeviri ile dil bariyerlerini aşmanızı sağlar.

Clean Architecture (VIPER) prensiplerine sıkı sıkıya bağlı kalarak geliştirilmiş olup, test edilebilir, modüler ve ölçeklenebilir bir yapıya sahiptir.

---

## 🚀 Öne Çıkan Özellikler

### 1. 📷 AR Scanner (YENİ)
Gerçek dünyayı dil öğrenme ortamına dönüştürün.
*   **Nesne Tanıma:** YOLOv3 CoreML modeli ile kameradaki nesneleri gerçek zamanlı (Real-time) tespit eder.
*   **Anlık Çeviri:** Tespit edilen nesnenin ismini Google Translate API entegrasyonu ile anlık olarak çevirir (TR <-> EN).
*   **AR Overlay:** Nesnelerin üzerine AR etiketleri yerleştirerek interaktif bir deneyim sunar.
*   **Snap & Save:** Tespit edilen kelimeleri tek dokunuşla favorilerinize ekleyin.

### 2. 🎮 Mini Games Hub (YENİ)
Öğrenmeyi eğlenceli hale getiren 5 farklı oyun modu:
*   **Hangman (Adam Asmaca):** Klasik kelime tahmin oyunu.
*   **Word Hunt (Kelime Avı):** Karışık harfler arasından doğru kelimeleri bulma.
*   **Memory Match:** Eşleştirme oyunu ile görsel hafızayı güçlendirme.
*   **Speed Fire:** Zamana karşı kelime bilme yarışı.
*   **Word Chain:** Kelime türeterek zincir oluşturma.
*   *Tüm oyunlar `MiniGameProgressManager` ile global XP ve Level sistemine entegredir.*

### 3. 🌐 Hibrit Sözlük Sistemi (YENİ)
Dil bariyerlerini ortadan kaldıran akıllı arama motoru.
*   **Akıllı Dil Tespiti:** Aranan kelimenin Türkçe mi İngilizce mi olduğunu otomatik algılar.
*   **Çift API Desteği:**
    *   🇹🇷 **Türkçe:** TDK (Türk Dil Kurumu) API entegrasyonu.
    *   🇬🇧 **İngilizce:** WordKit API entegrasyonu.
*   **Google Translate Fallback:** API'lerde bulunamayan kelimeler veya cümleler için Google Translate servisi otomatik devreye girer.

### 4. 🗣️ Speech Services (YENİ)
*   **Text-to-Speech (TTS):** Kelimelerin ve cümlelerin doğal telaffuzlarını dinleyin.
*   **Speech-to-Text (STT):** Yazmak yerine konuşarak arama yapın (Voice Search).

### 5. 🌍 Tam Yerelleştirme (Localization)
*   Uygulama tamamen **Türkçe** ve **İngilizce** dillerini destekler.
*   Cihaz diline göre otomatik uyum sağlar veya ayarlar menüsünden manuel değiştirilebilir.

---

## 📱 Temel Modüller

### Öğrenme (Learn) Modülü
*   **Flashcards:** 3D flip animasyonlu kelime kartları.
*   **Quiz:** İlerleme takipli, çoktan seçmeli testler.
*   **İstatistikler:** Günlük streak, toplam öğrenilen kelime ve XP takibi.

### Arama (Search) & Detay
*   Son aramalar (Recent Searches) geçmişi.
*   Kelime türleri (Noun, Verb vb.) ve fonetik okunuşlar.
*   Eş anlamlılar (Synonyms) ve örnek cümleler.

### Onboarding & Splash
*   Animasyonlu tanıtım ekranları.
*   Video arkaplanlı dinamik açılış ekranı.

---

## 🛠 Teknik Altyapı ve Mimari

Proje **VIPER (View - Interactor - Presenter - Entity - Router)** mimarisi ile geliştirilmiş olup, SOLID prensiplerine tam uyumluluk gösterir.

### Teknoloji Yığını
*   **Dil:** Swift 5.9
*   **UI:** UIKit (Tamamen Programmatic UI - No Storyboards)
*   **AI & ML:** CoreML, Vision (YOLOv3 Object Detection)
*   **AR:** ARKit, SpriteKit
*   **Audio:** AVFoundation (TTS), Speech (STT)
*   **Network:** URLSession, Generic Service Layer
*   **Storage:** UserDefaults, FileManager
*   **Design Pattern:** VIPER, Repository Pattern, Singleton, Delegate

### Tasarım Sistemi (Design System)
`Sources/DesignSystem` altında merkezi bir tasarım dili oluşturulmuştur:
*   **ThemeManager:** Dinamik Dark/Light mod desteği.
*   **Components:** Tekrar kullanılabilir UI bileşenleri (`DSButton`, `DSCard`, `DSEmptyView`).
*   **Typography & Colors:** Merkezi font ve renk yönetimi.

---

## 📦 Kurulum ve Çalıştırma

Bu projede büyük yapay zeka modelleri (ML Models) bulunduğu için **Git Large File Storage (LFS)** kullanılmaktadır.

### Gereksinimler
*   iOS 16.0+
*   Xcode 15.0+
*   Git LFS

### Adım Adım Kurulum

1.  **Git LFS'i Yükleyin (Eğer yüklü değilse):**
    ```bash
    brew install git-lfs
    git lfs install
    ```

2.  **Projeyi Klonlayın:**
    ```bash
    git clone https://github.com/CanSagnak1/Lingoverse.git
    cd Lingoverse
    ```

3.  **LFS Dosyalarını Çekin:**
    ```bash
    git lfs pull
    ```

4.  **Projeyi Açın:**
    ```bash
    open Lingoverse.xcodeproj
    ```
    *Paket bağımlılıklarının (SPM) yüklenmesini bekleyin ve ardından projeyi çalıştırın.*

---

## 🧪 Testler

Proje kapsamlı Unit ve UI testleri içerir. `Cmd+U` ile tüm testleri çalıştırabilirsiniz.
*   **Unit Tests:** Repository, Interactor ve Presenter katmanları için mantık testleri.
*   **UI Tests:** Kritik kullanıcı akışları (Search, Favorites) için otomasyon testleri.

---

## 📄 Lisans

Bu proje MIT lisansı ile lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakınız.
