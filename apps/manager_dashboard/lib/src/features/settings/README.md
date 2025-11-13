# Settings Feature

Comprehensive settings management for the Manager Dashboard following Odoo 17 design guidelines.

## Structure

```
settings/
├── models/
│   └── settings_models.dart          # Data models for all settings
├── providers/
│   └── settings_providers.dart       # State management with Riverpod
└── presentation/
    ├── pages/
    │   └── settings_page.dart        # Main settings page with tabs
    └── widgets/
        ├── general_settings_view.dart       # Restaurant info, timezone, currency
        ├── api_settings_view.dart           # API configuration
        ├── appearance_settings_view.dart    # Theme, colors, font size
        ├── business_settings_view.dart      # Operating hours, holidays
        ├── tax_settings_view.dart           # Tax rates and configuration
        ├── receipt_settings_view.dart       # Receipt customization
        └── notification_settings_view.dart  # Notification preferences
```

## Features

### 1. General Settings
- Restaurant name, location, contact information
- Timezone selection (UTC, America/New_York, etc.)
- Currency selection (USD, EUR, GBP, etc.)
- Language selection (English, Spanish, French, etc.)

### 2. API Settings
- API Base URL configuration
- Organization ID
- API Key (secured with visibility toggle)
- Request timeout settings
- Connection test functionality

### 3. Appearance Settings
- Theme mode (Light/Dark/System)
- Primary color picker with presets
- Custom color selection
- Font size adjustment (12-18px)
- Live preview of changes

### 4. Business Settings
- Operating hours for each day of the week
- Open/closed toggle per day
- Custom time selection for each day
- Holiday management (add/remove dates)

### 5. Tax Settings
- Default tax rate configuration
- Tax inclusive/exclusive pricing
- Multiple tax rates support
- Tax rate management (add/edit/delete)
- Default tax rate marking

### 6. Receipt Settings
- Custom header and footer text
- Logo display toggle
- QR code toggle
- Auto-print configuration
- Number of copies (1-5)
- Live receipt preview

### 7. Notification Settings
- Push notifications toggle
- Sound alerts toggle
- Email notifications toggle
- Notification types:
  - New orders
  - Low stock alerts
  - Daily reports
- Test notification functionality

## Data Models

### AppSettings
Main settings container with all configuration:
- General information
- API configuration
- Appearance preferences
- Business hours
- Tax settings
- Receipt settings
- Notification preferences

### Supporting Models
- `BusinessHours` - Operating hours per day
- `TaxRate` - Individual tax rate configuration
- `TaxSettings` - Tax configuration container
- `ReceiptSettings` - Receipt customization
- `NotificationSettings` - Notification preferences
- `ApiConfiguration` - API settings

## State Management

Uses Riverpod for state management:
- `settingsProvider` - Main settings state
- `SettingsNotifier` - State notifier with update methods
- Automatic persistence to SharedPreferences
- Derived providers for specific settings

## Persistence

Settings are automatically saved to SharedPreferences:
- JSON serialization/deserialization
- Automatic loading on app start
- Save button in UI for manual save
- Reset to defaults functionality

## Design Guidelines

Follows Odoo 17 design specifications:
- **Colors**: OdooColors palette (primary purple #714B67)
- **Typography**: Lato font family, Material 3 text styles
- **Spacing**: 4px base unit system
- **Cards**: White cards with subtle borders and shadows
- **Forms**: Proper validation and error handling
- **Buttons**: Filled buttons for primary actions, outlined for secondary
- **Switches**: Material switches with Odoo purple accent

## Usage

### Navigate to Settings

```dart
import 'package:manager_dashboard/src/features/settings/presentation/pages/settings_page.dart';

// In your router or navigation
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SettingsPage()),
);
```

### Access Settings in Code

```dart
// Watch settings
final settings = ref.watch(settingsProvider);
final restaurantName = settings.restaurantName;
final primaryColor = settings.primaryColor;

// Update settings
ref.read(settingsProvider.notifier).updateGeneralSettings(
  restaurantName: 'New Name',
);

// Save settings
await ref.read(settingsProvider.notifier).saveSettings();
```

### Use Derived Providers

```dart
// Get specific settings
final themeMode = ref.watch(themeModeProvider);
final currency = ref.watch(currencyProvider);
final timezone = ref.watch(timezoneProvider);
```

## Dependencies

Required dependencies (already in pubspec.yaml):
- `flutter_riverpod` - State management
- `flutter_colorpicker` - Color picker for appearance settings
- `intl` - Date/time formatting
- `pos_core` - AppStorage for persistence

## Integration Points

### AppStorage Integration
Settings use the pos_core AppStorage for persistence:
```dart
final storage = ref.watch(appStorageProvider).requireValue;
```

### Theme Integration
The theme mode and primary color can be used to update the app theme:
```dart
final themeMode = ref.watch(themeModeProvider);
final primaryColor = ref.watch(primaryColorProvider);

// Apply to MaterialApp
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
  // ... other theme properties
);
```

## Validation

All forms include proper validation:
- Required field validation
- Email format validation
- URL format validation (API base URL)
- Numeric input validation (tax rates)
- Range validation (font size, number of copies)

## Future Enhancements

Potential additions:
- Cloud sync for settings
- Import/export settings
- Multiple location support
- Advanced notification scheduling
- Custom tax rules
- Receipt template editor
- Multi-language support for receipts
- Advanced color theming
- Backup and restore settings

## Testing

To test the settings feature:
1. Navigate to Settings page
2. Test each tab:
   - Update general information
   - Configure API settings and test connection
   - Change theme and colors
   - Set business hours
   - Add tax rates
   - Customize receipt preview
   - Toggle notifications and send test
3. Save settings
4. Restart app to verify persistence
5. Reset to defaults to test reset functionality

## Notes

- All settings are persisted automatically on save
- Changes are reflected immediately in the UI
- The save button must be clicked to persist changes
- Reset to defaults requires confirmation
- API test connection is simulated (implement actual API call)
- Test notification is a UI-only demo (implement actual push notifications)
