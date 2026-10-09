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
    @State private var postcode = ""
    @State private var location: PostcodeLocation?
    @State private var isLookingUpPostcode = false
    @State private var postcodeError: String?
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
                    .disabled(isLookingUpPostcode || postcodeError != nil)
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

            VStack(alignment: .leading, spacing: 10) {
                InputField(icon: "mappin.and.ellipse", placeholder: "Postcode (e.g. 1012 AB)", text: $postcode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .textContentType(.postalCode)
                locationStatus
                    .animation(.snappy(duration: 0.2), value: location)
            }
            .task(id: postcode) { await resolvePostcode() }
        }
        .card()
    }

    @ViewBuilder
    private var locationStatus: some View {
        if isLookingUpPostcode {
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text("Finding your area…")
            }
            .font(.footnote)
            .foregroundStyle(Color.textSecondary)
        } else if let postcodeError {
            Label(postcodeError, systemImage: "exclamationmark.circle.fill")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.accentCoral)
        } else if let location {
            HStack(spacing: 10) {
                IconCircle(systemName: "mappin", tint: .brandPrimary, background: .brandPrimarySoft, size: 28)
                VStack(alignment: .leading, spacing: 1) {
                    Text(location.city ?? "Postcode \(location.postcode)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text("\(location.postcode) · Offers matched for this area")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer(minLength: 8)
                Badge(text: location.regionId, foreground: .brandPrimaryDeep, background: .brandPrimarySoft)
            }
            .accessibilityElement(children: .combine)
        } else if !shoppingRegion.isEmpty {
            Text("Current region: \(shoppingRegion). Add your postcode to update it.")
                .font(.footnote)
                .foregroundStyle(Color.textSecondary)
        } else {
            Text("We use your postcode to find supermarket offers near you.")
                .font(.footnote)
                .foregroundStyle(Color.textTertiary)
        }
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
            shoppingRegion: location?.shoppingRegion ?? (postcode.isEmpty ? shoppingRegion : ""),
            postcode: location?.postcode ?? "",
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
        // With a postcode the region is re-derived from it; the raw text is only kept for
        // preferences saved before postcode lookup existed.
        shoppingRegion = saved.postcode.isEmpty ? saved.shoppingRegion : ""
        postcode = saved.postcode
        breakfastRecipePreference = saved.breakfastRecipePreference
    }

    /// Resolves the typed postcode after a short pause. Runs whenever `postcode` changes; a newer
    /// keystroke cancels the previous lookup.
    private func resolvePostcode() async {
        isLookingUpPostcode = false
        let trimmed = postcode.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            location = nil
            postcodeError = nil
            return
        }
        guard PostcodeLocationService.normalize(trimmed) != nil else {
            location = nil
            // Only complain once a full-length postcode has been typed.
            let typed = trimmed.filter { !$0.isWhitespace }.count
            postcodeError = typed >= 6 ? PostcodeLookupError.invalidFormat.errorDescription : nil
            return
        }
        if location?.postcode == PostcodeLocationService.normalize(trimmed) { return }

        postcodeError = nil
        isLookingUpPostcode = true
        try? await Task.sleep(for: .milliseconds(400))
        guard !Task.isCancelled else { return }
        do {
            let resolved = try await PostcodeLocationService.resolve(trimmed)
            guard !Task.isCancelled else { return }
            location = resolved
        } catch {
            postcodeError = error.localizedDescription
        }
        isLookingUpPostcode = false
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
