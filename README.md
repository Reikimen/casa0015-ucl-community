# Campus Social App 📱 🎓

A Flutter-based campus social platform that enables students to connect, share experiences, and discover campus activities through an intuitive mobile interface. Features NFC-based authentication, automatic content translation, and a shake-to-refresh functionality.

![Campus Social App Icon](https://claude.ai/api/placeholder/200/200)

## ✨ Key Features

- **NFC Authentication**: Secure login using campus NFC cards
- **Bilingual Support**: Automatic translation between Chinese and English
- **Shake-to-Refresh**: Unique content update gesture
- **Content Categories**: Organized posts by topics (Study, Activities, Lost & Found, Food, Accommodation)
- **Social Interactions**: Like, comment, and share posts within the community

## 🛠️ Technology Stack

- **Framework**: Flutter 3.6.1+
- **State Management**: Provider
- **Authentication**: NFC Manager
- **Networking**: HTTP/Dio
- **Local Storage**: Shared Preferences
- **UI Components**: Material Design, Cached Network Image
- **Internationalization**: Flutter Localizations
- **Image Handling**: Image Picker, Permission Handler

## 📱 Screenshots

<div align="center">   <img src="/api/placeholder/250/500" alt="Home Screen" width="250"/>   <img src="/api/placeholder/250/500" alt="Profile Page" width="250"/>   <img src="/api/placeholder/250/500" alt="Post Detail" width="250"/> </div>

## 🎥 Demo Video

[Watch Demo Video](https://your-demo-video-link.com/)

## 🚀 Installation

### Prerequisites

- Flutter SDK: >=3.6.1
- Dart SDK: >=3.0.0
- Android Studio / VS Code with Flutter extensions
- Android SDK 21 or higher (for Android)
- iOS 12.0 or higher (for iOS)

### Setup Instructions

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-username/campus-social-app.git
   cd campus-social-app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Set up environment variables**

   - Copy the 

     ```
     .env.example
     ```

      file to 

     ```
     .env
     ```

     ```bash
     cp .env.example .env
     ```

   - Edit the 

     ```
     .env
     ```

      file and add your API keys:

     ```env
     GOOGLE_TRANSLATION_API_KEY=your_actual_api_key_here
     ```

4. **Run the app**

   ```bash
   flutter run
   ```

### Environment Configuration

1. **Google Cloud Translation API**
   - Get an API key from [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
   - Enable Google Cloud Translation API in your project
   - Add your API key to the `.env` file (see Setup Instructions)
2. **NFC Configuration**
   - Ensure your device supports NFC
   - Grant NFC permissions when prompted
   - Test with supported NFC cards (see docs for compatible card types)
3. **Security Note**
   - Never commit your `.env` file to version control
   - The `.gitignore` file is configured to exclude sensitive files
   - For production deployment, set environment variables directly in your hosting platform

## 📦 Dependencies

```yaml
dependencies:
  flutter_localizations: sdk: flutter
  provider: ^6.0.5
  http: ^1.1.0
  dio: ^5.3.2
  shared_preferences: ^2.2.0
  nfc_manager: ^3.3.0
  image_picker: ^1.0.4
  sensors_plus: ^3.0.3
  cached_network_image: ^3.3.0
  permission_handler: ^11.0.1
  intl: ^0.19.0
```

## 🏗️ Architecture

The app follows a clean architecture pattern with:

- **Providers**: State management for app, user, and post data
- **Services**: API and authentication services
- **Models**: Data models for posts, comments, and users
- **Screens**: UI components organized by feature
- **Widgets**: Reusable UI components

## 🌐 Internationalization

The app supports Chinese and English with automatic content translation:

- UI elements translated via `.arb` files
- Content translation powered by Google Cloud Translation API
- Language preference saved locally

## 🔐 Authentication

The app uses NFC-based authentication:

1. User taps their campus NFC card
2. App reads the card UID
3. Authentication service validates the card
4. User session is created

## 📝 Features in Development

- [ ] Push notifications
- [ ] Direct messaging between users
- [ ] Advanced post filtering
- [ ] Event calendar integration
- [ ] Offline mode support

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Contact

Project Lead: Dankao Chen
 Email: zczqdc2@ucl.ac.uk
 GitHub: [@Dankao](https://github.com/Reikimen)

## 🙏 Acknowledgments

- UCL CASA for project support
- Flutter community for excellent packages
- Google Cloud for translation services
- All contributors and testers

------

<div align="center">   Made with ❤️ by UCL CASA </div>
