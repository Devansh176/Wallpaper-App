# 🖼️ Wallviz – Flutter Wallpaper App

**Wallviz** is a sleek and modern wallpaper app built using **Flutter**, powered by the **Pexels** and **Unsplash** APIs. It allows users to browse, search, and download high-quality wallpapers across various categories with a beautiful UI and smooth performance.

---

## 🎯 Features

- 🌆 Fetch high-resolution wallpapers from **Pexels** and **Unsplash**
- 🔍 Keyword-based wallpaper search
- 🧱 Explore categories like Nature, Abstract, Technology, and more
- 📥 Wallpaper download support
- 🎨 Clean and responsive UI optimized for mobile
- ☁️ Lazy loading with smooth image grids

---

## ⚙️ Tech Stack

| Tech        | Purpose                               |
|-------------|----------------------------------------|
| Flutter     | Cross-platform UI development          |
| Pexels API  | Wallpaper data source (free images)    |
| Unsplash API| Alternate data source (free images)    |
| HTTP        | API calls and data fetching            |
| CachedNetworkImage | Efficient image loading & caching |

---

## 📁 Project Structure

```
lib/
├── main.dart             # App entry point
├── home_page.dart        # Main gallery UI
├── search_page.dart      # Search functionality
├── detail_page.dart      # Full-screen wallpaper view
├── api/
│   ├── pexels_api.dart
│   └── unsplash_api.dart
├── models/
│   ├── photo_model.dart
└── widgets/
    ├── wallpaper_tile.dart
```

---

## 🚀 Getting Started

### ✅ Prerequisites

- Flutter SDK installed
- Pexels API key: https://www.pexels.com/api/
- Unsplash API key: https://unsplash.com/developers

### 🔧 Setup

```bash
# 1. Clone the repository
git clone https://github.com/your-username/wallviz.git
cd wallviz

# 2. Install dependencies
flutter pub get

# 3. Add your API keys to the API service files
# e.g., pexels_api.dart, unsplash_api.dart

# 4. Run the app
flutter run
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.5
  cached_network_image: ^3.2.3
  flutter_staggered_grid_view: ^0.6.2
```

---

## 🔐 API Setup

- **Pexels:**  
  Sign up at [pexels.com](https://pexels.com), get your API key, and set it in `pexels_api.dart`

- **Unsplash:**  
  Create a developer account at [unsplash.com/developers](https://unsplash.com/developers), get the Access Key, and set it in `unsplash_api.dart`

---

## 📷 Screens (optional)

> You can add app UI screenshots here if needed.

---

## 👨‍💻 Author

**Devansh Dhopte**  
Crafted to experiment with third-party APIs and deliver an aesthetic wallpaper browsing experience using Flutter.

---

> _"A beautifully crafted wallpaper discovery app powered by two of the most generous image APIs."_  
