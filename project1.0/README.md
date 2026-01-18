# Mirror Me - Virtual Try-On App 👗

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Gemini AI](https://img.shields.io/badge/Gemini_AI-8E75B2?style=for-the-badge&logo=google&logoColor=white)

**A sophisticated Flutter application that leverages AI to provide virtual try-on experiences, wardrobe management, and personalized fashion recommendations.**

[Features](#-features) • [Architecture](#-architecture) • [Setup](#%EF%B8%8F-installation--setup) • [Configuration](#-configuration) • [Database](#-database-schema) • [Contributing](#-contributing)

</div>

---

## 📱 Overview

**Mirror Me** is a cutting-edge mobile application that revolutionizes the way users interact with fashion. By combining advanced AI technology from Google's Gemini API with Flutter's cross-platform capabilities and Supabase's robust backend infrastructure, the app delivers a seamless virtual try-on experience that helps users visualize outfits before making purchase decisions.

### 🎯 Key Objectives

- **Virtual Try-On**: Use AI-powered image generation to see how clothing items look on you
- **Digital Wardrobe**: Organize and manage your clothing collection digitally
- **Pose Gallery**: Store and manage reference poses for try-on experiences
- **AI Recommendations**: Get personalized styling advice powered by Gemini AI
- **Secure Authentication**: User-friendly authentication with Supabase

---

## ✨ Features

### 🔐 Authentication System
- **Email/Password Authentication** - Secure user registration and login
- **User Profile Management** - Store and manage user information
- **Auto-profile Creation** - Automatic profile generation on signup
- **Session Management** - Persistent login sessions with Supabase Auth
- **Row-Level Security** - Database-level security for user data

### 👔 Wardrobe Management
- **Digital Closet** - Upload and store clothing items with images
- **Category Organization** - Organize items by category (tops, bottoms, dresses, etc.)
- **Image Storage** - Cloud-based image hosting via Supabase Storage
- **Item CRUD Operations** - Complete Create, Read, Update, Delete functionality
- **User-specific Storage** - Private wardrobe accessible only to the owner

### 📸 Gallery Feature
- **Pose Library** - Store reference poses for virtual try-on
- **Image Management** - Upload, view, and delete user poses
- **Pose Descriptions** - Add context and notes to each pose
- **Cloud Synchronization** - Automatic sync across devices
- **RLS Protection** - Gallery items secured per user

### 🎨 Virtual Try-On (AI-Powered)
- **AI Image Generation** - Generate realistic try-on images using Gemini AI
- **Multi-image Support** - Combine pose images with clothing items
- **Result Saving** - Store generated try-on results in the cloud
- **Favorite System** - Mark favorite try-on results for quick access
- **History Tracking** - View all past try-on experiments
- **Custom Prompts** - Optional AI customization for specific styles

### 💡 AI Recommendations
- **Style Analysis** - Upload outfit images for AI analysis
- **Fashion Advice** - Get personalized recommendations from Gemini AI
- **Recommendation History** - Save and revisit past recommendations
- **Image Source Tracking** - Track whether recommendations came from gallery, wardrobe, or try-on
- **Context-aware Suggestions** - AI considers your personal style and preferences

---

## 🏗️ Architecture

This application follows **Clean Architecture** principles with a feature-based modular structure, ensuring high maintainability, testability, and scalability.

### 📐 Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  (UI, BLoC, Pages, Widgets)                                 │
│  • User Interface Components                                 │
│  • State Management (flutter_bloc)                          │
│  • User Interactions                                         │
└─────────────────────────────────────────────────────────────┘
                            ↕️
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                             │
│  (Entities, UseCases, Repository Interfaces)                │
│  • Business Logic                                            │
│  • Pure Dart (Framework Independent)                        │
│  • Abstract Definitions                                      │
└─────────────────────────────────────────────────────────────┘
                            ↕️
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                              │
│  (Models, Repository Implementations, Data Sources)         │
│  • API Communication                                         │
│  • Data Transformation                                       │
│  • External Services Integration                            │
└─────────────────────────────────────────────────────────────┘
```

### 🗂️ Project Structure

```
lib/
├── core/                           # Core functionality
│   ├── constants/                  # App-wide constants
│   │   └── gemini_config.dart      # AI API configuration
│   ├── errors/                     # Error handling
│   │   ├── exception.dart          # Custom exceptions
│   │   └── failure.dart            # Failure classes
│   └── theme/                      # UI theming
│       └── app_theme.dart          # App-wide theme definitions
│
├── features/                       # Feature modules
│   ├── auth/                       # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_currentuser_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── auth_bloc.dart
│   │       └── pages/
│   │           ├── auth_wrapper.dart
│   │           ├── login_page.dart
│   │           ├── register_page.dart
│   │           └── home_page.dart
│   │
│   ├── wardrobe/                   # Wardrobe management
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── wardrobe_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── clothing_item_model.dart
│   │   │   └── repositories/
│   │   │       └── wardrobe_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── clothing_item.dart
│   │   │   └── repositories/
│   │   │       └── wardrobe_repository.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── wardrobe_bloc.dart
│   │       └── pages/
│   │           └── wardrobe_page.dart
│   │
│   ├── gallery/                    # User pose gallery
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── gallery_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── user_image_model.dart
│   │   │   └── repositories/
│   │   │       └── gallery_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_image.dart
│   │   │   └── repositories/
│   │   │       └── gallery_repository.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── gallery_bloc.dart
│   │       └── pages/
│   │           └── gallery_page.dart
│   │
│   ├── tryon/                      # Virtual try-on feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── gemini_remote_data_source.dart
│   │   │   │   └── tryon_remote_data_source.dart
│   │   │   └── repositories/
│   │   │       └── tryon_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── tryon_result.dart
│   │   │   ├── repositories/
│   │   │   │   └── tryon_repository.dart
│   │   │   └── usecases/
│   │   │       ├── generate_tryon.dart
│   │   │       ├── save_tryon_result.dart
│   │   │       ├── get_tryon_results.dart
│   │   │       └── toggle_tryon_favorite.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── tryon_bloc.dart
│   │       └── pages/
│   │           └── tryon_page.dart
│   │
│   └── recommendations/            # AI recommendations
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── recommendation_remote_data_source.dart
│       │   │   └── recommendation_supabase_data_source.dart
│       │   └── repositories/
│       │       └── recommendation_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── recommendation.dart
│       │   ├── repositories/
│       │   │   └── recommendation_repository.dart
│       │   └── usecases/
│       │       ├── generate_recommendation.dart
│       │       ├── save_recommendation.dart
│       │       └── get_recommendations.dart
│       └── presentation/
│           ├── bloc/
│           │   └── recommendation_bloc.dart
│           └── pages/
│               └── recommendations_page.dart
│
├── injection_container.dart        # Dependency Injection setup
├── main.dart                       # App entry point
└── supabase_options.dart          # Supabase configuration
```

### 🎯 Design Patterns Used

1. **Clean Architecture** - Separation of concerns across layers
2. **Repository Pattern** - Abstract data access
3. **BLoC Pattern** (Business Logic Component) - State management
4. **Dependency Injection** - Using GetIt service locator
5. **UseCase Pattern** - Single responsibility for business logic
6. **Either Pattern** - Functional error handling with dartz

---

## 🛠️ Installation & Setup

### Prerequisites

Ensure you have the following installed:

- **Flutter SDK**: `>=3.10.0`
- **Dart SDK**: `>=3.10.0`
- **Android Studio** / **Xcode** (for mobile development)
- **VS Code** or **Android Studio** (recommended IDEs)
- **Git**

### 📥 Clone the Repository

```bash
git clone https://github.com/Theek237/Mirror-Me.git
cd Mirror-Me/project1.0
```

### 📦 Install Dependencies

```bash
flutter pub get
```

### 🔧 Configuration

#### 1. Supabase Setup

1. Create a Supabase account at [supabase.com](https://supabase.com)
2. Create a new project
3. Copy your project URL and anon key

#### 2. Configure Supabase Options

Create or update `lib/supabase_options.dart`:

```dart
class SupabaseOptions {
  static const String url = 'YOUR_SUPABASE_PROJECT_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

#### 3. Database Setup

Run the following SQL scripts in your Supabase SQL Editor (in order):

1. **`supabase_schema.sql`** - Creates base tables (users, wardrobe)
2. **`supabase_gallery_setup.sql`** - Sets up gallery feature
3. **`supabase_tryon_setup.sql`** - Sets up try-on feature
4. **`supabase_update_setup.sql`** - Adds recommendations and additional features

#### 4. Storage Setup

Follow instructions in **`SUPABASE_STORAGE_SETUP.md`** to configure:
- `wardrobe` bucket (public)
- `gallery` bucket (public)
- `tryon` bucket (public)

Set up storage policies for authenticated users.

#### 5. Gemini AI Configuration

1. Get your API key from [Google AI Studio](https://aistudio.google.com/apikey)
2. Copy `lib/core/constants/gemini_config.dart.example` to `lib/core/constants/gemini_config.dart`
3. Replace `YOUR_API_KEY_HERE` with your actual API key:

```dart
class GeminiConfig {
  static const String apiKey = 'YOUR_GEMINI_API_KEY';
  static const String imageModel = 'gemini-3-pro-image-preview';
}
```

⚠️ **Security Note**: Never commit your actual API keys to version control!

### ▶️ Run the Application

```bash
# For development
flutter run

# For specific device
flutter run -d chrome  # Web
flutter run -d macos   # macOS
flutter run -d android # Android
flutter run -d ios     # iOS
```

### 🏗️ Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

---

## 📚 Core Dependencies

### Production Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^9.1.1 | State management |
| `supabase_flutter` | ^2.8.3 | Backend & authentication |
| `google_generative_ai` | ^0.4.6 | Gemini AI integration |
| `get_it` | ^9.2.0 | Dependency injection |
| `dartz` | ^0.10.1 | Functional programming (Either) |
| `equatable` | ^2.0.7 | Value equality |
| `cached_network_image` | ^3.4.1 | Image caching |
| `image_picker` | ^1.2.1 | Image selection |
| `dio` | ^5.9.0 | HTTP client |
| `provider` | ^6.1.5+1 | State management support |
| `uuid` | ^4.5.2 | Unique ID generation |
| `http` | ^1.2.2 | HTTP requests |
| `path_provider` | ^2.1.5 | File system paths |
| `flutter_markdown` | ^0.7.4+3 | Markdown rendering |
| `internet_connection_checker` | ^3.0.1 | Network connectivity |
| `injectable` | ^2.7.1+2 | DI code generation |

### Development Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_lints` | ^6.0.0 | Code quality |
| `build_runner` | ^2.10.4 | Code generation |
| `injectable_generator` | ^2.11.1 | DI code generation |

---

## 🗄️ Database Schema

### Tables Overview

#### 1. **users** (User Profiles)
```sql
- id (UUID, PK, references auth.users)
- name (TEXT)
- email (TEXT)
- photo_url (TEXT)
- auth_provider (TEXT) [default: 'email']
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

#### 2. **wardrobe** (Clothing Items)
```sql
- id (UUID, PK)
- user_id (UUID, FK → users.id)
- name (TEXT)
- category (TEXT)
- image_url (TEXT)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

#### 3. **user_images** (Gallery/Pose Images)
```sql
- id (UUID, PK)
- user_id (UUID, FK → users.id)
- image_url (TEXT)
- pose_name (TEXT)
- description (TEXT, nullable)
- created_at (TIMESTAMP)
```

#### 4. **tryon_results** (Virtual Try-On Results)
```sql
- id (UUID, PK)
- user_id (UUID, FK → users.id)
- pose_image_url (TEXT)
- clothing_image_url (TEXT)
- result_image_url (TEXT)
- prompt (TEXT, nullable)
- is_favorite (BOOLEAN) [default: false]
- created_at (TIMESTAMP)
```

#### 5. **recommendations** (AI Fashion Recommendations)
```sql
- id (UUID, PK)
- user_id (UUID, FK → users.id)
- image_url (TEXT)
- recommendation_text (TEXT)
- image_source (TEXT, nullable) ['gallery', 'wardrobe', 'tryon', 'upload']
- created_at (TIMESTAMP)
```

### Storage Buckets

- **`wardrobe`** - Clothing item images (public)
- **`gallery`** - User pose images (public)
- **`tryon`** - Generated try-on results (public)

All buckets use Row-Level Security (RLS) to ensure users can only access their own data.

---

## 🎨 UI/UX Design

### Color Palette

```dart
Primary Color:    #1A1A2E  (Deep Navy)
Secondary Color:  #E94560  (Coral Red)
Accent Color:     #F5E6CC  (Cream)
Highlight Color:  #16213E  (Midnight Blue)
Background:       #FAF8F5  (Warm White)
```

### Theme Features

- **Material Design 3** (Material You)
- **Warm, Fashion-forward Palette**
- **Custom Gradients** for premium feel
- **Responsive Typography**
- **Consistent Spacing** (8px grid system)
- **Smooth Animations**

---

## 🚀 Features in Detail

### Authentication Flow

```
App Start
   ↓
AuthWrapper (checks session)
   ↓
├── Authenticated? → HomePage
└── Not Authenticated → LoginPage
         ↓
    [Login/Register]
         ↓
    Supabase Auth
         ↓
    Auto-create user profile
         ↓
    Navigate to HomePage
```

### Wardrobe Management Flow

```
User uploads clothing image
   ↓
Image Picker → Local file
   ↓
Upload to Supabase Storage (wardrobe bucket)
   ↓
Get public URL
   ↓
Save metadata to 'wardrobe' table
   ↓
Display in UI (with caching)
```

### Virtual Try-On Flow

```
User selects:
- Pose image (from gallery)
- Clothing item (from wardrobe)
   ↓
Convert images to bytes
   ↓
Send to Gemini AI API
   ↓
AI generates try-on result
   ↓
Upload result to Supabase Storage
   ↓
Save to 'tryon_results' table
   ↓
Display result to user
   ↓
Option to save to favorites
```

### Recommendations Flow

```
User uploads outfit image
   ↓
Convert to bytes
   ↓
Send to Gemini AI with fashion prompt
   ↓
AI analyzes and provides recommendations
   ↓
Display recommendations to user
   ↓
Option to save recommendation
   ↓
Store in 'recommendations' table
```

---

## 🔒 Security Features

1. **Row-Level Security (RLS)** - Database-level user isolation
2. **Authentication Required** - All features require valid session
3. **Storage Policies** - User-specific file access
4. **API Key Management** - Keys stored securely (not in version control)
5. **Input Validation** - Client and server-side validation
6. **HTTPS Only** - Secure communication with Supabase and APIs

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Integration tests
flutter test integration_test
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Supabase Connection Error
```
Solution: Verify your supabase_options.dart has correct URL and anon key
```

#### 2. Gemini API Error
```
Solution: 
- Check your API key in gemini_config.dart
- Ensure you have billing enabled on Google AI Studio
- Verify model name is correct
```

#### 3. Image Upload Failure
```
Solution:
- Check storage bucket policies in Supabase
- Verify bucket names match code ('wardrobe', 'gallery', 'tryon')
- Ensure buckets are set to public
```

#### 4. Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### 5. Dependency Conflicts
```bash
# Update dependencies
flutter pub upgrade
flutter pub outdated
```

---

## 📈 Performance Optimizations

- **Image Caching** - Using `cached_network_image`
- **Lazy Loading** - BLoC state management prevents unnecessary rebuilds
- **Optimized Database Queries** - Indexed columns for faster searches
- **Compressed Images** - Storage optimization
- **Connection Checking** - Prevent unnecessary API calls

---

## 🔮 Future Enhancements

- [ ] Social sharing of try-on results
- [ ] Outfit combinations suggestions
- [ ] Weather-based recommendations
- [ ] Style quiz for personalization
- [ ] AR try-on using device camera
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Outfit calendar/planner
- [ ] Community features (share looks)
- [ ] Integration with e-commerce platforms

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Standards

- Follow [Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed
- Ensure code passes `flutter analyze`

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👥 Authors

**Theek237** - *Initial work* - [GitHub](https://github.com/Theek237)

---

## 🙏 Acknowledgments

- **Flutter Team** - Amazing cross-platform framework
- **Supabase Team** - Excellent backend-as-a-service
- **Google AI Studio** - Powerful Gemini AI capabilities
- **Open Source Community** - For incredible packages and support

---

## 📞 Support

For support, email your-email@example.com or open an issue in the repository.

---

## 📊 Project Status

🟢 **Active Development** - Currently in version 0.1.0

---

## 🔗 Important Links

- [Flutter Documentation](https://flutter.dev/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Gemini AI Documentation](https://ai.google.dev/docs)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev/)

---

<div align="center">

**Made with ❤️ using Flutter**

⭐ Star this repo if you find it helpful!

</div>
