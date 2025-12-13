//
//  Strings.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 3.11.2025.
//

public enum Strings {
    static let title             = "Search"
    static let searchPlaceholder = "Search for a word…"
    static let headerRecent      = "Recent Searches"
    static let hintStart         = "Start searching or browse your recent searches."
    static let hintNoRecent      = "You have no recent searches."
    static let errorGeneric      = "Something went wrong.\nCheck your connection and try again."
    static let retryButtonLabel  = "Try again"
    static let synonymsText      = "Synonyms"
    static let favoritesTitle      = "Favorites"
    static let hintNoFavorites     = "You have no favorited words yet.\nAdd words from the recent search list."
    static let favoriteActionTitle = "Favorite"
    static let deleteActionTitle   = "Delete"
    static let errorLabel          = "Error"
    static let errorIntCon         = "Internet connection not found. Please check your connection."
}

public enum Cammon {
    static let fatalError = "init(coder:) has not been implemented"
}

public enum CellIdentifier {
    static let recentCell = "RecentSearchCell"
    static let header     = "RecentHeader"
}
