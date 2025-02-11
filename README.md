<div align="center">
  <!-- <img src="assets/sample/logo.png" alt="ChitChat Logo" width="150"/> -->
  
  # ✨ ChitChat App
  
  <p align="center">
    <strong>A sleek and modern Flutter chat application with powerful features</strong>
  </p>
  
  <p>
    <a href="#features">Features</a> •
    <a href="#preview">Preview</a> •
    <a href="#installation">Installation</a> •
    <a href="#architecture">Architecture</a> •
    <a href="#contributing">Contributing</a>
  </p>

  <div align="center">
    <img src="https://img.shields.io/badge/Flutter-3.0.0-blue.svg" alt="Flutter Version" />
    <img src="https://img.shields.io/badge/Dart-3.0.0-green.svg" alt="Dart Version" />
    <img src="https://img.shields.io/badge/License-MIT-red.svg" alt="License" />
    <img src="https://img.shields.io/badge/PRs-Welcome-brightgreen.svg" alt="PRs Welcome" />
  </div>
</div>

<br>

## 🌟 Preview

<div align="center">
  <h3>Experience ChitChat in Action</h3>
  <img src="assets/sample/ChatIntro.gif" alt="Chat Demo" width="300"/>
</div>

### 📱 App Showcase
<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="assets/sample/image.png" width="250" alt="Home Screen"/>
        <br>
        <em>Home Screen</em>
      </td>
      <td align="center">
        <img src="assets/sample/image-1.png" width="250" alt="Chat Screen"/>
        <br>
        <em>Chat Interface</em>
      </td>
      <td align="center">
        <img src="assets/sample/image-2.png" width="250" alt="Media Preview"/>
        <br>
        <em>Media Sharing</em>
      </td>
    </tr>
  </table>
</div>

## ⚡ Key Features

<div align="center">
  <table>
    <tr>
      <td>
        <h3>🏠 Home Experience</h3>
        <ul>
          <li>Real-time user status</li>
          <li>Smart search functionality</li>
          <li>Beautiful UI with gradients</li>
          <li>Quick profile access</li>
        </ul>
      </td>
      <td>
        <h3>💭 Chat Capabilities</h3>
        <ul>
          <li>Instant messaging</li>
          <li>Rich media sharing</li>
          <li>Message status tracking</li>
          <li>Smart typing indicators</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>
        <h3>🔐 Security</h3>
        <ul>
          <li>Google authentication</li>
          <li>Session management</li>
          <li>Secure data handling</li>
          <li>Privacy controls</li>
        </ul>
      </td>
      <td>
        <h3>📱 Media Features</h3>
        <ul>
          <li>Image optimization</li>
          <li>Video compression</li>
          <li>Cloud storage</li>
          <li>Offline support</li>
        </ul>
      </td>
    </tr>
  </table>
</div>

## 🏗️ Architecture

<div align="center">
  ```
  ┌──────────────────────────────────────────────────────────┐
  │                     ChitChat App                         │
  └──────────────────┬───────────────────┬──────────────────┘
                    │                   │
  ┌──────────────────▼──┐    ┌──────────▼───────┐    ┌──────────────┐
  │   Presentation      │    │  Business Logic   │    │    Data      │
  │   Layer            │    │  Layer            │    │    Layer     │
  ├───────────────────┐│    ├──────────────────┐│    ├─────────────┐│
  │ ┌───────────────┐ ││    │ ┌──────────────┐ ││    │ ┌─────────┐ ││
  │ │    Views      │ ││    │ │  Services    │ ││    │ │ Models  │ ││
  │ └───────────────┘ ││    │ └──────────────┘ ││    │ └─────────┘ ││
  │ ┌───────────────┐ ││    │ ┌──────────────┐ ││    │ ┌─────────┐ ││
  │ │  Controllers  │ ││    │ │  Repositories │ ││    │ │ APIs    │ ││
  │ └───────────────┘ ││    │ └──────────────┘ ││    │ └─────────┘ ││
  │ ┌───────────────┐ ││    │ ┌──────────────┐ ││    │ ┌─────────┐ ││
  │ │    Widgets    │ ││    │ │   Bindings   │ ││    │ │Firebase │ ││
  │ └───────────────┘ ││    │ └──────────────┘ ││    │ └─────────┘ ││
  └───────────────────┘│    └──────────────────┘│    └─────────────┘│
   └───────────────────┘     └──────────────────┘     └─────────────┘
  ```
  
  ### 🔄 Data Flow
  
  ```
  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
  │  Widget  │ => │Controller│ => │ Service  │ => │Firebase  │
  └──────────┘    └──────────┘    └──────────┘    └──────────┘
        ▲              │               │                │
        └──────────────┴───────────────┴────────────────┘
                      Data Flow
  ```
</div>

This architecture follows Clean Architecture principles with:

1. **Presentation Layer**
   - Views & Widgets
   - Controllers (GetX)
   - UI Logic

2. **Business Logic Layer**
   - Services
   - Repositories
   - Use Cases

3. **Data Layer**
   - Models
   - APIs
   - Firebase Integration

### 📱 Project Structure

<details>
<summary><b>📱 Core Modules</b></summary>
<br>

- `app/`
  - `bindings/` - Dependency injection
  - `core/` - Core configurations
  - `data/` - Data layer (models, services)
  - `modules/` - Feature modules
  - `routes/` - App navigation
  - `widgets/` - Reusable widgets
</details>

<details>
<summary><b>🎯 Features</b></summary>
<br>

- `chat/` 
  - Real-time messaging implementation
  - Media handling
  - Message status tracking
- `home/`
  - User listing
  - Search functionality
- `auth/`
  - Authentication flow
  - User session management
</details>

<details>
<summary><b>🛠️ Services</b></summary>
<br>

- `auth_service.dart` - Authentication handling
- `chat_service.dart` - Chat functionality
- `media_service.dart` - Media operations
</details>

<details>
<summary><b>📄 Core Files</b></summary>
<br>

- `app_config.dart` - Application configuration
- `app_pages.dart` - Route definitions
- `initial_binding.dart` - Initial dependencies
</details>

<br>

## 🔧 Environment Setup

1. Copy `.env.example` to `.env`
2. Fill in the required environment variables:
   - `GOOGLE_API_KEY`: Your Google API key for services

Never commit the `.env` file or actual API keys to version control.

## 🔥 Firebase Setup

1. Get `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`
3. Never commit this file to version control

<br>

## 📚 Resources

<div align="center">
  
[![Flutter](https://img.shields.io/badge/Flutter-Docs-02569B?logo=flutter&logoColor=white)](https://docs.flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Docs-FFA611?logo=firebase&logoColor=white)](https://firebase.google.com/docs)
[![GetX](https://img.shields.io/badge/GetX-Package-8A2BE2)](https://pub.dev/packages/get)

</div>

<br>

<div align="center">
  <sub>Built with ❤️ using Flutter and Firebase</sub>
</div>