# Customer Display Integration Guide

Odoo-style POS Customer Display with Real-Time Integration

## Overview

The Customer Display is a companion screen that shows customers what's being rung up at the POS register in real-time. It follows Odoo POS customer display patterns 100%.

## Features

### Display Modes

1. **Idle Mode**: Marketing content when no active transaction
2. **Cart Mode**: Real-time cart display as items are scanned
3. **Payment Mode**: Payment processing status
4. **Thank You Mode**: Order completion confirmation

### Real-Time Integration

- WebSocket-based communication with POS register
- Instant updates when items are added/removed/changed
- Last scanned item highlighting
- Running total prominently displayed
- Payment status tracking
- Automatic idle timeout

## Architecture

```
┌─────────────────┐          WebSocket          ┌──────────────────┐
│   POS Register  │ ◄────────────────────────► │ Customer Display │
│                 │                              │                  │
│ - Scan Items    │    Display Protocol         │ - Show Cart      │
│ - Process Payment│   (JSON Messages)          │ - Show Total     │
│ - Complete Order│                              │ - Show Payment   │
└─────────────────┘                              └──────────────────┘
```

## Setup Instructions

### 1. Customer Display Setup

#### Launch the Display App

```bash
cd apps/order_display
flutter run
```

#### Configure Connection

1. Triple-tap top-right corner to access settings
2. Navigate to **Connection Settings**
3. Enter POS register details:
   - **Display Name**: "Customer Display 1"
   - **POS Server Host**: IP address of POS register (e.g., `192.168.1.100`)
   - **Port**: `8080` (default)
4. Enable **Auto Reconnect**
5. Enable **Idle Timeout**
6. Click **Connect**

### 2. POS Register Setup

#### Enable Customer Display Integration

```dart
import 'package:pos_register/src/data/services/customer_display_integration_service.dart';

// In your app initialization
final displayService = ref.read(customerDisplayIntegrationServiceProvider);
displayService.enable();
```

#### Send Cart Updates

```dart
// When item is added to cart
displayService.sendItemAdded(cartItem);

// When item is removed
displayService.sendItemRemoved(itemId);

// When quantity changes
displayService.sendItemQuantityChanged(itemId, newQuantity);

// When cart is cleared
displayService.sendCartCleared();

// Send full cart update
displayService.sendCartUpdate(cart);
```

#### Send Payment Updates

```dart
// Start payment
displayService.sendPaymentStarted('card', 28.84);

// Update payment status
displayService.sendPaymentUpdated(
  'success',
  transactionId: 'TXN123456789',
);

// Or on failure
displayService.sendPaymentUpdated(
  'failed',
  errorMessage: 'Card declined',
);
```

#### Complete Order

```dart
displayService.sendOrderCompleted(order);
```

#### Return to Idle

```dart
displayService.sendDisplayIdle();
```

## Display Protocol

### Message Format

```json
{
  "id": "msg_1234567890",
  "type": "item_added",
  "timestamp": "2025-01-12T10:30:00Z",
  "payload": { ... }
}
```

### Event Types

#### `cart_updated`
Full cart synchronization.

```json
{
  "type": "cart_updated",
  "payload": {
    "cart": {
      "id": "cart123",
      "items": [...],
      "subtotal": 20.97,
      "tax": 2.10,
      "discount": 0,
      "total": 23.07
    }
  }
}
```

#### `item_added`
New item added to cart.

```json
{
  "type": "item_added",
  "payload": {
    "item": {
      "id": "item1",
      "productId": "burger1",
      "productName": "Classic Burger",
      "quantity": 1,
      "unitPrice": 12.99,
      "lineTotal": 12.99,
      "modifiers": ["No onions", "Extra cheese"],
      "isLastScanned": true
    }
  }
}
```

#### `item_removed`
Item removed from cart.

```json
{
  "type": "item_removed",
  "payload": {
    "itemId": "item1"
  }
}
```

#### `item_quantity_changed`
Item quantity updated.

```json
{
  "type": "item_quantity_changed",
  "payload": {
    "itemId": "item1",
    "newQuantity": 2
  }
}
```

#### `cart_cleared`
Cart cleared/cancelled.

```json
{
  "type": "cart_cleared",
  "payload": {}
}
```

#### `payment_started`
Payment process began.

```json
{
  "type": "payment_started",
  "payload": {
    "method": "card",
    "amount": 23.07
  }
}
```

#### `payment_updated`
Payment status changed.

```json
{
  "type": "payment_updated",
  "payload": {
    "status": "success",
    "transactionId": "TXN123456789"
  }
}
```

#### `order_completed`
Order completed.

```json
{
  "type": "order_completed",
  "payload": {
    "order": {
      "id": "order123",
      "orderNumber": "ORD-456",
      "total": 23.07,
      "totalItems": 3,
      "completedAt": "2025-01-12T10:35:00Z"
    }
  }
}
```

#### `display_idle`
Return display to idle mode.

```json
{
  "type": "display_idle",
  "payload": {}
}
```

#### `marketing_content_updated`
Update idle screen content.

```json
{
  "type": "marketing_content_updated",
  "payload": {
    "content": {
      "id": "promo1",
      "type": "promotion",
      "title": "50% Off Burgers!",
      "subtitle": "Today only!",
      "imageUrl": "https://..."
    }
  }
}
```

## Testing

### Test Connection

1. Connect display to POS register
2. In settings, click **Test Connection**
3. Display will run a demo showing:
   - Add burger → Cart updates
   - Add fries → Cart updates
   - Add drink → Cart updates
   - Start payment → Payment screen shows
   - Complete payment → Thank you screen
   - Return to idle

### Manual Testing

```dart
// In your POS app
final displayService = ref.read(customerDisplayIntegrationServiceProvider);

// Test item addition
displayService.sendItemAdded(
  CustomerCartItem(
    id: 'test1',
    productId: 'burger1',
    productName: 'Test Burger',
    quantity: 1,
    unitPrice: 9.99,
    lineTotal: 9.99,
  ),
);

// Test payment
Future.delayed(Duration(seconds: 3), () {
  displayService.sendPaymentStarted('card', 9.99);
});

Future.delayed(Duration(seconds: 6), () {
  displayService.sendPaymentUpdated('success', transactionId: 'TEST123');
});
```

## Network Configuration

### Same Device (Development)
- Host: `localhost`
- Port: `8080`

### Local Network
1. Find POS register IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
2. Use IP address: e.g., `192.168.1.100`
3. Ensure both devices on same network
4. Check firewall allows port 8080

### Production
- Use static IP or hostname for POS register
- Configure router to reserve IP for POS
- Consider VPN for remote displays

## Troubleshooting

### Connection Failed

**Check:**
- Both devices on same network
- Correct IP address and port
- Firewall not blocking port 8080
- POS register WebSocket server running

**Solution:**
```bash
# Test connectivity
ping 192.168.1.100

# Test port (on POS machine)
netstat -an | grep 8080
```

### Display Not Updating

**Check:**
- Connection status (top-right in settings)
- POS integration service enabled
- Events being sent from POS

**Solution:**
```dart
// Verify service is enabled
print(displayService.isEnabled); // Should be true

// Check connected displays
print(displayService.connectedDisplayCount); // Should be > 0
```

### Auto-Reconnect Not Working

**Check:**
- Auto-reconnect enabled in settings
- Max reconnect attempts not exceeded
- Network stable

**Solution:**
- Re-save connection settings
- Restart display app
- Check logs for errors

## Best Practices

### Cart Operations

✅ **DO:**
- Send `item_added` when scanning items
- Send `cart_cleared` when canceling orders
- Send full `cart_updated` after bulk operations
- Send `display_idle` after completing orders

❌ **DON'T:**
- Send too frequent updates (batch if possible)
- Forget to send idle after order completion
- Send invalid item data

### Payment Flow

```dart
// Correct flow
1. displayService.sendPaymentStarted('card', amount);
2. // Process payment...
3. displayService.sendPaymentUpdated('success', transactionId: 'TXN123');
4. displayService.sendOrderCompleted(order);
5. // Display auto-returns to idle after 5s
```

### Error Handling

```dart
try {
  displayService.sendItemAdded(item);
} catch (e) {
  // Log error but don't block POS operations
  print('[Customer Display] Failed to send update: $e');
  // POS continues normally
}
```

## Performance

### Optimization Tips

- **Batch Updates**: Send `cart_updated` instead of multiple `item_added`
- **Debounce**: Don't send updates more than once per 100ms
- **Lazy Connection**: Only connect when display is needed
- **Heartbeat**: Keep connection alive with 30s heartbeat

### Resource Usage

- **Network**: ~1KB per message, <10KB/s typical
- **CPU**: Negligible impact on POS
- **Memory**: <10MB for display service

## Odoo Patterns Followed

✅ Real-time cart synchronization
✅ Last scanned item highlighting
✅ Large readable text (28-96px)
✅ Split-panel layout (items | totals)
✅ Purple theme (#714B67)
✅ Color-coded status indicators
✅ Smooth animations and transitions
✅ Idle screen with marketing content
✅ Payment status display
✅ Thank you screen with order summary
✅ Auto-idle timeout
✅ Modifiers display
✅ Discount indicators

## Version History

### v1.0.0 (Phase 3 Day 1-2)
- Initial customer display implementation
- Cart, payment, thank you, idle screens
- State management with Riverpod
- Mock demo mode

### v1.1.0 (Phase 3 Day 3-4)
- WebSocket integration
- Display protocol
- POS register integration service
- Connection settings UI
- Auto-reconnect
- Error recovery

## Support

For issues or questions:
1. Check logs in debug console
2. Verify network connectivity
3. Test with mock demo mode
4. Review this guide

## License

Part of the Vodo POS System.
