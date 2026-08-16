# Prompt: Build "Tailor Management" — Native Android App in Kotlin

Copy everything below into your AI assistant inside Android Studio (or a new Claude/Gemini/Copilot conversation) as the starting brief for the project.

---

## 1. What this app is

A fully offline-first tailoring-shop management app for a single tailor shop (sold as a shared product to many independent shops — each install is its own isolated business, no shared backend). It manages customers, their body measurements, clothing orders, expenses, and gives the shop owner delivery reminders, WhatsApp notifications to customers, PDF invoices, Google Drive backup, a PIN lock, dark mode, English/Urdu localization, and a 7-day trial + per-device unlock-code licensing gate.

Build this as a **native Android app in Kotlin using Android Studio**, replicating every feature and behavior below exactly — not just visually similar, but functionally equivalent (same data model, same business rules, same edge-case handling).

## 2. Recommended tech stack (Kotlin/Android equivalents of the Flutter stack)

| Concern | Flutter (source app) | Kotlin/Android equivalent |
|---|---|---|
| UI | Flutter widgets (Material 3) | Jetpack Compose (Material 3) |
| Local DB | sqflite (raw SQL) | Room (or raw SQLite via `SupportSQLiteOpenHelper` if you want to mirror the migration style 1:1) |
| Simple key-value state | shared_preferences | Jetpack DataStore (Preferences) |
| Encrypted secret storage (PIN) | flutter_secure_storage | `EncryptedSharedPreferences` (AndroidX Security-Crypto) or Keystore-backed storage |
| App-wide state | provider (ChangeNotifier) | ViewModel + StateFlow/State, or a simple DI container (Hilt optional) |
| Local notifications | flutter_local_notifications | AlarmManager (`setExactAndAllowWhileIdle` / `setAndAllowWhileIdle`) + a `BroadcastReceiver` + `NotificationCompat`, plus a `BOOT_COMPLETED` receiver to reschedule after reboot |
| Google Sign-In + Drive | google_sign_in + googleapis (Drive v3) | Credential Manager / Google Sign-In SDK + Google Drive REST API (`com.google.api-client:google-api-client-android` + `google-api-services-drive`) |
| PDF generation | pdf + printing packages | `PdfDocument` (android.graphics.pdf) or iText/PDFBox-Android, shared via `FileProvider` + `Intent.ACTION_SEND` |
| CSV export | csv package | Manual CSV writer (comma-escaping helper) written to a file, shared via `FileProvider` |
| WhatsApp deep link | url_launcher → wa.me | `Intent(Intent.ACTION_VIEW, Uri.parse("https://wa.me/..."))` |
| Camera / gallery photo | image_picker | `ActivityResultContracts.TakePicture` / `.PickVisualMedia`, with a `FileProvider` for the camera URI |
| Device ID (for licensing) | device_info_plus (Android ID) | `Settings.Secure.ANDROID_ID` |
| MD5 hashing | crypto package | `java.security.MessageDigest.getInstance("MD5")` |
| Localization | flutter_localizations + .arb files | Android `strings.xml` (values/ and values-ur/), with RTL layout support (`android:supportsRtl="true"`) |
| Timezone-aware scheduling | timezone package | `java.time` / `ZonedDateTime` (or `Calendar` if targeting older API levels) |

Minimum SDK: match the Flutter app's `min_sdk_android: 21` if you want the same device reach, though 24+ is more realistic for modern AlarmManager/notification APIs.

## 3. Data model — SQLite schema (replicate exactly via Room entities or raw SQL)

The Flutter app is at schema version 5, built via non-destructive migrations. Build the **final schema directly** (no need to replicate the migration history since this is a fresh app), but preserve every column and constraint below.

```sql
CREATE TABLE customers (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  unique_id  TEXT    NOT NULL UNIQUE,   -- shop-assigned display ID like "#0001", auto-incremented in app code
  name       TEXT    NOT NULL,
  phone      TEXT    NOT NULL,
  address    TEXT,
  notes      TEXT
);
CREATE INDEX idx_customers_phone ON customers(phone);

CREATE TABLE measurements (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id     INTEGER NOT NULL,
  clothing_type   TEXT NOT NULL DEFAULT 'Shalwar Kameez',  -- 'Shalwar Kameez' | 'Waistcoat' | 'Two Piece' | 'Three Piece'
  -- Shalwar Kameez fields
  shirt_length    TEXT,
  shirt_width     TEXT,
  shoulder        TEXT,
  sleeve          TEXT,
  collar          TEXT,
  ban_type        TEXT,   -- 'ban' | 'gol_ban'
  chest           TEXT,
  ghera           TEXT,
  pancha          TEXT,
  shalwar_length  TEXT,
  daman_type      TEXT,   -- 'square' | 'round'
  front_pocket    INTEGER NOT NULL DEFAULT 0,   -- boolean 0/1
  pocket_type     TEXT,   -- 'single' | 'double'
  sleeve_type     TEXT,   -- 'gol' | 'cuff'
  cuff            INTEGER NOT NULL DEFAULT 0,
  shalwar_pocket  INTEGER NOT NULL DEFAULT 0,
  ring_button     INTEGER NOT NULL DEFAULT 0,
  double_silai    INTEGER NOT NULL DEFAULT 0,
  chamak_tar      INTEGER NOT NULL DEFAULT 0,
  sada_patti      INTEGER NOT NULL DEFAULT 0,
  design_button   INTEGER NOT NULL DEFAULT 0,
  notes           TEXT,
  created_at      TEXT NOT NULL,  -- ISO8601 string
  -- Waistcoat fields (reuses shirt_length/shoulder/chest/collar above + waist)
  waist           TEXT,
  -- Two Piece / Three Piece: coat fields
  coat_length     TEXT,
  coat_shoulder   TEXT,
  coat_sleeve     TEXT,
  coat_chest      TEXT,
  coat_waist      TEXT,
  coat_collar     TEXT,
  -- Three Piece only: vest fields
  vest_length     TEXT,
  vest_chest      TEXT,
  vest_waist      TEXT,
  -- Two Piece / Three Piece: pant fields
  pant_length     TEXT,
  pant_waist      TEXT,
  pant_hip        TEXT,
  pant_pancha     TEXT,
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);
CREATE INDEX idx_measurements_customer_id ON measurements(customer_id);

CREATE TABLE orders (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id     INTEGER NOT NULL,
  measurement_id  INTEGER NOT NULL,
  clothing_type   TEXT NOT NULL,          -- copied from the measurement at order-create time, independently editable
  price           REAL NOT NULL,
  amount_paid     REAL NOT NULL DEFAULT 0,
  priority        INTEGER NOT NULL DEFAULT 0,  -- "Urgent" flag
  delivery_date   TEXT,                   -- ISO8601, nullable
  status          TEXT NOT NULL DEFAULT 'Pending',  -- 'Pending' | 'In Progress' | 'Ready' | 'Delivered'
  notes           TEXT,
  image_url       TEXT,                   -- local file path to reference photo
  created_at      TEXT NOT NULL,
  order_number    TEXT,                   -- format: ORD-YYYYMMDD-<id>, generated after insert once id is known
  FOREIGN KEY (customer_id)    REFERENCES customers(id)    ON DELETE CASCADE,
  FOREIGN KEY (measurement_id) REFERENCES measurements(id) ON DELETE RESTRICT
);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);

CREATE TABLE expenses (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  category      TEXT    NOT NULL,   -- 'Fabric / Material' | 'Rent' | 'Utilities' | 'Salaries' | 'Other'
  amount        REAL    NOT NULL,
  notes         TEXT,
  expense_date  TEXT    NOT NULL,
  created_at    TEXT    NOT NULL
);
```

Enable `PRAGMA foreign_keys = ON`.

## 4. Feature-by-feature specification

### 4.1 Customers
- List screen: search bar (filters by name/phone), each row shows name, phone, and a shop-assigned display ID badge (e.g. "#0001" — auto-incrementing per shop, zero-padded to 4 digits, generated client-side from the current max).
- Add/Edit via a bottom sheet or dialog: Name (required), Phone (required), Address (optional), Notes (optional).
- Tapping a customer opens a **Customer Detail** screen:
  - Header card: name, unique ID badge, phone, address (if set), notes (if set).
  - Measurements section: if the customer has zero measurements, show an "Add Measurement" button; if they already have one or more, hide the "add" affordance (a customer is expected to have exactly one active measurement profile per clothing type — but the current app only ever really uses the latest one; keep this same "only show add button when the list is empty" rule) and instead let them add more via a per-measurement "Edit" flow. Each measurement renders as an expandable card (collapsed/expanded), title = "{clothing type} - Created: {date}", showing all fields relevant to that clothing type (see §4.2) plus stitching-detail badges and notes.
  - Orders for this customer: cards showing photo (if any)/clothing type/price/due amount/status badge, with WhatsApp / Invoice / Edit action buttons in a row below a divider.
  - Toolbar actions: Edit customer, Delete customer (blocked with an error message if the customer has any orders — must delete/reassign orders first; this is enforced by the `ON DELETE RESTRICT` semantics you should replicate in code even if not at the DB level for orders→customer, or simply check for existing orders before allowing delete).

### 4.2 Measurements (clothing-type-driven dynamic form)
This is the most structurally important piece. The measurement form is **not one fixed field set** — it changes completely based on a "Clothing Type" dropdown at the top of the form, always visible, defaulting to "Shalwar Kameez". The 4 supported types and their exact field sets:

**Shalwar Kameez** (the original/full field set):
- Dimensions: Shirt Length, Shirt Width, Shoulder, Sleeve, Chest, Ghera, Pancha, Shalwar Length, Collar.
- Style dropdowns: Ban Type (Ban / Gol Ban), Daman Type (Square / Round), Sleeve Type (Gol / Cuff), Side Pocket (Single / Double) — all optional, no "none" default shown once selected (empty = unset).
- Stitching & Details — toggle chips (booleans): Front Pocket, Shalwar Pocket, Ring Button, Double Stitch, Shiny Thread ("Chamak Tar"), Simple Placket ("Sada Patti"), Design Button.
- A free-text Notes field.
- Every text dimension field has a small "add fraction" popup button (¼, ⅓, ½, ¾) that appends a Unicode fraction glyph to the end of the current value (replacing any fraction glyph already there) — useful for tailoring measurements like `38½`.

**Waistcoat**:
- Dimensions only: Length, Shoulder, Chest, Waist, Collar. (Reuses the same underlying `shirt_length`/`shoulder`/`chest`/`collar` + a new `waist` column — no style/stitching section.)

**Two Piece** (coat + pant):
- Coat Dimensions: Coat Length, Coat Shoulder, Coat Sleeve, Coat Chest, Coat Waist, Coat Collar.
- Pant Dimensions: Pant Length, Pant Waist, Pant Hip, Pant Pancha/Bottom.

**Three Piece** (coat + vest + pant):
- Coat Dimensions: same as Two Piece.
- Vest Dimensions: Vest Length, Vest Chest, Vest Waist.
- Pant Dimensions: same as Two Piece.

Style/stitching-detail fields (ban type, daman type, sleeve type, pocket type, and all the boolean toggle chips) only apply to Shalwar Kameez — when saving a non-Shalwar-Kameez measurement, force all of those to null/false regardless of what's in the (hidden) state.

Switching the Clothing Type dropdown mid-edit swaps the visible field sections immediately (the underlying text controllers are shared/reused across types where field names overlap, e.g. Waistcoat's "Length" reuses the same controller as Shalwar Kameez's "Shirt Length").

### 4.3 Orders
- **Order List** screen: horizontal filter chips (All / Pending / In Progress / Ready / Delivered), a search box (matches customer name, phone, or order number), and a scrollable list of order cards.
- Each order card shows: photo thumbnail (or a placeholder icon if none), order number, priority flag icon if urgent, customer name, delivery date, price, "due" badge if `price > amount_paid`, status badge (color-coded per status), and a row of WhatsApp / Invoice / Edit action buttons plus an "Update Status ▾" dropdown.
- **Status flow is strictly linear and one-directional via the UI**: Pending → In Progress → Ready → Delivered. The "Update Status" control only ever offers the *single next* status, not an arbitrary picker — e.g. an order at "Pending" can only be advanced to "In Progress" from this button, never skipped ahead or moved backward. Once "Delivered", the button becomes disabled/greyed out.
- **Payment-on-delivery flow**: if marking an order "Delivered" and there's still an outstanding balance (`price - amount_paid > 0`), automatically pop a "Confirm Payment" dialog pre-filled with the exact due amount, letting the shop owner adjust it before confirming; the entered amount is *added* to `amount_paid` (not replacing it). If there's no outstanding balance, just apply the status change directly.
- For already-Delivered orders with remaining balance, show a "Pay Rs. X" action instead of the status dropdown, opening the same payment dialog. If fully paid, show a "Fully Paid ✓" indicator instead.
- **Order Form** (create/edit), in this exact field order:
  1. Customer picker (dropdown of all customers, searchable-friendly by name).
  2. Measurement picker — populated with that customer's measurements once a customer is chosen (each entry labeled "ID: {id} ({created date})"). **Auto-select the most recently created measurement by default** when creating a new order (measurements are fetched sorted newest-first); in edit mode, preselect the exact measurement that was already linked to this order.
  3. Clothing Type dropdown (Shalwar Kameez / Waistcoat / Two Piece / Three Piece) — **auto-populated from the selected measurement's clothing type**, but the shop owner can still override it independently (the order's clothing type is stored separately from the measurement's, since a shop might reuse one measurement profile loosely). Changing the Measurement picker's selection re-syncs this dropdown to that measurement's type; changing the Customer picker clears both.
  4. Price (numeric, required) and Amount Paid (numeric, optional, defaults empty/0) side-by-side. If Amount Paid > Price, show an inline warning ("more than the price — please double-check") without blocking submission.
  5. Delivery Date picker (optional; date-only, no past dates selectable).
  6. "Urgent" toggle chip (maps to `priority`).
  7. Reference photo: tap to open a bottom sheet with "Take Photo" / "Choose from Gallery" / (if a photo is already set) "Remove Photo". Captured/picked photos are copied into the app's private storage under an `order_photos/` folder with a unique timestamp-based filename — never reference the picker's raw temp path directly.
- On save: `status` defaults to `'Pending'` for new orders (untouched on edits — status changes only happen via the list screen's dedicated flow, never via this form). Generate `order_number` as `ORD-{yyyyMMdd}-{id}` immediately after the insert (once the auto-increment id is known), then patch it into the row.
- **Delivery reminder scheduling** happens automatically on every save (see §4.5) — cancel any existing reminder for this order id, then reschedule if applicable.
- **Photo memory-safety requirements** (this bit the Flutter app in production, replicate the fix): when previewing the attached photo as a small thumbnail, decode it downsampled to the display size (Android equivalent: use `BitmapFactory.Options.inSampleSize` or `Glide`/`Coil`'s target-size loading) — never decode a full-resolution bitmap just to show a 48dp thumbnail, since repeated full-res decodes across multiple retakes in one session will exhaust memory and get the process killed by the OS, especially on low-RAM devices. Also delete the previous photo file when the user retakes/reselects one during the same form session — but never delete the original photo already saved to an order you're editing until the user actually saves (in case they back out without saving).
- Cap captured/picked photo resolution at import time (e.g. 1600×1600 max, ~85% JPEG quality) rather than storing the camera's native resolution.

### 4.4 Dashboard (home screen)
Stat cards, 2-column grid, each with an icon, an accent color, and a colored left border:
- Row 1: "Today" revenue (sum of `amount_paid` for orders created today), "This Week" revenue (week starting Monday).
- Row 2: "This Month" revenue, "Outstanding" (sum of `price - amount_paid` across all orders where that's positive).
- "Status" section header, then a 2x2 grid: Total Customers, Total Orders, Pending Orders, Ready Orders (raw counts).
- Two quick-action buttons: "Add Customer" and "New Order", each navigating to the respective list screen.
- Revenue figures are **collected revenue** (`amount_paid`), not order value — this distinction matters, don't confuse it with total order price.
- On screen open: trigger an auto-backup-if-signed-in check (§4.9) and reschedule all pending delivery reminders (§4.5) as a reconciliation pass.
- Pull-to-refresh re-fetches everything.

### 4.5 Delivery reminders (local notifications)
- Purely on-device scheduled notifications, no server/push.
- For any order with a delivery date set and status not yet "Delivered", schedule a **single notification 3 days before the delivery date at 9:00 AM**. Title: "Delivery Due In 3 Days". Body: "{customer name} — {clothing type} is due for delivery in 3 days."
- If that computed reminder time has already passed (e.g. the delivery date is less than 3 days away when the order is created), **do not schedule anything** for it — don't fire a late/backlog notification.
- Use an inexact-but-allow-while-idle scheduling mode (Android: `AlarmManager.setAndAllowWhileIdle`, not the exact-alarm APIs) — this avoids needing the special "Alarms & reminders" permission Android 12+ gates behind manual user approval, which is appropriate for a same-day-precision reminder rather than something needing second-level accuracy. **Do not use `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM`** unless you have a specific reason to — Google Play policy restricts that permission to apps whose core function is alarms/clocks/timers, and a tailoring app requesting it risks rejection on submission.
- Each order's reminder must be **idempotent by order ID** — use the order's database ID as the notification/alarm's request code, so re-scheduling the same order just overwrites its existing alarm rather than stacking duplicates.
- Reminder lifecycle: (a) scheduled on every order create/edit (cancel-then-reschedule), (b) cancelled when an order's status is set to "Delivered", (c) all non-delivered orders' reminders are re-reconciled every time the Dashboard opens (walk all such orders, reschedule each) — this is important because Android clears all pending alarms on device reboot, and a `BOOT_COMPLETED` receiver alone can't always be relied on across OEM skins, so opening the app is the practical reconciliation point.
- **Document this clearly for shop owners**: notifications frequently fail to fire when the app has been fully closed, because aggressive OEM battery managers (MIUI/Xiaomi, ColorOS/Realme, EMUI/Huawei) kill background processes and cancel their scheduled alarms unless the app is manually exempted from battery optimization and has "autostart"/"auto-launch" enabled. This is not fixable from app code alone — build a simple in-app help screen or first-run tip directing users to their device's battery/autostart settings.

### 4.6 Notifications screen (in-app reminder inbox)
A dedicated screen (reachable from the drawer) that lists the *same* reminder-eligible orders (delivery date set, not yet Delivered) as their own inbox-style list — **do not** also keep a separate "Upcoming Deliveries" screen; this Notifications screen replaces that concept entirely, avoiding two screens showing near-duplicate data.
- Sorted by reminder time ascending (soonest first).
- Each row: bell icon (filled/"active" style if the reminder time has already passed = "sent", outline style if still upcoming = "scheduled"), customer name, clothing type, and a status line — "Reminder sent" (past) or "Reminder scheduled for {date}" (future).
- Read/unread state: rows are bold until tapped once (tapping opens a detail dialog and marks it read); read rows render in a lighter/italic style. Persist read-state as a simple set of order IDs in local key-value storage (don't need a DB table for this).
- Tapping a row opens a modal with the customer name, clothing type, due date, and the same sent/scheduled message, plus a Close button (which also marks it read).
- Empty state: bell icon + "No notifications" + explanatory subtext.

### 4.7 Reports
- Date-range filter chips: This Month / Last 30 Days / All Time.
- Stat cards for the selected range: Revenue Collected, Outstanding, Total Expenses, Net Profit (= Revenue Collected − Total Expenses), Total Customers (all-time, not range-filtered).
- A breakdown chart/section: Orders by Status, Orders by Clothing Type (counts within the selected range).
- Empty state if there are no orders in the selected range.

### 4.8 Expenses
- Simple CRUD list: category (dropdown: Fabric/Material, Rent, Utilities, Salaries, Other), amount, date, optional notes.
- List sorted by date descending, with a running total header.
- Add via a bottom sheet form; tap to edit; delete via confirmation dialog.
- Feeds into the Reports screen's Total Expenses / Net Profit figures.

### 4.9 Backup & Restore (Google Drive)
- Google Sign-In with the `drive.file` scope only (not full Drive access — this app should only ever see files it created itself).
- On sign-in, find-or-create a Drive folder named "{App Name} Backups" (cache its file ID in local key-value storage so you don't re-search every time; if the cached ID turns out to be invalid/trashed, re-resolve it).
- "Back Up Now": snapshot the local SQLite DB (`VACUUM INTO` a temp file, or a plain file copy) and upload it as `backup_{yyyy-MM-ddTHH-mm-ss}.db` into that Drive folder.
- Retention: after each backup, list all files in the folder sorted by creation time descending, and delete anything beyond the most recent **10**.
- "Restore Backup": list available backups (id, name, created time) in a bottom sheet; selecting one shows a destructive-action confirmation ("this will overwrite all local data — cannot be undone"); on confirm, download the chosen file, close the live DB connection, delete any WAL/SHM side-files, replace the live DB file with the downloaded one, then navigate back to a fresh Dashboard.
- Auto-backup: fire a backup automatically (a) once per Dashboard open if already signed in, and (b) silently in the background (fire-and-forget, swallow errors, never interrupt the user's current action) after every customer/measurement/order create/update/delete.
- Track and expose exactly one in-flight operation at a time (sign-in / backing-up / listing-backups / restoring) so the UI can show a loading spinner on *only* the specific button the user tapped — don't let one shared "busy" flag light up every button on the screen simultaneously; a state machine like `enum BackupOperation { NONE, SIGNING_IN, BACKING_UP, LISTING, RESTORING }` avoids that bug.
- **Play Store OAuth verification note**: while the app's OAuth consent screen is in "Testing" publishing status, Google Sign-In only works for explicitly whitelisted test-user emails (capped at 100) — real shop owners outside that list get an "Access blocked... has not completed the Google verification process" error. Moving to "In production" requires submitting for Google's verification (needs a privacy policy URL, app homepage/logo) — plan for this before wide distribution, and don't treat that error as an app bug when it occurs.

### 4.10 Invoices (PDF)
- Generate an A5-sized PDF per order: shop name (large, bold) + shop phone/address if set, order number, current date, "Bill To" (customer name + phone), "Order Details" (clothing type, status, delivery date), then a Price / Amount Paid / Amount Due breakdown (Amount Due in bold), and a "Thank you for your business!" closing line.
- Share via the system share sheet (`Intent.ACTION_SEND` with a `FileProvider` URI), filename `invoice_{orderId}.pdf`.
- This content is **always in English regardless of the app's active UI language** — invoices/WhatsApp/CSV exports are customer-facing documents and intentionally not localized, only the in-app UI is.

### 4.11 WhatsApp notify
- Manual trigger only (a "WhatsApp" button on order cards) — never auto-fire on every status change, so the shop owner isn't prompted on every Pending→In Progress transition and can choose when it's actually appropriate to notify the customer.
- Phone normalization for Pakistani numbers: strip all non-digit characters, strip a single leading `0`, then prepend `92` if the result doesn't already start with `92`.
- Message template: `"Hi {customerName}, your order for {clothingType} at {shopName} is now {status}."`, with `" Please visit to collect it."` appended when status is Ready or Delivered.
- Opens `https://wa.me/{normalizedPhone}?text={urlEncodedMessage}` via an external-app intent; show a "Couldn't open WhatsApp" message if the intent fails to resolve (i.e., WhatsApp isn't installed).

### 4.12 CSV export
- Export all orders and all customers as separate CSV files (shop owner's choice of which), shared via the system share sheet — usable in Excel or elsewhere. Always in English, matching the invoice/WhatsApp non-localization rule.

### 4.13 PIN app lock
- A Settings toggle: enabling it opens a "Set PIN" flow (4-digit numeric keypad UI, enter twice to confirm, mismatch shows an inline error and restarts the confirm step); disabling it first re-prompts for the current PIN (via a dialog) and only disables if correct.
- The PIN itself is stored in `EncryptedSharedPreferences` (or Android Keystore-backed storage) — not hashed, since the storage layer is already encrypted at rest and a salted hash of an unsalted 4-digit PIN adds negligible real protection.
- A separate boolean flag ("is lock enabled") lives in plain preferences (DataStore) — only the PIN value itself needs the encrypted store.
- On app cold-start (after the splash/branding screen), check license status first (§4.15), then PIN-lock status, then route to either a PIN-verify screen or straight to the Dashboard.

### 4.14 Dark mode & theming
- A single Settings toggle switches the whole app between light/dark Material 3 themes; persist the choice in DataStore, apply on next recompose (no restart needed).
- Design tokens should be theme-aware getters (not hardcoded hex per-screen) so every screen automatically reflects light/dark without per-screen special-casing — mirrors the source app's `AppColors` static-getter pattern driven by a single `isDark` flag.

### 4.15 Trial / licensing gate
This is the commercial protection mechanism — replicate it exactly, it's intentionally offline-only (no backend):
- **Trial length**: 7 days, but the countdown **starts from the oldest order's `created_at`**, not from first app launch — a shop with zero orders never has an expiring trial; the clock only starts once they've actually used the app for real work (query `MIN(created_at)` from `orders`).
- **Per-device unlock codes**, not one shared code: compute `deviceId` from `Settings.Secure.ANDROID_ID`. The valid code for a device = first 8 hex characters (uppercased) of `MD5(deviceId + "ZubairSecret2026")`. *(Change this salt string for your own app — it's a shared secret between the app binary and whoever is issuing unlock codes to customers.)*
- **Master override code**: `MASTER2026` (or your own choice) — works on *any* device regardless of its ID, as a developer backdoor. Not shown anywhere in the UI, just accepted silently as an alternate valid input alongside the per-device check.
- When the trial expires and the app isn't activated, show a full-screen, non-dismissible (no back button) paywall: lock icon, "Trial Expired" title, explanatory message, the device's ID displayed as **selectable text** (so the shop owner can read/copy it to send to you), an unlock-code text input, and an "Activate" button. Wrong code shows an inline error; correct code persists an "activated" flag (DataStore boolean, permanent) and navigates to the Dashboard.
- This check runs **before** the PIN-lock check in the cold-start routing logic — no point prompting for a PIN if the trial itself is expired.
- Also surface trial/license status in Settings (a small card: "X days left in your free trial" or "Activated", with a button to enter the unlock code proactively even before expiry — don't force the user to wait until the paywall to enter a code they may already have).

### 4.16 Shop profile (configurable branding)
- Since this is a shared app sold to many shops, the shop's own name/phone/address must be configurable per-install, not hardcoded — a Settings screen section ("Shop Profile") with Name (required)/Phone/Address fields, persisted in DataStore, defaulting to a generic placeholder (e.g. "Tailor Management") for a fresh install with nothing saved yet.
- This shop name feeds: the app's drawer header, the splash/branding screen text, PDF invoice header, and the WhatsApp message template's `{shopName}` placeholder.
- Keep this **separate** from your own publisher/developer credit (e.g. a fixed "Developed by {Your Company}" line in the drawer/Settings — that's your brand as the software vendor, not the shop's own identity, and should stay fixed across all installs).

### 4.17 Localization (English + Urdu)
- Full bilingual UI — every in-app screen, button, dialog, and validation message must pull from string resources (`strings.xml` / `values-ur/strings.xml`), no hardcoded literals, no "English / Urdu" slash-concatenated hacks.
- Urdu is RTL — support `android:supportsRtl="true"` and verify layouts mirror correctly (though tailoring measurement *values* like `38½` should always render LTR even inside an RTL layout, since they're numeric).
- **Status/category values stored in the database must stay in fixed English strings** (e.g. `'Pending'`, `'In Progress'`, `'Fabric / Material'`) — only the *display* layer translates them via a lookup/mapping function per language. Never store the translated string itself, or filtering/business logic breaks when the language is switched.
- WhatsApp messages, PDF invoices, and CSV exports are the one deliberate exception — those stay English always, regardless of the active UI language (see §4.10–4.12).

### 4.18 Navigation structure
A navigation drawer (hamburger menu) with, in order: Dashboard, Customers, Orders, Notifications, Reports, Expenses, — divider — Settings, — divider — Share App, More Apps (link to your Play Store developer page), Exit (confirmation dialog before killing the app). Drawer header shows the shop name + "Developed by {publisher}" + app icon. Footer shows a small version label.

Settings screen sections, top to bottom: Shop Profile, Language (visual English/Urdu picker cards), Appearance (dark mode toggle), App Lock (PIN toggle), License (trial/activation status), Backup & Restore (Google Sign-In / Back Up Now / Restore Backup / Disconnect), Export Data (CSV buttons), System Info (app version, publisher, DB status).

## 5. Cross-cutting engineering requirements

- **Non-destructive schema evolution**: this app holds real shop production data. If you ever need to change the schema after shipping, use additive Room migrations (`ALTER TABLE ... ADD COLUMN`) — never a destructive recreate that would wipe a shop's existing customers/orders.
- **New async-loaded app state must be ready before it's read.** If you use a DI container or service-locator pattern where some state loads asynchronously from DataStore/EncryptedSharedPreferences (e.g. license status, PIN-lock-enabled flag), make sure it's initialized eagerly at app start — not lazily on first read — since the splash-screen routing logic reads it synchronously right after a fixed delay; a lazy-loaded flag that hasn't finished loading yet will silently evaluate to its default value and produce the wrong routing decision (e.g. a PIN lock that never activates even though a PIN is saved).
- **Loading feedback**: any action that can take more than ~1 second (Drive operations especially) must show a visible per-button loading state the instant it's tapped, not just after the operation completes — and that loading state must be scoped to the specific button/operation, not a single shared "busy" flag that lights up every button on the screen at once.
- **Modal bottom sheets with variable-length lists** (e.g. the restore-backup picker) must be scroll-controlled (`isScrollControlled` / equivalent) rather than relying on the platform default height cap, or they'll overflow once the list has more than a handful of items.
- **Camera/gallery photo handling**: cap resolution on import, decode thumbnails downsampled (never full-res for a small preview), and clean up superseded photo files — see §4.3's photo memory-safety notes in detail; this was a real crash in the source app and is the single most important non-obvious requirement in this whole spec.

## 6. What NOT to build

- No backend server, no remote database, no push notifications — everything above is achievable fully offline/on-device.
- No remote kill-switch for licensing — the trial/license system is intentionally local-only (see §4.15's own reasoning).
- Don't localize WhatsApp/PDF/CSV output (§4.10–4.12) — that's a deliberate scope boundary, not an oversight to "fix."
