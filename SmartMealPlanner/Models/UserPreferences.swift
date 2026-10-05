//
//  UserPreferences.swift
//  SmartGroceryApp
//

import Foundation

/// How breakfast should appear in the weekly plan (catalog recipes vs simple cereal).
enum BreakfastRecipePreference: String, Codable, CaseIterable, Identifiable {
    /// Use your meal routine to pick breakfast recipes from the catalog.
    case includeRecipes = "includeRecipes"
    /// No cooked breakfast recipe — you eat granola, muesli, or similar; grocery list stays focused on lunch/dinner.
    case granolaMuesliOnly = "granolaMuesliOnly"

    var id: String { rawValue }

    var menuTitle: String {
        switch self {
        case .includeRecipes:
            return "Include breakfast recipes"
        case .granolaMuesliOnly:
            return "Granola / muesli only (no cooked recipe)"
        }
    }
}

struct UserPreferences: Codable, Equatable {
    var dietType: String
    var cuisines: [String]
    var dislikes: [String]
    var allergies: [String]
    var budgetWeekly: Double
    /// Area or city used to match regional supermarket offers (e.g. "Amsterdam", "NL-North").
    var shoppingRegion: String
    /// When `granolaMuesliOnly`, the planner never assigns a catalog recipe to breakfast.
    var breakfastRecipePreference: BreakfastRecipePreference

    init(
        dietType: String,
        cuisines: [String],
        dislikes: [String],
        allergies: [String],
        budgetWeekly: Double,
        shoppingRegion: String = "",
        breakfastRecipePreference: BreakfastRecipePreference = .includeRecipes
    ) {
        self.dietType = dietType
        self.cuisines = cuisines
        self.dislikes = dislikes
        self.allergies = allergies
        self.budgetWeekly = budgetWeekly
        self.shoppingRegion = shoppingRegion
        self.breakfastRecipePreference = breakfastRecipePreference
    }

    enum CodingKeys: String, CodingKey {
        case dietType, cuisines, dislikes, allergies, budgetWeekly, shoppingRegion, breakfastRecipePreference
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        dietType = try c.decode(String.self, forKey: .dietType)
        cuisines = try c.decodeIfPresent([String].self, forKey: .cuisines) ?? []
        dislikes = try c.decodeIfPresent([String].self, forKey: .dislikes) ?? []
        allergies = try c.decodeIfPresent([String].self, forKey: .allergies) ?? []
        budgetWeekly = try c.decode(Double.self, forKey: .budgetWeekly)
        shoppingRegion = try c.decodeIfPresent(String.self, forKey: .shoppingRegion) ?? ""
        breakfastRecipePreference = try c.decodeIfPresent(BreakfastRecipePreference.self, forKey: .breakfastRecipePreference)
            ?? .includeRecipes
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(dietType, forKey: .dietType)
        try c.encode(cuisines, forKey: .cuisines)
        try c.encode(dislikes, forKey: .dislikes)
        try c.encode(allergies, forKey: .allergies)
        try c.encode(budgetWeekly, forKey: .budgetWeekly)
        try c.encode(shoppingRegion, forKey: .shoppingRegion)
        try c.encode(breakfastRecipePreference, forKey: .breakfastRecipePreference)
    }

    static func loadFromUserDefaults() -> UserPreferences? {
        guard let data = UserDefaults.standard.data(forKey: "userPreferences"),
              let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return nil
        }
        return prefs
    }
}
