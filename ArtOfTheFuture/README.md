# ArtOfTheFuture

**Modular, FAANG-Style SwiftUI Project Structure**

---

## Folder Overview

- **App/**  
  Main entry points and global navigation (e.g. `ArtOfTheFutureApp.swift`, `MainTabView.swift`).

- **Core/**  
  Shared, app-wide utilities and data types.
    - `Models/` – Base models used across multiple features (`Artwork.swift`, `User.swift`).

- **Features/**  
  Each product feature gets its own folder, with:
    - `Models/` – Data types only for this feature.
    - `Views/` – SwiftUI views/UI code for the feature.
    - `Services/` – Networking, business logic, or data manipulation for the feature.
    - `Data/` – Static data/config unique to this feature.

    Example features:
      - `Lessons/` (Gamified Learning flows)
      - `Profile/` (User info/progress)
      - `Gallery/` (User artworks)
      - `Onboarding/` (First-time user experience)
      - `Drawing/` (Procreate-style engine)
      - `Challenges/` (Daily Updated exercises)

- **Utilities/**  
  Cross-feature helpers, managers, or mock data (e.g. haptics, test services).

- **Assets.xcassets/**  
  Images, icons, colors, and other Xcode asset catalogs.

- **Info.plist**  
  Project config.

---

## **Architecture Principles**

- **Feature-First:** All code is grouped by feature, not by layer, to maximize scalability and prevent spaghetti code.
- **Single Source of Truth:** Each model/service/data type only exists in one place.
- **Zero Global Junk:** If it isn’t used app-wide, it doesn’t live in Core/ or Utilities/.
- **Ready for Growth:** Add new features with a single new folder. No messy refactoring as you scale.

---

## **Contributing**

- **Add a New Feature?**  
  Copy an existing `Features/<FeatureName>/` folder, update your Models/Views/Services, and wire it into the app in `App/`.
- **Shared Logic?**  
  If it crosses feature boundaries, add to `Core/` or `Utilities/` only after confirming it’s truly global.
- **Naming:**  
  Use descriptive, explicit file and type names. No `Utils.swift`, ever.

---


---

## **License**
:

