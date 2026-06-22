//
//  Intention.swift
//  Roamly
//
//  The kind of city experience a user wants right now.
//

import SwiftUI

enum Intention: String, Codable, CaseIterable, Identifiable, Hashable {
    case history
    case artCulture
    case sports
    case foodie
    case architecture
    case familyFriendly
    case natureParks
    case hiddenGems
    case shopping
    case nightlife
    case photography
    case religiousHeritage
    case localClassics
    case surpriseMe

    var id: String { rawValue }

    /// Display title.
    var title: String {
        switch self {
        case .history: return "History"
        case .artCulture: return "Art & Culture"
        case .sports: return "Sports"
        case .foodie: return "Foodie"
        case .architecture: return "Architecture"
        case .familyFriendly: return "Family Friendly"
        case .natureParks: return "Nature & Parks"
        case .hiddenGems: return "Hidden Gems"
        case .shopping: return "Shopping"
        case .nightlife: return "Nightlife"
        case .photography: return "Photography"
        case .religiousHeritage: return "Religious / Heritage"
        case .localClassics: return "Local Classics"
        case .surpriseMe: return "Surprise Me"
        }
    }

    /// SF Symbol representing the intention.
    var symbol: String {
        switch self {
        case .history: return "building.columns.fill"
        case .artCulture: return "paintpalette.fill"
        case .sports: return "sportscourt.fill"
        case .foodie: return "fork.knife"
        case .architecture: return "building.2.fill"
        case .familyFriendly: return "figure.2.and.child.holdinghands"
        case .natureParks: return "leaf.fill"
        case .hiddenGems: return "sparkles"
        case .shopping: return "bag.fill"
        case .nightlife: return "moon.stars.fill"
        case .photography: return "camera.fill"
        case .religiousHeritage: return "books.vertical.fill"
        case .localClassics: return "star.fill"
        case .surpriseMe: return "dice.fill"
        }
    }

    /// A short tagline for cards / detail views.
    var blurb: String {
        switch self {
        case .history: return "Landmarks, ruins & stories from the past"
        case .artCulture: return "Museums, galleries & creative corners"
        case .sports: return "Stadiums, arenas & active spots"
        case .foodie: return "Markets, eats & local flavors"
        case .architecture: return "Iconic buildings & design"
        case .familyFriendly: return "Fun for all ages"
        case .natureParks: return "Green escapes & waterfronts"
        case .hiddenGems: return "Quiet spots only locals know"
        case .shopping: return "Boutiques, markets & retail therapy"
        case .nightlife: return "Bars, music & after-dark energy"
        case .photography: return "The most photogenic views"
        case .religiousHeritage: return "Sacred & historic heritage sites"
        case .localClassics: return "The must-sees, done right"
        case .surpriseMe: return "Let Roamly pick for you"
        }
    }

    /// The accent tint used in chips/cards.
    var tint: Color {
        switch self {
        case .foodie, .nightlife: return RoamlyColor.accentOrange
        case .natureParks: return RoamlyColor.success
        case .surpriseMe: return Color(hex: 0x8E5BE8)
        default: return RoamlyColor.primaryBlue
        }
    }

    /// Intentions that are real place categories (excludes Surprise Me).
    static var selectableCategories: [Intention] {
        allCases.filter { $0 != .surpriseMe }
    }
}
