//
//  Ingredient.swift
//  SmartGroceryApp
//
//  Created by Nivedhitha on 29/12/2025.
//

import Foundation

struct Ingredient: Codable, Identifiable {
    let id: UUID
    var name: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double?
    var defaultPrice: Double
    
    init(id: UUID = UUID(), name: String, calories: Double, protein: Double, carbs: Double, fat: Double, fiber: Double? = nil, defaultPrice: Double) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.defaultPrice = defaultPrice
    }
}
