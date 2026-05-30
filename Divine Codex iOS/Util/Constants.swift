//
//  Constants.swift
//  Divine Codex iOS
//
//  Created by Dennis Miller on 5/28/26.
//

import Foundation



// MARK: - Asset Names
/// Names of image assets bundled in the app. Kept as a flat array for now;
/// consider promoting to an enum when accessed from multiple sites.
let IMAGE_NAMES : [String] = ["monad-emanation.jpg","monad-eye-refined.jpg","monad-source.jpg","logo.png", "icon.png"]



// MARK: - Navigation
enum MainTab: CaseIterable {
    case home
    case explorer
    case search
    case settings

    var title: String {
        switch self {
        case .home:     return "Home"
        case .explorer: return "Explorer"
        case .search:   return "Search"
        case .settings: return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .home:     return "house.fill"
        case .explorer: return "sparkles"
        case .search:   return "magnifyingglass"
        case .settings: return "gear"
        }
    }
}
