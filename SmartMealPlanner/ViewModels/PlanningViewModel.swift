//
//  PlanningViewModel.swift
//  SmartGroceryApp
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class PlanningViewModel: ObservableObject {

    @Published var suggestedPlan: AISuggestedWeekPlan?
    @Published var isLoading = false
    @Published var lastError: String?

    private let ai: AIPlanningService

    private enum Keys {
        /// Bumped when `AISuggestedWeekPlan` shape changes (e.g. single-day → full week).
        static let lastPlan = "lastAISuggestedWeekPlan_v2"
    }

    init(ai: AIPlanningService) {
        self.ai = ai
        loadCachedPlan()
    }

    func loadCachedPlan() {
        guard let data = UserDefaults.standard.data(forKey: Keys.lastPlan) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        suggestedPlan = try? decoder.decode(AISuggestedWeekPlan.self, from: data)
    }

    func generatePlan() async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }

        do {
            let recipes: [Recipe] = try JSONLoader.load("recipes", as: [Recipe].self)
            let offers: [SupermarketOffer] = try JSONLoader.load("offers", as: [SupermarketOffer].self)

            guard let prefsData = UserDefaults.standard.data(forKey: "userPreferences"),
                  let prefs = try? JSONDecoder().decode(UserPreferences.self, from: prefsData) else {
                lastError = "Save your preferences on the Preferences tab first."
                return
            }

            guard let routineData = UserDefaults.standard.data(forKey: "mealRoutine"),
                  let routine = try? JSONDecoder().decode(MealRoutine.self, from: routineData) else {
                lastError = "Set your meal routine (Preferences → Meal Routine) first."
                return
            }

            let plan = try await ai.generateWeeklySuggestions(
                preferences: prefs,
                routine: routine,
                recipes: recipes,
                weeklyOffers: offers
            )
            suggestedPlan = plan
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let encoded = try? encoder.encode(plan) {
                UserDefaults.standard.set(encoded, forKey: Keys.lastPlan)
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func clearPlan() {
        suggestedPlan = nil
        UserDefaults.standard.removeObject(forKey: Keys.lastPlan)
    }
}
