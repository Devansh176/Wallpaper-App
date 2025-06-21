# 🖼️ Wallviz – Flutter Wallpaper App

**Wallviz** is a sleek and modern wallpaper app built using **Flutter**, powered by the **Pexels** and **Unsplash** APIs. It allows users to browse, search, and download high-quality wallpapers across various categories with a beautiful UI and smooth performance.

---

## 🎯 Features

- 🌆 Fetch high-resolution wallpapers from **Pexels** and **Unsplash**
- 🔍 Keyword-based wallpaper search
- 🧱 Explore categories like Nature, Abstract, Technology, and more
- 📥 Wallpaper download support
- 📜 **Pagination** for efficient data loading
- 🎨 Clean and responsive UI optimized for mobile
- ☁️ Lazy loading with smooth image grids
- 💡 Splash screen and smooth navigation


---

## ⚙️ Tech Stack

| Tech        | Purpose                               |
|-------------|----------------------------------------|
| Flutter     | Cross-platform UI development          |
| Pexels API  | Wallpaper data source (free images)    |
| Unsplash API| Alternate data source (free images)    |
| HTTP        | API calls and data fetching            |
| CachedNetworkImage | Efficient image loading & caching |
| Staggered Grid View | Grid layout with masonry effect|

---

## 📁 Project Structure

```
lib/
├── main.dart               # App entry point
├── SplashScreen.dart       # App splash/loading screen
├── ImageScreen.dart        # Fullscreen wallpaper view
├── Wallpaper.dart          # Home screen + image grid
assets/                     # App icons, placeholder images
```

Other platforms:  
- `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/` for cross-platform support  
- `test/` for unit and widget tests

---


---

## 🚀 Getting Started

### ✅ Prerequisites

- Flutter SDK installed
- Pexels API key: https://www.pexels.com/api/
- Unsplash API key: https://unsplash.com/developers

### 🔧 Setup

```bash
# 1. Clone the repository
git clone https://github.com/Devansh176/Wallpaper-App.git
cd wallviz

# 2. Install dependencies
flutter pub get

# 3. Add your API keys to the API service files
# e.g., pexels_api.dart, unsplash_api.dart

# 4. Run the app
flutter run
```

---

## 🔁 Pagination

Pagination is handled by tracking the current page number and loading more results as the user scrolls. Both Pexels and Unsplash support paginated API requests, making it efficient for loading large image collections.

- **Implemented using ScrollController**
- API calls increment page count on scroll end
- Seamless loading without UI jank

---

## 📦 Key Dependencies

| Package                  | Purpose                                                                 |
|--------------------------|-------------------------------------------------------------------------|
| `http`                   | To make REST API calls to Pexels and Unsplash                          |
| `cached_network_image`   | Efficient image loading with memory and disk caching                   |
| `flutter_cache_manager`  | Custom cache control for downloaded image assets                        |
| `image_gallery_saver` / `saver_gallery` | Save downloaded wallpapers to the device gallery         |
| `flutter_wallpaper_manager` | Set wallpaper directly from the app (Android only)                 |
| `permission_handler`     | Manage runtime permissions (e.g., storage access for saving wallpapers) |
| `palette_generator`      | Extract dominant color from wallpapers for theming/background effects   |
| `carousel_slider`        | Image sliders and featured wallpaper carousels                          |
| `share_plus`             | Enable sharing wallpapers directly from the app                         |
| `flutter_launcher_icons`| Customize the app launcher icon                                         |
| `flutter_native_splash` | Configure native splash screen for branding                             |


---

## 🔐 API Setup

- **Pexels:**  
  Sign up at [pexels.com](https://pexels.com), get your API key, and set it in `pexels_api.dart`

- **Unsplash:**  
  Create a developer account at [unsplash.com/developers](https://unsplash.com/developers), get the Access Key, and set it in `unsplash_api.dart`


## 👨‍💻 Author

**Devansh Dhopte**  
Crafted to experiment with third-party APIs and deliver an aesthetic wallpaper browsing experience using Flutter.

---

> _"A beautifully crafted wallpaper discovery app powered by two of the most generous image APIs."_  
