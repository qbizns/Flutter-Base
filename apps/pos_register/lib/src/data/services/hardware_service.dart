/// Hardware Service
/// Provides access to POS hardware devices via Device Bridge
/// Following Odoo IoT Box integration patterns
library;

import 'package:device_bridge_client/device_bridge_client.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_core/pos_core.dart';

/// Hardware Service
/// Manages all hardware device interactions for POS
class HardwareService {
  final DeviceBridgeClient _deviceBridge;
  final String? _receiptPrinterId;
  final String? _kitchenPrinterId;
  final String? _barcodeScan​nerId;
  final String? _paymentTerminalId;

  HardwareService({
    required DeviceBridgeClient deviceBridge,
    String? receiptPrinterId,
    String? kitchenPrinterId,
    String? barcodeScan​nerId,
    String? paymentTerminalId,
  })  : _deviceBridge = deviceBridge,
        _receiptPrinterId = receiptPrinterId,
        _kitchenPrinterId = kitchenPrinterId,
        _barcodeScan​nerId = barcodeScan​nerId,
        _paymentTerminalId = paymentTerminalId;

  // ========================================
  // Receipt Printer Operations
  // ========================================

  /// Print customer receipt
  Future<Result<String>> printReceipt({
    required Order order,
    required String cashierName,
    double? cashReceived,
    double? change,
  }) async {
    try {
      if (_receiptPrinterId == null) {
        return Result.failure(
          Failure(message: 'Receipt printer not configured'),
        );
      }

      debugPrint('[HardwareService] Printing receipt for order ${order.orderNumber}');

      final printer = _deviceBridge.printer(_receiptPrinterId!);

      // Build receipt using builder pattern
      final result = await printer.printReceipt(
        (b) => b
          ..text(
            'SmartPOS',
            alignment: TextAlignment.center,
            size: TextSize.large,
            bold: true,
          )
          ..text(
            'Restaurant & Retail',
            alignment: TextAlignment.center,
          )
          ..text(
            '123 Main Street, City',
            alignment: TextAlignment.center,
          )
          ..text(
            'Tel: (555) 123-4567',
            alignment: TextAlignment.center,
          )
          ..lineFeed(lines: 1)
          ..divider()
          ..text(
            'Order #${order.orderNumber}',
            alignment: TextAlignment.center,
            size: TextSize.medium,
            bold: true,
          )
          ..text(
            DateTime.now().toString().substring(0, 19),
            alignment: TextAlignment.center,
          )
          ..text('Cashier: $cashierName')
          ..divider()
          ..lineFeed(lines: 1)
          // Items header
          ..row([
            ReceiptColumn(text: 'Item', width: 6),
            ReceiptColumn(text: 'Qty', width: 2, alignment: TextAlignment.right),
            ReceiptColumn(text: 'Price', width: 2, alignment: TextAlignment.right),
            ReceiptColumn(text: 'Total', width: 2, alignment: TextAlignment.right),
          ])
          ..divider(char: '-')
          // Items
          ..addAll(order.items.map((item) => [
                b.row([
                  ReceiptColumn(text: item.name, width: 6),
                  ReceiptColumn(
                    text: '${item.quantity}',
                    width: 2,
                    alignment: TextAlignment.right,
                  ),
                  ReceiptColumn(
                    text: '\$${item.price.toStringAsFixed(2)}',
                    width: 2,
                    alignment: TextAlignment.right,
                  ),
                  ReceiptColumn(
                    text: '\$${item.subtotal.toStringAsFixed(2)}',
                    width: 2,
                    alignment: TextAlignment.right,
                  ),
                ]),
              ]).expand((x) => x))
          ..divider()
          ..lineFeed(lines: 1)
          // Totals
          ..keyValue('Subtotal:', '\$${order.subtotal.toStringAsFixed(2)}')
          ..keyValue('Tax:', '\$${order.tax.toStringAsFixed(2)}')
          ..keyValue(
            'TOTAL:',
            '\$${order.total.toStringAsFixed(2)}',
            keyStyle: const TextStyle(bold: true),
            valueStyle: const TextStyle(bold: true, size: TextSize.large),
          )
          ..lineFeed(lines: 1)
          ..divider()
          ..text('Payment: ${order.paymentMethod?.name ?? "Cash"}')
          ..when(
            cashReceived != null,
            (b) => b
              ..text('Cash Received: \$${cashReceived!.toStringAsFixed(2)}')
              ..text('Change: \$${change!.toStringAsFixed(2)}'),
          )
          ..lineFeed(lines: 2)
          ..text(
            'Thank you for your business!',
            alignment: TextAlignment.center,
            bold: true,
          )
          ..text(
            'Please come again',
            alignment: TextAlignment.center,
          )
          ..lineFeed(lines: 1)
          // QR code for digital receipt
          ..qrCode(
            'https://smartpos.app/receipts/${order.id}',
            size: 6,
          )
          ..lineFeed(lines: 2)
          ..cut(),
        options: PrintOptions(
          copies: 1,
          autoCut: true,
          openDrawer: cashReceived != null, // Open drawer if cash payment
        ),
      );

      debugPrint('[HardwareService] Receipt printed: ${result.jobId}');
      return Result.success(result.jobId);
    } catch (e) {
      debugPrint('[HardwareService] Print receipt failed: $e');
      return Result.failure(
        Failure(message: 'Failed to print receipt: $e'),
      );
    }
  }

  /// Test receipt printer
  Future<Result<bool>> testReceiptPrinter() async {
    try {
      if (_receiptPrinterId == null) {
        return Result.failure(
          Failure(message: 'Receipt printer not configured'),
        );
      }

      final printer = _deviceBridge.printer(_receiptPrinterId!);
      await printer.printTestPage();

      return const Result.success(true);
    } catch (e) {
      debugPrint('[HardwareService] Test print failed: $e');
      return Result.failure(
        Failure(message: 'Test print failed: $e'),
      );
    }
  }

  // ========================================
  // Kitchen Printer Operations
  // ========================================

  /// Print kitchen order
  Future<Result<String>> printKitchenOrder({
    required Order order,
    required String waiterName,
    String? tableName,
  }) async {
    try {
      if (_kitchenPrinterId == null) {
        return Result.failure(
          Failure(message: 'Kitchen printer not configured'),
        );
      }

      debugPrint('[HardwareService] Printing kitchen order ${order.orderNumber}');

      final printer = _deviceBridge.printer(_kitchenPrinterId!);

      final result = await printer.printReceipt(
        (b) => b
          ..text(
            'KITCHEN ORDER',
            alignment: TextAlignment.center,
            size: TextSize.extraLarge,
            bold: true,
          )
          ..lineFeed(lines: 1)
          ..divider(char: '=')
          ..text(
            'Order #${order.orderNumber}',
            size: TextSize.large,
            bold: true,
          )
          ..text(DateTime.now().toString().substring(0, 19))
          ..when(
            tableName != null,
            (b) => b..text('Table: $tableName', bold: true),
          )
          ..text('Waiter: $waiterName')
          ..divider(char: '=')
          ..lineFeed(lines: 2)
          // Items with large font
          ..addAll(order.items.map((item) => [
                b
                  ..text(
                    '${item.quantity}x ${item.name}',
                    size: TextSize.large,
                    bold: true,
                  )
                  ..when(
                    item.notes?.isNotEmpty == true,
                    (b) => b..text('   Notes: ${item.notes}', bold: true),
                  )
                  ..lineFeed(lines: 1),
              ]).expand((x) => x))
          ..lineFeed(lines: 2)
          ..divider(char: '=')
          ..text(
            'Total Items: ${order.items.fold<int>(0, (sum, item) => sum + item.quantity)}',
            size: TextSize.large,
            bold: true,
          )
          ..lineFeed(lines: 3)
          ..cut(),
        options: PrintOptions(
          copies: 1,
          autoCut: true,
        ),
      );

      debugPrint('[HardwareService] Kitchen order printed: ${result.jobId}');
      return Result.success(result.jobId);
    } catch (e) {
      debugPrint('[HardwareService] Print kitchen order failed: $e');
      return Result.failure(
        Failure(message: 'Failed to print kitchen order: $e'),
      );
    }
  }

  // ========================================
  // Cash Drawer Operations
  // ========================================

  /// Open cash drawer
  Future<Result<bool>> openCashDrawer() async {
    try {
      if (_receiptPrinterId == null) {
        return Result.failure(
          Failure(message: 'Receipt printer not configured'),
        );
      }

      debugPrint('[HardwareService] Opening cash drawer');

      final printer = _deviceBridge.printer(_receiptPrinterId!);
      await printer.openCashDrawer();

      return const Result.success(true);
    } catch (e) {
      debugPrint('[HardwareService] Open cash drawer failed: $e');
      return Result.failure(
        Failure(message: 'Failed to open cash drawer: $e'),
      );
    }
  }

  // ========================================
  // Barcode Scanner Operations
  // ========================================

  /// Listen to barcode scanner events
  Stream<String> get barcodeStream {
    if (_barcodeScan​nerId == null) {
      debugPrint('[HardwareService] Barcode scanner not configured');
      return const Stream.empty();
    }

    final scanner = _deviceBridge.scanner(_barcodeScan​nerId!);
    return scanner.scanStream.map((scan) {
      debugPrint('[HardwareService] Barcode scanned: ${scan.code}');
      return scan.code;
    });
  }

  // ========================================
  // Payment Terminal Operations
  // ========================================

  /// Process card payment
  Future<Result<PaymentResult>> processCardPayment({
    required double amount,
    required String orderId,
  }) async {
    try {
      if (_paymentTerminalId == null) {
        return Result.failure(
          Failure(message: 'Payment terminal not configured'),
        );
      }

      debugPrint('[HardwareService] Processing card payment: \$$amount');

      final terminal = _deviceBridge.paymentTerminal(_paymentTerminalId!);

      final request = PaymentRequest(
        amount: amount,
        currency: 'USD',
        reference: orderId,
      );

      final response = await terminal.processPayment(request);

      debugPrint('[HardwareService] Payment result: ${response.status}');

      if (response.status == PaymentStatus.approved) {
        return Result.success(PaymentResult(
          success: true,
          transactionId: response.transactionId,
          authCode: response.authorizationCode,
          cardType: response.cardType,
          cardLastFour: response.cardLastFour,
        ));
      } else {
        return Result.failure(
          Failure(
            message: response.errorMessage ?? 'Payment declined',
            type: FailureType.validation,
          ),
        );
      }
    } catch (e) {
      debugPrint('[HardwareService] Payment processing failed: $e');
      return Result.failure(
        Failure(message: 'Payment processing failed: $e'),
      );
    }
  }

  /// Cancel payment
  Future<Result<bool>> cancelPayment() async {
    try {
      if (_paymentTerminalId == null) {
        return Result.failure(
          Failure(message: 'Payment terminal not configured'),
        );
      }

      debugPrint('[HardwareService] Cancelling payment');

      final terminal = _deviceBridge.paymentTerminal(_paymentTerminalId!);
      await terminal.cancelTransaction();

      return const Result.success(true);
    } catch (e) {
      debugPrint('[HardwareService] Cancel payment failed: $e');
      return Result.failure(
        Failure(message: 'Failed to cancel payment: $e'),
      );
    }
  }

  // ========================================
  // Device Status Operations
  // ========================================

  /// Check receipt printer status
  Future<Result<bool>> checkReceiptPrinterStatus() async {
    try {
      if (_receiptPrinterId == null) {
        return const Result.success(false);
      }

      final printer = _deviceBridge.printer(_receiptPrinterId!);
      final status = await printer.getStatus();

      return Result.success(status.isReady);
    } catch (e) {
      debugPrint('[HardwareService] Check printer status failed: $e');
      return const Result.success(false);
    }
  }

  /// Check payment terminal status
  Future<Result<bool>> checkPaymentTerminalStatus() async {
    try {
      if (_paymentTerminalId == null) {
        return const Result.success(false);
      }

      final terminal = _deviceBridge.paymentTerminal(_paymentTerminalId!);
      final status = await terminal.getStatus();

      return Result.success(status.isReady);
    } catch (e) {
      debugPrint('[HardwareService] Check terminal status failed: $e');
      return const Result.success(false);
    }
  }
}

/// Payment Result
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? authCode;
  final String? cardType;
  final String? cardLastFour;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.authCode,
    this.cardType,
    this.cardLastFour,
  });
}
