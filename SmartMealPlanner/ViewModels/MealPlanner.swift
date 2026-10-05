//
//  MealPlanner.swift
//  SmartGroceryApp
//

import Foundation

final class MealPlanner {

    /// Builds seven consecutive days (from the start of `startingFrom`) using the same routine each day.
    func generateWeeklyMealPlan(
        recipes: [Recipe],
        preferences: UserPreferences,
        routine: MealRoutine,
        startingFrom: Date = Date(),
        calendar: Calendar = .current
    ) -> WeeklyMealPlan {
        let filtered = filterRecipes(recipes, preferences)
        let weekStart = calendar.startOfDay(for: startingFrom)
        let days: [DailyMealPlanSlot] = (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: weekStart) else { return nil }
            let breakfast: Recipe?
            switch preferences.breakfastRecipePreference {
            case .granolaMuesliOnly:
                breakfast = nil
            case .includeRecipes:
                breakfast = selectMeal(type: routine.breakfastType, from: filtered)
            }
            return DailyMealPlanSlot(
                date: date,
                breakfast: breakfast,
                lunch: selectMeal(type: routine.lunchType, from: filtered),
                dinner: selectMeal(type: routine.dinnerType, from: filtered)
            )
        }
        return WeeklyMealPlan(id: UUID(), weekStart: weekStart, days: days)
    }

    private func filterRecipes(
        _ recipes: [Recipe],
        _ preferences: UserPreferences
    ) -> [Recipe] {
        let dislikeTokens = preferences.dislikes
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }

        return recipes.filter { recipe in
            switch preferences.dietType {
            case "Vegetarian":
                if recipe.containsMeat { return false }
            case "Vegan":
                if recipe.containsAnimalProducts { return false }
            default:
                break
            }

            for allergy in preferences.allergies {
                let token = allergy.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                guard !token.isEmpty else { continue }
                if recipe.ingredients.contains(where: {
                    $0.ingredient.name.lowercased().contains(token)
                }) {
                    return false
                }
            }

            for dislike in dislikeTokens {
                if recipe.ingredients.contains(where: {
                    $0.ingredient.name.lowercased().contains(dislike)
                }) {
                    return false
                }
            }

            if !preferences.cuisines.isEmpty {
                let match = preferences.cuisines.contains {
                    $0.caseInsensitiveCompare(recipe.cuisine) == .orderedSame
                }
                if !match { return false }
            }

            return true
        }
    }

    private func selectMeal(
        type: MealType,
        from recipes: [Recipe]
    ) -> Recipe? {
        switch type {
        case .fixed:
            return recipes.first
        case .homeCooked:
            return recipes.randomElement()
        case .outside:
            return nil
        case .flexible:
            return recipes.randomElement()
        }
    }
}
