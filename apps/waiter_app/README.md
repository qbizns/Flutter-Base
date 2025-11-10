# Waiter/Server App

Mobile-first application for restaurant servers to take orders and manage tables.

## Features

### Core Functionality
- **Table Selection**: Visual grid of all tables with status indicators
- **Order Taking**: Mobile-optimized product selection and cart management
- **Active Orders**: Real-time view of all active orders
- **Order Status**: Track preparation and readiness
- **Payment Processing**: Quick checkout and bill processing (coming soon)
- **Table Transfer**: Move orders between tables (coming soon)

### Table Management
- Visual table grid with status colors:
  - 🟢 Green: Available
  - 🟠 Orange: Occupied
  - 🔵 Blue: Reserved
  - ⚪ Grey: Cleaning
  - 🔴 Red: Blocked
- Zone-based filtering
- Table capacity display
- Quick actions for occupied tables

### Order Taking Flow
1. **Select Table**: Tap a table from the grid
2. **Browse Menu**: Search and filter products by category
3. **Add Items**: Tap products to add to cart
4. **Customize**: Select modifiers for customizable items
5. **Review Cart**: View cart via FAB or cart icon
6. **Send to Kitchen**: Submit order to kitchen display

### Active Orders View
- List of all orders (preparing and ready)
- Filter by status
- Order details in bottom sheet
- Quick payment access for ready orders
- Real-time status updates

## Architecture

### Dependencies
- `pos_core`: Shared business logic (orders, products, tables)
- `pos_ui`: Reusable UI components
- `flutter_riverpod`: State management
- `go_router`: Navigation
- `intl`: Time formatting

### File Structure
```
lib/
├── main.dart                           # App entry and routing
└── src/
    └── features/
        ├── tables/
        │   └── presentation/
        │       └── pages/
        │           └── table_selection_page.dart    # Table grid
        └── order/
            └── presentation/
                └── pages/
                    ├── order_taking_page.dart       # Order entry
                    └── active_orders_page.dart      # Orders list
```

## Configuration

Configuration via `assets/config/app_config_dev.json`:

```json
{
  "appType": "waiter",
  "posMode": "restaurant",
  "enabledFeatures": ["auth", "tables", "orders", "payments", "products"],
  "featureFlags": {
    "enableTableTransfer": true,
    "enableOrderSplitting": true,
    "enableQuickAdd": true,
    "showKitchenStatus": true
  }
}
```

## Mobile Optimization

### UI/UX
- **Large touch targets**: Minimum 48x48dp for all interactive elements
- **Comfortable density**: VisualDensity.comfortable for better touch
- **Mobile-first text sizes**: Optimized for 5-7 inch screens
- **Pull-to-refresh**: Refresh tables and orders with swipe
- **FAB for primary actions**: Easy thumb access
- **Bottom sheets**: Modal views for details without navigation
- **Search bar**: Quick menu item lookup

### Performance
- Lazy loading for product images
- Efficient list rendering with ListView.builder
- Debounced search input
- Cached network requests
- Optimistic UI updates

## Navigation Structure

```
/ (Home)
├─ Table Selection Grid
│  ├─ Tap Available → /table/:id/order
│  ├─ Tap Occupied → Table Options Sheet
│  │  ├─ View Current Order → /table/:id/current-order
│  │  ├─ Add More Items → /table/:id/order
│  │  ├─ Request Bill → /table/:id/checkout
│  │  └─ Transfer Table → Transfer Dialog
│  └─ FAB → /orders
│
├─ /table/:id/order
│  └─ Order Taking Page
│     ├─ Search products
│     ├─ Filter by category
│     ├─ Add to cart (with modifiers)
│     ├─ View cart (bottom sheet)
│     └─ Send to kitchen → Navigate back to /
│
└─ /orders
   └─ Active Orders Page
      ├─ Filter by status
      ├─ Tap order → Order Details (bottom sheet)
      └─ Ready orders → /table/:id/checkout
```

## Usage

### Running the App
```bash
cd apps/waiter_app
flutter run
```

### Taking an Order
1. Open app → See table grid
2. Tap available table (green)
3. Browse menu or search
4. Tap items to add
5. Customize with modifiers if needed
6. Tap "Send (X)" FAB
7. Confirm send to kitchen

### Managing Active Orders
1. Tap "My Orders" FAB on home
2. View all active orders
3. Tap order for details
4. For ready orders, tap "Process Payment"

### Table Actions
1. Tap occupied table (orange)
2. Choose action:
   - View current order
   - Add more items
   - Request bill
   - Transfer table

## Integration with Other Apps

**With pos_register (Cashier):**
- Waiter creates order → Order appears in cashier's order list
- Waiter can initiate payment → Cashier completes transaction

**With kitchen_display (Kitchen):**
- Waiter sends order → Appears in KDS queue
- Kitchen bumps order → Shows as "Ready" in waiter app
- Real-time status synchronization

**Data Flow:**
```
waiter_app → Create Order → pos_core
                ↓
         kitchen_display receives
                ↓
         Kitchen prepares & bumps
                ↓
         waiter_app shows "Ready"
                ↓
         Waiter processes payment
                ↓
         pos_register finalizes
```

## Future Enhancements

### Phase 1 (Next)
- [ ] Complete checkout/payment flow
- [ ] Current order view with edit capability
- [ ] Table transfer functionality
- [ ] Order splitting
- [ ] Quick add favorites

### Phase 2
- [ ] Offline mode support
- [ ] Order notes and special requests
- [ ] Customer feedback collection
- [ ] Tips tracking
- [ ] Shift management

### Phase 3
- [ ] Voice ordering integration
- [ ] Multi-language menu support
- [ ] Allergen and dietary filters
- [ ] Upsell suggestions
- [ ] Performance analytics

## Development Notes

### Reusability
This app reuses ~70% of code from pos_register:
- Same pos_core domain logic
- Same pos_ui components
- Same state management patterns
- Different UI optimized for mobile

### Testing
Test scenarios:
- Multiple tables with different statuses
- Orders with many items
- Orders with complex modifiers
- Concurrent order taking
- Network failure handling
- Cart persistence

### Best Practices
- Always confirm before sending to kitchen
- Clear cart after successful order
- Show loading states
- Handle network errors gracefully
- Provide immediate feedback

## License

Part of SmartPOS ecosystem - Internal use only
