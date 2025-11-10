# Kitchen Display System (KDS)

Real-time kitchen order management application for restaurant kitchens.

## Features

### Core Functionality
- **Real-time Order Queue**: Auto-refreshing order display (5-second intervals)
- **Visual Order Cards**: Large, easy-to-read order cards with color-coded urgency
- **Bump Orders**: One-tap order completion with confirmation
- **Station Filtering**: Filter orders by kitchen station (grill, fry, salad, etc.)
- **Timer Tracking**: Visual elapsed time with color-coded warnings
- **Order Details**: Tap any order to view full details

### Order Card Information
Each order card displays:
- Order number and type badge (dine-in, takeaway, delivery, etc.)
- Table number (for dine-in orders)
- Elapsed time since order creation
- Item list with quantities
- Modifiers for each item
- Special notes/instructions (highlighted)
- Large "BUMP" button for completion

### Visual Alerts
- **Green** (< 10 minutes): Normal preparation time
- **Amber** (10-15 minutes): Warning - order taking longer than expected
- **Red** (> 15 minutes): Critical - order significantly delayed

### Station Filtering
Pre-configured kitchen stations:
- **Grill Station** (red) - Grilled items
- **Fry Station** (amber) - Fried items
- **Salad Station** (green) - Cold prep
- **Dessert Station** (pink) - Desserts
- **Drinks Station** (blue) - Beverages

## Architecture

### Dependencies
- `pos_core`: Shared business logic (orders, products)
- `pos_ui`: Reusable UI components
- `flutter_riverpod`: State management
- `intl`: Time formatting

### File Structure
```
lib/
├── main.dart                           # App entry point
└── src/
    ├── features/
    │   └── kds/
    │       └── presentation/
    │           └── pages/
    │               └── kds_main_page.dart  # Main KDS screen
    └── widgets/
        ├── kds_order_card.dart         # Order card widget
        ├── station_selector.dart       # Station filter widget
        └── widgets.dart                # Exports
```

## Configuration

Configuration is managed through `assets/config/app_config_dev.json`:

```json
{
  "featureFlags": {
    "enableAudioAlerts": true,
    "enableTimerWarnings": true,
    "autoRefreshOrders": true,
    "showOrderPhotos": true,
    "enablePriorityOrdering": true
  },
  "kdsSettings": {
    "refreshInterval": 5,
    "warningTimeMinutes": 10,
    "criticalTimeMinutes": 15
  }
}
```

## Usage

### Running the App
```bash
cd apps/kitchen_display
flutter run
```

### Bumping Orders
1. Review order details on the card
2. Tap "BUMP" button when order is ready
3. Confirm in the dialog
4. Order moves to "Ready" status and disappears from queue

### Filtering by Station
1. Tap station chip at the top
2. View orders for that station only
3. Tap "All Stations" to clear filter

## Display Recommendations

### Hardware
- **Screen Size**: 15" or larger for optimal visibility
- **Orientation**: Landscape for grid layout
- **Touch**: Touchscreen for easy bump interaction
- **Mounting**: Wall-mounted or countertop stand

### Settings
- **Brightness**: High brightness for kitchen environments
- **Keep Awake**: Prevent screen sleep during service hours
- **Volume**: Enable for audio alerts (if supported)

## Integration with POS System

The KDS app integrates with pos_register:
1. Cashier creates order in pos_register
2. Order status changes to "Preparing"
3. KDS automatically displays the order
4. Kitchen staff prepares the order
5. Kitchen staff bumps order to "Ready"
6. Cashier sees order is ready in pos_register
7. Food is served to customer

## Future Enhancements

### Planned Features
- [ ] Audio alerts for new orders
- [ ] Print to kitchen printer on order arrival
- [ ] Course/course timing (appetizers, mains, desserts)
- [ ] Rush/priority order marking
- [ ] Recall bumped orders
- [ ] Order history view
- [ ] Kitchen performance metrics
- [ ] Multi-station order routing
- [ ] Custom station configuration
- [ ] Printer assignment per station

## Development Notes

### Mock Data
Currently uses mock data from `pos_core`. In production, connect to:
- Real-time WebSocket for instant order updates
- REST API for order status updates
- Printer service for kitchen tickets

### Testing
Test with multiple concurrent orders to verify:
- Grid layout responsiveness
- Timer accuracy
- Bump functionality
- Station filtering
- Auto-refresh behavior

## License

Part of SmartPOS ecosystem - Internal use only
