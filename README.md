# Mirror Me - Virtual Try-On App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Gemini AI](https://img.shields.io/badge/Gemini_AI-8E75B2?style=for-the-badge&logo=google&logoColor=white)

A Flutter application that uses Google Gemini AI for virtual clothing try-on, wardrobe management, and personalized fashion recommendations. Built with Clean Architecture and powered by Supabase.

</div>

---

## Features

### Authentication
- Email/password signup and login via Supabase Auth
- Automatic profile creation on registration
- Persistent sessions with auto-login
- Row-level security for all user data

### Wardrobe Management
- Upload and organize clothing items with images
- Categorize items (T-Shirt, Shirt, Trousers, Dress, Jacket, Shoes, etc.)
- Cloud-hosted images via Supabase Storage
- Full CRUD operations with per-user isolation

### Pose Gallery
- Store reference poses for virtual try-on
- Categorize poses (Front View, Side View, Full Body, etc.)
- Add descriptions and notes to each pose
- Full-screen viewer with pinch-to-zoom

### Virtual Try-On (AI)
- Select a pose from your gallery and a clothing item from your wardrobe
- Gemini AI generates a realistic try-on image
- Save results to cloud storage
- Favorite system for quick access to best results

### AI Recommendations
- Upload an image from gallery, wardrobe, try-on results, or device
- Gemini AI analyzes the outfit and provides styling advice
- Recommendations rendered as formatted markdown
- Save and revisit past recommendations

---

## Architecture

The app follows **Clean Architecture** with feature-based modularity:

```
lib/
├── main.dart                        # App entry point
├── injection_container.dart         # GetIt dependency injection
├── supabase_options.dart            # Supabase credentials (gitignored)
│
├── core/
│   ├── constants/
│   │   └── gemini_config.dart       # Gemini API config (gitignored)
│   ├── errors/
│   │   ├── exception.dart           # ServerException, CacheException
│   │   └── failure.dart             # Failure base class
│   └── theme/
│       └── app_theme.dart           # Material 3 theme + reusable widgets
│
└── features/
    ├── auth/                        # Authentication
    ├── wardrobe/                    # Clothing management
    ├── gallery/                     # Pose image library
    ├── tryon/                       # AI virtual try-on
    └── recommendations/             # AI fashion advice
```

Each feature follows a three-layer structure:

| Layer | Contents | Purpose |
|-------|----------|---------|
| **data** | DataSources, Models, Repository Impl | API calls, JSON mapping, data logic |
| **domain** | Entities, Repository Interfaces, UseCases | Business rules, pure Dart |
| **presentation** | BLoC, Pages, Widgets | UI, state management |

### Key Patterns
- **BLoC** for state management (`flutter_bloc`)
- **Repository** pattern for data abstraction
- **UseCase** pattern for single-responsibility business logic
- **Either** (from `dartz`) for functional error handling
- **GetIt** service locator for dependency injection

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.10.0`
- A [Supabase](https://supabase.com) project
- A [Gemini API key](https://aistudio.google.com/apikey)

### 1. Clone & Install

```bash
git clone https://github.com/Theek237/Mirror-Me.git
cd Mirror-Me
flutter pub get
```

### 2. Configure Supabase

Copy the example file and add your credentials:

```bash
cp lib/supabase_options.dart.example lib/supabase_options.dart
```

Edit `lib/supabase_options.dart` with your Project URL and anon key from **Supabase Dashboard > Project Settings > API**.

### 3. Configure Gemini AI

```bash
cp lib/core/constants/gemini_config.dart.example lib/core/constants/gemini_config.dart
```

Edit `lib/core/constants/gemini_config.dart` with your API key from [Google AI Studio](https://aistudio.google.com/apikey).

### 4. Set Up Database

Run the SQL scripts in your Supabase SQL Editor **in order**:

1. [`docs/01_schema.sql`](docs/01_schema.sql) - Users and wardrobe tables
2. [`docs/02_gallery_setup.sql`](docs/02_gallery_setup.sql) - Gallery tables and storage
3. [`docs/03_tryon_setup.sql`](docs/03_tryon_setup.sql) - Try-on results tables and storage
4. [`docs/04_recommendations_setup.sql`](docs/04_recommendations_setup.sql) - Recommendations and favorites

### 5. Set Up Storage Buckets

Follow [`docs/storage_setup.md`](docs/storage_setup.md) to create the required Supabase Storage buckets:

| Bucket | Purpose | Access |
|--------|---------|--------|
| `wardrobe` | Clothing item images | Public with RLS |
| `gallery` | User pose images | Public with RLS |
| `tryon` | Generated try-on results | Public with RLS |

### 6. Run

```bash
flutter run
```

---

## Database Schema

| Table | Key Columns | Description |
|-------|-------------|-------------|
| `users` | id, name, email, photo_url | User profiles (auto-created on signup) |
| `wardrobe` | id, user_id, name, category, image_url | Clothing items |
| `user_images` | id, user_id, image_url, pose_name, description | Gallery poses |
| `tryon_results` | id, user_id, pose_image_url, clothing_image_url, result_image_url, is_favorite | AI try-on outputs |
| `recommendations` | id, user_id, image_url, recommendation_text, image_source | AI styling advice |

All tables use Row-Level Security (RLS) to isolate user data.

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management (BLoC pattern) |
| `get_it` | Dependency injection |
| `supabase_flutter` | Backend, auth, and storage |
| `google_generative_ai` | Gemini AI SDK |
| `dio` / `http` | HTTP networking |
| `dartz` | Functional `Either` type |
| `equatable` | Value equality for entities and states |
| `cached_network_image` | Image caching and loading |
| `flutter_markdown` | Render AI recommendations |
| `image_picker` | Camera and gallery image selection |
| `uuid` | Unique ID generation |

---

## Project Theme

The app uses a warm, fashion-forward Material 3 palette:

| Color | Hex | Usage |
|-------|-----|-------|
| Deep Navy | `#1A1A2E` | Primary |
| Coral Red | `#E94560` | Secondary / Accent buttons |
| Cream | `#F5E6CC` | Accent backgrounds |
| Warm White | `#FAF8F5` | Scaffold background |

Reusable theme widgets: `GradientContainer`, `GlassCard`, `AccentTag` (defined in `app_theme.dart`).

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Supabase connection error | Verify URL and anon key in `supabase_options.dart` |
| Gemini API error | Check API key in `gemini_config.dart`; ensure billing is enabled |
| Image upload failure | Verify storage bucket names and RLS policies in Supabase |
| Build errors | Run `flutter clean && flutter pub get && flutter run` |

---

## License

This project is licensed under the MIT License.

---

## Author

**Theek237** - [GitHub](https://github.com/Theek237)
