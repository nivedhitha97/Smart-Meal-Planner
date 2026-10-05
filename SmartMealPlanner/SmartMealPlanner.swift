//
//  SmartMealPlannerApp.swift
//  SmartMealPlanner
//
//  Created by Nivedhitha on 29/12/2025.
//

import SwiftUI

@main
struct SmartMealPlannerApp: App {

    @StateObject private var planning = PlanningViewModel(ai: LocalHeuristicAIPlanner())

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(planning)
        }
    }
}
