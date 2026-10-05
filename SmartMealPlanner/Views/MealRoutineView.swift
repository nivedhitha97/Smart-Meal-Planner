//
//  MealRoutineView.swift
//  SmartGroceryApp
//
//  Created by Nivedhitha on 30/12/2025.
//

import SwiftUI

struct MealRoutineView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var breakfast: MealType = .fixed
    @State private var lunch: MealType = .outside
    @State private var dinner: MealType = .homeCooked
    
    private func loadRoutine() {
        guard let data = UserDefaults.standard.data(forKey: "mealRoutine"),
              let saved = try? JSONDecoder().decode(MealRoutine.self, from: data) else {
            return
        }

        breakfast = saved.breakfastType
        lunch = saved.lunchType
        dinner = saved.dinnerType
    }
    
    var body: some View {
        Form {
            
            Section(header: Text("Breakfast")) {
                Picker("Breakfast Type", selection: $breakfast) {
                    ForEach(MealType.allCases) { type in
                        Text(type.rawValue)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section(header: Text("Lunch")) {
                Picker("Lunch Type", selection: $lunch) {
                    ForEach(MealType.allCases) { type in
                        Text(type.rawValue)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section(header: Text("Dinner")) {
                Picker("Dinner Type", selection: $dinner) {
                    ForEach(MealType.allCases) { type in
                        Text(type.rawValue)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section {
                Button("Save Meal Routine") {
                    saveRoutine()
                }
            }
        }
        .navigationTitle("Meal Routine")
        .onAppear {
            loadRoutine()
        }
    }
    
    func saveRoutine() {
        let routine = MealRoutine(
            breakfastType: breakfast,
            lunchType: lunch,
            dinnerType: dinner
        )
        
        if let encoded = try? JSONEncoder().encode(routine) {
            UserDefaults.standard.set(encoded, forKey: "mealRoutine")
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        MealRoutineView()
    }
}
