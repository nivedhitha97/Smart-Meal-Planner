//
//  AISuggestedWeekPlan.swift
//  SmartGroceryApp
//

import Foundation

struct GroceryLineItem: Identifiable, Codable, Hashable {
    var id: UUID
    var ingredientName: String
    var totalGrams: Double
    var matchedOffer: SupermarketOffer?
    var estimatedLinePrice: Double
    var rationale: String

    init(
        id: UUID = UUID(),
        ingredientName: String,
        totalGrams: Double,
        matchedOffer: SupermarketOffer?,
        estimatedLinePrice: Double,
        rationale: String
    ) {
        self.id = id
        self.ingredientName = ingredientName
        self.totalGrams = totalGrams
        self.matchedOffer = matchedOffer
        self.estimatedLinePrice = estimatedLinePrice
        self.rationale = rationale
    }
}

/// Output from the AI planning pipeline (local heuristic or remote model).
struct AISuggestedWeekPlan: Identifiable, Codable {
    var id: UUID
    var createdAt: Date
    var weeklyMealPlan: WeeklyMealPlan
    var groceryLines: [GroceryLineItem]
    var aiSummary: String
    var offerHighlights: [String]
    var estimatedGroceryTotal: Double
    var budgetWeekly: Double

    var isWithinBudget: Bool {
        estimatedGroceryTotal <= budgetWeekly
    }
}
