# 🧵 Zubair Tailors Management System

A comprehensive, offline-first shop management system designed for tailoring businesses. This repository contains the source code for the **Zubair Tailors Mobile App** (built using Flutter), administrative tools for license generation, and development briefs for future native Android migration.

---

## 📂 Repository Structure

The repository is organized as follows:

*   **[`mobile_app/`](file:///e:/Zubair%20Tailors/mobile_app)**: The primary mobile application built with Flutter (Material 3). It supports customer management, measurements tracking (with historic logs), order status tracking, custom PDF invoicing, offline-first SQLite storage, Google Drive sync, and bilingual localization (English / Urdu).
*   **[`generate-unlock-code.ps1`](file:///e:/Zubair%20Tailors/generate-unlock-code.ps1)**: A PowerShell administrative script used to generate device-specific offline license activation keys.
*   **[`kotlin_app_prompt.md`](file:///e:/Zubair%20Tailors/kotlin_app_prompt.md)**: A complete, structured system specification and development brief detailing all requirements, schemas, and logic for migrating the Flutter app to a native Kotlin Android application (using Jetpack Compose, Room, DataStore, and AlarmManager).

---

## 📱 Mobile App (Flutter)

The core product is a fully offline-first app that runs on Android, iOS, and Windows/Linux desktop environments (web is not supported due to native SQLite requirements).

### Key Features
*   **Customers & Measurements**: Store complete customer files with detailed measurements for *Shalwar Kameez*, *Waistcoat*, *Two-Piece*, and *Three-Piece* suits (with historical backup).
*   **Order & Payment Workflows**: Create orders with custom delivery dates, priority status, reference photos, linear status tracking (Pending ➔ In Progress ➔ Ready ➔ Delivered), and automatic payment-on-delivery collection prompts.
*   **Bilingual & Adaptive UI**: Full support for English and Urdu with automatic Right-to-Left (RTL) layout switching and an offline theme toggle (Light / Dark Mode).
*   **Google Drive Backups**: Sync offline SQLite databases directly to the shop owner's personal Google Drive folder for safe-keeping.
*   **Security & Licensing**: Keep data safe via a 4-digit PIN stored in encrypted secure storage, and enforce monetization with a 7-day offline trial and device-locked activation codes.
*   **Utility Services**: One-tap WhatsApp notifications, local notifications for delivery reminders (Android only), PDF invoice generation, and CSV data export.

For deep-dive setup instructions, Google Cloud/Drive OAuth configuration, and platform-specific build details, please refer to the **[Mobile App README](file:///e:/Zubair%20Tailors/mobile_app/README.md)**.

---

## 🔑 Administrative License Key Generator

The mobile app includes a licensing gate to manage activations. To activate a device, you can use the provided **[`generate-unlock-code.ps1`](file:///e:/Zubair%20Tailors/generate-unlock-code.ps1)** utility.

### Generating an Activation Key

1. Retrieve the **Device ID** from the application's licensing/trial screen (derived from the hardware's secure Android ID).
2. Open PowerShell and run the script, passing the Device ID as a parameter:
   ```powershell
   .\generate-unlock-code.ps1 -DeviceId "DEVICE_ID_HERE"
   ```
3. The script will generate a unique 8-character uppercase unlock code linked exclusively to that device.

---

## 🤖 Kotlin Migration Specification

For teams or developers looking to port this project from Flutter to a native Android application, **[`kotlin_app_prompt.md`](file:///e:/Zubair%20Tailors/kotlin_app_prompt.md)** contains a complete mapping of Flutter packages and state paradigms to their modern native counterparts:
*   **UI Layout**: Flutter Widgets ➔ Jetpack Compose (Material 3)
*   **Local Persistence**: `sqflite` ➔ Room Database
*   **Local Notifications & Reminders**: `AlarmManager` + `BroadcastReceiver`
*   **Encrypted PIN Storage**: `flutter_secure_storage` ➔ `EncryptedSharedPreferences`

Refer to the prompt document directly to bootstrap native Kotlin development.

---

## 🛠️ Quick Start

To run the Flutter mobile app in your local development environment:

1. Navigate to the mobile app directory:
   ```bash
   cd mobile_app
   ```
2. Install the necessary dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application on your connected emulator or physical device:
   ```bash
   flutter run
   ```

*Note: For detailed Android NDK pinning guidelines, local notification configurations, and asset generation instructions, see the [mobile app documentation](file:///e:/Zubair%20Tailors/mobile_app/README.md).*
