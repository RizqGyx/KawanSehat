# KawanSehat — Your Personal Health Companion

<p align="center">
  <img src="KawanSehat/Assets.xcassets/Logo.imageset/Frame 3.png" alt="KawanSehat Logo" width="120"/>
</p>

<p align="center">
  <strong>Kesehatan Terintegrasi · Integrated Health for Every Indonesian</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2016%2B-blue?logo=apple" />
  <img src="https://img.shields.io/badge/Language-Swift%205.9-orange?logo=swift" />
  <img src="https://img.shields.io/badge/UI-SwiftUI-purple" />
  <img src="https://img.shields.io/badge/Architecture-MVVM-green" />
  <img src="https://img.shields.io/badge/AI-Gemini%202.5%20Flash-red?logo=google" />
</p>

---

## Overview

**KawanSehat** (Health Buddy) is an iOS application designed to help budget-conscious Indonesians track nutrition, manage health reminders, and receive AI-powered meal recommendations — all tailored to their personal health goals and daily budget.

The app integrates Google's **Gemini 2.5 Flash AI** to provide personalized food suggestions, evaluates food health scores, and intelligently recommends daily meals that fit within the user's Rupiah budget. It also features a smart reminder system that keeps users on track with hydration, exercise, sleep, and meal logging.

---

## Screenshots

| Splash Screen | Onboarding | Activity Level |
|:---:|:---:|:---:|
| ![Splash](KawanSehat/Assets/SPLASH%20SCREEN.png) | ![Onboarding](KawanSehat/Assets/INPUT%20DATA%20DIRI.png) | ![Activity](KawanSehat/Assets/INPUT%20DATA%20LIGHTLY.png) |

| Budget Input | Finish |
|:---:|:---:|
| ![Budget](KawanSehat/Assets/INPUT%20DATA%20BUDGET.png) | ![Finish](KawanSehat/Assets/FINISH%20INPUT%20DATA.png) |

---

## Features

### 1. Personalized Health Dashboard
- **BMI Calculator** — Computes Body Mass Index and displays category (Underweight / Normal / Overweight / Obese) with color-coded indicators
- **TDEE Calculator** — Uses the Harris-Benedict formula to calculate Total Daily Energy Expenditure based on age, gender, weight, height, and activity level
- **Daily Budget Planner** — Splits the user's daily Rupiah budget into per-meal amounts (3 meals/day)
- **Meal Suggestions** — Displays budget-aware meal recommendations from a curated Indonesian food database
- **Free Workout Suggestions** — Recommends exercises tailored to BMI and activity level
- **Time-based Greeting** — Dynamic greeting banner adapts to time of day

### 2. Nutrition Tracker & Food Search
- **40+ Indonesian Foods Database** — Covers Main Dishes, Side Dishes, Vegetables, Snacks, Beverages, and Carbs (e.g., Nasi Goreng, Gado-Gado, Tempe Goreng, Pecel Lele)
- **Nutrition Details** — Calories, protein, carbohydrates, fats, fiber, price (IDR), and health score (1–10)
- **AI-Powered Health Suggestions** — Gemini AI analyzes selected food and provides a health opinion and 2–3 alternative options
- **Smart Alternatives Engine** — Finds healthier and cheaper alternatives filtered by the user's per-meal budget
- **Suggestion History** — Saves up to 50 AI suggestions for offline review

### 3. Smart Health Reminders
- **5 Goal Types** — Log Meals, Drink Water, Exercise, Sleep Early, Check Weight
- **Custom Schedules** — Set specific times and days of the week per reminder
- **Daily Meal Notifications** — AI-generated meal recommendations delivered at breakfast (7:00 AM), lunch (12:55 PM), and dinner (6:00 PM)
- **Smart Re-engagement** — Motivational push notifications sent after a configurable period of inactivity (6, 12, 24, 48, or 72 hours)
- **Meal Recommendation History** — Full history of AI-generated meal notifications with timestamps

---

## Tech Stack

| Layer | Technology |
|---|---|
| **UI Framework** | SwiftUI |
| **Architecture** | MVVM |
| **State Management** | `@StateObject`, `@EnvironmentObject`, `@Published` |
| **Persistence** | `UserDefaults` |
| **Networking** | `URLSession` with `async/await` |
| **AI API** | Google Gemini 2.5 Flash (`generativelanguage.googleapis.com`) |
| **Notifications** | `UserNotifications` framework |
| **Language** | Swift 5.9+ |
| **Target** | iOS 16+ |

---

## Architecture

The project follows the **MVVM (Model-View-ViewModel)** pattern with clean separation of concerns.

```
KawanSehat/
├── Config/
│   ├── APIConfig.swift              # Gemini API endpoint configuration
│   └── APISecrets.swift             # API keys (gitignored in production)
│
├── Models/
│   ├── UserProfile.swift            # Health data & BMI/TDEE calculations
│   ├── FoodItem.swift               # Food database model
│   ├── HealthReminder.swift         # Reminder & smart config models
│   └── MealReminderHistory.swift    # Meal recommendation history model
│
├── Services/
│   ├── UserDefaultsService.swift    # Local data persistence
│   ├── FoodDatabase.swift           # 40+ Indonesian foods & suggestion engine
│   ├── GeminiService.swift          # Gemini AI API client with key rotation
│   └── NotificationService.swift   # Notification scheduling & smart reminders
│
├── ViewModel/
│   ├── UserProfileViewModel.swift   # User data & health calculations
│   ├── NutritionViewModel.swift     # Food search, details & AI suggestions
│   └── ReminderViewModel.swift      # Reminder CRUD & notification sync
│
├── Views/
│   ├── RootView.swift               # Onboarding router
│   ├── SplashScreenView.swift       # Animated 3-second splash
│   ├── MainTabView.swift            # 3-tab navigation
│   ├── Onboarding/
│   │   └── OnboardingView.swift     # 4-step onboarding flow
│   ├── Dashboard/
│   │   ├── DashboardView.swift      # Home screen
│   │   └── ProfileEditView.swift   # Edit profile
│   ├── Nutrition/
│   │   └── NutritionView.swift      # Food search & nutrition details
│   └── Reminders/
│       ├── ReminderView.swift       # Reminder settings
│       └── MealReminderHistoryView.swift  # AI meal notification history
│
└── Helpers/
    └── KeyboardHelpers.swift        # Keyboard dismissal utilities
```

### Data Flow

```
User Input → ViewModel → Service → Model → View (via @Published bindings)
                        ↓
                UserDefaults (persistence)
                        ↓
                GeminiService (AI) / NotificationService (alerts)
```

---

## Health Calculations

### BMR (Basal Metabolic Rate) — Harris-Benedict Formula

```
Male:   BMR = 88.362 + (13.397 × weight_kg) + (4.799 × height_cm) - (5.677 × age)
Female: BMR = 447.593 + (9.247 × weight_kg) + (3.098 × height_cm) - (4.330 × age)
```

### TDEE (Total Daily Energy Expenditure)

| Activity Level | Multiplier |
|---|---|
| Sedentary (little/no exercise) | × 1.2 |
| Lightly Active (1–3 days/week) | × 1.375 |
| Moderately Active (3–5 days/week) | × 1.55 |
| Very Active (6–7 days/week) | × 1.725 |
| Extra Active (physical job + exercise) | × 1.9 |

### BMI Categories

| BMI Range | Category |
|---|---|
| < 18.5 | Underweight |
| 18.5 – 24.9 | Normal |
| 25.0 – 29.9 | Overweight |
| ≥ 30.0 | Obese |

---

## AI Integration (Google Gemini)

KawanSehat uses **Google Gemini 2.5 Flash** for two types of AI requests:

### 1. Food Health Suggestion
When a user selects a food item, Gemini evaluates its health impact and suggests 2–3 healthier or more budget-friendly alternatives, returned in structured Indonesian text.

### 2. Meal Recommendation
At meal times (breakfast, lunch, dinner), Gemini generates a personalized recommendation based on the user's calorie needs and budget, delivered as a push notification with the recommendation saved to history.

### Reliability Features
- **Multi-key fallback** — 4 API keys with automatic rotation on quota exhaustion or errors
- **Retry logic** — Handles rate-limiting (HTTP 429) and server errors (5xx) with backoff
- **30-second timeout** — Prevents hanging requests
- **Structured parsing** — Extracts "Saran:" and "Alternatif:" sections from Gemini's free-form responses

---

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 16.0+ device or simulator
- Google Gemini API key(s) — get one at [Google AI Studio](https://aistudio.google.com/)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/KawanSehat.git
   cd KawanSehat
   ```

2. **Add your API key(s)**

   Open `KawanSehat/Config/APISecrets.swift` and replace the placeholder values:
   ```swift
   struct APISecrets {
       static let geminiAPIKeys: [String] = [
           "YOUR_GEMINI_API_KEY_1",
           "YOUR_GEMINI_API_KEY_2",  // optional fallback keys
       ]
   }
   ```

   > Having multiple API keys is optional but recommended to avoid rate-limiting.

3. **Open in Xcode**
   ```bash
   open KawanSehat.xcodeproj
   ```

4. **Select target and run**
   - Choose your device or simulator
   - Press `Cmd + R` to build and run

### Notification Permissions

For push notifications to work on a physical device:
- Run the app on a real iPhone (notifications are not fully supported in the Simulator)
- When prompted, allow notification permissions
- See [NOTIFICATION_DEBUG.md](NOTIFICATION_DEBUG.md) for detailed setup and troubleshooting

---

## User Flow

```
App Launch
    └── Splash Screen (3s)
            └── First time?
                ├── YES → Onboarding (4 steps)
                │           ├── Step 1: Name, Age, Gender, Weight, Height
                │           ├── Step 2: Activity Level (slider)
                │           ├── Step 3: Daily Budget (Rp)
                │           └── Step 4: Confirmation → Save Profile
                │
                └── NO → Main App (3 tabs)
                            ├── Tab 1: Dashboard
                            │     Health summary, meal & workout suggestions
                            ├── Tab 2: Nutrisi
                            │     Food search, nutrition details, AI tips
                            └── Tab 3: Pengingat
                                  Goal reminders, meal notifications, history
```

---

## Onboarding

The 4-step onboarding collects all data needed for personalized recommendations:

| Step | Fields | Validation |
|---|---|---|
| **Personal Info** | Name, Age, Gender, Weight, Height | Age: 1–120, Weight: 20–300 kg, Height: 100–250 cm |
| **Activity Level** | Interactive 5-level slider with illustrations | Required selection |
| **Daily Budget** | Rupiah amount (IDR) | Minimum Rp 1,000 |
| **Confirmation** | Summary + animated Party Popper | — |

All fields validate in real-time after the first submission attempt. Errors are shown with red borders and descriptive messages.

---

## Indonesian Food Database

The app includes 40+ common Indonesian foods across 6 categories:

| Category | Examples |
|---|---|
| **Main Dishes** | Nasi Goreng, Pecel Lele, Gado-Gado, Soto Ayam, Mie Goreng |
| **Side Dishes** | Tempe Goreng, Ayam Goreng, Telur Ceplok, Ikan Bakar |
| **Vegetables** | Bayam Rebus, Kangkung Tumis, Lalapan |
| **Snacks** | Pisang, Roti Gandum, Kacang Rebus |
| **Beverages** | Air Putih, Teh Tawar, Jus Jeruk, Susu |
| **Rice & Carbs** | Nasi Merah, Singkong, Ubi Jalar |

Each food entry includes: calories, protein, carbs, fats, fiber, price (IDR), and a health score from 1–10.

---

## Design

### Color Palette

| Role | Description |
|---|---|
| **Brand Green** | Primary green with pale → dark gradient range |
| **Background** | Warm off-white (RGB: 255, 250, 245) |
| **Input Fields** | Light green tint (RGB: 240, 244, 239) |
| **Health Score** | Red (poor) → Orange → Blue → Green (excellent) |
| **Budget Status** | Green (within budget) / Orange (over budget) |

### UI Highlights
- Animated splash screen with logo fade-in
- Progress bar across onboarding steps
- Card-based dashboard with gradient backgrounds
- Search-first nutrition view with expandable food details
- Toggle + time picker per reminder goal
- Expandable AI suggestion cards with saved history

---

## Contributing

Contributions are welcome! If you have suggestions for new features, food items, or bug fixes:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m "Add: your feature description"`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Acknowledgements

- [Google Gemini API](https://ai.google.dev/) — AI-powered health and food suggestions
- [Harris-Benedict Equation](https://en.wikipedia.org/wiki/Harris%E2%80%93Benedict_equation) — BMR & TDEE calculation formula
- Indonesian food nutritional data compiled from public health references

---

<p align="center">Made with ❤️ for healthier Indonesians</p>
