/// Customer Display Models
/// Models for Odoo-style POS customer display
/// Shows current cart being rung up at the register
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_display_models.freezed.dart';
part 'customer_display_models.g.dart';

/// Customer Display State
/// Represents the current state of the customer-facing display
@freezed
class CustomerDisplayState with _$CustomerDisplayState {
  const CustomerDisplayState._();

  const factory CustomerDisplayState({
    /// Current mode
    @Default(DisplayMode.idle) DisplayMode mode,

    /// Current cart (when in cart mode)
    CustomerCart? currentCart,

    /// Payment in progress (when in payment mode)
    PaymentProgress? paymentProgress,

    /// Last completed order (when in thankYou mode)
    CompletedOrder? completedOrder,

    /// Marketing content (when in idle mode)
    MarketingContent? marketingContent,

    /// Timestamp of last update
    DateTime? lastUpdate,
  }) = _CustomerDisplayState;

  factory CustomerDisplayState.fromJson(Map<String, dynamic> json) =>
      _$CustomerDisplayStateFromJson(json);

  /// Create idle state
  factory CustomerDisplayState.idle({MarketingContent? content}) {
    return CustomerDisplayState(
      mode: DisplayMode.idle,
      marketingContent: content,
      lastUpdate: DateTime.now(),
    );
  }

  /// Create cart state
  factory CustomerDisplayState.showingCart(CustomerCart cart) {
    return CustomerDisplayState(
      mode: DisplayMode.cart,
      currentCart: cart,
      lastUpdate: DateTime.now(),
    );
  }

  /// Create payment state
  factory CustomerDisplayState.processingPayment(PaymentProgress payment) {
    return CustomerDisplayState(
      mode: DisplayMode.payment,
      paymentProgress: payment,
      lastUpdate: DateTime.now(),
    );
  }

  /// Create thank you state
  factory CustomerDisplayState.completedOrder(CompletedOrder order) {
    return CustomerDisplayState(
      mode: DisplayMode.thankYou,
      completedOrder: order,
      lastUpdate: DateTime.now(),
    );
  }

  bool get isIdle => mode == DisplayMode.idle;
  bool get isShowingCart => mode == DisplayMode.cart;
  bool get isProcessingPayment => mode == DisplayMode.payment;
  bool get isShowingThankYou => mode == DisplayMode.thankYou;
}

/// Display Mode
enum DisplayMode {
  idle, // Showing marketing content
  cart, // Showing current cart
  payment, // Processing payment
  thankYou; // Order completed

  String get displayName {
    switch (this) {
      case DisplayMode.idle:
        return 'Idle';
      case DisplayMode.cart:
        return 'Cart';
      case DisplayMode.payment:
        return 'Payment';
      case DisplayMode.thankYou:
        return 'Thank You';
    }
  }
}

/// Customer Cart
/// Current cart being rung up at the register
@freezed
class CustomerCart with _$CustomerCart {
  const CustomerCart._();

  const factory CustomerCart({
    required String id,
    required List<CustomerCartItem> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
    String? customerName,
    DateTime? createdAt,
    String? lastScannedItemId,
  }) = _CustomerCart;

  factory CustomerCart.fromJson(Map<String, dynamic> json) =>
      _$CustomerCartFromJson(json);

  /// Get last scanned item
  CustomerCartItem? get lastScannedItem {
    if (lastScannedItemId == null) return null;
    try {
      return items.firstWhere((item) => item.id == lastScannedItemId);
    } catch (e) {
      return null;
    }
  }

  /// Get total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

/// Customer Cart Item
/// Individual item in the cart
@freezed
class CustomerCartItem with _$CustomerCartItem {
  const CustomerCartItem._();

  const factory CustomerCartItem({
    required String id,
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required double lineTotal,
    String? imageUrl,
    String? categoryName,
    @Default([]) List<String> modifiers,
    double? discount,
    bool? isLastScanned,
    DateTime? scannedAt,
  }) = _CustomerCartItem;

  factory CustomerCartItem.fromJson(Map<String, dynamic> json) =>
      _$CustomerCartItemFromJson(json);

  /// Get display price (after discount)
  double get displayPrice =>
      discount != null && discount! > 0 ? unitPrice - discount! : unitPrice;

  /// Get total after discount
  double get totalAfterDiscount => displayPrice * quantity;

  /// Check if item has discount
  bool get hasDiscount => discount != null && discount! > 0;
}

/// Payment Progress
/// Current payment being processed
@freezed
class PaymentProgress with _$PaymentProgress {
  const PaymentProgress._();

  const factory PaymentProgress({
    required String id,
    required double amount,
    required PaymentMethod paymentMethod,
    required PaymentStatus status,
    String? transactionId,
    DateTime? startedAt,
    String? errorMessage,
  }) = _PaymentProgress;

  factory PaymentProgress.fromJson(Map<String, dynamic> json) =>
      _$PaymentProgressFromJson(json);

  bool get isPending => status == PaymentStatus.pending;
  bool get isProcessing => status == PaymentStatus.processing;
  bool get isSuccess => status == PaymentStatus.success;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isCancelled => status == PaymentStatus.cancelled;
}

/// Payment Method
enum PaymentMethod {
  cash,
  card,
  mobile,
  voucher,
  other;

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.mobile:
        return 'Mobile Payment';
      case PaymentMethod.voucher:
        return 'Voucher';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.payments;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.mobile:
        return Icons.phone_android;
      case PaymentMethod.voucher:
        return Icons.card_giftcard;
      case PaymentMethod.other:
        return Icons.payment;
    }
  }
}

/// Payment Status
enum PaymentStatus {
  pending,
  processing,
  success,
  failed,
  cancelled;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing...';
      case PaymentStatus.success:
        return 'Payment Successful';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.cancelled:
        return 'Payment Cancelled';
    }
  }
}

/// Completed Order
/// Order that was just completed
@freezed
class CompletedOrder with _$CompletedOrder {
  const CompletedOrder._();

  const factory CompletedOrder({
    required String id,
    required String orderNumber,
    required double total,
    required int totalItems,
    required DateTime completedAt,
    String? customerName,
  }) = _CompletedOrder;

  factory CompletedOrder.fromJson(Map<String, dynamic> json) =>
      _$CompletedOrderFromJson(json);
}

/// Marketing Content
/// Content to display when idle
@freezed
class MarketingContent with _$MarketingContent {
  const factory MarketingContent({
    required String id,
    required MarketingContentType type,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? videoUrl,
    @Default([]) List<String> bulletPoints,
    Duration? displayDuration,
  }) = _MarketingContent;

  factory MarketingContent.fromJson(Map<String, dynamic> json) =>
      _$MarketingContentFromJson(json);

  /// Create welcome content
  factory MarketingContent.welcome() {
    return const MarketingContent(
      id: 'welcome',
      type: MarketingContentType.welcome,
      title: 'Welcome!',
      subtitle: 'Thank you for visiting us today',
    );
  }

  /// Create promotion content
  factory MarketingContent.promotion({
    required String title,
    required String subtitle,
    String? imageUrl,
  }) {
    return MarketingContent(
      id: 'promo_${DateTime.now().millisecondsSinceEpoch}',
      type: MarketingContentType.promotion,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
    );
  }

  /// Create store info content
  factory MarketingContent.storeInfo({
    required String title,
    required List<String> bulletPoints,
  }) {
    return MarketingContent(
      id: 'info_${DateTime.now().millisecondsSinceEpoch}',
      type: MarketingContentType.storeInfo,
      title: title,
      bulletPoints: bulletPoints,
    );
  }
}

/// Marketing Content Type
enum MarketingContentType {
  welcome,
  promotion,
  storeInfo,
  video;
}

/// Import required icons
class Icons {
  static const payments = 0xe8d3;
  static const credit_card = 0xe8dc;
  static const phone_android = 0xe324;
  static const card_giftcard = 0xe8f6;
  static const payment = 0xe8d1;
}
