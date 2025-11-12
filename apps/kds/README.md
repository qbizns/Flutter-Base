# Kitchen Display System (KDS)

Real-time kitchen display application for restaurant operations, following Odoo KDS patterns 100%.

## Overview

The Kitchen Display System (KDS) provides a real-time view of incoming orders for kitchen staff. Orders are displayed as cards with color-coded status indicators, timers, and detailed item information grouped by category.

## Features

### ✅ Implemented (Phase 2 Day 1-2)

1. **Multi-Station Support**
   - 8 predefined stations: All, Grill, Fryer, Cold Prep, Hot Prep, Dessert, Bar, Expo
   - Station-specific order filtering
   - Color-coded station indicators
   - Easy station switching via horizontal selector

2. **Order Status Workflow**
   - **New** → **Preparing** → **Ready** → **Done**
   - Status-specific colors (White → Yellow → Green → Gray)
   - One-click status transitions
   - Cancel option for new orders

3. **Order Cards (Odoo-Style)**
   - Order number with elapsed time timer
   - Table/customer information
   - Priority badges (High, Urgent)
   - Allergy warnings
   - Order notes display
   - Items grouped by category
   - Individual item tracking (checkbox completion)
   - Modifier and notes display per item

4. **Color-Coded Alerts**
   - Red border and background for delayed orders (>15 minutes)
   - Warning icon on timer
   - Visual emphasis for urgent orders
   - Pulsing effect on critical delays

5. **Statistics Bar**
   - Real-time counts by status (New, Preparing, Ready)
   - Active orders counter
   - Delayed orders warning counter
   - Clickable status filters

6. **Responsive Grid Layout**
   - 2-4 columns based on screen width
   - Optimized for kitchen displays (tablets/monitors)
   - Touch-friendly interactions

### 🔄 Coming Soon (Phase 2 Day 3-7)

7. **Real-Time Updates**
   - WebSocket integration
   - Auto-refresh on new orders
   - Sound notifications
   - Visual alerts for new orders

8. **Advanced Features**
   - Order preparation timer tracking
   - Multiple display modes (Grid, List, Kanban)
   - Printer integration
   - Performance analytics
   - Custom station configuration

## Architecture

### Models

#### KitchenOrder
```dart
class KitchenOrder {
  String id;
  String orderNumber;
  DateTime createdAt;
  KitchenOrderStatus status;
  List<KitchenOrderItem> items;
  String? tableNumber;
  String? customerName;
  List<String> stationIds;
  OrderPriority priority;
  // ... more fields
}
```

#### KitchenStation
```dart
class KitchenStation {
  String id;
  String name;
  StationType type;
  List<String> categoryIds; // Categories this station handles
  Color color;
  IconData icon;
}
```

### Widgets

1. **KdsDisplayPage** - Main page with grid layout
2. **KdsOrderCard** - Individual order display card
3. **StationSelector** - Horizontal station chips
4. **KdsStatsBar** - Order statistics bar

## Odoo KDS Patterns Followed

### Visual Design
- ✅ White background for new orders
- ✅ Yellow background for orders in progress
- ✅ Green background for ready orders
- ✅ Red border and alerts for delayed orders
- ✅ Large, readable fonts
- ✅ Color-coded status workflow

### Functionality
- ✅ One-click status transitions
- ✅ Timer showing elapsed time
- ✅ Items grouped by category
- ✅ Priority and urgency indicators
- ✅ Allergy warnings
- ✅ Order notes prominently displayed
- ✅ Multi-station filtering

### User Experience
- ✅ Large touch targets for kitchen gloves
- ✅ Clear visual hierarchy
- ✅ Minimal clicks to complete actions
- ✅ Real-time status updates
- ✅ Responsive grid layout

## Screen Layout

```
┌─────────────────────────────────────────────────────────┐
│  🍴 Kitchen Display - Grill Station          ⚙️ 🔄     │
│  [All] [Grill] [Fryer] [Cold] [Hot] [Dessert] [Bar]   │
├─────────────────────────────────────────────────────────┤
│  NEW: 3   PREPARING: 2   READY: 1   ⚠️ 1 Delayed       │
├─────────────────────────────────────────────────────────┤
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│  │ ORD-001  │ │ ORD-002  │ │ ORD-003  │ │ ORD-004  │  │
│  │ 5m 🕐    │ │ 18m ⚠️  │ │ 3m 🕐    │ │ 8m 🕐    │  │
│  │ Table 12 │ │ Table 5  │ │ John Doe │ │ Table 8  │  │
│  │          │ │ 🔴 HIGH  │ │          │ │          │  │
│  │ BURGERS  │ │ STEAKS   │ │ PASTA    │ │ CHICKEN  │  │
│  │ 2x Burger│ │ 1x Steak │ │ 1x Carb. │ │ 3x Chick │  │
│  │          │ │ ☑️ Salad │ │          │ │          │  │
│  │ SIDES    │ │          │ │ DRINKS   │ │          │  │
│  │ 2x Fries │ │          │ │ 2x Tea   │ │          │  │
│  │          │ │          │ │          │ │          │  │
│  │ [START]  │ │ [READY]  │ │ [START]  │ │ [READY]  │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Status Colors

| Status | Background | Border | Header | Description |
|--------|-----------|--------|--------|-------------|
| New | White | Purple | Purple | Just received |
| Preparing | Light Yellow | Yellow | Yellow | Being cooked |
| Ready | Light Green | Green | Green | Ready to serve |
| Done | Light Gray | Gray | Gray | Completed |
| Cancelled | Light Red | Red | Red | Cancelled |
| **Delayed** | Light Red | **Red Bold** | Red | >15 min elapsed |

## Usage

### Running the App

```bash
# Install dependencies
flutter pub get

# Run on device
flutter run

# Build for production
flutter build apk  # Android
flutter build ios  # iOS
flutter build web  # Web
```

### Development Mode

The app currently uses mock data for development. Sample orders are loaded on startup with various statuses, priorities, and timing scenarios.

To connect to real backend:
1. Update `KdsDisplayPage` to use Riverpod providers
2. Implement WebSocket connection for real-time updates
3. Replace mock data with API calls

## Configuration

### Station Configuration

Stations are defined in `DefaultKitchenStations`:

```dart
const KitchenStation(
  id: 'grill',
  name: 'Grill Station',
  type: StationType.grill,
  categoryIds: ['burgers', 'steaks', 'chicken'],
  colorCode: '#E67E22',
),
```

### Alert Thresholds

Configure delay thresholds in `KitchenOrder`:

```dart
bool get isOrderDelayed {
  final threshold = isUrgent ? 10 : 15;  // Minutes
  return elapsedMinutes > threshold;
}
```

## Testing Scenarios

### Test Case 1: New Order Flow
1. New order appears with white background
2. Click "START" → Status changes to Preparing (yellow)
3. Click "READY" → Status changes to Ready (green)
4. Click "DONE" → Order marked complete

### Test Case 2: Item Tracking
1. Open order in Preparing status
2. Click individual items to mark complete
3. Items show checkmark and strikethrough
4. Track completion percentage

### Test Case 3: Delayed Order Alert
1. Order older than 15 minutes
2. Card shows red border and background
3. Timer shows warning icon
4. "Delayed" counter updates

### Test Case 4: Station Filtering
1. Select "Grill" station
2. Only orders with grill items shown
3. Switch to "All" to see all orders
4. Each station shows relevant orders only

## Dependencies

```yaml
dependencies:
  pos_core: ^1.0.0           # Core models and theme
  flutter_riverpod: ^2.6.1   # State management
  go_router: ^14.6.2         # Navigation
  web_socket_channel: ^2.4.0 # Real-time updates
  audioplayers: ^5.2.1       # Sound notifications
```

## Future Enhancements

1. **Real-Time Integration**
   - WebSocket connection to POS system
   - Push notifications for new orders
   - Auto-refresh on order updates

2. **Sound Notifications**
   - Configurable alert sounds
   - Different sounds for priorities
   - Volume control

3. **Advanced Timer Features**
   - Target completion times by item
   - Progressive color changes
   - Countdown timers

4. **Performance Analytics**
   - Average preparation time
   - Station efficiency metrics
   - Peak time analysis
   - Order completion rates

5. **Customization**
   - Custom station setup
   - Configurable alert thresholds
   - Display preferences (text size, colors)
   - Layout options (grid, list, kanban)

6. **Printer Integration**
   - Auto-print on new orders
   - Station-specific printing
   - Ticket formatting

## Contributing

When adding features, ensure:
1. Follow Odoo KDS patterns 100%
2. Maintain color-coded status system
3. Keep UI touch-friendly (large buttons)
4. Test with kitchen staff
5. Optimize for speed (orders load in <1s)

## License

Part of the Flutter-Base SmartPOS ecosystem.

---

**Kitchen Display System** - Built with Flutter, following Odoo patterns 100%
