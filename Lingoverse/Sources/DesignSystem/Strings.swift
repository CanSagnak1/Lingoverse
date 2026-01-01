//
//  Strings.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 3.11.2025.
//

import Foundation

public enum Strings {
    // MARK: - Navigation
    static let title = "Search"
    static let favoritesTitle = "Favorites"

    // MARK: - Search
    static let searchPlaceholder = "Search for a word…"
    static let headerRecent = "Recent Searches"
    static let hintStart = "Start searching or browse your recent searches."
    static let hintNoRecent = "You have no recent searches."
    static let searchButton = "Search"

    // MARK: - Favorites
    static let hintNoFavorites =
        "You have no favorited words yet.\nAdd words from the recent search list."

    // MARK: - Detail
    static let synonymsText = "Synonyms"

    // MARK: - Actions
    static let favoriteActionTitle = "Favorite"
    static let deleteActionTitle = "Delete"
    static let retryButtonLabel = "Try again"

    // MARK: - Errors
    static let errorGeneric = "Something went wrong.\nCheck your connection and try again."
    static let errorIntCon = "Internet connection not found. Please check your connection."
    static let errorNotFound = "Word not found."
    static let errorLabel = "Error"
}

public enum Cammon {
    static let fatalError = "init(coder:) has not been implemented"
}

public enum CellIdentifier {
    static let recentCell = "RecentSearchCell"
    static let header = "RecentHeader"
}
