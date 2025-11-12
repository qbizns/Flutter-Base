# Hardware Device Integration - SmartPOS

## Overview

SmartPOS integrates with real hardware devices using the **Device Bridge** system. Device Bridge is a local microservice that acts as a hardware abstraction layer, allowing POS applications to communicate with printers, scanners, payment terminals, and other peripherals through a unified API.

## Architecture

```
┌─────────────────┐
│  Flutter Apps   │
│  (POS/Waiter)   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│ device_bridge_client    │
│ (Flutter SDK)           │
└────────┬────────────────┘
         │ HTTP/WebSocket
         ▼
┌─────────────────────────┐
│   Device Bridge         │
│   (Go Backend)          │
│   localhost:8080        │
└────────┬────────────────┘
         │ USB/Serial/TCP
         ▼
┌─────────────────────────┐
│  Hardware Devices       │
│  Printers, Scanners,    │
│  Payment Terminals, etc.│
└─────────────────────────┘
```

## Supported Devices

### Phase 1 (Implemented)

1. **ESC/POS Receipt Printers**
   - USB, Serial (RS-232), TCP/IP (port 9100)
   - Text formatting, barcodes, QR codes, logos
   - Paper cutting, cash drawer pulse

2. **Kitchen Printers**
   - ESC/POS compatible
   - Large font emphasis for kitchen orders
   - Buzzer support (optional)

3. **Barcode/QR Scanners**
   - USB HID mode (keyboard wedge)
   - USB Raw mode
   - Serial scanners

4. **Payment Terminals**
   - EMV/Chip & PIN
   - Contactless (NFC)
   - Real-time transaction status

5. **Cash Drawers**
   - Via printer pulse (ESC/POS)
   - Direct I/O (future)

## Setup Guide

### 1. Install Device Bridge Backend

The Device Bridge backend is located at `/Flutter-Device` in the repository.

```bash
cd Flutter-Device
go build -o device-bridge ./cmd/bridge

# Run Device Bridge
./device-bridge serve --port 8080
```

### 2. Register Devices

Devices can be registered via:

**A. Static Configuration** (config.yaml):
```yaml
devices:
  - id: printer-receipt-01
    name: "Receipt Printer"
    type: escpos_printer
    connection:
      type: network
      address: "192.168.1.100"
      port: 9100

  - id: printer-kitchen-01
    name: "Kitchen Printer"
    type: escpos_printer
    connection:
      type: usb
      vendor_id: "0x0416"
      product_id: "0x5011"

  - id: scanner-01
    name: "Barcode Scanner"
    type: barcode_scanner
    connection:
      type: usb_hid
```

**B. Dynamic Discovery**:
```bash
# List available USB devices
./device-bridge devices list

# Auto-discover and register
./device-bridge devices discover
```

**C. REST API**:
```bash
# Register device via API
curl -X POST http://localhost:8080/v1/devices \
  -H "Content-Type: application/json" \
  -d '{
    "id": "printer-receipt-01",
    "name": "Receipt Printer",
    "type": "escpos_printer",
    "connection": {
      "type": "network",
      "address": "192.168.1.100",
      "port": 9100
    }
  }'
```

### 3. Configure Flutter Apps

Add device IDs to app configuration:

**POS Register** (`assets/config/app_config.json`):
```json
{
  "deviceBridgeUrl": "http://localhost:8080",
  "receiptPrinterId": "printer-receipt-01",
  "barcodeScan​nerId": "scanner-01",
  "paymentTerminalId": "terminal-01"
}
```

**Waiter App** (`assets/config/app_config.json`):
```json
{
  "deviceBridgeUrl": "http://localhost:8080",
  "kitchenPrinterId": "printer-kitchen-01"
}
```

### 4. Test Hardware

```bash
# Test printer
curl -X POST http://localhost:8080/v1/devices/printer-receipt-01/printer/test-print

# Check device status
curl http://localhost:8080/v1/devices/printer-receipt-01/printer/status
```

## Usage in Flutter Apps

### POS Register - Receipt Printing

Receipt printing is automatically triggered after payment completion:

```dart
// File: apps/pos_register/lib/src/features/payment/presentation/pages/payment_page.dart

// After order is saved, print receipt
final hardware = ref.read(hardwareServiceProvider);

final result = await hardware.printReceipt(
  order: order,
  cashierName: cashierName,
  cashReceived: cashReceived,
  change: change,
);
```

**Receipt Features:**
- Store header with name and address
- Order number and timestamp
- Cashier name
- Line items with quantities and prices
- Subtotal, tax, and total
- Payment method details
- Cash received and change (for cash payments)
- QR code for digital receipt
- Auto-cut paper
- Auto-open cash drawer (for cash payments)

### Waiter App - Kitchen Printing

Kitchen orders are printed when sent to kitchen:

```dart
// File: apps/waiter_app/lib/src/ui/pages/order_taking_page.dart

// When order is sent to kitchen, print ticket
final deviceBridge = ref.read(deviceBridgeClientProvider);
final printer = deviceBridge.printer(kitchenPrinterId);

await printer.printReceipt(
  (b) => b
    ..text('KITCHEN ORDER', size: TextSize.extraLarge, bold: true)
    ..text('Order #${order.orderNumber}', bold: true)
    ..text('Table: ${table.name}')
    ..text('Waiter: ${waiter.name}')
    ..divider()
    // Items with large fonts
    ..addAll(items.map((item) =>
      b.text('${item.quantity}x ${item.name}', size: TextSize.large)
    ))
    ..cut(),
);
```

**Kitchen Ticket Features:**
- Large, bold fonts for easy reading
- Order number prominently displayed
- Table and waiter information
- Item quantities emphasized
- Special instructions/notes highlighted
- Auto-cut for easy separation

### Payment Terminal Integration

```dart
// Process card payment
final hardware = ref.read(hardwareServiceProvider);

final result = await hardware.processCardPayment(
  amount: order.total,
  orderId: order.id,
);

result.when(
  success: (payment) {
    // Payment approved
    print('Transaction ID: ${payment.transactionId}');
    print('Auth Code: ${payment.authCode}');
    print('Card: ${payment.cardType} ****${payment.cardLastFour}');
  },
  failure: (error) {
    // Payment declined
    print('Payment failed: ${error.message}');
  },
);
```

### Barcode Scanner

```dart
// Listen to barcode scanner stream
ref.listen(barcodeScannerStreamProvider, (previous, next) {
  next.whenData((barcode) {
    // Barcode scanned
    print('Scanned: $barcode');
    // Search for product and add to cart
    searchProduct(barcode);
  });
});
```

### Cash Drawer

```dart
// Open cash drawer manually
final hardware = ref.read(hardwareServiceProvider);
await hardware.openCashDrawer();
```

## Device Bridge Client API

### Printer Service

```dart
final printer = deviceBridge.printer('printer-id');

// Check status
final status = await printer.getStatus();
if (status.isReady) {
  // Print using builder pattern
  await printer.printReceipt(
    (b) => b
      ..header('My Store')
      ..text('123 Main St')
      ..divider()
      ..keyValue('Total', '\$50.00')
      ..qrCode('https://example.com/receipt/123')
      ..cut(),
    options: PrintOptions(
      copies: 1,
      autoCut: true,
      openDrawer: true,
    ),
  );
}

// Print barcode
await printer.printBarcode(
  '1234567890',
  BarcodeFormat.code128,
);

// Print QR code
await printer.printQRCode(
  'https://smartpos.app',
  size: 6,
);

// Feed paper
await printer.feedPaper(lines: 3);

// Open cash drawer
await printer.openCashDrawer();
```

### Scanner Service

```dart
final scanner = deviceBridge.scanner('scanner-id');

// Listen to scans
scanner.scanStream.listen((scan) {
  print('Barcode: ${scan.code}');
  print('Format: ${scan.format}');
});
```

### Payment Terminal Service

```dart
final terminal = deviceBridge.paymentTerminal('terminal-id');

// Process payment
final request = PaymentRequest(
  amount: 50.00,
  currency: 'USD',
  reference: 'ORDER-123',
);

final response = await terminal.processPayment(request);

if (response.status == PaymentStatus.approved) {
  print('Payment approved!');
} else {
  print('Payment declined: ${response.errorMessage}');
}

// Cancel transaction
await terminal.cancelTransaction();
```

## Hardware Providers (Riverpod)

```dart
// Device Bridge Client
final deviceBridgeClientProvider = Provider<DeviceBridgeClient>((ref) {
  final config = ref.watch(configProvider);
  return DeviceBridgeClient(
    baseUrl: config.metadata['deviceBridgeUrl'] ?? 'http://localhost:8080',
  );
});

// Hardware Service (POS Register)
final hardwareServiceProvider = Provider<HardwareService>((ref) {
  return HardwareService(
    deviceBridge: ref.watch(deviceBridgeClientProvider),
    receiptPrinterId: ref.watch(receiptPrinterIdProvider),
    kitchenPrinterId: ref.watch(kitchenPrinterIdProvider),
    barcodeScan​nerId: ref.watch(barcodeScannerIdProvider),
    paymentTerminalId: ref.watch(paymentTerminalIdProvider),
  );
});

// Device status
final receiptPrinterStatusProvider = FutureProvider<bool>((ref) async {
  final hardware = ref.watch(hardwareServiceProvider);
  final result = await hardware.checkReceiptPrinterStatus();
  return result.when(
    success: (isReady) => isReady,
    failure: (_) => false,
  );
});
```

## Troubleshooting

### Printer Not Found

```bash
# Check if Device Bridge is running
curl http://localhost:8080/health

# List registered devices
curl http://localhost:8080/v1/devices

# Check device status
curl http://localhost:8080/v1/devices/{device-id}/printer/status
```

### Network Printer Connection Issues

```bash
# Test connectivity
ping 192.168.1.100

# Check if port 9100 is open
nc -zv 192.168.1.100 9100

# Try raw print test
echo "Test" | nc 192.168.1.100 9100
```

### USB Device Not Detected

```bash
# Linux: List USB devices
lsusb

# macOS: List USB devices
system_profiler SPUSBDataType

# Check permissions (Linux)
sudo chmod 666 /dev/usb/lp0
```

### Payment Terminal Timeout

- Check terminal is powered on and connected
- Verify network connectivity (for network terminals)
- Ensure terminal is not in sleep mode
- Check Device Bridge logs for detailed error messages

## Production Deployment

### Security Considerations

1. **Network Isolation**
   - Run Device Bridge on local network only
   - Do not expose to public internet
   - Use firewall rules to restrict access

2. **PCI-DSS Compliance**
   - Never log card numbers (PAN)
   - Use encrypted communication for payment terminals
   - Follow payment processor security guidelines

3. **Device Authentication**
   - Use API keys for Device Bridge access
   - Implement device certificates for sensitive operations

### High Availability

1. **Redundant Devices**
   - Configure backup printers
   - Automatic failover to backup devices
   - Queue print jobs during outages

2. **Monitoring**
   - Monitor device status (online/offline)
   - Alert on low paper, cover open, etc.
   - Track print job success rates

### Performance Optimization

1. **Async Printing**
   - Print operations are non-blocking
   - UI remains responsive during printing
   - Background job queue for retries

2. **Connection Pooling**
   - Reuse device connections
   - Automatic reconnection on failure
   - Health check intervals

## Related Documentation

- [Device Bridge V2 Specification](../Flutter-Device/docs/DEVICE_BRIDGE_V2_SPECIFICATION.md)
- [Device Management](24-Device-Management.md)
- [POS Register Documentation](../apps/pos_register/README.md)
- [Waiter App Documentation](../apps/waiter_app/README.md)

## Support

For hardware-specific issues:
- Check Device Bridge logs: `./device-bridge logs`
- Device manufacturer documentation
- Community forums: https://github.com/Macber-eg/Flutter-Device/discussions
