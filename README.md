# Tracky 🔥❄️

Tracky is my iOS learning and habit-tracking app built with **SwiftUI** and **MVVM**. I built this project to practice writing clean, structured Swift code while solving real user-experience gaps in daily habit trackers.

---

## 💡 Why I Built It This Way (UX & Logic)

While working on the screens, I noticed a few things that didn't feel natural for a real user, so I designed the logic to handle them:

- **The 32-Hour Streak Rule:** Missing midnight shouldn't instantly ruin your streak. Users get a 32-hour window (until 8:00 AM the next day) to log their learning. During those final 8 hours, yesterday turns light red as a gentle warning so the user can tap it and save their streak.
- **Rescuing a Freeze:** Freezing a day works with a single tap—no annoying confirmation popup. However, if the user ends up studying within that 32-hour window, they can tap the frozen button to log the day as learned and get their freeze credit back.
- **Accidental Tap Protection:** Since the main "Log as Learned" button is large and permanent for the day, I added a confirmation alert so users don't log a day by mistake.
- **Fair Goal Updates:** If a user extends their goal period (e.g., from a Week to a Month) for the *same* topic, they keep their progress. Progress only resets if they change the topic or shorten the timeframe.
- **Losing a Streak ≠ Failing the Goal:** If a streak breaks after 32 hours, the user gets a choice to either continue their current learning period or start fresh.

---

## 📱 What's Inside

- **Onboarding:** Pick what you want to learn and set a timeframe (Week, Month, or Year).
- **Main Activity Screen:** Interactive weekly strip, live streak & freeze counters, and dynamic states for goal completion or end-of-period.
- **Monthly Calendar:** Full scrollable history showing learned, frozen, and missed days.
- **Goal Editor:** Edit your learning topic or extend your timeframe anytime.
- **Themes:** Full support for both **Light Mode** and **Dark Mode**.

---

## 🛠️ Built With

- **Swift & SwiftUI**
- **MVVM Architecture** (keeping all date calculations, streak rules, and state logic inside the ViewModels, leaving Views clean and focused on UI).
