//
//  MealRoutine.swift
//  SmartGroceryApp
//
//  Created by Nivedhitha on 29/12/2025.
//

import Foundation

struct MealRoutine: Codable {
    var breakfastType: MealType
    var lunchType: MealType
    var dinnerType: MealType
}

enum MealType: String, Codable, CaseIterable, Identifiable {
    case fixed = "Fixed"
    case flexible = "Flexible"
    case homeCooked = "Home Cooked"
    case outside = "Outside"
    
    var id: String { rawValue }
}
