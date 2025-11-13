/// Kitchen Ticket Print Service
/// Handles printing of kitchen tickets following Odoo KDS patterns
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kitchen_order.dart';
import '../models/kitchen_station.dart';

/// Print format options
enum PrintFormat {
  /// 80mm thermal printer (standard)
  thermal80mm,

  /// 58mm thermal printer (compact)
  thermal58mm,

  /// A4 paper (laser/inkjet)
  a4,

  /// Receipt (narrow format)
  receipt,
}

/// Print settings
class PrintSettings {
  final PrintFormat format;
  final bool autoPrint;
  final bool printOnNewOrder;
  final bool printOnStatusChange;
  final int fontSize;
  final bool includeLogo;
  final bool includeBarcode;
  final List<String> enabledStations;

  const PrintSettings({
    this.format = PrintFormat.thermal80mm,
    this.autoPrint = true,
    this.printOnNewOrder = true,
    this.printOnStatusChange = false,
    this.fontSize = 12,
    this.includeLogo = true,
    this.includeBarcode = true,
    this.enabledStations = const [],
  });

  PrintSettings copyWith({
    PrintFormat? format,
    bool? autoPrint,
    bool? printOnNewOrder,
    bool? printOnStatusChange,
    int? fontSize,
    bool? includeLogo,
    bool? includeBarcode,
    List<String>? enabledStations,
  }) {
    return PrintSettings(
      format: format ?? this.format,
      autoPrint: autoPrint ?? this.autoPrint,
      printOnNewOrder: printOnNewOrder ?? this.printOnNewOrder,
      printOnStatusChange: printOnStatusChange ?? this.printOnStatusChange,
      fontSize: fontSize ?? this.fontSize,
      includeLogo: includeLogo ?? this.includeLogo,
      includeBarcode: includeBarcode ?? this.includeBarcode,
      enabledStations: enabledStations ?? this.enabledStations,
    );
  }
}

/// Kitchen Ticket Print Service
/// Manages printing of kitchen tickets to thermal printers
class KitchenTicketPrintService {
  PrintSettings _settings = const PrintSettings();
  final _printQueue = <String>[];

  PrintSettings get settings => _settings;

  /// Initialize print service
  Future<void> initialize() async {
    // Initialize printer connection
    // In production, this would connect to actual printer hardware
    // For now, this is a placeholder
  }

  /// Update print settings
  void updateSettings(PrintSettings settings) {
    _settings = settings;
  }

  /// Print kitchen ticket for order
  Future<bool> printTicket(KitchenOrder order) async {
    // Check if printing is enabled for this station
    if (_settings.enabledStations.isNotEmpty &&
        !order.stationIds.any((id) => _settings.enabledStations.contains(id))) {
      return false;
    }

    try {
      final ticketContent = _generateTicketContent(order);

      // In production, send to actual printer
      // For now, simulate printing
      await _printToDevice(ticketContent);

      return true;
    } catch (e) {
      // Print failed
      return false;
    }
  }

  /// Print ticket for specific station
  Future<bool> printStationTicket(
    KitchenOrder order,
    String stationId,
  ) async {
    // Filter items for this station
    final stationItems = order.items.where((item) {
      // In production, check item's station assignment
      // For now, include all items
      return true;
    }).toList();

    if (stationItems.isEmpty) return false;

    // Create modified order with only station items
    final stationOrder = order.copyWith(
      items: stationItems,
      stationIds: [stationId],
    );

    return await printTicket(stationOrder);
  }

  /// Generate ticket content following Odoo format
  String _generateTicketContent(KitchenOrder order) {
    final lines = <String>[];
    final width = _getTicketWidth();

    // Logo (if enabled)
    if (_settings.includeLogo) {
      lines.add(_center('***** KITCHEN TICKET *****', width));
      lines.add(_center('Restaurant Name', width));
      lines.add(_line(width));
    }

    // Order header
    lines.add(_bold('Order: ${order.orderNumber}'));
    lines.add(_line(width));

    // Order info
    if (order.tableName != null) {
      lines.add(_bold('Table: ${order.tableName}'));
    } else if (order.customerName != null) {
      lines.add(_bold('Customer: ${order.customerName}'));
    }

    // Order type & priority
    final typeAndPriority = <String>[];
    typeAndPriority.add('Type: ${_getOrderTypeDisplay(order)}');
    if (order.priority != OrderPriority.normal) {
      typeAndPriority.add('Priority: ${order.priority.displayName}');
    }
    lines.add(typeAndPriority.join(' | '));

    // Stations
    if (order.stationIds.isNotEmpty) {
      final stationNames = order.stationIds
          .map((id) => DefaultKitchenStations.getStationById(id)?.name ?? id)
          .join(', ');
      lines.add('Station: $stationNames');
    }

    // Time
    final timeStr = _formatTime(order.createdAt);
    lines.add('Time: $timeStr');
    lines.add(_line(width));

    // Items
    lines.add(_bold('ITEMS:'));
    lines.add('');

    for (final item in order.items) {
      // Quantity and product name
      lines.add(_bold('${item.quantity}x ${item.productName}'));

      // Modifiers
      if (item.modifiers.isNotEmpty) {
        for (final modifier in item.modifiers) {
          lines.add('  + $modifier');
        }
      }

      // Item notes
      if (item.notes != null && item.notes!.isNotEmpty) {
        lines.add('  NOTE: ${item.notes}');
      }

      lines.add('');
    }

    // Order notes
    if (order.notes != null && order.notes!.isNotEmpty) {
      lines.add(_line(width));
      lines.add(_bold('ORDER NOTES:'));
      lines.add(order.notes!);
      lines.add('');
    }

    // Special instructions
    if (order.specialInstructions != null &&
        order.specialInstructions!.isNotEmpty) {
      lines.add(_bold('SPECIAL INSTRUCTIONS:'));
      lines.add(order.specialInstructions!);
      lines.add('');
    }

    // Allergy warning
    if (order.hasAllergyInfo) {
      lines.add(_line(width));
      lines.add(_center('⚠️ ALLERGY ALERT ⚠️', width));
      lines.add(_line(width));
    }

    // Barcode (if enabled)
    if (_settings.includeBarcode) {
      lines.add('');
      lines.add(_center('[BARCODE: ${order.orderNumber}]', width));
    }

    // Footer
    lines.add('');
    lines.add(_line(width));
    lines.add(_center('Thank you!', width));
    lines.add('');
    lines.add('');
    lines.add('');

    return lines.join('\n');
  }

  /// Send content to printer device
  Future<void> _printToDevice(String content) async {
    // Add to print queue
    _printQueue.add(content);

    // In production, this would send to actual printer via:
    // - USB connection
    // - Network connection (TCP/IP)
    // - Bluetooth
    // - Platform print API

    // For now, simulate print delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Remove from queue after "printing"
    if (_printQueue.isNotEmpty) {
      _printQueue.removeAt(0);
    }
  }

  /// Get ticket width based on format
  int _getTicketWidth() {
    switch (_settings.format) {
      case PrintFormat.thermal80mm:
        return 48;
      case PrintFormat.thermal58mm:
        return 32;
      case PrintFormat.receipt:
        return 40;
      case PrintFormat.a4:
        return 80;
    }
  }

  /// Format helpers
  String _center(String text, int width) {
    if (text.length >= width) return text;
    final padding = (width - text.length) ~/ 2;
    return ' ' * padding + text;
  }

  String _line(int width) {
    return '-' * width;
  }

  String _bold(String text) {
    // In actual thermal printer, use ESC/POS commands for bold
    // For now, use uppercase
    return text.toUpperCase();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getOrderTypeDisplay(KitchenOrder order) {
    if (order.tableName != null) return 'Dine-In';
    if (order.customerName != null) return 'Takeaway';
    return 'Unknown';
  }

  /// Test print function
  Future<bool> testPrint() async {
    try {
      final testContent = _generateTestTicket();
      await _printToDevice(testContent);
      return true;
    } catch (e) {
      return false;
    }
  }

  String _generateTestTicket() {
    final width = _getTicketWidth();
    final lines = <String>[];

    lines.add(_center('TEST PRINT', width));
    lines.add(_line(width));
    lines.add('');
    lines.add('If you can read this,');
    lines.add('the printer is working!');
    lines.add('');
    lines.add(_line(width));
    lines.add(_center('${DateTime.now()}', width));
    lines.add('');
    lines.add('');

    return lines.join('\n');
  }

  /// Get print queue status
  int get queueLength => _printQueue.length;
  bool get isPrinting => _printQueue.isNotEmpty;

  /// Clear print queue
  void clearQueue() {
    _printQueue.clear();
  }

  /// Dispose resources
  Future<void> dispose() async {
    // Close printer connection
    _printQueue.clear();
  }
}

/// Print service provider
final kitchenTicketPrintServiceProvider =
    Provider<KitchenTicketPrintService>((ref) {
  final service = KitchenTicketPrintService();

  // Initialize on first access
  service.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() => service.dispose());

  return service;
});

/// Print settings provider
final printSettingsProvider = StateProvider<PrintSettings>((ref) {
  return const PrintSettings();
});

/// Print settings notifier
class PrintSettingsNotifier extends StateNotifier<PrintSettings> {
  final KitchenTicketPrintService _service;

  PrintSettingsNotifier(this._service) : super(const PrintSettings()) {
    _service.updateSettings(state);
  }

  void updateSettings(PrintSettings settings) {
    state = settings;
    _service.updateSettings(settings);
  }

  void setFormat(PrintFormat format) {
    updateSettings(state.copyWith(format: format));
  }

  void setAutoPrint(bool enabled) {
    updateSettings(state.copyWith(autoPrint: enabled));
  }

  void setPrintOnNewOrder(bool enabled) {
    updateSettings(state.copyWith(printOnNewOrder: enabled));
  }

  void setFontSize(int size) {
    updateSettings(state.copyWith(fontSize: size));
  }
}

/// Print settings notifier provider
final printSettingsNotifierProvider =
    StateNotifierProvider<PrintSettingsNotifier, PrintSettings>((ref) {
  final service = ref.watch(kitchenTicketPrintServiceProvider);
  return PrintSettingsNotifier(service);
});
