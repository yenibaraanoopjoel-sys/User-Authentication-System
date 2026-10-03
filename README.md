# 🔐 User Authentication System

A complete, production-ready, modern **User Authentication & Account Management System** built with **Flutter**, **Dart**, and **Firebase**.

[![Live Demo](https://img.shields.io/badge/Live_Demo-Firebase_Hosting-007ACC?style=for-the-badge&logo=firebase&logoColor=FFCA28)](https://user-authentication-syst-98bd7.web.app)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-FFA611?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20Windows-brightgreen?style=for-the-badge)](https://user-authentication-syst-98bd7.web.app)

---

## 🌐 Live Web Application

The application is deployed and live on Firebase Hosting:
* 👉 **Primary URL:** [https://user-authentication-syst-98bd7.web.app](https://user-authentication-syst-98bd7.web.app)
* 👉 **Alternative URL:** [https://user-authentication-syst-98bd7.firebaseapp.com](https://user-authentication-syst-98bd7.firebaseapp.com)
* **Firebase Console:** [User Authentication System Project Overview](https://console.firebase.google.com/project/user-authentication-syst-98bd7/overview)

> [!IMPORTANT]
> ### ⚙️ One-Time Firebase Console Activation
> To allow new users to sign up and log in, ensure **Email/Password** is enabled in the Firebase Console:
> 1. Open the [Firebase Authentication Console](https://console.firebase.google.com/project/user-authentication-syst-98bd7/authentication).
> 2. Click the blue **"Get started"** button (if you haven't already).
> 3. Under the **"Sign-in method"** tab, select **"Email/Password"**.
> 4. Switch the first toggle **"Enable"** to **ON** and click **Save**.
>
> Once enabled, user registrations, logins, email verifications, and profile persistence will function in real time!

---

## 📖 About the Application

The **User Authentication System** is designed to demonstrate real-world authentication and user profile lifecycle management in mobile and web applications. It bridges **Firebase Authentication** for identity, credential management, and session tokens with **Cloud Firestore** for real-time user profile data persistence.

Rather than being a simple UI prototype, this system provides full end-to-end integration:
* Automatic routing based on live Firebase authentication state
* Email verification enforcement
* Real-time Firestore profile sync with server timestamping
* Secure password updates and irreversible account deletion
* Production-grade error handling with user-friendly error banners and validation

---

## ✨ Features

### 1. 🔑 Authentication & Security
* **User Registration:** Creates a new Firebase Auth account, captures the user's full name, and initializes their Cloud Firestore document.
* **Email & Password Login:** Secure authentication with persistent login state across app restarts or browser refreshes.
* **Password Reset / Recovery:** Dispatches password reset emails directly through Firebase Auth with instant feedback.
* **Email Verification Flow:** Dedicated screen that checks email confirmation status in real-time, with a resend cooldown timer and redirect upon verification.
* **Session Management:** Centralized `AuthService` exposing `authStateChanges` stream for instantaneous route transitions.

### 2. 👤 Account & Profile Management
* **Personal Profile:** View and update display name, phone number, and bio.
* **Avatar & Status:** Dynamic initials avatar, verification badges, and account creation dates.
* **Change Password:** In-app secure password update modal with validation.
* **Delete Account:** Dual-confirmation dialog to permanently erase both Firebase Auth credentials and Firestore profile records.
* **Sign Out:** One-click secure session termination.

### 3. 🎨 Modern UI & UX Design
* **Curated Dark Theme:** Deep slate background (`#0B0F19`), surface elevations (`#111827`, `#1F2937`), and vibrant electric indigo accent (`#6366F1`).
* **Micro-interactions & Polish:** Form field focus transitions, password visibility toggles, loading spinners, and styled dialogs.
* **Responsive Layout:** Adaptive centered card layouts optimized for mobile, tablet, and desktop screens.
* **Typography:** Clean, legible modern typography using Google Fonts (Inter).

### 4. 🛡️ Cloud Security
* **Firestore Security Rules:** Granular rule enforcement ensuring authenticated users can strictly read and write only their own records (`request.auth.uid == userId`).

---

## 🏗️ Architecture & Project Structure

```text
User-Authentication-System/
├── android/                   # Android native platform configuration & google-services.json
├── web/                       # Web platform configuration & index.html
├── firestore.rules            # Security rules for Cloud Firestore
├── firebase.json              # Firebase hosting & project configuration
├── .firebaserc                # Firebase CLI active project mapping
└── lib/
    ├── main.dart              # App entry point, theme setup, & Firebase initialization
    ├── firebase_options.dart  # Multi-platform Firebase configuration
    ├── models/
    │   └── user_model.dart    # UserModel data class with Firestore serialization
    ├── services/
    │   ├── auth_service.dart      # Firebase Authentication service wrapper
    │   └── firestore_service.dart # Cloud Firestore profile CRUD service
    ├── routes/
    │   └── app_routes.dart    # Centralized named routes & page transitions
    ├── screens/
    │   ├── splash_screen.dart             # Auth gate & splash screen
    │   ├── login_screen.dart              # User sign-in interface
    │   ├── register_screen.dart           # User account creation interface
    │   ├── forgot_password_screen.dart    # Password reset email interface
    │   ├── email_verification_screen.dart # Email confirmation interface
    │   ├── dashboard_screen.dart          # Authenticated home dashboard
    │   └── profile_screen.dart            # Profile view, editing & account settings
    ├── utils/
    │   ├── app_colors.dart    # Design system color palette
    │   └── validators.dart    # Form validation rules (email, password strength, etc.)
    └── widgets/
        ├── custom_text_field.dart # Reusable styled text input with icons
        ├── primary_button.dart    # Gradient action buttons with loading states
        └── loading_indicator.dart # Consistent loading overlays
```

---

## 🛠️ Tech Stack & Dependencies

* **Frontend:** [Flutter](https://flutter.dev) (Dart)
* **Backend & Auth:** [Firebase Authentication](https://firebase.google.com/docs/auth)
* **Database:** [Cloud Firestore](https://firebase.google.com/docs/firestore)
* **Hosting:** [Firebase Hosting](https://firebase.google.com/docs/hosting)
* **Key Packages:**
  * `firebase_core`: `^3.15.2`
  * `firebase_auth`: `^5.7.0`
  * `cloud_firestore`: `^5.6.8`
  * `google_fonts`: `^6.3.3`
  * `intl`: `^0.20.2`

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (version `>=3.6.0`)
* [Firebase CLI](https://firebase.google.com/docs/cli) installed and logged in (`firebase login`)
* Google Chrome (for web testing) or Android device / emulator

### 1. Clone the Repository
```bash
git clone https://github.com/yenibaraanoopjoel-sys/User-Authentication-System.git
cd User-Authentication-System
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Locally
To run on Chrome (Web):
```bash
flutter run -d chrome
```

To run on an Android Device or Emulator:
```bash
flutter run -d android
```

### 4. Build & Deploy to Firebase Hosting
```bash
# Build production web bundle
flutter build web --release

# Deploy hosting & security rules
firebase deploy --only hosting,firestore:rules
```

---

## 🔒 Security Configuration

The Firestore database is safeguarded by strict authorization rules:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // User profile documents: only authenticated users can access their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
