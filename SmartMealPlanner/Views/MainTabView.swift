//
//  MainTabView.swift
//  SmartGroceryApp
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            WeeklyPlanView()
                .tabItem {
                    Label("Plan", systemImage: "calendar.badge.clock")
                }
            WeeklyOffersView()
                .tabItem {
                    Label("Offers", systemImage: "tag.fill")
                }
            PreferencesView()
                .tabItem {
                    Label("Preferences", systemImage: "slider.horizontal.3")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(PlanningViewModel(ai: LocalHeuristicAIPlanner()))
}
