//
//  WeeklyPlanView.swift
//  SmartGroceryApp
//

import SwiftUI

struct WeeklyPlanView: View {

    @EnvironmentObject private var planning: PlanningViewModel

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f
    }()

    var body: some View {
        NavigationStack {
            Group {
                if planning.isLoading {
                    ProgressView("Building your 7-day plan and grocery list…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let plan = planning.suggestedPlan {
                    planScroll(plan)
                } else {
                    ContentUnavailableView(
                        "No weekly plan yet",
                        systemImage: "calendar",
                        description: Text("Save preferences and a meal routine, then generate a full week with recipes and links.")
                    )
                }
            }
            .navigationTitle("Weekly plan")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Generate") {
                        Task { await planning.generatePlan() }
                    }
                    .disabled(planning.isLoading)
                }
                ToolbarItem(placement: .cancellationAction) {
                    if planning.suggestedPlan != nil {
                        Button("Clear", role: .destructive) {
                            planning.clearPlan()
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let message = planning.lastError {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(.ultraThinMaterial)
                }
            }
        }
    }

    @ViewBuilder
    private func planScroll(_ plan: AISuggestedWeekPlan) -> some View {
        let breakfastPref = UserPreferences.loadFromUserDefaults()?.breakfastRecipePreference ?? .includeRecipes
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                budgetCard(plan)

                Text(plan.aiSummary)
                    .font(.body)

                if !plan.offerHighlights.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Offer highlights")
                            .font(.headline)
                        ForEach(plan.offerHighlights, id: \.self) { line in
                            Label(line, systemImage: "tag.fill")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                weekSection(plan.weeklyMealPlan, breakfastPreference: breakfastPref)

                weeklyNutritionSection(plan.weeklyMealPlan)

                grocerySection(plan)
            }
            .padding()
        }
    }

    private func budgetCard(_ plan: AISuggestedWeekPlan) -> some View {
        let over = plan.estimatedGroceryTotal - plan.budgetWeekly
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Estimated grocery (week)")
                    .font(.headline)
                Spacer()
                Text("€\(plan.estimatedGroceryTotal, format: .number.precision(.fractionLength(2)))")
                    .font(.title2.bold())
            }
            HStack {
                Text("Weekly budget")
                Spacer()
                Text("€\(plan.budgetWeekly, format: .number.precision(.fractionLength(2)))")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            if plan.isWithinBudget {
                Label("Within budget", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Label("Over budget by €\(over, format: .number.precision(.fractionLength(2)))", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
    }

    private func weekSection(_ weekly: WeeklyMealPlan, breakfastPreference: BreakfastRecipePreference) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("7-day meals")
                .font(.title2.bold())
            Text("Tap a dish for the full recipe, photo, YouTube, and cookbook references.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            ForEach(weekly.days) { day in
                VStack(alignment: .leading, spacing: 12) {
                    Text(Self.dayFormatter.string(from: day.date))
                        .font(.headline)
                        .foregroundStyle(.primary)

                    ForEach(day.mealsWithSlot, id: \.0) { slot, recipe in
                        mealSlotRow(slot: slot, recipe: recipe, breakfastPreference: breakfastPreference)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12).fill(.thinMaterial))
            }
        }
    }

    @ViewBuilder
    private func mealSlotRow(slot: MealSlot, recipe: Recipe?, breakfastPreference: BreakfastRecipePreference) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text(slot.rawValue)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 88, alignment: .leading)

            if let recipe {
                NavigationLink {
                    RecipeDetailView(recipe: recipe)
                } label: {
                    HStack(spacing: 10) {
                        recipeThumb(recipe)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe.name)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text(recipe.cuisine)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if recipe.youtubeURL != nil || recipe.cookbookURL != nil {
                                Label("Video & book links", systemImage: "link")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text(emptySlotLabel(slot: slot, breakfastPreference: breakfastPreference))
                        .font(.body)
                        .foregroundStyle(.tertiary)
                    if slot == .breakfast && breakfastPreference == .granolaMuesliOnly {
                        Text("Buy granola or muesli separately— not part of recipe catalog.")
                            .font(.caption2)
                            .foregroundStyle(.quaternary)
                    }
                }
                Spacer()
            }
        }
    }

    private func emptySlotLabel(slot: MealSlot, breakfastPreference: BreakfastRecipePreference) -> String {
        if slot == .breakfast && breakfastPreference == .granolaMuesliOnly {
            return "Granola / muesli (your usual)"
        }
        return "Outside / flexible"
    }

    @ViewBuilder
    private func recipeThumb(_ recipe: Recipe) -> some View {
        Group {
            if let url = recipe.imageURLParsed {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Color.gray.opacity(0.2)
                            .overlay {
                                Image(systemName: "fork.knife")
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
            } else {
                Color.gray.opacity(0.2)
                    .overlay {
                        Image(systemName: "fork.knife")
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func weeklyNutritionSection(_ weekly: WeeklyMealPlan) -> some View {
        let totals = NutritionTotals.aggregate(recipes: weekly.allPlannedRecipes)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Approx. nutrition (all home meals this week)")
                .font(.headline)
            Grid(horizontalSpacing: 16, verticalSpacing: 8) {
                GridRow {
                    metric("kcal", totals.calories)
                    metric("protein g", totals.protein)
                }
                GridRow {
                    metric("carbs g", totals.carbs)
                    metric("fat g", totals.fat)
                }
            }
            .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(.thinMaterial))
    }

    private func metric(_ title: String, _ value: Double) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundStyle(.secondary)
            Text(value, format: .number.precision(.fractionLength(0)))
                .fontWeight(.medium)
        }
    }

    private func grocerySection(_ plan: AISuggestedWeekPlan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Grocery list")
                .font(.title2.bold())
            ForEach(plan.groceryLines) { line in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(line.ingredientName)
                            .font(.headline)
                        Spacer()
                        Text("€\(line.estimatedLinePrice, format: .number.precision(.fractionLength(2)))")
                            .fontWeight(.semibold)
                    }
                    Text("\(Int(line.totalGrams)) g total (7-day plan)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(line.rationale)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    if let offer = line.matchedOffer {
                        Text("\(offer.storeName) — \(offer.productName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)
                Divider()
            }
        }
    }
}

#Preview {
    WeeklyPlanView()
        .environmentObject(PlanningViewModel(ai: LocalHeuristicAIPlanner()))
}
