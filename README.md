# SmartMealPlanner – iOS (SwiftUI)

## Project Overview

**Smart Meal Planner** is a SwiftUI-based iOS application designed to generate personalized meal plans based on user dietary preferences, meal routines, and nutritional goals. The project focuses on **clean architecture, scalability, and real-world problem solving**, and serves as a portfolio-quality demonstration of modern iOS development practices.

The app addresses a practical challenge faced by users—planning meals and groceries efficiently while managing nutrition, preferences, and budget—especially in environments with multiple supermarkets and food options.

---

## Key Features

### User Preferences Management
- Supports dietary types (Vegetarian / Non-Vegetarian)
- Preferred cuisines and ingredient exclusions (allergies/dislikes)
- Preferences persisted globally using `UserDefaults`

### Meal Routine Configuration
- Customizable breakfast, lunch, and dinner routines
- Supports fixed, home-cooked, flexible, and outside meals

### Meal Planning Engine
- Generates daily meal plans based on:
  - User preferences
  - Meal routine
  - Available recipes
- Intelligent filtering logic to exclude incompatible recipes

### Nutrition Calculation
- Aggregates nutritional values per meal plan:
  - Calories
  - Protein
  - Carbohydrates
  - Fat
  - Fiber

### Recipe Data Handling
- Recipes loaded from local JSON files
- Data modeled using `Codable` for safe and maintainable parsing
- UI-safe identifiers generated at runtime for SwiftUI lists

---

## Technical Architecture

The application follows a **service-oriented, MVVM-inspired SwiftUI architecture**, emphasizing separation of concerns and testability.

```
SmartMealPlanner
│
├── App Layer
│   └── SmartMealPlannerApp.swift
│
├── Models
│   ├── Recipe.swift
│   ├── Ingredient.swift
│   ├── MealPlan.swift
│   ├── MealRoutine.swift
│   └── UserPreferences.swift
│
├── Services
│   ├── MealPlannerService.swift
│   └── JSONLoader.swift
│
├── State Management
│   └── UserPreferencesStore.swift
│
├── Views
│   ├── ContentView.swift
│   ├── MealPlanView.swift
│   ├── PreferencesView.swift
│   └── MealRoutineView.swift
│
├── Resources
│   └── recipes.json
```

---

## Design & Engineering Highlights

- Implemented global state management using `ObservableObject` and `@EnvironmentObject`
- Encapsulated business logic (filtering, meal generation, nutrition calculation) in a dedicated service layer
- Applied `Codable` best practices, including optional handling and runtime UUID generation
- Ensured SwiftUI preview stability via dependency injection and mock environments
- Designed the app with extensibility in mind (weekly plans, budgeting, API integration)

---

## Technology Stack

**Platform:** iOS  
**Language:** Swift  
**UI Framework:** SwiftUI  
**Architecture:** MVVM-inspired, Service Layer  
**State Management:** Combine (`ObservableObject`, `@Published`)  
**Data Persistence:** UserDefaults  
**Data Parsing:** Codable (JSON)

---

## Getting Started

1. Clone the repository
2. Open the project in Xcode 15 or later
3. Build and run on the iOS Simulator
4. Begin exploration from `ContentView`

No third-party dependencies are required.

---

## Scalability & Future Enhancements

- Weekly and monthly meal planning
- Budget-aware grocery recommendations
- Supermarket price comparison
- Nutrition visualization using Swift Charts
- Backend/API integration (Firebase / Supabase)
- AI-assisted recipe recommendations

---

## Purpose of This Project

This project was built to:
- Demonstrate **production-ready SwiftUI development skills**
- Showcase architectural decision-making and clean code practices
- Solve a real-world problem with a scalable technical approach
- Serve as a professional portfolio project for iOS and mobile engineering roles

---

## Author

**Nivedhitha Parthasarathy**  
Senior Mobile Developer (iOS / React Native)

---

## Notes for Reviewers

This project emphasizes **architecture, maintainability, and real-world applicability** over UI polish alone. It is designed to be easily extendable and suitable as a foundation for larger-scale applications.

