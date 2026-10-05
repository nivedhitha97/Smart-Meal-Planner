//
//  SmartGroceryAppApp.swift
//  SmartGroceryApp
//
//  Created by Nivedhitha on 29/12/2025.
//

import SwiftUI

@main
struct SmartGroceryAppApp: App {

    @StateObject private var planning = PlanningViewModel(ai: LocalHeuristicAIPlanner())

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(planning)
        }
    }
}
