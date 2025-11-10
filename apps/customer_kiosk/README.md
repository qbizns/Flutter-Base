# Customer Kiosk App

Self-service ordering system optimized for large touchscreen displays (10-15 inches).

## Features

### Core Functionality
- **Welcome Screen**: Idle state with "Start Order" button and language selection
- **Product Browsing**: Large product cards with images and clear pricing
- **Cart Management**: Review and edit order with large quantity controls
- **Self-Checkout**: Payment method selection and terminal integration
- **Order Tracking**: Confirmation screen with order number and wait time
- **Auto-Reset**: Returns to welcome screen after timeout (configurable)

### User Experience
- Large touch targets (minimum 60x60dp)
- Extra-large text (18-64px) for easy reading
- Simple, intuitive navigation
- Visual feedback on all interactions
- Clear pricing and order summary
- Accessibility-friendly design

### Customer Flow
```
Welcome Screen
    ↓ (Tap "Start Order")
Menu (Browse & Add)
    ↓ (View Cart)
Cart Review
    ↓ (Proceed to Checkout)
Checkout (Select Payment)
    ↓ (Pay)
Order Tracking
    ↓ (Auto-redirect after 30s)
Welcome Screen
```

## Architecture

### Kiosk-Specific Optimizations

**Display Size**: Optimized for 10-15 inch touchscreens
- 3-column product grid
- Large buttons (60-100px height)
- Extra-large text (18-64px)
- Spacious padding (24-48px)
- Clear visual hierarchy

**Touch Targets**:
- Minimum 60x60dp for all interactive elements
- Large icon buttons (32-48px icons)
- Generous padding around all buttons
- Card-based layouts for easy tapping

**Typography**:
- Display (44-64px): Hero text, order numbers
- Headline (28-36px): Section headers
- Title (18-28px): Product names, buttons
- Body (14-18px): Descriptions, labels

### Dependencies
- `pos_core`: Shared business logic
- `pos_ui`: Reusable UI components (ModifierSelector)
- `flutter_riverpod`: State management
- `go_router`: Navigation
- `intl`: Currency and time formatting

### File Structure
```
lib/
├── main.dart                           # App entry + kiosk themes
└── src/
    └── features/
        ├── welcome/
        │   └── presentation/pages/
        │       └── welcome_page.dart        # Idle/start screen
        ├── menu/
        │   └── presentation/pages/
        │       └── menu_page.dart           # Product browsing
        ├── cart/
        │   └── presentation/pages/
        │       └── cart_page.dart           # Cart review
        ├── checkout/
        │   └── presentation/pages/
        │       └── checkout_page.dart       # Payment
        └── order/
            └── presentation/pages/
                └── order_tracking_page.dart # Confirmation
```

## Configuration

Configuration via `assets/config/app_config_dev.json`:

```json
{
  "appType": "kiosk",
  "posMode": "restaurant",
  "featureFlags": {
    "enableMultiLanguage": true,
    "enableAccessibility": true,
    "enablePaymentTerminal": true,
    "idleTimeout": 60
  },
  "kioskSettings": {
    "displaySize": "large",
    "orderType": "takeaway",
    "autoResetSeconds": 60,
    "showOrderTracking": true,
    "languages": ["en", "es", "ar"]
  }
}
```

## Usage

### Running the App
```bash
cd apps/customer_kiosk
flutter run -d <device>
```

### Customer Journey

**1. Start Order**
- Customer approaches kiosk
- Welcome screen displays
- Tap "Start Order" button
- Optional: Select language

**2. Browse Menu**
- View all products or filter by category
- Large product cards with:
  * Product name
  * Description
  * Price
  * Image placeholder
- Tap product to add to cart
- Select modifiers if applicable
- See confirmation feedback

**3. Review Cart**
- Tap cart button (shows total)
- Review all items
- Adjust quantities with +/- buttons
- Remove items with trash icon
- See subtotal, tax, total

**4. Checkout**
- Tap "Proceed to Checkout"
- View order summary
- Select payment method:
  * Credit/Debit Card
  * Cash
  * Mobile Pay
- Tap "Pay" button
- Payment processing...

**5. Order Confirmation**
- Success animation displays
- Large order number shown
- Estimated wait time
- Instructions for pickup
- Option to print receipt
- Auto-redirect to home in 30s

## Screen Details

### Welcome Page
- **Purpose**: Attract customers and initiate ordering
- **Layout**: Centered hero content with branding
- **CTAs**: Large "Start Order" button, language selector
- **Idle State**: This is the default/idle screen

### Menu Page
- **Purpose**: Product selection and cart building
- **Layout**: 3-column grid, category filters at top
- **Features**: Search, category filtering, cart badge
- **Navigation**: Back to welcome, view cart

### Cart Page
- **Purpose**: Order review and editing
- **Layout**: List of items with quantity controls
- **Features**: Add/remove items, update quantities
- **CTAs**: "Add More Items", "Proceed to Checkout"

### Checkout Page
- **Purpose**: Payment method selection
- **Layout**: 3-column payment grid, order summary
- **Features**: Card, cash, mobile pay options
- **CTAs**: Large "Pay $X.XX" button

### Order Tracking Page
- **Purpose**: Confirmation and customer guidance
- **Layout**: Centered order number and instructions
- **Features**: Success animation, wait time, print receipt
- **Auto-behavior**: Returns to home after 30 seconds

## Integration with Ecosystem

**With pos_core:**
- Uses products, categories, cart providers
- Creates orders via createOrderUseCase
- Processes payments via processPaymentUseCase

**With kitchen_display:**
- Order created → Appears in kitchen queue
- Kitchen prepares food
- Staff calls order number

**With pos_register:**
- Kiosk creates order
- Cashier can view if customer needs help
- Payment processed directly via kiosk

**Data Flow:**
```
customer_kiosk (create & pay)
    ↓
pos_core (business logic)
    ↓
kitchen_display (prepare)
    ↓
Customer picks up order
```

## Kiosk-Specific Features

### Auto-Reset
- Automatically returns to welcome screen after timeout
- Prevents previous customer's data from showing
- Configurable timeout (default: 60 seconds on order tracking)
- Clears cart on navigation back from menu

### Language Support
- Welcome screen shows language selector
- Supports English, Spanish, Arabic
- Persists selection during session
- Resets on timeout

### Accessibility
- Large text for readability
- High contrast UI
- Clear visual hierarchy
- Simple, intuitive navigation
- Minimal steps to complete order

### Payment Terminal Integration
- Placeholder for card terminal
- Supports multiple payment methods
- Visual feedback during processing
- Error handling for failed payments

## Hardware Recommendations

### Display
- **Size**: 15-21 inch touchscreen
- **Resolution**: 1920x1080 (Full HD) minimum
- **Type**: Capacitive touch for best response
- **Orientation**: Portrait or landscape (app adapts)
- **Mounting**: Counter-mounted or wall-mounted kiosk stand

### Payment Terminal
- **Types**: EMV chip reader, NFC for mobile pay
- **Integration**: Via pos_core payment provider
- **Security**: PCI compliant terminal required

### Receipt Printer
- **Type**: Thermal printer, 80mm width
- **Connection**: USB or Bluetooth
- **Location**: Customer-facing for self-pickup

### Additional
- **Barcode Scanner**: For QR code loyalty (future)
- **Card Dispenser**: For physical loyalty cards (future)
- **Speakers**: For audio feedback (future)

## Future Enhancements

### Phase 1 (Next)
- [ ] Multi-language implementation
- [ ] Actual image loading for products
- [ ] Payment terminal SDK integration
- [ ] Receipt printer integration
- [ ] Idle screen timeout settings

### Phase 2
- [ ] Loyalty program integration
- [ ] Saved favorites for quick reorder
- [ ] Nutritional information display
- [ ] Allergen filtering
- [ ] Calorie counter

### Phase 3
- [ ] Upsell suggestions
- [ ] Combo deals and promotions
- [ ] Voice ordering
- [ ] Accessibility features (TTS, large text mode)
- [ ] Age verification for restricted items

### Phase 4
- [ ] Analytics dashboard
- [ ] A/B testing for layouts
- [ ] Dynamic pricing
- [ ] Personalized recommendations
- [ ] Social media integration

## Development Notes

### Testing Scenarios
- Order with single item
- Order with multiple items
- Order with modifiers
- Cart editing (add, remove, update)
- Different payment methods
- Navigation: forward and back
- Timeout/auto-reset behavior
- Error handling (payment failure, network issues)

### Performance
- Fast product loading (< 1s)
- Smooth animations
- Responsive touch feedback
- No lag on interactions
- Efficient memory usage

### Maintenance
- Regular content updates (products, prices)
- Software updates (overnight)
- Hardware cleaning (daily)
- Monitor uptime and errors
- Remote management capability

## Security

### Data Protection
- No personal data stored
- Payment data handled by terminal (PCI compliant)
- Order data temporary (clears on reset)
- Network communication encrypted

### Physical Security
- Kiosk securely mounted
- Payment terminal tamper-evident
- Regular hardware inspections
- Receipt printer jam protection

## License

Part of SmartPOS ecosystem - Internal use only

## Support

For issues with the kiosk app:
1. Check hardware connections
2. Restart the app
3. Check network connectivity
4. Review error logs
5. Contact IT support if needed
