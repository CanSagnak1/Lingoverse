//
//  Strings.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 3.11.2025.
//

import Foundation

public enum Strings {

    // MARK: - Private Localization Dictionary
    private static var englishStrings: [String: String] = [
        // Tab Bar
        "tab.search": "Search",
        "tab.favorites": "Favorites",
        "tab.learn": "Learn",
        "tab.settings": "Settings",

        // Search Screen
        "search.title": "Search",
        "search.placeholder": "Search for a word…",
        "search.headerRecent": "Recent Searches",
        "search.hintStart": "Start searching or browse your recent searches.",
        "search.hintNoRecent": "You have no recent searches.",
        "search.button": "Search",

        // Favorites Screen
        "favorites.title": "Favorites",
        "favorites.hintNoFavorites":
            "You have no favorited words yet.\nAdd words from the recent search list.",
        "favorites.tapToView": "Tap to view definition",
        "favorites.savedWords": "%d saved words",
        "favorites.savedWord": "1 saved word",

        // Search Detail
        "detail.synonyms": "Synonyms",
        "detail.definition": "Definition",
        "detail.example": "Example",
        "detail.sharedVia": "— Shared via Lingoverse 📖",

        // Part of Speech
        "partOfSpeech.noun": "Noun",
        "partOfSpeech.verb": "Verb",
        "partOfSpeech.adjective": "Adjective",
        "partOfSpeech.adverb": "Adverb",
        "partOfSpeech.pronoun": "Pronoun",
        "partOfSpeech.preposition": "Preposition",
        "partOfSpeech.conjunction": "Conjunction",
        "partOfSpeech.interjection": "Interjection",
        "partOfSpeech.determiner": "Determiner",
        "partOfSpeech.exclamation": "Exclamation",

        // Actions
        "action.favorite": "Favorite",
        "action.delete": "Delete",
        "action.retry": "Try again",
        "action.cancel": "Cancel",
        "action.ok": "OK",
        "action.done": "Done",

        // Errors
        "error.generic": "Something went wrong.\nCheck your connection and try again.",
        "error.internetConnection": "Internet connection not found. Please check your connection.",
        "error.notFound": "Word not found.",
        "error.title": "Error",
        "error.notEnoughWords": "Not enough words with definitions",
        "error.definitionNotFound": "Definition not found",
        "error.failedToLoad": "Failed to load definition",
        "error.definitionNotAvailable": "Definition not available",

        // Settings
        "settings.title": "Settings",
        "settings.section.appearance": "Appearance",
        "settings.section.language": "Language",
        "settings.section.general": "General",
        "settings.section.data": "Data",
        "settings.section.legal": "Legal",
        "settings.section.about": "About",
        "settings.theme": "Theme",
        "settings.language": "Language",
        "settings.showOnboarding": "Show Onboarding",
        "settings.clearCache": "Clear Cache",
        "settings.version": "Version",
        "settings.selectLanguage": "Select Language",
        "settings.restartRequired": "App Restart Required",
        "settings.restartMessage": "The app needs to restart to apply the language change.",
        "settings.restartNow": "Restart Now",

        // Legal
        "legal.privacyPolicy": "Privacy Policy",
        "legal.termsOfUse": "Terms of Use",
        "legal.acknowledgements": "Acknowledgements",

        // Onboarding
        "onboarding.next": "Next",
        "onboarding.skip": "Skip",
        "onboarding.getStarted": "Get Started",
        "onboarding.searchWords.title": "Search Words",
        "onboarding.searchWords.description":
            "Search for English or Turkish words instantly and get comprehensive definitions, phonetics, and examples.",
        "onboarding.learn.title": "Learn & Practice",
        "onboarding.learn.description":
            "Master new vocabulary with interactive Flashcards and Quizzes.",
        "onboarding.pronunciation.title": "Listen to Pronunciation",
        "onboarding.pronunciation.description":
            "Hear the correct pronunciation of words with built-in audio playback.",
        "onboarding.favorites.title": "Save Favorites",
        "onboarding.favorites.description":
            "Build your personal vocabulary by saving words to your favorites list for quick access.",
        "onboarding.recentSearches.title": "Recent Searches",
        "onboarding.recentSearches.description":
            "Never lose track of your searches. Access your recent lookups anytime.",
        "onboarding.offline.title": "Fast & Offline",
        "onboarding.offline.description":
            "Lightning-fast searches with offline caching. Previously searched words work without internet.",
        "onboarding.profile.title": "Profile & Badges",
        "onboarding.profile.description":
            "Track your progress, keep your streak alive, and earn badges as you learn.",
        "onboarding.swipeNavigation.title": "Swipe to Navigate",
        "onboarding.swipeNavigation.description":
            "Swipe left or right on flashcards to navigate between words quickly.",
        "onboarding.tapToFlip.title": "Tap to Reveal",
        "onboarding.tapToFlip.description":
            "Tap on a flashcard to flip it and see the definition on the other side.",
        "onboarding.swipeToDelete.title": "Swipe to Manage",
        "onboarding.swipeToDelete.description":
            "Swipe left on any favorite word to quickly remove it from your collection.",

        // Learn
        "learn.title": "Learn",
        "learn.flashcards": "Flashcards",
        "learn.flashcardsSubtitle": "Flip cards to learn definitions",
        "learn.quiz": "Quiz",
        "learn.quizSubtitle": "Test your knowledge",
        "learn.statistics": "Statistics",
        "learn.statisticsSubtitle": "Track your progress",
        "learn.emptyState": "Add words to favorites to start learning!",
        "learn.wordsToPractice": "You have %d words to practice",

        // Flashcard
        "flashcard.word": "WORD",
        "flashcard.definition": "DEFINITION",
        "flashcard.tapToFlip": "Tap card to flip",
        "flashcard.previous": "Previous",
        "flashcard.next": "Next",

        // Quiz
        "quiz.score": "Score: %d",
        "quiz.questionPrompt": "What does this word mean?",
        "quiz.playAgain": "Play Again",
        "quiz.excellent": "Excellent!",
        "quiz.excellentMessage": "You're a vocabulary master!",
        "quiz.goodJob": "Good Job!",
        "quiz.goodJobMessage": "Keep practicing to improve!",
        "quiz.keepLearning": "Keep Learning!",
        "quiz.keepLearningMessage": "Review your flashcards and try again.",

        // Stats
        "stats.title": "Statistics",
        "stats.yourProgress": "Your Progress",
        "stats.quizAccuracy": "Quiz Accuracy",
        "stats.streakDays": "Streak Days",
        "stats.flashcardSessions": "Flashcard Sessions",
        "stats.quizSessions": "Quiz Sessions",
        "stats.correctAnswers": "Correct Answers",
        "stats.totalQuestions": "Total Questions",
        "stats.resetProgress": "Reset Progress",
        "stats.resetConfirmTitle": "Reset Progress",
        "stats.resetConfirmMessage":
            "This will reset all your learning statistics. This action cannot be undone.",
        "stats.reset": "Reset",
        "stats.motivation.streak":
            "Amazing! You've been practicing for %d days straight. Keep up the great work!",
        "stats.motivation.accuracy": "Excellent accuracy! You're mastering these words quickly.",
        "stats.motivation.questions": "You've answered %d questions! Practice makes perfect.",
        "stats.motivation.flashcards":
            "Great job reviewing flashcards! Try the quiz to test your knowledge.",
        "stats.motivation.default":
            "Start with flashcards to learn new words, then test yourself with quizzes!",
        "stats.totalXP": "Total XP",
        "stats.section.learning": "Learning",
        "stats.section.learningSubtitle": "Flashcards & Quizzes",
        "stats.section.minigames": "Mini Games",
        "stats.section.minigamesSubtitle": "All game stats",
        "stats.section.achievements": "Achievements",
        "stats.section.achievementsSubtitle": "Best performances",
        "stats.quick.accuracy": "Accuracy",
        "stats.quick.questions": "Questions",
        "stats.quick.correct": "Correct",
        "stats.row.flashcardSessions": "Flashcard Sessions",
        "stats.row.quizSessions": "Quiz Sessions",
        "stats.row.dailyStreak": "Daily Streak",
        "stats.game.bestScore": "Best",
        "stats.game.points": "%@ points",
        "stats.game.fewestMoves": "Fewest Moves",
        "stats.game.longestChain": "Longest Chain",
        "stats.game.winRate": "Win Rate",
        "stats.game.bestCombo": "Best Combo",
        "stats.empty.minigames":
            "You haven't played any mini games yet.\nStart from Learn > Mini Games!",
        "stats.empty.achievements": "Play more to unlock achievements!",
        "achievement.quizMaster": "Quiz Master",
        "achievement.streakRecord": "Streak Record",
        "achievement.gameXP": "Game XP",
        "achievement.favoriteGame": "Favorite Game",
        "achievement.comboMaster": "Combo Master",
        "achievement.accuracy": "%.0f%% accuracy",
        "stats.sessions": "%d sessions",
        // Profile
        "profile.title": "Profile",
        "profile.streak": "streak",
        "profile.badges": "Badges",
        "profile.level": "Level %d",  // "Level 5"
        "profile.streakDays": "%d Day",  // "5 Day"
        "profile.streakSubtitle": "Daily Streak",

        // Badges
        // Badges
        "badge.first_step.title": "First Step",
        "badge.first_step.desc": "Welcome to Lingoverse!",
        "badge.streak_7.title": "Week Warrior",
        "badge.streak_7.desc": "You studied for 7 days straight.",
        "badge.streak_30.title": "Monthly Legend",
        "badge.streak_30.desc": "You learned for 30 days without stopping!",
        "badge.xp_100.title": "Apprentice",
        "badge.xp_100.desc": "You reached 100 XP.",
        "badge.xp_1000.title": "Master",
        "badge.xp_1000.desc": "You crossed the 1000 XP mark.",
        "badge.xp_5000.title": "Sage",
        "badge.xp_5000.desc": "You are at the top with 5000 XP.",
        "badge.quiz_master.title": "Quiz Master",
        "badge.quiz_master.desc": "You completed a quiz perfectly.",

        // Mini Games
        "minigames.title": "Mini Games",
        "minigames.subtitle": "Have fun while learning!",
        "minigames.availableWords": "%d words available",
        "minigames.needWords": "Need %d words to play",
        "minigames.minWordsShort": "Min %d Words",
        "minigames.headerTitle": "Champions Arena",
        "minigames.headerSubtitle": "Test your vocabulary, break new records!",
        "minigames.learnedWords": "%d Learned Words",
        "minigames.needMore": "Need %d more",

        // Word Hunt
        "wordhunt.title": "Word Hunt",
        "wordhunt.subtitle": "Find hidden words in the grid",
        "wordhunt.found": "Found: %d/%d",
        "wordhunt.instruction": "Tap letters to form a word",

        // Matching
        "matching.title": "Matching",
        "matching.subtitle": "Match words with definitions",
        "matching.moves": "Moves: %d",
        "matching.pairs": "Pairs: %d/%d",

        // Word Chain
        "wordchain.title": "Word Chain",
        "wordchain.subtitle": "Continue the word chain",
        "wordchain.lastLetter": "Start with: %@",
        "wordchain.chainLength": "Chain: %d",
        "wordchain.yourTurn": "Your turn!",
        "wordchain.hint": "Hint",

        // Hangman
        "hangman.title": "Hangman",
        "hangman.subtitle": "Guess the hidden word",
        "hangman.lives": "%d lives",
        "hangman.hint": "Hint: %@",
        "hangman.won": "You Won!",
        "hangman.lost": "Game Over",

        // Speed Fire
        "speedfire.title": "Speed Fire",
        "speedfire.subtitle": "60 seconds challenge!",
        "speedfire.combo": "%dx Combo!",
        "speedfire.true": "TRUE",
        "speedfire.false": "FALSE",
        "speedfire.isThisCorrect": "Is this definition correct?",

        // Common Game
        "game.score": "Score: %d",
        "game.timeUp": "Time's Up!",
        "game.xpEarned": "+%d XP",
        "game.playAgain": "Play Again",
        "game.excellent": "Excellent!",
        "game.excellentMessage": "You're a vocabulary champion!",
        "game.greatJob": "Great Job!",
        "game.greatJobMessage": "Keep practicing to improve!",
        "game.keepTrying": "Keep Trying!",
        "game.keepTryingMessage": "Practice makes perfect.",

        // AR Scanner
        "tab.arScanner": "AR Scanner",
        "ar.title": "AR Scanner",
        "ar.scanButton": "Scan",
        "ar.scanning": "Scanning...",
        "ar.noObjectDetected": "No object detected.",
        "ar.cameraPermissionDenied": "Camera access denied.",
        "ar.instruction": "Scan to recognize objects",
        "ar.searchingObjects": "Searching for objects...",
        "ar.objectsDetected": "%d object(s) detected",
        "ar.detectedObjects": "Detected Objects",
        "ar.tryAgain": "Try again",
    ]

    private static var turkishStrings: [String: String] = [
        // Tab Bar
        "tab.search": "Ara",
        "tab.favorites": "Favoriler",
        "tab.learn": "Öğren",
        "tab.settings": "Ayarlar",

        // Search Screen
        "search.title": "Ara",
        "search.placeholder": "Bir kelime arayın…",
        "search.headerRecent": "Son Aramalar",
        "search.hintStart": "Aramaya başlayın veya son aramalarınıza göz atın.",
        "search.hintNoRecent": "Son aramanız bulunmuyor.",
        "search.button": "Ara",

        // Favorites Screen
        "favorites.title": "Favoriler",
        "favorites.hintNoFavorites":
            "Henüz favori kelimeniz yok.\nSon aramalar listesinden kelime ekleyin.",
        "favorites.tapToView": "Tanımı görmek için dokunun",
        "favorites.savedWords": "%d kayıtlı kelime",
        "favorites.savedWord": "1 kayıtlı kelime",

        // Search Detail
        "detail.synonyms": "Eş Anlamlılar",
        "detail.definition": "Tanım",
        "detail.example": "Örnek",
        "detail.sharedVia": "— Lingoverse ile paylaşıldı 📖",

        // Part of Speech
        "partOfSpeech.noun": "İsim",
        "partOfSpeech.verb": "Fiil",
        "partOfSpeech.adjective": "Sıfat",
        "partOfSpeech.adverb": "Zarf",
        "partOfSpeech.pronoun": "Zamir",
        "partOfSpeech.preposition": "Edat",
        "partOfSpeech.conjunction": "Bağlaç",
        "partOfSpeech.interjection": "Ünlem",
        "partOfSpeech.determiner": "Belirteç",
        "partOfSpeech.exclamation": "Ünlem",

        // Actions
        "action.favorite": "Favori",
        "action.delete": "Sil",
        "action.retry": "Tekrar dene",
        "action.cancel": "İptal",
        "action.ok": "Tamam",
        "action.done": "Bitti",

        // Errors
        "error.generic": "Bir şeyler yanlış gitti.\nBağlantınızı kontrol edip tekrar deneyin.",
        "error.internetConnection":
            "İnternet bağlantısı bulunamadı. Lütfen bağlantınızı kontrol edin.",
        "error.notFound": "Kelime bulunamadı.",
        "error.title": "Hata",
        "error.notEnoughWords": "Tanımları olan yeterli kelime yok",
        "error.definitionNotFound": "Tanım bulunamadı",
        "error.failedToLoad": "Tanım yüklenemedi",
        "error.definitionNotAvailable": "Tanım mevcut değil",

        // Settings
        "settings.title": "Ayarlar",
        "settings.section.appearance": "Görünüm",
        "settings.section.language": "Dil",
        "settings.section.general": "Genel",
        "settings.section.data": "Veri",
        "settings.section.legal": "Yasal",
        "settings.section.about": "Hakkında",
        "settings.theme": "Tema",
        "settings.language": "Dil",
        "settings.showOnboarding": "Tanıtımı Göster",
        "settings.clearCache": "Önbelleği Temizle",
        "settings.version": "Sürüm",
        "settings.selectLanguage": "Dil Seçin",
        "settings.restartRequired": "Uygulama Yeniden Başlatılmalı",
        "settings.restartMessage":
            "Dil değişikliğini uygulamak için uygulamanın yeniden başlatılması gerekiyor.",
        "settings.restartNow": "Şimdi Yeniden Başlat",

        // Legal
        "legal.privacyPolicy": "Gizlilik Politikası",
        "legal.termsOfUse": "Kullanım Koşulları",
        "legal.acknowledgements": "Teşekkürler",

        // Onboarding
        "onboarding.next": "İleri",
        "onboarding.skip": "Atla",
        "onboarding.getStarted": "Başla",
        "onboarding.searchWords.title": "Kelime Arayın",
        "onboarding.searchWords.description":
            "İngilizce veya Türkçe kelimeleri anında arayın; kapsamlı tanımlar, fonetikler ve örnekler alın.",
        "onboarding.learn.title": "Öğren ve Pratik Yap",
        "onboarding.learn.description":
            "İnteraktif Kartlar ve Testlerle yeni kelimelerde ustalaşın.",
        "onboarding.pronunciation.title": "Telaffuzu Dinleyin",
        "onboarding.pronunciation.description":
            "Yerleşik ses çalma özelliğiyle kelimelerin doğru telaffuzunu duyun.",
        "onboarding.favorites.title": "Favorilere Kaydedin",
        "onboarding.favorites.description":
            "Hızlı erişim için kelimeleri favoriler listenize kaydederek kişisel kelime dağarcığınızı oluşturun.",
        "onboarding.recentSearches.title": "Son Aramalar",
        "onboarding.recentSearches.description":
            "Aramalarınızın izini asla kaybetmeyin. Son aramalarınıza istediğiniz zaman erişin.",
        "onboarding.offline.title": "Hızlı ve Çevrimdışı",
        "onboarding.offline.description":
            "Çevrimdışı önbellek ile yıldırım hızında aramalar. Daha önce aranan kelimeler internet olmadan da çalışır.",
        "onboarding.profile.title": "Profil ve Rozetler",
        "onboarding.profile.description":
            "İlerlemeni takip et, serini canlı tut ve öğrenirken rozetler kazan.",
        "onboarding.swipeNavigation.title": "Kaydırarak Gezin",
        "onboarding.swipeNavigation.description":
            "Kelimeler arasında hızlıca gezinmek için kartları sola veya sağa kaydırın.",
        "onboarding.tapToFlip.title": "Dokunarak Çevir",
        "onboarding.tapToFlip.description":
            "Kartın diğer tarafındaki tanımı görmek için karta dokunun.",
        "onboarding.swipeToDelete.title": "Kaydırarak Yönetin",
        "onboarding.swipeToDelete.description":
            "Bir kelimeyi koleksiyonunuzdan hızlıca kaldırmak için sola kaydırın.",

        // Learn
        "learn.title": "Öğren",
        "learn.flashcards": "Kartlar",
        "learn.flashcardsSubtitle": "Tanımları öğrenmek için kartları çevirin",
        "learn.quiz": "Test",
        "learn.quizSubtitle": "Bilginizi test edin",
        "learn.statistics": "İstatistikler",
        "learn.statisticsSubtitle": "İlerlemenizi takip edin",
        "learn.emptyState": "Öğrenmeye başlamak için favorilere kelime ekleyin!",
        "learn.wordsToPractice": "Pratik yapacak %d kelimeniz var",

        // Flashcard
        "flashcard.word": "KELİME",
        "flashcard.definition": "TANIM",
        "flashcard.tapToFlip": "Çevirmek için dokunun",
        "flashcard.previous": "Önceki",
        "flashcard.next": "Sonraki",

        // Quiz
        "quiz.score": "Puan: %d",
        "quiz.questionPrompt": "Bu kelimenin anlamı nedir?",
        "quiz.playAgain": "Tekrar Oyna",
        "quiz.excellent": "Mükemmel!",
        "quiz.excellentMessage": "Kelime ustasısınız!",
        "quiz.goodJob": "Aferin!",
        "quiz.goodJobMessage": "Gelişmek için pratik yapmaya devam edin!",
        "quiz.keepLearning": "Öğrenmeye Devam!",
        "quiz.keepLearningMessage": "Kartlarınızı gözden geçirin ve tekrar deneyin.",

        // Stats
        "stats.title": "İstatistikler",
        "stats.yourProgress": "İlerlemeniz",
        "stats.quizAccuracy": "Test Doğruluğu",
        "stats.streakDays": "Seri Günü",
        "stats.flashcardSessions": "Kart Oturumları",
        "stats.quizSessions": "Test Oturumları",
        "stats.correctAnswers": "Doğru Cevaplar",
        "stats.totalQuestions": "Toplam Sorular",
        "stats.resetProgress": "İlerlemeyi Sıfırla",
        "stats.resetConfirmTitle": "İlerlemeyi Sıfırla",
        "stats.resetConfirmMessage":
            "Bu, tüm öğrenme istatistiklerinizi sıfırlayacak. Bu işlem geri alınamaz.",
        "stats.reset": "Sıfırla",
        "stats.motivation.streak":
            "Muhteşem! %d gündür aralıksız pratik yapıyorsunuz. Harika gidiyorsunuz!",
        "stats.motivation.accuracy": "Mükemmel doğruluk! Bu kelimeleri hızla öğreniyorsunuz.",
        "stats.motivation.questions": "%d soruyu cevapladınız! Pratik mükemmelleştirir.",
        "stats.motivation.flashcards":
            "Kartları inceleme konusunda harika iş çıkardınız! Bilginizi test etmek için teste katılın.",
        "stats.motivation.default":
            "Yeni kelimeler öğrenmek için kartlarla başlayın, sonra testlerle kendinizi sınayın!",
        "stats.totalXP": "Toplam XP",
        "stats.section.learning": "Öğrenme",
        "stats.section.learningSubtitle": "Kartlar & Sınavlar",
        "stats.section.minigames": "Mini Oyunlar",
        "stats.section.minigamesSubtitle": "Tüm oyun istatistikleri",
        "stats.section.achievements": "Başarılar",
        "stats.section.achievementsSubtitle": "En iyi performanslar",
        "stats.quick.accuracy": "Doğruluk",
        "stats.quick.questions": "Soru",
        "stats.quick.correct": "Doğru",
        "stats.row.flashcardSessions": "Kart Oturumları",
        "stats.row.quizSessions": "Sınav Oturumları",
        "stats.row.dailyStreak": "Günlük Seri",
        "stats.game.bestScore": "En İyi",
        "stats.game.points": "%@ puan",
        "stats.game.fewestMoves": "En Az Hamle",
        "stats.game.longestChain": "En Uzun Zincir",
        "stats.game.winRate": "Kazanma Oranı",
        "stats.game.bestCombo": "En İyi Kombo",
        "stats.empty.minigames": "Henüz mini oyun oynamadınız.\nLearn > Mini Games'den başlayın!",
        "stats.empty.achievements": "Daha fazla oynayarak başarılar kazanın!",
        "achievement.quizMaster": "Sınav Ustası",
        "achievement.streakRecord": "Seri Rekoru",
        "achievement.gameXP": "Oyun XP'si",
        "achievement.favoriteGame": "Favori Oyun",
        "achievement.comboMaster": "Kombo Ustası",
        "achievement.accuracy": "%.0f%% doğruluk",
        "stats.sessions": "%d oturum",
        // Profile
        "profile.title": "Profil",
        "profile.streak": "seri",
        "profile.badges": "Rozetler",
        "profile.level": "Seviye %d",
        "profile.streakDays": "%d Gün",
        "profile.streakSubtitle": "Günlük Seri",

        // Badges
        "badge.first_step.title": "İlk Adım",
        "badge.first_step.desc": "Lingoverse'e hoş geldin!",
        "badge.streak_7.title": "Haftalık Savaşçı",
        "badge.streak_7.desc": "7 gün boyunca aralıksız çalıştın.",
        "badge.streak_30.title": "Aylık Efsane",
        "badge.streak_30.desc": "30 gün boyunca durmadan öğrendin!",
        "badge.xp_100.title": "Çırak",
        "badge.xp_100.desc": "100 XP'ye ulaştın.",
        "badge.xp_1000.title": "Usta",
        "badge.xp_1000.desc": "1000 XP barajını aştın.",
        "badge.xp_5000.title": "Bilge",
        "badge.xp_5000.desc": "5000 XP ile zirvedesin.",
        "badge.quiz_master.title": "Quiz Ustası",
        "badge.quiz_master.desc": "Bir quiz'i hatasız tamamladın.",

        // Mini Games
        "minigames.title": "Mini Oyunlar",
        "minigames.subtitle": "Eğlenerek öğren!",
        "minigames.availableWords": "%d kelime mevcut",
        "minigames.needWords": "Oynamak için %d kelime gerekli",
        "minigames.minWordsShort": "Min %d Kelime",
        "minigames.headerTitle": "Şampiyonlar Arenası",
        "minigames.headerSubtitle": "Kelime bilgini teste tabi tut, yeni rekorlar kır!",
        "minigames.learnedWords": "%d Öğrenilen Kelime",
        "minigames.needMore": "%d Kelime eksik",

        // Word Hunt
        "wordhunt.title": "Kelime Avı",
        "wordhunt.subtitle": "Gizli kelimeleri bul",
        "wordhunt.found": "Bulunan: %d/%d",
        "wordhunt.instruction": "Kelime oluşturmak için harflere dokun",

        // Matching
        "matching.title": "Eşleştirme",
        "matching.subtitle": "Kelimeleri tanımlarla eşleştir",
        "matching.moves": "Hamle: %d",
        "matching.pairs": "Çift: %d/%d",

        // Word Chain
        "wordchain.title": "Kelime Zinciri",
        "wordchain.subtitle": "Kelime zincirini sürdür",
        "wordchain.lastLetter": "Şu harfle başla: %@",
        "wordchain.chainLength": "Zincir: %d",
        "wordchain.yourTurn": "Senin sıran!",
        "wordchain.hint": "İpucu",

        // Hangman
        "hangman.title": "Adam Asmaca",
        "hangman.subtitle": "Gizli kelimeyi tahmin et",
        "hangman.lives": "%d can",
        "hangman.hint": "İpucu: %@",
        "hangman.won": "Kazandın!",
        "hangman.lost": "Oyun Bitti",

        // Speed Fire
        "speedfire.title": "Hızlı Ateş",
        "speedfire.subtitle": "60 saniye meydan okuması!",
        "speedfire.combo": "%dx Kombo!",
        "speedfire.true": "DOĞRU",
        "speedfire.false": "YANLIŞ",
        "speedfire.isThisCorrect": "Bu tanım doğru mu?",

        // Common Game
        "game.score": "Puan: %d",
        "game.timeUp": "Süre Doldu!",
        "game.xpEarned": "+%d XP",
        "game.playAgain": "Tekrar Oyna",
        "game.excellent": "Mükemmel!",
        "game.excellentMessage": "Kelime şampiyonusun!",
        "game.greatJob": "Harika!",
        "game.greatJobMessage": "Gelişmek için pratik yapmaya devam et!",
        "game.keepTrying": "Denemeye Devam!",
        "game.keepTryingMessage": "Pratik mükemmelleştirir.",

        // AR Scanner
        "tab.arScanner": "AR Tarayıcı",
        "ar.title": "AR Tarayıcı",
        "ar.scanButton": "Tara",
        "ar.scanning": "Taranıyor...",
        "ar.noObjectDetected": "Nesne tespit edilemedi.",
        "ar.cameraPermissionDenied": "Kamera erişimi reddedildi.",
        "ar.instruction": "Nesneleri tanımak için tarama yapın",
        "ar.searchingObjects": "Nesneler aranıyor...",
        "ar.objectsDetected": "%d nesne tespit edildi",
        "ar.detectedObjects": "Tespit Edilen Nesneler",
        "ar.tryAgain": "Tekrar deneyin",
    ]

    private static func localizedString(_ key: String) -> String {
        let strings =
            LocalizationManager.shared.currentLanguage == .turkish ? turkishStrings : englishStrings
        // Fallback for missing keys in Turkish (should be rare with good process)
        if strings[key] == nil && LocalizationManager.shared.currentLanguage == .turkish {
            return englishStrings[key] ?? key
        }
        return strings[key] ?? key
    }

    // MARK: - Tab Bar
    static var tabSearch: String { localizedString("tab.search") }
    static var tabFavorites: String { localizedString("tab.favorites") }
    static var tabLearn: String { localizedString("tab.learn") }
    static var tabSettings: String { localizedString("tab.settings") }

    // MARK: - Search
    static var title: String { localizedString("search.title") }
    static var searchPlaceholder: String { localizedString("search.placeholder") }
    static var headerRecent: String { localizedString("search.headerRecent") }
    static var hintStart: String { localizedString("search.hintStart") }
    static var hintNoRecent: String { localizedString("search.hintNoRecent") }
    static var searchButton: String { localizedString("search.button") }

    // MARK: - Favorites
    static var favoritesTitle: String { localizedString("favorites.title") }
    static var hintNoFavorites: String { localizedString("favorites.hintNoFavorites") }
    static var favoriteTapHint: String { localizedString("favorites.tapToView") }
    static func savedWordsCount(_ count: Int) -> String {
        count == 1
            ? localizedString("favorites.savedWord")
            : String(format: localizedString("favorites.savedWords"), count)
    }

    // MARK: - Search Detail
    static var synonymsText: String { localizedString("detail.synonyms") }
    static var definitionText: String { localizedString("detail.definition") }
    static var exampleText: String { localizedString("detail.example") }
    static var sharedVia: String { localizedString("detail.sharedVia") }

    // MARK: - Part of Speech
    static func localizedPartOfSpeech(_ partOfSpeech: String) -> String {
        let key = "partOfSpeech.\(partOfSpeech.lowercased())"
        let localized = localizedString(key)
        // If no localization found (key returned as-is), return the original capitalized
        return localized == key ? partOfSpeech.capitalized : localized
    }

    // MARK: - Actions
    static var favoriteActionTitle: String { localizedString("action.favorite") }
    static var deleteActionTitle: String { localizedString("action.delete") }
    static var retryButtonLabel: String { localizedString("action.retry") }
    static var cancelButton: String { localizedString("action.cancel") }
    static var okButton: String { localizedString("action.ok") }
    static var doneButton: String { localizedString("action.done") }

    // MARK: - Errors
    static var errorGeneric: String { localizedString("error.generic") }
    static var errorIntCon: String { localizedString("error.internetConnection") }
    static var errorNotFound: String { localizedString("error.notFound") }
    static var errorLabel: String { localizedString("error.title") }
    static var errorNotEnoughWords: String { localizedString("error.notEnoughWords") }
    static var errorDefinitionNotFound: String { localizedString("error.definitionNotFound") }
    static var errorFailedToLoad: String { localizedString("error.failedToLoad") }
    static var errorDefinitionNotAvailable: String {
        localizedString("error.definitionNotAvailable")
    }

    // MARK: - Settings
    static var settingsTitle: String { localizedString("settings.title") }
    static var settingsAppearance: String { localizedString("settings.section.appearance") }
    static var settingsLanguage: String { localizedString("settings.section.language") }
    static var settingsGeneral: String { localizedString("settings.section.general") }
    static var settingsData: String { localizedString("settings.section.data") }
    static var settingsLegal: String { localizedString("settings.section.legal") }
    static var settingsAbout: String { localizedString("settings.section.about") }
    static var settingsTheme: String { localizedString("settings.theme") }
    static var settingsLanguageRow: String { localizedString("settings.language") }
    static var settingsShowOnboarding: String { localizedString("settings.showOnboarding") }
    static var settingsClearCache: String { localizedString("settings.clearCache") }
    static var settingsVersion: String { localizedString("settings.version") }
    static var settingsSelectLanguage: String { localizedString("settings.selectLanguage") }
    static var settingsRestartRequired: String { localizedString("settings.restartRequired") }
    static var settingsRestartMessage: String { localizedString("settings.restartMessage") }
    static var settingsRestartNow: String { localizedString("settings.restartNow") }

    // MARK: - Legal
    static var legalPrivacyPolicy: String { localizedString("legal.privacyPolicy") }
    static var legalTermsOfUse: String { localizedString("legal.termsOfUse") }
    static var legalAcknowledgements: String { localizedString("legal.acknowledgements") }

    // MARK: - Onboarding
    static var onboardingNext: String { localizedString("onboarding.next") }
    static var onboardingSkip: String { localizedString("onboarding.skip") }
    static var onboardingGetStarted: String { localizedString("onboarding.getStarted") }
    static var onboardingSearchTitle: String { localizedString("onboarding.searchWords.title") }
    static var onboardingSearchDesc: String {
        localizedString("onboarding.searchWords.description")
    }
    static var onboardingPronunciationTitle: String {
        localizedString("onboarding.pronunciation.title")
    }
    static var onboardingPronunciationDesc: String {
        localizedString("onboarding.pronunciation.description")
    }
    static var onboardingFavoritesTitle: String { localizedString("onboarding.favorites.title") }
    static var onboardingFavoritesDesc: String {
        localizedString("onboarding.favorites.description")
    }
    static var onboardingRecentTitle: String { localizedString("onboarding.recentSearches.title") }
    static var onboardingRecentDesc: String {
        localizedString("onboarding.recentSearches.description")
    }
    static var onboardingOfflineTitle: String { localizedString("onboarding.offline.title") }
    static var onboardingOfflineDesc: String { localizedString("onboarding.offline.description") }
    static var onboardingProfileTitle: String { localizedString("onboarding.profile.title") }
    static var onboardingProfileDesc: String { localizedString("onboarding.profile.description") }
    static var onboardingLearnTitle: String { localizedString("onboarding.learn.title") }
    static var onboardingLearnDesc: String { localizedString("onboarding.learn.description") }
    static var onboardingSwipeNavigationTitle: String {
        localizedString("onboarding.swipeNavigation.title")
    }
    static var onboardingSwipeNavigationDesc: String {
        localizedString("onboarding.swipeNavigation.description")
    }
    static var onboardingTapToFlipTitle: String { localizedString("onboarding.tapToFlip.title") }
    static var onboardingTapToFlipDesc: String {
        localizedString("onboarding.tapToFlip.description")
    }
    static var onboardingSwipeToDeleteTitle: String {
        localizedString("onboarding.swipeToDelete.title")
    }
    static var onboardingSwipeToDeleteDesc: String {
        localizedString("onboarding.swipeToDelete.description")
    }

    // MARK: - Learn
    static var learnTitle: String { localizedString("learn.title") }
    static var learnFlashcards: String { localizedString("learn.flashcards") }
    static var learnFlashcardsSubtitle: String { localizedString("learn.flashcardsSubtitle") }
    static var learnQuiz: String { localizedString("learn.quiz") }
    static var learnQuizSubtitle: String { localizedString("learn.quizSubtitle") }
    static var learnStatistics: String { localizedString("learn.statistics") }
    static var learnStatisticsSubtitle: String { localizedString("learn.statisticsSubtitle") }
    static var learnEmptyState: String { localizedString("learn.emptyState") }
    static func learnWordsToPractice(_ count: Int) -> String {
        String(format: localizedString("learn.wordsToPractice"), count)
    }

    // MARK: - Flashcard
    static var flashcardWord: String { localizedString("flashcard.word") }
    static var flashcardDefinition: String { localizedString("flashcard.definition") }
    static var flashcardTapToFlip: String { localizedString("flashcard.tapToFlip") }
    static var flashcardPrevious: String { localizedString("flashcard.previous") }
    static var flashcardNext: String { localizedString("flashcard.next") }

    // MARK: - Quiz
    static func quizScore(_ score: Int) -> String {
        String(format: localizedString("quiz.score"), score)
    }
    static var quizQuestionPrompt: String { localizedString("quiz.questionPrompt") }
    static var quizPlayAgain: String { localizedString("quiz.playAgain") }
    static var quizExcellent: String { localizedString("quiz.excellent") }
    static var quizExcellentMessage: String { localizedString("quiz.excellentMessage") }
    static var quizGoodJob: String { localizedString("quiz.goodJob") }
    static var quizGoodJobMessage: String { localizedString("quiz.goodJobMessage") }
    static var quizKeepLearning: String { localizedString("quiz.keepLearning") }
    static var quizKeepLearningMessage: String { localizedString("quiz.keepLearningMessage") }

    // MARK: - Stats
    static var statsTitle: String { localizedString("stats.title") }
    static var statsYourProgress: String { localizedString("stats.yourProgress") }
    static var statsQuizAccuracy: String { localizedString("stats.quizAccuracy") }
    static var statsStreakDays: String { localizedString("stats.streakDays") }
    static var statsFlashcardSessions: String { localizedString("stats.flashcardSessions") }
    static var statsQuizSessions: String { localizedString("stats.quizSessions") }
    static var statsCorrectAnswers: String { localizedString("stats.correctAnswers") }
    static var statsTotalQuestions: String { localizedString("stats.totalQuestions") }
    static var statsResetProgress: String { localizedString("stats.resetProgress") }
    static var statsResetConfirmTitle: String { localizedString("stats.resetConfirmTitle") }
    static var statsResetConfirmMessage: String { localizedString("stats.resetConfirmMessage") }
    static var statsReset: String { localizedString("stats.reset") }
    static func statsMotivationStreak(_ days: Int) -> String {
        String(format: localizedString("stats.motivation.streak"), days)
    }
    static var statsMotivationAccuracy: String { localizedString("stats.motivation.accuracy") }
    static func statsMotivationQuestions(_ count: Int) -> String {
        String(format: localizedString("stats.motivation.questions"), count)
    }
    static var statsMotivationFlashcards: String { localizedString("stats.motivation.flashcards") }
    static var statsMotivationDefault: String { localizedString("stats.motivation.default") }

    static var statsTotalXP: String { localizedString("stats.totalXP") }
    static var statsSectionLearning: String { localizedString("stats.section.learning") }
    static var statsSectionLearningSubtitle: String {
        localizedString("stats.section.learningSubtitle")
    }
    static var statsSectionMinigames: String { localizedString("stats.section.minigames") }
    static var statsSectionMinigamesSubtitle: String {
        localizedString("stats.section.minigamesSubtitle")
    }
    static var statsSectionAchievements: String { localizedString("stats.section.achievements") }
    static var statsSectionAchievementsSubtitle: String {
        localizedString("stats.section.achievementsSubtitle")
    }

    static var statsQuickAccuracy: String { localizedString("stats.quick.accuracy") }
    static var statsQuickQuestions: String { localizedString("stats.quick.questions") }
    static var statsQuickCorrect: String { localizedString("stats.quick.correct") }

    static var statsRowFlashcardSessions: String { localizedString("stats.row.flashcardSessions") }
    static var statsRowQuizSessions: String { localizedString("stats.row.quizSessions") }
    static var statsRowDailyStreak: String { localizedString("stats.row.dailyStreak") }

    static var statsGameBestScore: String { localizedString("stats.game.bestScore") }
    static func statsGamePoints(_ value: String) -> String {
        String(format: localizedString("stats.game.points"), value)
    }
    static var statsGameFewestMoves: String { localizedString("stats.game.fewestMoves") }
    static var statsGameLongestChain: String { localizedString("stats.game.longestChain") }
    static var statsGameWinRate: String { localizedString("stats.game.winRate") }
    static var statsGameBestCombo: String { localizedString("stats.game.bestCombo") }

    static var statsEmptyMinigames: String { localizedString("stats.empty.minigames") }
    static var statsEmptyAchievements: String { localizedString("stats.empty.achievements") }

    static var achievementQuizMaster: String { localizedString("achievement.quizMaster") }
    static var achievementStreakRecord: String { localizedString("achievement.streakRecord") }
    static var achievementGameXP: String { localizedString("achievement.gameXP") }
    static var achievementFavoriteGame: String { localizedString("achievement.favoriteGame") }
    static var achievementComboMaster: String { localizedString("achievement.comboMaster") }
    static func achievementAccuracy(_ val: Double) -> String {
        String(format: localizedString("achievement.accuracy"), val)
    }

    static func statsSessions(_ count: Int) -> String {
        String(format: localizedString("stats.sessions"), count)
    }

    // MARK: - Profile
    static var profileTitle: String { localizedString("profile.title") }
    static var profileBadges: String { localizedString("profile.badges") }
    static var profileStreakSubtitle: String { localizedString("profile.streakSubtitle") }
    static func profileLevel(_ level: Int) -> String {
        String(format: localizedString("profile.level"), level)
    }
    static func profileStreakDays(_ days: Int) -> String {
        String(format: localizedString("profile.streakDays"), days)
    }

    // MARK: - Badges
    static func badgeTitle(_ key: String) -> String { localizedString("badge.\(key).title") }
    static func badgeDesc(_ key: String) -> String { localizedString("badge.\(key).desc") }

    // MARK: - Mini Games
    static var minigamesTitle: String { localizedString("minigames.title") }
    static var minigamesSubtitle: String { localizedString("minigames.subtitle") }
    static func minigamesAvailableWords(_ count: Int) -> String {
        String(format: localizedString("minigames.availableWords"), count)
    }
    static func minigamesNeedWords(_ count: Int) -> String {
        String(format: localizedString("minigames.needWords"), count)
    }
    static func minigamesMinWordsShort(_ count: Int) -> String {
        String(format: localizedString("minigames.minWordsShort"), count)
    }
    static var minigamesHeaderTitle: String { localizedString("minigames.headerTitle") }
    static var minigamesHeaderSubtitle: String { localizedString("minigames.headerSubtitle") }
    static func minigamesLearnedWords(_ count: Int) -> String {
        String(format: localizedString("minigames.learnedWords"), count)
    }
    static func minigamesNeedMore(_ count: Int) -> String {
        String(format: localizedString("minigames.needMore"), count)
    }

    // MARK: - Word Hunt
    static var wordhuntTitle: String { localizedString("wordhunt.title") }
    static var wordhuntSubtitle: String { localizedString("wordhunt.subtitle") }
    static func wordhuntFound(_ found: Int, _ total: Int) -> String {
        String(format: localizedString("wordhunt.found"), found, total)
    }
    static var wordhuntInstruction: String { localizedString("wordhunt.instruction") }

    // MARK: - Matching
    static var matchingTitle: String { localizedString("matching.title") }
    static var matchingSubtitle: String { localizedString("matching.subtitle") }
    static func matchingMoves(_ moves: Int) -> String {
        String(format: localizedString("matching.moves"), moves)
    }
    static func matchingPairs(_ found: Int, _ total: Int) -> String {
        String(format: localizedString("matching.pairs"), found, total)
    }

    // MARK: - Word Chain
    static var wordchainTitle: String { localizedString("wordchain.title") }
    static var wordchainSubtitle: String { localizedString("wordchain.subtitle") }
    static func wordchainLastLetter(_ letter: String) -> String {
        String(format: localizedString("wordchain.lastLetter"), letter)
    }
    static func wordchainChainLength(_ length: Int) -> String {
        String(format: localizedString("wordchain.chainLength"), length)
    }
    static var wordchainYourTurn: String { localizedString("wordchain.yourTurn") }
    static var wordchainHint: String { localizedString("wordchain.hint") }

    // MARK: - Hangman
    static var hangmanTitle: String { localizedString("hangman.title") }
    static var hangmanSubtitle: String { localizedString("hangman.subtitle") }
    static func hangmanLives(_ lives: Int) -> String {
        String(format: localizedString("hangman.lives"), lives)
    }
    static func hangmanHint(_ hint: String) -> String {
        String(format: localizedString("hangman.hint"), hint)
    }
    static var hangmanWon: String { localizedString("hangman.won") }
    static var hangmanLost: String { localizedString("hangman.lost") }

    // MARK: - Speed Fire
    static var speedfireTitle: String { localizedString("speedfire.title") }
    static var speedfireSubtitle: String { localizedString("speedfire.subtitle") }
    static func speedfireCombo(_ combo: Int) -> String {
        String(format: localizedString("speedfire.combo"), combo)
    }
    static var speedfireTrue: String { localizedString("speedfire.true") }
    static var speedfireFalse: String { localizedString("speedfire.false") }
    static var speedfireIsThisCorrect: String { localizedString("speedfire.isThisCorrect") }

    // MARK: - Common Game
    static func gameScore(_ score: Int) -> String {
        String(format: localizedString("game.score"), score)
    }
    static var gameTimeUp: String { localizedString("game.timeUp") }

    static func gameXPEarned(_ xp: Int) -> String {
        String(format: localizedString("game.xpEarned"), xp)
    }
    static var gamePlayAgain: String { localizedString("game.playAgain") }
    static var gameExcellent: String { localizedString("game.excellent") }
    static var gameExcellentMessage: String { localizedString("game.excellentMessage") }
    static var gameGreatJob: String { localizedString("game.greatJob") }
    static var gameGreatJobMessage: String { localizedString("game.greatJobMessage") }
    static var gameKeepTrying: String { localizedString("game.keepTrying") }
    static var gameKeepTryingMessage: String { localizedString("game.keepTryingMessage") }

    // MARK: - AR Scanner
    static var tabARScanner: String { localizedString("tab.arScanner") }
    static var arTitle: String { localizedString("ar.title") }
    static var arScanButton: String { localizedString("ar.scanButton") }
    static var arScanning: String { localizedString("ar.scanning") }
    static var arNoObjectDetected: String { localizedString("ar.noObjectDetected") }
    static var arCameraPermissionDenied: String { localizedString("ar.cameraPermissionDenied") }
    static var arInstruction: String { localizedString("ar.instruction") }
    static var arSearchingObjects: String { localizedString("ar.searchingObjects") }
    static func arObjectsDetected(_ count: Int) -> String {
        String(format: localizedString("ar.objectsDetected"), count)
    }
    static var arDetectedObjects: String { localizedString("ar.detectedObjects") }
    static var arTryAgain: String { localizedString("ar.tryAgain") }
}

public enum Common {
    static let fatalError = "init(coder:) has not been implemented"
}

public enum CellIdentifier {
    static let recentCell = "RecentSearchCell"
    static let header = "RecentHeader"
}
