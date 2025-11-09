# SmartPOS - Prioritized Action Plan

**Purpose**: Clear roadmap of what to build next, in order of priority

---

## 🎯 IMMEDIATE PRIORITIES (Start Today)

### Priority 1: Make pos_register Functional (1-2 weeks)

**Goal**: Create your first working POS application that can take orders and process payments.

#### Screen 1: Main POS Screen (3-4 days)
**File**: `apps/pos_register/lib/src/features/pos/presentation/pages/main_pos_page.dart`

```dart
Layout:
┌─────────────────────────────────────────┐
│  Category Chips  [Pizza] [Salads] [...]│
├───────────────────┬─────────────────────┤
│                   │                     │
│   Product Grid    │    Cart Panel      │
│                   │                     │
│  [Pizza]  [Salad] │  Items: 3          │
│  [Burger] [Pasta] │  Total: $45.50     │
│                   │                     │
│                   │  [Checkout]         │
└───────────────────┴─────────────────────┘
```

**Components to use:**
- `CategoryChipList` from pos_ui
- `ProductGrid` from pos_ui
- `CartPanel` from pos_ui
- `ModifierSelector` (when product tapped)

**State management:**
```dart
// Use existing providers
final products = ref.watch(productsProvider());
final categories = ref.watch(categoriesProvider());
final cart = ref.watch(cartNotifierProvider);

// Actions
ref.read(cartNotifierProvider.notifier).addItem(orderItem);
ref.read(cartNotifierProvider.notifier).checkout(...);
```

**Estimated time**: 3-4 days

---

#### Screen 2: Checkout Flow (2-3 days)
**File**: `apps/pos_register/lib/src/features/checkout/presentation/pages/checkout_page.dart`

```dart
Steps:
1. Review Order → 2. Select Payment → 3. Process → 4. Receipt

Layout:
┌─────────────────────────────────────────┐
│  Step 1: Review Order                   │
│  ─────────────────────────────          │
│  Order Summary                          │
│  Items, Total, etc.                     │
│                                         │
│  [Add Discount] [Add Tip]              │
│  [Continue to Payment] →                │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  Step 2: Payment Method                 │
│  ─────────────────────────────          │
│  [Cash]    [Card]    [Wallet]          │
│                                         │
│  Amount: $45.50                         │
│  [Enter Amount] (for cash)              │
│                                         │
│  [Process Payment] →                    │
└─────────────────────────────────────────┘
```

**Components to use:**
- `PaymentMethodGrid` from pos_ui
- `TipSelector` from pos_ui
- `AmountInput` from pos_ui (for cash)
- `NumericKeypad` from pos_ui

**State management:**
```dart
// Process payment
final payment = Payment(...);
final result = await ref.read(processPaymentUseCaseProvider)(payment);

// Handle result
result.when(
  success: (payment) => showReceiptAndClear(),
  failure: (error) => showError(error),
);
```

**Estimated time**: 2-3 days

---

#### Screen 3: Table Management (2 days)
**File**: `apps/pos_register/lib/src/features/tables/presentation/pages/tables_page.dart`

```dart
Layout:
┌─────────────────────────────────────────┐
│  Zone: [All] [Main Floor] [Patio]      │
├─────────────────────────────────────────┤
│                                         │
│  [Table 1]  [Table 2]  [Table 3]       │
│  Available  Occupied   Available        │
│                                         │
│  [Table 4]  [Table 5]  [Table 6]       │
│  Cleaning   Occupied   Reserved         │
│                                         │
└─────────────────────────────────────────┘
```

**Components to use:**
- `ZoneSelector` from pos_ui
- `TableGrid` from pos_ui
- `TableCard` from pos_ui

**State management:**
```dart
final tables = ref.watch(tablesProvider());
final zones = ref.watch(zonesProvider());

// Actions
ref.read(assignOrderToTableUseCaseProvider)(tableId, orderId);
ref.read(clearTableUseCaseProvider)(tableId);
```

**Estimated time**: 2 days

---

#### Screen 4: Order History (1-2 days)
**File**: `apps/pos_register/lib/src/features/orders/presentation/pages/order_history_page.dart`

```dart
Layout:
┌─────────────────────────────────────────┐
│  Filters: [Today] [Status: All]        │
├─────────────────────────────────────────┤
│                                         │
│  [Order #001]  Completed  $45.50       │
│  [Order #002]  Preparing  $32.00       │
│  [Order #003]  Cancelled  $28.50       │
│                                         │
└─────────────────────────────────────────┘
```

**Components to use:**
- `OrderCard` from pos_ui (in ListView)
- Filter chips
- Date picker

**State management:**
```dart
final orders = ref.watch(ordersProvider(
  status: selectedStatus,
  fromDate: startDate,
  toDate: endDate,
));
```

**Estimated time**: 1-2 days

---

#### Navigation & App Shell (1 day)
**File**: `apps/pos_register/lib/src/features/shell/presentation/pages/app_shell.dart`

```dart
Bottom Navigation:
[POS] [Tables] [Orders] [More]

OR Drawer Navigation:
│ POS
│ Tables
│ Orders
│ History
│ Settings
```

**Use existing:**
- `home_shell_page.dart` as template
- go_router for navigation

**Estimated time**: 1 day

---

### Priority 2: Backend Integration (Week 3)

**Replace mock data with real API calls**

#### Tasks:
1. **Set up backend** (if not exists)
   - Node.js/Express OR
   - Laravel OR
   - Firebase/Supabase OR
   - Use existing backend

2. **Update data sources**
   ```dart
   // Replace in:
   - packages/pos_core/lib/src/features/products/data/sources/products_remote_source.dart
   - packages/pos_core/lib/src/features/orders/data/sources/orders_remote_source.dart
   - packages/pos_core/lib/src/features/tables/data/sources/tables_remote_source.dart
   - packages/pos_core/lib/src/features/payments/data/sources/payments_remote_source.dart
   ```

3. **API endpoints needed:**
   ```
   Products:
   GET    /api/products
   GET    /api/products/:id
   GET    /api/categories
   POST   /api/products/search

   Orders:
   POST   /api/orders
   GET    /api/orders
   GET    /api/orders/:id
   PATCH  /api/orders/:id/status

   Tables:
   GET    /api/tables
   PATCH  /api/tables/:id/status
   POST   /api/tables/:id/assign-order

   Payments:
   POST   /api/payments
   POST   /api/refunds
   GET    /api/payments
   ```

4. **Use existing ApiClient**
   ```dart
   // Already built in:
   packages/pos_core/lib/src/core/network/api_client.dart

   // Just call it:
   final response = await apiClient.get('/products');
   ```

**Estimated time**: 3-5 days

---

### Priority 3: Testing & Polish (Week 4)

#### Unit Tests (2-3 days)
```dart
test/
├── unit/
│   ├── products/
│   │   ├── product_test.dart
│   │   ├── cart_test.dart
│   │   └── products_repository_test.dart
│   ├── orders/
│   ├── tables/
│   └── payments/
```

**Test:**
- Domain entities (Product, Order, Cart calculations)
- Use cases (CreateOrder, ProcessPayment)
- Repositories (mock data)

**Estimated time**: 2-3 days

#### Widget Tests (1-2 days)
```dart
test/
├── widget/
│   ├── product_card_test.dart
│   ├── cart_panel_test.dart
│   ├── table_card_test.dart
│   └── payment_method_grid_test.dart
```

**Estimated time**: 1-2 days

#### Bug Fixes & Polish (2-3 days)
- Fix edge cases
- Improve error messages
- Add loading states
- Smooth animations
- Accessibility

**Estimated time**: 2-3 days

---

## 📅 4-WEEK SPRINT PLAN

### Week 1: Core Screens
- ✅ Day 1-2: Main POS screen
- ✅ Day 3-4: Product selection & cart
- ✅ Day 5: Navigation & shell

### Week 2: Checkout & Tables
- ✅ Day 1-2: Checkout flow
- ✅ Day 3-4: Payment processing
- ✅ Day 5: Table management

### Week 3: Backend & Integration
- ✅ Day 1-2: Backend setup
- ✅ Day 3-4: API integration
- ✅ Day 5: Real-time updates

### Week 4: Testing & Launch
- ✅ Day 1-2: Unit tests
- ✅ Day 3: Widget tests
- ✅ Day 4: Bug fixes
- ✅ Day 5: Deploy & monitor

---

## 🎯 SUCCESS CRITERIA

### Week 1 Done When:
- [ ] Can browse products
- [ ] Can add items to cart
- [ ] Can view cart total
- [ ] Can navigate between screens

### Week 2 Done When:
- [ ] Can complete checkout
- [ ] Can process cash payment
- [ ] Can view tables
- [ ] Can assign orders to tables

### Week 3 Done When:
- [ ] Products load from real API
- [ ] Orders save to database
- [ ] Payments process through API
- [ ] Real-time updates working

### Week 4 Done When:
- [ ] 60%+ test coverage
- [ ] All critical bugs fixed
- [ ] App deployed to web
- [ ] First user tested successfully

---

## 🚫 DON'T BUILD YET (Save for Later)

These are important but not critical for MVP:

- ❌ Kitchen Display System (Phase 4)
- ❌ Waiter App (Phase 5)
- ❌ Inventory Management (Phase 8)
- ❌ Reports & Analytics (Phase 7)
- ❌ Employee Management (Phase 9)
- ❌ Loyalty Program (Phase 9)
- ❌ Customer Kiosk (Phase 6)

**Why?** First get ONE app working perfectly, then replicate.

---

## 💡 QUICK WINS (Can Do in 1 Hour Each)

1. **Add discount button to cart**
   - Use existing Cart.applyDiscount()
   - Add TextField for amount/percentage

2. **Add search to products**
   - Use existing ProductSearch provider
   - Add SearchBar widget

3. **Add order notes**
   - Already in OrderItem.notes
   - Just add TextField in cart

4. **Add table numbers to orders**
   - Already in Order.tableName
   - Display in OrderCard

5. **Add time tracking**
   - Already in Order.createdAt
   - Show "15m ago" in OrderCard

---

## 🎨 DESIGN TOKENS (Already Set Up)

All styling is centralized:

```dart
// Colors
packages/pos_core/lib/src/core/theme/app_colors.dart

// Typography
packages/pos_core/lib/src/core/theme/app_typography.dart

// Sizes
packages/pos_core/lib/src/core/theme/app_sizes.dart

// Full theme
packages/pos_core/lib/src/core/theme/app_theme.dart
```

**Just use Material 3 components and they'll look good!**

---

## 📚 CODE EXAMPLES

### Example 1: Main POS Page (Simplified)

```dart
class MainPosPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider());
    final categories = ref.watch(categoriesProvider());
    final cart = ref.watch(cartNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('POS Register')),
      body: Row(
        children: [
          // Left: Products
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Categories
                CategoryChipList(
                  categories: categories.value ?? [],
                  onCategoryTap: (cat) => /* filter */,
                ),
                // Products
                Expanded(
                  child: ProductGrid(
                    products: products.value ?? [],
                    onProductTap: (product) async {
                      // Show modifier selector if needed
                      if (product.allowModifiers) {
                        final modifiers = await ModifierSelector.show(
                          context,
                          product: product,
                        );
                        // Add to cart with modifiers
                      } else {
                        // Add to cart directly
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Right: Cart
          Expanded(
            flex: 1,
            child: CartPanel(
              cart: cart,
              onCheckout: () => /* navigate to checkout */,
              onItemRemoved: (item) => ref.read(
                cartNotifierProvider.notifier
              ).removeItem(item.id),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Example 2: Checkout Page (Simplified)

```dart
class CheckoutPage extends ConsumerStatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  PaymentMethod? selectedMethod;
  double tipAmount = 0;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: Column(
        children: [
          // Order Summary
          OrderSummaryCard(cart: cart),

          // Tip Selector
          TipSelector(
            subtotal: cart.subtotal,
            onTipChanged: (tip) => setState(() => tipAmount = tip),
          ),

          // Payment Methods
          PaymentMethodGrid(
            onMethodSelected: (method) {
              setState(() => selectedMethod = method);
            },
          ),

          // Process Button
          FilledButton(
            onPressed: () => _processPayment(),
            child: Text('Complete Payment'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    final cart = ref.read(cartNotifierProvider);

    // Create payment
    final payment = Payment(
      id: '',
      orderId: '', // Will be created
      amount: cart.total,
      method: selectedMethod!,
      status: PaymentStatus.pending,
      tipAmount: tipAmount,
      createdAt: DateTime.now(),
    );

    // Process
    final result = await ref.read(
      processPaymentUseCaseProvider
    )(payment);

    result.when(
      success: (payment) {
        // Show success, print receipt
        _showSuccess();
        ref.read(cartNotifierProvider.notifier).clear();
      },
      failure: (error) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      },
    );
  }
}
```

---

## 🔥 START HERE CHECKLIST

Copy this to your task manager:

```markdown
## Week 1: Foundation
- [ ] Create main_pos_page.dart
- [ ] Add product grid layout
- [ ] Add cart panel layout
- [ ] Wire up add to cart
- [ ] Add category filtering
- [ ] Test product selection flow

## Week 2: Checkout
- [ ] Create checkout_page.dart
- [ ] Add payment method selection
- [ ] Add tip selector
- [ ] Wire up payment processing
- [ ] Add receipt display
- [ ] Create tables_page.dart
- [ ] Test full order flow

## Week 3: Backend
- [ ] Set up backend API
- [ ] Create API endpoints
- [ ] Replace ProductsRemoteSourceMock
- [ ] Replace OrdersRemoteSourceMock
- [ ] Replace TablesRemoteSourceMock
- [ ] Replace PaymentsRemoteSourceMock
- [ ] Test with real data

## Week 4: Polish
- [ ] Write unit tests for Cart
- [ ] Write unit tests for Order
- [ ] Write widget tests
- [ ] Fix all bugs
- [ ] Add loading states
- [ ] Add error messages
- [ ] Deploy to web
- [ ] User testing
```

---

## 🎯 FINAL ADVICE

1. **Start small**: Get one screen working before moving to the next
2. **Use what exists**: All components are built, just assemble them
3. **Don't over-engineer**: MVP first, polish later
4. **Test early**: Don't wait until the end
5. **Ship fast**: Better to have one working app than 16 half-done apps

**You have everything you need. Now just build the screens and wire them up!** 🚀

The hard part (architecture, features, widgets) is DONE.
The easy part (assembling screens) is all that's left.

**Estimated time to first working app: 2-4 weeks**
**Estimated time to 16 apps: 6-12 months** (because you'll reuse everything!)

Go build something amazing! 💪
