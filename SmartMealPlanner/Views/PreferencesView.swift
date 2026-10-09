//
//  PreferencesView.swift
//  SmartMealPlanner
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
    @State private var routineSummary: String?
    @State private var didSave = false

    private let cuisines = ["Indian", "Italian", "Dutch", "Asian", "Mexican", "Greek", "French"]
    private let dietOptions = ["Vegetarian", "Non-Vegetarian", "Vegan", "High Protein"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(title: "Preferences", subtitle: "These shape your weekly plan and grocery list.")
                        .padding(.bottom, 8)

                    dietCard
                    breakfastCard
                    cuisinesCard
                    exclusionsCard
                    budgetCard
                    routineLink

                    Button(action: savePreferences) {
                        Label(didSave ? "Saved" : "Save preferences", systemImage: didSave ? "checkmark" : "tray.and.arrow.down")
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.primary)
                    .sensoryFeedback(.success, trigger: didSave) { _, new in new }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .screenBackground()
            .navigationTitle("Preferences")
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                loadPreferences()
                loadRoutineSummary()
            }
        }
    }

    // MARK: - Cards

    private var dietCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            CardHeader(icon: "leaf.fill", tint: .brandPrimary, tintBackground: .brandPrimarySoft, title: "Diet", subtitle: "What do you eat?")
            FlowLayout {
                ForEach(dietOptions, id: \.self) { option in
                    Chip(title: option, isSelected: dietType == option) {
                        dietType = option
                    }
                }
            }
        }
        .card()
    }

    private var breakfastCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            CardHeader(icon: "cup.and.saucer.fill", tint: .accentAmber, tintBackground: .accentAmberSoft, title: "Breakfast", subtitle: "How breakfast appears in your plan")
            breakfastOption(.includeRecipes, title: "Include breakfast recipes", subtitle: "Pick from the recipe catalog")
            breakfastOption(.granolaMuesliOnly, title: "Granola / muesli only", subtitle: "No cooked breakfast; lunch & dinner still follow your routine")
        }
        .card()
    }

    private func breakfastOption(_ mode: BreakfastRecipePreference, title: String, subtitle: String) -> some View {
        let isSelected = breakfastRecipePreference == mode
        return Button {
            withAnimation(.snappy(duration: 0.2)) { breakfastRecipePreference = mode }
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? Color.brandPrimaryDeep : Color.textPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 8)
                SelectionIndicator(isSelected: isSelected)
            }
            .padding(14)
            .background(isSelected ? Color.brandPrimarySoft : Color.bgCanvas, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? Color.brandPrimary : Color.borderSubtle, lineWidth: isSelected ? 1.5 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var cuisinesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            CardHeader(icon: "globe.europe.africa.fill", tint: .accentCoral, tintBackground: .accentCoralSoft, title: "Cuisines", subtitle: "Pick as many as you like")
            FlowLayout {
                ForEach(cuisines, id: \.self) { cuisine in
                    Chip(title: cuisine, isSelected: selectedCuisines.contains(cuisine)) {
                        if selectedCuisines.contains(cuisine) {
                            selectedCuisines.remove(cuisine)
                        } else {
                            selectedCuisines.insert(cuisine)
                        }
                    }
                }
            }
        }
        .card()
    }

    private var exclusionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            CardHeader(icon: "nosign", tint: .textSecondary, tintBackground: .bgMuted, title: "Exclusions", subtitle: "Comma-separated")
            InputField(icon: "hand.thumbsdown", placeholder: "Disliked ingredients", text: $dislikes, multiline: true)
            InputField(icon: "allergens", placeholder: "Allergies (e.g. peanuts, gluten)", text: $allergies, multiline: true)
        }
        .card()
    }

    private var budgetCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            CardHeader(icon: "wallet.bifold.fill", tint: .brandPrimary, tintBackground: .brandPrimarySoft, title: "Budget & region")

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(weeklyBudget.eurosRounded)
                    .font(.screenTitle)
                    .tracking(-0.6)
                    .foregroundStyle(Color.textPrimary)
                    .contentTransition(.numericText(value: weeklyBudget))
                    .animation(.snappy, value: weeklyBudget)
                Text("/ week")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(Color.textSecondary)
            }

            VStack(spacing: 4) {
                Slider(value: $weeklyBudget, in: 20...150, step: 5) {
                    Text("Weekly budget")
                }
                .tint(.brandPrimary)
                HStack {
                    Text("€20")
                    Spacer()
                    Text("€150")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.textTertiary)
            }

            InputField(icon: "mappin.and.ellipse", placeholder: "Shopping region (e.g. NL-North, Amsterdam)", text: $shoppingRegion)
                .textInputAutocapitalization(.never)
        }
        .card()
    }

    private var routineLink: some View {
        NavigationLink {
            MealRoutineView()
                .onDisappear(perform: loadRoutineSummary)
        } label: {
            HStack(spacing: 12) {
                IconTile(systemName: "clock.fill", tint: .accentAmber, background: .accentAmberSoft)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Meal routine")
                        .font(.cardTitle)
                        .foregroundStyle(Color.textPrimary)
                    Text(routineSummary ?? "Not set yet")
                        .font(.footnote)
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.textTertiary)
            }
            .card()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Persistence

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
            didSave = true
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                didSave = false
            }
        }
    }

    private func loadPreferences() {
        guard let saved = UserPreferences.loadFromUserDefaults() else { return }
        dietType = saved.dietType
        selectedCuisines = Set(saved.cuisines)
        dislikes = saved.dislikes.joined(separator: ", ")
        allergies = saved.allergies.joined(separator: ", ")
        weeklyBudget = saved.budgetWeekly
        shoppingRegion = saved.shoppingRegion
        breakfastRecipePreference = saved.breakfastRecipePreference
    }

    private func loadRoutineSummary() {
        guard let data = UserDefaults.standard.data(forKey: "mealRoutine"),
              let routine = try? JSONDecoder().decode(MealRoutine.self, from: data) else {
            routineSummary = nil
            return
        }
        routineSummary = [routine.breakfastType, routine.lunchType, routine.dinnerType]
            .map(\.rawValue)
            .joined(separator: " · ")
    }

    private func splitList(_ raw: String) -> [String] {
        raw.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

// MARK: - Shared form pieces

struct SelectionIndicator: View {
    let isSelected: Bool
    var size: CGFloat = 22

    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.brandPrimary : Color.bgSurface)
            Circle()
                .strokeBorder(isSelected ? Color.clear : Color.borderSubtle, lineWidth: 1.5)
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: size, height: size)
    }
}

private struct InputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var multiline = false

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.textTertiary)
                .frame(width: 18)
            if multiline {
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(1...4)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .font(.callout)
        .foregroundStyle(Color.textPrimary)
        .padding(14)
        .background(Color.bgCanvas, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.borderSubtle))
    }
}

#Preview {
    PreferencesView()
}
