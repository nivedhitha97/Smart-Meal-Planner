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
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environmentObject(planning)
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                try? await Task.sleep(for: .seconds(1.4))
                withAnimation(.easeOut(duration: 0.35)) { showSplash = false }
            }
        }
    }
}
