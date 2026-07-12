# Zubair Tailors

A Flutter app for managing a tailoring shop's customers, measurements, orders, and expenses. Fully offline — all data lives in a local SQLite database on the device, no backend or internet connection required (Google Drive backup is the one optional online feature). Fully bilingual UI (English / Urdu, with RTL support) and dark mode.

## Features

- **Customers** — add, edit, search, and view customers, each with an auto-generated unique ID, phone, address, and notes.
- **Measurements** — record shalwar-kameez measurements per customer (shirt length/width, shoulder, sleeve, collar, chest, ghera, pancha, ban/daman/sleeve style, pockets, and finishing details like ring button, double silai, chamak tar), with a full measurement history per customer.
- **Orders** — create and edit orders linking a customer to one of their measurements: clothing type, price, amount paid (with an outstanding "Due" amount shown automatically), delivery date, an urgent/priority flag, an optional reference photo, and status (Pending → In Progress → Ready → Delivered). Filter the order list by status.
- **Customer order history** — a customer's detail page shows their full order history alongside their measurements.
- **Upcoming Deliveries** — a dedicated view of all non-delivered orders with a delivery date, sorted soonest-first, with overdue orders flagged in red.
- **Delivery reminders** — a local notification fires at 9 AM on an order's delivery date to remind the shop owner it's due (Android only; cancelled automatically once the order is marked Delivered).
- **Dashboard** — at-a-glance counts of customers/orders/pending/ready, quick navigation to every section, and a single search box that searches customers and orders together.
- **Reports** — revenue collected, outstanding payments, total expenses, net profit, and order breakdowns by status and clothing type, filterable by This Month / Last 30 Days / All Time.
- **Expenses** — track shop expenses (Fabric/Material, Rent, Utilities, Salaries, Other) with amount, date, and notes; totals feed into Reports' net profit calculation.
- **WhatsApp notify** — a one-tap button on any order opens WhatsApp with a pre-filled message to the customer about their order status (Pakistani phone numbers only; normalizes local format automatically).
- **PDF invoices** — generate and share a PDF invoice for any order (shop name, customer details, price/paid/due) via the native share sheet.
- **CSV export** — export all customers or all orders as a CSV file (Settings → Export Data) to open in Excel or share elsewhere.
- **App Lock** — an optional 4-digit PIN, set in Settings, required every time the app is opened. The PIN is stored in the device's encrypted secure storage, never in plain preferences.
- **Dark mode** — a full dark theme, toggled in Settings, applied consistently across every screen.
- **Settings** — switch between English and Urdu at any time (applies to every screen in the app); the choice is persisted.
- **Backup & Restore** — connect a Google account once, and the app automatically backs up the database to a visible "Zubair Tailors Backups" folder in that Google Drive every time the app is opened, so Drive stays in sync with whatever local changes were made since the app was last used. Manual "Back Up Now" and "Restore Backup" buttons are also available in Settings for an on-demand backup or to roll back to an earlier one. This is what protects your data if the phone is lost, stolen, or breaks — see [Setting up Google Drive backup](#setting-up-google-drive-backup) below, which you must complete once before it will work. Note: order reference photos are stored locally only and are **not** included in Drive backups.

## Tech stack

- **Flutter** (Material 3)
- **sqflite** for local persistence (`lib/db/database_helper.dart` + `lib/repositories/`), with `sqflite_common_ffi` and `sqlite3_flutter_libs` so the same code also runs on Windows/Linux desktop for local testing. Android and iOS use the native `sqflite` plugin directly. Schema is currently at version 3 (customers, measurements, orders, expenses), migrated non-destructively via `onUpgrade`.
- **provider** for app-wide state (locale, theme, app lock, Google Drive backup status)
- **google_sign_in** + **googleapis** (`drive/v3`) for Google Drive backup/restore (`lib/services/backup_service.dart`, `lib/providers/backup_provider.dart`)
- **flutter_localizations** / `.arb` files for English + Urdu strings across the entire app (see `l10n.yaml`)
- **image_picker**, **path_provider** for order reference photos
- **pdf** + **printing** for generating and sharing PDF invoices (`lib/services/invoice_service.dart`)
- **csv** for CSV export (`lib/services/export_service.dart`)
- **flutter_local_notifications** + **timezone** for delivery reminder notifications (`lib/services/notification_service.dart`, Android only)
- **flutter_secure_storage** for the app-lock PIN (`lib/providers/app_lock_provider.dart`)
- **share_plus**, **url_launcher** for Share App / More Apps / WhatsApp deep links

## Project structure

```
lib/
  db/            DatabaseHelper — schema definition, versioned migrations, and SQLite connection
  models/        Customer, Measurement, Order, Expense (plain Dart classes with toJson/fromJson/copyWith)
  repositories/  CustomerRepository, MeasurementRepository, OrderRepository, ExpenseRepository — all SQL lives here
  services/      BackupService (Google Drive), InvoiceService (PDF), ExportService (CSV), NotificationService (delivery reminders)
  providers/     LocaleProvider, ThemeProvider, BackupProvider, AppLockProvider (ChangeNotifiers)
  screens/       One file per screen (dashboard, customer list/detail, measurement form, order list/form,
                 upcoming deliveries, reports, expense list, settings, app lock, splash)
  widgets/       Shared widgets (app drawer, add-customer sheet, expense form sheet)
  utils/         AppColors (theme-aware design tokens), FractionHelper (unicode fraction input),
                 StatusHelper (maps stored English status/category/range values to the current locale's display text),
                 WhatsappHelper (phone normalization + message building)
  l10n/          Generated localization code + app_en.arb / app_ur.arb source strings
```

There is no `services/api_service.dart` layer — screens talk to the repositories directly, which talk to SQLite. The only network calls in the app are Google Drive backup/restore; everything else is fully offline.

## Getting started

```bash
flutter pub get
flutter run -d <device>
```

Run on **Android** for the real target platform (delivery reminders and the app icon/signing setup are Android-specific). iOS and Windows/Linux desktop also build for quick local testing (via `sqflite_common_ffi`, wired up in `main.dart`), though delivery reminders are skipped outside Android. **Web is not supported** — `sqflite` has no browser backend.

### Android build notes

- `android/app/build.gradle.kts` pins `ndkVersion` to a specific value already present in the local Android SDK cache, instead of `flutter.ndkVersion`. This avoids Gradle re-downloading the NDK (a large, occasionally flaky download) on every clean build. If you're setting up a new machine and don't have that NDK version cached, either let Gradle download it once or update the pin to a version you already have (`ls $ANDROID_SDK/ndk`).
- Core library desugaring is enabled (`isCoreLibraryDesugaringEnabled = true` + `coreLibraryDesugaring` dependency) — required by `flutter_local_notifications`. Don't remove this or the build will fail with an AAR metadata error.
- `POST_NOTIFICATIONS` is declared in `AndroidManifest.xml` and requested at runtime on first launch (Android 13+), needed for delivery reminders.

### Regenerating the app icon

The launcher icon is generated by `flutter_launcher_icons` from `assets/images/icon.png` (and `assets/images/icon_adaptive_fg.png`, a version of the same logo padded into Android's adaptive-icon safe zone). After changing the logo, regenerate with:

```bash
dart run flutter_launcher_icons
```

### Adding translations

All in-app UI text (screens, buttons, dialogs, labels) goes through `AppLocalizations` — there should be no hardcoded English strings in any screen or widget. To add a new string: add the same key to both `lib/l10n/app_en.arb` and `lib/l10n/app_ur.arb`, then regenerate:

```bash
flutter gen-l10n
```

If a field's value is stored in the database as a fixed English string but also shown to the user (e.g. order `status`, expense `category`), never translate the stored value itself — add a mapping case to `lib/utils/status_helper.dart` instead, so storage/logic stays in English and only the display text changes with locale.

WhatsApp message text, PDF invoice content, and CSV export headers are intentionally **not** localized — they're customer-facing documents/records where a consistent language matters more than matching the app's current UI language.

### Setting up Google Drive backup

The app's backup code talks to a Google Cloud project that you must create yourself — this is a one-time setup:

1. Go to [console.cloud.google.com](https://console.cloud.google.com) → create/select a project (e.g. "Zubair Tailors").
2. **APIs & Services → Library** → search "Google Drive API" → **Enable**.
3. **APIs & Services → OAuth consent screen**:
   - User type: **External**.
   - App name "Zubair Tailors", support/developer email = your Google account.
   - Scopes: add only `https://www.googleapis.com/auth/drive.file` (the app can only see files it creates itself — not your whole Drive). This is a *sensitive*, not *restricted*, scope, so it never needs Google's formal review.
   - Test users: add your own Google account.
   - Publishing status: leave as **Testing** to start (test-user sessions expire after 7 days of inactivity, forcing a quick re-login — harmless). Once you've confirmed backup/restore works, switch to **In production**; `drive.file` doesn't require review to do this as long as you stay under Google's 100-user cap for unverified apps, which a single shop easily does. Users just see a one-time "Google hasn't verified this app" click-through, then it works normally with no more 7-day expiry.
4. **APIs & Services → Credentials → Create Credentials → OAuth client ID → Android**, package name `com.zubair.tailors`. Google allows only one SHA-1 fingerprint per Android client, so create **two** client entries:
   - **Debug**: run
     ```
     keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
     and copy the `SHA1:` value.
   - **Release**: open `android/key.properties` yourself for the `storeFile` and `keyAlias` values (don't share the password with anyone), then run
     ```
     keytool -list -v -keystore <storeFile path> -alias <keyAlias>
     ```
     entering the password when prompted, and copy the `SHA1:` value.
   - No client secret and no `google-services.json` are needed (this app doesn't use Firebase).
5. If you later publish to the Play Store, also add the Play App Signing SHA-1 (Play Console → Setup → App integrity) as a third Android client entry.

Once the OAuth clients exist with the correct SHA-1s registered, no app code or config string needs to change — `google_sign_in` resolves the right client automatically from the package name + SHA-1 match at runtime. Test via Settings → Connect Google Account.

## Known limitations

- Order reference photos are stored locally only and are not included in Google Drive backups — after a restore on a new device, photo thumbnails will show a fallback "not found" icon instead of the original image.
- Delivery reminder notifications are Android-only (no-op on other platforms).
- Relative backup timestamps in Settings ("5m ago", "2h ago") are not localized to Urdu.
- No automated test coverage yet (`test/widget_test.dart` is the unmodified Flutter template and does not test this app).
