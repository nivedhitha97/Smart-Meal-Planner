//
//  PreferencesView.swift
//  SmartGroceryApp
//

import SwiftUI

struct PreferencesView: View {

    @State private var dietType = "Vegetarian"
    @State private var selectedCuisines: Set<String> = []
    @State private var dislikes = ""
    @State private var allergies = ""
    @State private var weeklyBudget: Double = 50
    @State private var shoppingRegion = ""
    @State private var breakfastRecipePreference: BreakfastRecipePreference = .includeRecipes

    private let cuisines = ["Indian", "Italian", "Dutch", "Asian", "Mexican", "Greek", "French"]
    private let dietOptions = ["Vegetarian", "Non-Vegetarian", "Vegan", "High Protein"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Preferences drive both the meal planner and the AI-assisted grocery list. Regional offers are matched when your area overlaps flyer data.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Diet") {
                    Picker("Diet type", selection: $dietType) {
                        ForEach(dietOptions, id: \.self) {
                            Text($0)
                        }
                    }
                }

                Section {
                    Picker("Breakfast in weekly plan", selection: $breakfastRecipePreference) {
                        ForEach(BreakfastRecipePreference.allCases) { mode in
                            Text(mode.menuTitle).tag(mode)
                        }
                    }
                    Text("Choose “Granola / muesli only” if you don’t want cooked breakfast recipes—lunch and dinner still follow your meal routine.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Breakfast")
                }

                Section("Cuisines") {
                    ForEach(cuisines, id: \.self) { cuisine in
                        Toggle(cuisine, isOn: Binding(
                            get: { selectedCuisines.contains(cuisine) },
                            set: { isSelected in
                                if isSelected {
                                    selectedCuisines.insert(cuisine)
                                } else {
                                    selectedCuisines.remove(cuisine)
                                }
                            }
                        ))
                    }
                }

                Section("Exclusions") {
                    TextField("Disliked ingredients (comma-separated)", text: $dislikes, axis: .vertical)
                        .lineLimit(2...4)
                    TextField("Allergies (comma-separated)", text: $allergies, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Budget & region") {
                    Slider(value: $weeklyBudget, in: 20...150, step: 5) {
                        Text("Weekly budget")
                    }
                    Text("€\(Int(weeklyBudget)) / week")
                        .font(.headline)
                    TextField("Shopping region (e.g. NL-North, Amsterdam)", text: $shoppingRegion)
                        .textInputAutocapitalization(.never)
                }

                Section("Routine") {
                    NavigationLink("Meal routine") {
                        MealRoutineView()
                    }
                }

                Section {
                    Button(action: savePreferences) {
                        Text("Save preferences")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Preferences")
            .onAppear(perform: loadPreferences)
        }
    }

    private func savePreferences() {
        let preferences = UserPreferences(
            dietType: dietType,
            cuisines: Array(selectedCuisines),
            dislikes: splitList(dislikes),
            allergies: splitList(allergies),
            budgetWeekly: weeklyBudget,
            shoppingRegion: shoppingRegion.trimmingCharacters(in: .whitespacesAndNewlines),
            breakfastRecipePreference: breakfastRecipePreference
        )
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: "userPreferences")
        }
    }

    private func loadPreferences() {
        guard let data = UserDefaults.standard.data(forKey: "userPreferences"),
              let saved = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return
        }
        dietType = saved.dietType
        selectedCuisines = Set(saved.cuisines)
        dislikes = saved.dislikes.joined(separator: ", ")
        allergies = saved.allergies.joined(separator: ", ")
        weeklyBudget = saved.budgetWeekly
        shoppingRegion = saved.shoppingRegion
        breakfastRecipePreference = saved.breakfastRecipePreference
    }

    private func splitList(_ raw: String) -> [String] {
        raw.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

#Preview {
    PreferencesView()
}
