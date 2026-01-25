//
//  MiniGameProgressManager.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 25.01.2026.
//

import Foundation

final class MiniGameProgressManager {

    static let shared = MiniGameProgressManager()

    private let userDefaults: UserDefaults

    // Keys
    private let wordhuntSessionsKey = "minigame_wordhunt_sessions"
    private let wordhuntBestScoreKey = "minigame_wordhunt_best"
    private let wordhuntTotalScoreKey = "minigame_wordhunt_total"
    private let wordhuntWordsFoundKey = "minigame_wordhunt_words_found"

    private let matchingSessionsKey = "minigame_matching_sessions"
    private let matchingBestMovesKey = "minigame_matching_best_moves"
    private let matchingTotalPairsKey = "minigame_matching_total_pairs"

    private let wordchainSessionsKey = "minigame_wordchain_sessions"
    private let wordchainBestChainKey = "minigame_wordchain_best"
    private let wordchainTotalWordsKey = "minigame_wordchain_total_words"

    private let hangmanSessionsKey = "minigame_hangman_sessions"
    private let hangmanWinsKey = "minigame_hangman_wins"
    private let hangmanLossesKey = "minigame_hangman_losses"

    private let speedfireSessionsKey = "minigame_speedfire_sessions"
    private let speedfireBestScoreKey = "minigame_speedfire_best"
    private let speedfireBestComboKey = "minigame_speedfire_best_combo"
    private let speedfireTotalCorrectKey = "minigame_speedfire_total_correct"

    private let totalMiniGameXPKey = "minigame_total_xp"

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Word Hunt Stats

    var wordhuntSessions: Int {
        get { userDefaults.integer(forKey: wordhuntSessionsKey) }
        set { userDefaults.set(newValue, forKey: wordhuntSessionsKey) }
    }

    var wordhuntBestScore: Int {
        get { userDefaults.integer(forKey: wordhuntBestScoreKey) }
        set { userDefaults.set(newValue, forKey: wordhuntBestScoreKey) }
    }

    var wordhuntTotalScore: Int {
        get { userDefaults.integer(forKey: wordhuntTotalScoreKey) }
        set { userDefaults.set(newValue, forKey: wordhuntTotalScoreKey) }
    }

    var wordhuntWordsFound: Int {
        get { userDefaults.integer(forKey: wordhuntWordsFoundKey) }
        set { userDefaults.set(newValue, forKey: wordhuntWordsFoundKey) }
    }

    func recordWordhuntSession(score: Int, wordsFound: Int) {
        wordhuntSessions += 1
        wordhuntTotalScore += score
        wordhuntWordsFound += wordsFound
        if score > wordhuntBestScore {
            wordhuntBestScore = score
        }
    }

    // MARK: - Matching Stats

    var matchingSessions: Int {
        get { userDefaults.integer(forKey: matchingSessionsKey) }
        set { userDefaults.set(newValue, forKey: matchingSessionsKey) }
    }

    var matchingBestMoves: Int {
        get { userDefaults.integer(forKey: matchingBestMovesKey) }
        set { userDefaults.set(newValue, forKey: matchingBestMovesKey) }
    }

    var matchingTotalPairs: Int {
        get { userDefaults.integer(forKey: matchingTotalPairsKey) }
        set { userDefaults.set(newValue, forKey: matchingTotalPairsKey) }
    }

    func recordMatchingSession(moves: Int, pairs: Int) {
        matchingSessions += 1
        matchingTotalPairs += pairs
        if matchingBestMoves == 0 || moves < matchingBestMoves {
            matchingBestMoves = moves
        }
    }

    // MARK: - Word Chain Stats

    var wordchainSessions: Int {
        get { userDefaults.integer(forKey: wordchainSessionsKey) }
        set { userDefaults.set(newValue, forKey: wordchainSessionsKey) }
    }

    var wordchainBestChain: Int {
        get { userDefaults.integer(forKey: wordchainBestChainKey) }
        set { userDefaults.set(newValue, forKey: wordchainBestChainKey) }
    }

    var wordchainTotalWords: Int {
        get { userDefaults.integer(forKey: wordchainTotalWordsKey) }
        set { userDefaults.set(newValue, forKey: wordchainTotalWordsKey) }
    }

    func recordWordchainSession(chainLength: Int) {
        wordchainSessions += 1
        wordchainTotalWords += chainLength
        if chainLength > wordchainBestChain {
            wordchainBestChain = chainLength
        }
    }

    // MARK: - Hangman Stats

    var hangmanSessions: Int {
        get { userDefaults.integer(forKey: hangmanSessionsKey) }
        set { userDefaults.set(newValue, forKey: hangmanSessionsKey) }
    }

    var hangmanWins: Int {
        get { userDefaults.integer(forKey: hangmanWinsKey) }
        set { userDefaults.set(newValue, forKey: hangmanWinsKey) }
    }

    var hangmanLosses: Int {
        get { userDefaults.integer(forKey: hangmanLossesKey) }
        set { userDefaults.set(newValue, forKey: hangmanLossesKey) }
    }

    var hangmanWinRate: Double {
        let total = hangmanWins + hangmanLosses
        guard total > 0 else { return 0 }
        return Double(hangmanWins) / Double(total) * 100
    }

    func recordHangmanSession(won: Bool) {
        hangmanSessions += 1
        if won {
            hangmanWins += 1
        } else {
            hangmanLosses += 1
        }
    }

    // MARK: - Speed Fire Stats

    var speedfireSessions: Int {
        get { userDefaults.integer(forKey: speedfireSessionsKey) }
        set { userDefaults.set(newValue, forKey: speedfireSessionsKey) }
    }

    var speedfireBestScore: Int {
        get { userDefaults.integer(forKey: speedfireBestScoreKey) }
        set { userDefaults.set(newValue, forKey: speedfireBestScoreKey) }
    }

    var speedfireBestCombo: Int {
        get { userDefaults.integer(forKey: speedfireBestComboKey) }
        set { userDefaults.set(newValue, forKey: speedfireBestComboKey) }
    }

    var speedfireTotalCorrect: Int {
        get { userDefaults.integer(forKey: speedfireTotalCorrectKey) }
        set { userDefaults.set(newValue, forKey: speedfireTotalCorrectKey) }
    }

    func recordSpeedfireSession(score: Int, maxCombo: Int, correct: Int) {
        speedfireSessions += 1
        speedfireTotalCorrect += correct
        if score > speedfireBestScore {
            speedfireBestScore = score
        }
        if maxCombo > speedfireBestCombo {
            speedfireBestCombo = maxCombo
        }
    }

    // MARK: - Total XP

    var totalMiniGameXP: Int {
        get { userDefaults.integer(forKey: totalMiniGameXPKey) }
        set { userDefaults.set(newValue, forKey: totalMiniGameXPKey) }
    }

    func addMiniGameXP(_ xp: Int) {
        totalMiniGameXP += xp
    }

    // MARK: - Computed Stats

    var totalMiniGameSessions: Int {
        wordhuntSessions + matchingSessions + wordchainSessions + hangmanSessions
            + speedfireSessions
    }

    var mostPlayedGame: String? {
        let games = [
            ("Word Hunt", wordhuntSessions),
            ("Matching", matchingSessions),
            ("Word Chain", wordchainSessions),
            ("Hangman", hangmanSessions),
            ("Speed Fire", speedfireSessions),
        ]
        return games.max(by: { $0.1 < $1.1 })?.0
    }

    // MARK: - Reset

    func resetProgress() {
        wordhuntSessions = 0
        wordhuntBestScore = 0
        wordhuntTotalScore = 0
        wordhuntWordsFound = 0

        matchingSessions = 0
        matchingBestMoves = 0
        matchingTotalPairs = 0

        wordchainSessions = 0
        wordchainBestChain = 0
        wordchainTotalWords = 0

        hangmanSessions = 0
        hangmanWins = 0
        hangmanLosses = 0

        speedfireSessions = 0
        speedfireBestScore = 0
        speedfireBestCombo = 0
        speedfireTotalCorrect = 0

        totalMiniGameXP = 0
    }
}
