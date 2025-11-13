# Missing Backend APIs for Odoo-Pattern POS System

**Generated:** 2025-11-13
**Backend Location:** `/home/user/Flutter-Database/backend`
**Status:** 179 modules exist, only 10 exposed via API

---

## Executive Summary

The backend has **comprehensive implementation** but suffers from:
1. **169 modules NOT registered** in `/backend/cmd/api/main.go`
2. **Missing Odoo-specific workflow endpoints**
3. **No offline sync infrastructure**
4. **No real-time updates (WebSocket/SSE)**

**Effort Required:**
- Quick wins (register existing modules): **2-4 hours**
- Odoo-specific enhancements: **8-12 hours**
- Offline sync infrastructure: **16-20 hours**
- Real-time updates: **8-12 hours**

---

## PRIORITY 1: REGISTER EXISTING MODULES (Quick Wins)

### Location: `/backend/cmd/api/main.go`

Add these function calls to `initializeModules()` (after line 236):

```go
// ==========================================
// POS SESSION MANAGEMENT (CRITICAL)
// ==========================================
initializePOSSessionsModule(r, db, logger)
initializeCashDrawerSessionsModule(r, db, logger)
initializeCashMovementsModule(r, db, logger)

// ==========================================
// ORDER DETAILS (CRITICAL)
// ==========================================
initializeOrderItemsModule(r, db, logger)
initializeOrderItemModifiersModule(r, db, logger)

// ==========================================
// KITCHEN DISPLAY (CRITICAL)
// ==========================================
initializeKitchenTicketsModule(r, db, logger)

// ==========================================
// PRODUCT CONFIGURATION (HIGH)
// ==========================================
initializeModifiersModule(r, db, logger)
initializeModifierGroupsModule(r, db, logger)
initializeProductModifierGroupsModule(r, db, logger)

// ==========================================
// TABLE MANAGEMENT (MEDIUM)
// ==========================================
initializeReservationsModule(r, db, logger)
initializeRestaurantFloorsModule(r, db, logger)
initializeRestaurantZonesModule(r, db, logger)

// ==========================================
// PAYMENT METHODS (MEDIUM)
// ==========================================
initializePaymentMethodsModule(r, db, logger)
initializePaymentTerminalsModule(r, db, logger)

// ==========================================
// LOYALTY & DISCOUNTS (LOW)
// ==========================================
initializeLoyaltyProgramsModule(r, db, logger)
initializeDiscountsModule(r, db, logger)
initializePromotionsModule(r, db, logger)
```

**Result:** ~15-20 new API endpoint groups immediately available

---

## PRIORITY 2: POS SESSION MANAGEMENT (Odoo Pattern)

### Module: `/backend/internal/pos_session/`

**STATUS:** ✅ Handler exists, ❌ NOT exposed, ⚠️ Needs Odoo enhancements

### Required Endpoints

#### 1. Open Session (Enhanced)
```http
POST /api/v1/organizations/{org_id}/pos-sessions/open
Authorization: Bearer {jwt_token}

Request:
{
  "device_id": "POS-001",
  "device_name": "Main Counter POS",
  "opened_by": "user-uuid",
  "opening_balance": {
    "cash": 500.00,
    "card": 0.00,
    "other": 0.00
  },
  "cash_denominations": {
    "pennies": { "count": 50, "value": 0.50 },
    "nickels": { "count": 40, "value": 2.00 },
    "dimes": { "count": 50, "value": 5.00 },
    "quarters": { "count": 80, "value": 20.00 },
    "ones": { "count": 100, "value": 100.00 },
    "fives": { "count": 40, "value": 200.00 },
    "tens": { "count": 10, "value": 100.00 },
    "twenties": { "count": 5, "value": 100.00 },
    "fifties": { "count": 0, "value": 0.00 },
    "hundreds": { "count": 0, "value": 0.00 }
  },
  "notes": "Morning shift opening"
}

Response: 201 Created
{
  "id": "session-uuid",
  "session_number": "2025-11-13-001",
  "device_id": "POS-001",
  "opened_at": "2025-11-13T08:00:00Z",
  "opened_by": "user-uuid",
  "status": "open",
  "opening_balance": 500.00,
  "current_balance": 500.00
}
```

**Enhancement Needed:**
- Add `cash_denominations` JSONB field to `pos_sessions` table
- Add validation for denomination math (must sum to opening_balance.cash)
- Check for existing open session on device (only 1 open session per device)
- Auto-generate session_number (format: YYYY-MM-DD-NNN)

---

#### 2. Get Current Session
```http
GET /api/v1/organizations/{org_id}/pos-sessions/current?device_id={device_id}
Authorization: Bearer {jwt_token}

Response: 200 OK
{
  "id": "session-uuid",
  "session_number": "2025-11-13-001",
  "device_id": "POS-001",
  "opened_at": "2025-11-13T08:00:00Z",
  "opened_by": "user-uuid",
  "status": "open",
  "opening_balance": 500.00,
  "current_balance": 1250.75,
  "total_sales": 850.75,
  "total_orders": 32,
  "total_payments": {
    "cash": 450.25,
    "card": 350.50,
    "mobile": 50.00
  }
}
```

**Enhancement Needed:**
- Add repository method: `GetCurrentSessionByDevice(orgID, deviceID)`
- Calculate real-time statistics from orders/payments
- Return nil/404 if no open session

---

#### 3. Cash In/Out
```http
POST /api/v1/organizations/{org_id}/pos-sessions/{session_id}/cash-movement
Authorization: Bearer {jwt_token}

Request:
{
  "movement_type": "cash_in",  // or "cash_out"
  "amount": 100.00,
  "reason": "safe_deposit",  // safe_deposit, change_request, bank_deposit, expense
  "description": "Depositing $100 to safe",
  "performed_by": "user-uuid",
  "requires_approval": false
}

Response: 201 Created
{
  "id": "movement-uuid",
  "session_id": "session-uuid",
  "movement_type": "cash_in",
  "amount": 100.00,
  "timestamp": "2025-11-13T10:30:00Z",
  "session_balance_after": 1350.75
}
```

**Enhancement Needed:**
- Update `pos_sessions.current_balance` on cash movement
- Add transaction support (atomic balance update)
- Add audit trail
- Support approval workflow for large amounts (>$500)

---

#### 4. Close Session (Enhanced)
```http
POST /api/v1/organizations/{org_id}/pos-sessions/{session_id}/close
Authorization: Bearer {jwt_token}

Request:
{
  "closed_by": "user-uuid",
  "counted_cash": {
    "cash": 550.50,
    "card": 0.00,
    "other": 0.00
  },
  "cash_denominations": {
    "pennies": { "count": 100, "value": 1.00 },
    "nickels": { "count": 50, "value": 2.50 },
    "dimes": { "count": 80, "value": 8.00 },
    "quarters": { "count": 100, "value": 25.00 },
    "ones": { "count": 150, "value": 150.00 },
    "fives": { "count": 50, "value": 250.00 },
    "tens": { "count": 10, "value": 100.00 },
    "twenties": { "count": 1, "value": 20.00 },
    "fifties": { "count": 0, "value": 0.00 },
    "hundreds": { "count": 0, "value": 0.00 }
  },
  "closing_notes": "End of morning shift"
}

Response: 200 OK
{
  "id": "session-uuid",
  "session_number": "2025-11-13-001",
  "closed_at": "2025-11-13T16:00:00Z",
  "status": "closed",
  "opening_balance": 500.00,
  "closing_balance": 1250.75,
  "expected_cash": 950.75,
  "counted_cash": 550.50,
  "difference": {
    "cash": -400.25,  // Short
    "card": 0.00,
    "other": 0.00,
    "total": -400.25
  },
  "session_summary": {
    "total_orders": 32,
    "total_sales": 850.75,
    "total_refunds": 50.00,
    "net_sales": 800.75,
    "payments_by_method": {
      "cash": 450.25,
      "card": 350.50,
      "mobile": 50.00
    },
    "cash_movements": {
      "cash_in": 100.00,
      "cash_out": 0.00,
      "net": 100.00
    }
  }
}
```

**Enhancement Needed:**
- Add `closing_cash_denominations` JSONB field
- Calculate expected cash:
  - `expected_cash = opening_cash + cash_payments + cash_in - cash_out - card_payments - mobile_payments`
- Calculate differences (short/over)
- Validate denomination math
- Generate Z-report number
- Update session status to 'closed'
- Prevent reopening closed sessions

---

#### 5. Session Report (Z-Report)
```http
GET /api/v1/organizations/{org_id}/pos-sessions/{session_id}/report
Authorization: Bearer {jwt_token}

Response: 200 OK
{
  "session": {
    "session_number": "2025-11-13-001",
    "z_report_number": "Z-2025-11-13-001",
    "device_id": "POS-001",
    "opened_at": "2025-11-13T08:00:00Z",
    "closed_at": "2025-11-13T16:00:00Z",
    "duration_hours": 8.0
  },
  "financial_summary": {
    "opening_balance": 500.00,
    "closing_balance": 1250.75,
    "expected_cash": 950.75,
    "counted_cash": 550.50,
    "difference": -400.25,
    "variance_percentage": -42.10
  },
  "sales_summary": {
    "total_orders": 32,
    "gross_sales": 850.75,
    "discounts": 25.00,
    "refunds": 50.00,
    "net_sales": 775.75,
    "taxes": 62.06,
    "tips": 125.00
  },
  "payment_breakdown": [
    { "method": "Cash", "count": 18, "amount": 450.25 },
    { "method": "Card", "count": 12, "amount": 350.50 },
    { "method": "Mobile", "count": 2, "amount": 50.00 }
  ],
  "cash_movements": [
    { "type": "Cash In", "reason": "Safe Deposit", "amount": 100.00 }
  ],
  "category_breakdown": [
    { "category": "Beverages", "count": 48, "amount": 240.00 },
    { "category": "Food", "count": 64, "amount": 560.75 }
  ],
  "hourly_sales": [
    { "hour": "08:00", "orders": 2, "sales": 45.50 },
    { "hour": "09:00", "orders": 5, "sales": 125.25 }
    // ... etc
  ]
}
```

**Enhancement Needed:**
- Create dedicated report service
- Aggregate from orders, payments, order_items
- Calculate hourly/category breakdowns
- Cache report after session close
- Support PDF export

---

## PRIORITY 3: ORDER MANAGEMENT (Nested Creation)

### Module: `/backend/internal/order/`

**STATUS:** ✅ Exposed, ⚠️ Needs nested create

### Required Endpoint

#### Create Order with Items and Modifiers
```http
POST /api/v1/organizations/{org_id}/orders
Authorization: Bearer {jwt_token}

Request:
{
  "session_id": "session-uuid",
  "table_id": "table-uuid",  // Optional for quick service
  "customer_id": "customer-uuid",  // Optional
  "order_type": "dine_in",  // dine_in, takeout, delivery
  "status": "new",
  "customer_notes": "No onions please",
  "kitchen_notes": "Priority order",
  "items": [
    {
      "product_id": "product-uuid",
      "quantity": 2,
      "unit_price": 15.99,
      "special_instructions": "Well done",
      "kitchen_station_id": "grill-station-uuid",
      "modifiers": [
        {
          "modifier_id": "modifier-uuid",
          "modifier_group_id": "modifier-group-uuid",
          "price_adjustment": 2.50,
          "quantity": 1
        }
      ]
    },
    {
      "product_id": "beverage-uuid",
      "quantity": 2,
      "unit_price": 3.99,
      "kitchen_station_id": "bar-station-uuid",
      "modifiers": []
    }
  ]
}

Response: 201 Created
{
  "id": "order-uuid",
  "order_number": "001",
  "session_id": "session-uuid",
  "table_id": "table-uuid",
  "status": "new",
  "subtotal": 41.96,
  "tax_amount": 3.36,
  "total": 45.32,
  "items": [
    {
      "id": "item-uuid-1",
      "product_id": "product-uuid",
      "quantity": 2,
      "unit_price": 15.99,
      "subtotal": 36.98,
      "modifiers": [
        {
          "id": "item-modifier-uuid",
          "modifier_id": "modifier-uuid",
          "price_adjustment": 2.50
        }
      ]
    }
  ],
  "created_at": "2025-11-13T12:30:00Z"
}
```

**Enhancement Needed:**
- Create transaction-wrapped service method:
  1. Create order
  2. Create order items (loop)
  3. Create order item modifiers (loop)
  4. Create kitchen tickets (if dine_in)
  5. Update table status to 'occupied'
  6. Calculate totals
  7. Commit transaction
- Validate product/modifier existence
- Validate price integrity
- Generate order_number (auto-increment per session)

---

## PRIORITY 4: KITCHEN DISPLAY SYSTEM

### Module: `/backend/internal/kitchen_ticket/`

**STATUS:** ✅ Handler exists, ❌ NOT exposed

### Required Endpoints

#### 1. Get Active Tickets for Station
```http
GET /api/v1/organizations/{org_id}/kitchen-stations/{station_id}/tickets?status=active
Authorization: Bearer {jwt_token}

Response: 200 OK
{
  "tickets": [
    {
      "id": "ticket-uuid",
      "ticket_number": "T-001",
      "order_id": "order-uuid",
      "order_number": "001",
      "table_name": "Table 5",
      "status": "new",  // new, acknowledged, in_progress, ready, completed
      "priority": 1,  // 1=high, 2=medium, 3=low
      "fired_at": "2025-11-13T12:30:00Z",
      "elapsed_seconds": 180,
      "items": [
        {
          "id": "item-uuid",
          "product_name": "Cheeseburger",
          "quantity": 2,
          "special_instructions": "No onions",
          "modifiers": [
            { "name": "Extra Cheese", "quantity": 1 }
          ]
        }
      ],
      "customer_notes": "Table prefers well done",
      "is_delayed": false
    }
  ],
  "summary": {
    "new": 5,
    "in_progress": 3,
    "ready": 2,
    "average_prep_time_seconds": 420
  }
}
```

**Enhancement Needed:**
- Add repository method to fetch by station and status
- Calculate `elapsed_seconds` dynamically
- Flag `is_delayed` if > 15 minutes
- Include order and table details via joins
- Sort by priority then fired_at (oldest first)

---

#### 2. Update Ticket Status
```http
PATCH /api/v1/organizations/{org_id}/kitchen-tickets/{ticket_id}/status
Authorization: Bearer {jwt_token}

Request:
{
  "status": "in_progress",  // new → acknowledged → in_progress → ready → completed
  "updated_by": "user-uuid"
}

Response: 200 OK
{
  "id": "ticket-uuid",
  "status": "in_progress",
  "started_at": "2025-11-13T12:33:00Z",
  "elapsed_seconds": 180
}
```

**Enhancement Needed:**
- Update timestamp fields based on status:
  - `acknowledged` → set `acknowledged_at`
  - `in_progress` → set `started_at`
  - `ready` → set `ready_at`
  - `completed` → set `bumped_at`
- Validate status transitions (can't skip states)
- Broadcast to WebSocket clients (see Priority 6)

---

#### 3. Bump Ticket (Remove from Display)
```http
POST /api/v1/organizations/{org_id}/kitchen-tickets/{ticket_id}/bump
Authorization: Bearer {jwt_token}

Request:
{
  "bumped_by": "user-uuid"
}

Response: 200 OK
{
  "id": "ticket-uuid",
  "status": "completed",
  "bumped_at": "2025-11-13T12:45:00Z",
  "total_prep_time_seconds": 900
}
```

**Enhancement Needed:**
- Set status to 'completed'
- Set `bumped_at` timestamp
- Calculate total prep time
- Update order status to 'ready' if all tickets completed
- Archive ticket (don't show in active queries)

---

## PRIORITY 5: PRODUCT & MODIFIER MANAGEMENT

### Modules: `/backend/internal/modifier/` & `/backend/internal/modifier_group/`

**STATUS:** ✅ Exist, ❌ NOT exposed

### Required Endpoints

#### 1. Get Modifiers
```http
GET /api/v1/organizations/{org_id}/modifiers?active=true
Authorization: Bearer {jwt_token}

Response: 200 OK
{
  "modifiers": [
    {
      "id": "modifier-uuid",
      "name": "Extra Cheese",
      "price": 2.50,
      "active": true,
      "modifier_group_id": "toppings-group-uuid"
    }
  ]
}
```

#### 2. Get Modifier Groups
```http
GET /api/v1/organizations/{org_id}/modifier-groups?active=true
Authorization: Bearer {jwt_token}

Response: 200 OK
{
  "modifier_groups": [
    {
      "id": "toppings-group-uuid",
      "name": "Toppings",
      "min_selections": 0,
      "max_selections": 5,
      "active": true,
      "modifiers": [
        { "id": "modifier-uuid", "name": "Extra Cheese", "price": 2.50 }
      ]
    }
  ]
}
```

#### 3. Get Product with Modifiers
```http
GET /api/v1/organizations/{org_id}/products/{product_id}/modifiers
Authorization: Bearer {jwt_token}

Response: 200 OK
{
  "product": {
    "id": "product-uuid",
    "name": "Cheeseburger",
    "price": 15.99
  },
  "modifier_groups": [
    {
      "id": "toppings-group-uuid",
      "name": "Toppings",
      "min_selections": 0,
      "max_selections": 5,
      "modifiers": [...]
    }
  ]
}
```

**Enhancement Needed:**
- Expose existing handlers
- Add product-modifier relationship query
- Support nested loading for offline cache

---

## PRIORITY 6: OFFLINE SYNC & BULK OPERATIONS

### NEW Module Required: `/backend/internal/sync/`

**STATUS:** ❌ Doesn't exist

### Required Endpoints

#### 1. Bulk Load for Offline Session
```http
GET /api/v1/organizations/{org_id}/sync/session-data?session_id={session_id}
Authorization: Bearer {jwt_token}

Response: 200 OK
{
  "timestamp": "2025-11-13T08:00:00Z",
  "session": {
    "id": "session-uuid",
    "session_number": "2025-11-13-001"
  },
  "products": [
    {
      "id": "product-uuid",
      "name": "Cheeseburger",
      "price": 15.99,
      "barcode": "123456789",
      "category_id": "food-uuid",
      "modifiers": [...]
    }
    // ALL active products (could be 1000+)
  ],
  "categories": [...],
  "modifiers": [...],
  "modifier_groups": [...],
  "tables": [...],
  "zones": [...],
  "payment_methods": [...],
  "tax_settings": {...}
}
```

**Implementation Needed:**
- Create new sync controller/service
- Load all master data in single request
- Compress response (gzip)
- Cache server-side (5-minute TTL)
- Include version/timestamp for incremental sync

---

#### 2. Bulk Create Offline Orders
```http
POST /api/v1/organizations/{org_id}/sync/orders
Authorization: Bearer {jwt_token}

Request:
{
  "session_id": "session-uuid",
  "device_id": "POS-001",
  "orders": [
    {
      "client_id": "offline-uuid-1",  // Client-generated UUID
      "client_timestamp": "2025-11-13T10:00:00Z",
      "table_id": "table-uuid",
      "status": "completed",
      "items": [...],
      "payments": [...]
    }
  ]
}

Response: 200 OK
{
  "synced": [
    {
      "client_id": "offline-uuid-1",
      "server_id": "order-uuid",
      "status": "created"
    }
  ],
  "failed": [],
  "conflicts": []
}
```

**Implementation Needed:**
- Accept array of orders
- Use client_id for idempotency
- Create orders with items/modifiers/payments atomically
- Handle conflicts (duplicate order numbers)
- Return mapping of client_id → server_id

---

#### 3. Incremental Sync (Pull Changes)
```http
GET /api/v1/organizations/{org_id}/sync/changes?since={timestamp}&device_id={device_id}
Authorization: Bearer {jwt_token}

Response: 200 OK
{
  "timestamp": "2025-11-13T12:00:00Z",
  "changes": {
    "products": {
      "updated": [...],
      "deleted": ["product-uuid"]
    },
    "orders": {
      "updated": [...],  // Orders created on other devices
      "deleted": []
    },
    "tables": {
      "updated": [
        {
          "id": "table-uuid",
          "status": "occupied",
          "updated_at": "2025-11-13T11:45:00Z"
        }
      ]
    }
  }
}
```

**Implementation Needed:**
- Track updated_at on all tables
- Query for changes since timestamp
- Exclude changes from requesting device (via device_id)
- Support pagination for large datasets

---

## PRIORITY 7: REAL-TIME UPDATES (WebSocket)

### NEW Module Required: `/backend/internal/websocket/`

**STATUS:** ❌ Doesn't exist

### Required WebSocket Endpoints

#### 1. Kitchen Display WebSocket
```
WebSocket: wss://api.domain.com/ws/kitchen/{org_id}?station_id={station_id}&auth={jwt}

Messages from Server → Client:

1. New Ticket:
{
  "type": "ticket.created",
  "data": {
    "ticket_id": "ticket-uuid",
    "ticket_number": "T-001",
    "order_id": "order-uuid",
    "table_name": "Table 5",
    "items": [...]
  }
}

2. Ticket Updated:
{
  "type": "ticket.status_updated",
  "data": {
    "ticket_id": "ticket-uuid",
    "status": "in_progress",
    "updated_at": "2025-11-13T12:33:00Z"
  }
}

3. Order Modified:
{
  "type": "order.modified",
  "data": {
    "order_id": "order-uuid",
    "ticket_id": "ticket-uuid",
    "added_items": [...],
    "removed_items": [...]
  }
}

Messages from Client → Server:

1. Acknowledge Ticket:
{
  "action": "acknowledge",
  "ticket_id": "ticket-uuid"
}

2. Update Status:
{
  "action": "update_status",
  "ticket_id": "ticket-uuid",
  "status": "in_progress"
}
```

**Implementation Needed:**
- Use gorilla/websocket
- Implement pub/sub pattern
- Room-based broadcasting (per station)
- JWT authentication in URL params
- Heartbeat/ping-pong (30s interval)
- Graceful reconnection handling
- Message persistence (Redis) for missed messages

---

#### 2. POS Multi-Device Sync WebSocket
```
WebSocket: wss://api.domain.com/ws/pos/{org_id}?device_id={device_id}&auth={jwt}

Messages from Server → Client:

1. Order Created (Other Device):
{
  "type": "order.created",
  "data": {
    "order_id": "order-uuid",
    "order_number": "042",
    "device_id": "POS-002",  // Created on different device
    "table_id": "table-uuid"
  }
}

2. Table Status Changed:
{
  "type": "table.status_changed",
  "data": {
    "table_id": "table-uuid",
    "status": "occupied",
    "order_id": "order-uuid"
  }
}

3. Session Closed (Manager):
{
  "type": "session.closed",
  "data": {
    "session_id": "session-uuid",
    "closed_by": "manager-uuid",
    "message": "Session closed by manager"
  }
}
```

**Implementation Needed:**
- Organization-scoped rooms
- Exclude sender from broadcast
- Support reconnection with message replay
- Notify on critical events (session close, system maintenance)

---

## PRIORITY 8: PAYMENT METHOD CONFIGURATION

### Module: `/backend/internal/payment_method/`

**STATUS:** ✅ Exists, ❌ NOT exposed

### Required Endpoints

#### 1. Get Payment Methods for Organization
```http
GET /api/v1/organizations/{org_id}/payment-methods?active=true
Authorization: Bearer {jwt_token}

Response: 200 OK
{
  "payment_methods": [
    {
      "id": "cash-uuid",
      "name": "Cash",
      "type": "cash",
      "active": true,
      "requires_authorization": false,
      "opens_cash_drawer": true,
      "icon": "💵"
    },
    {
      "id": "card-uuid",
      "name": "Credit Card",
      "type": "card",
      "active": true,
      "requires_authorization": true,
      "payment_terminal_id": "terminal-uuid",
      "icon": "💳"
    }
  ]
}
```

**Enhancement Needed:**
- Expose existing handler
- Add `active` filter
- Include payment terminal configuration
- Support sorting by display_order

---

## PRIORITY 9: TABLE & FLOOR MANAGEMENT

### Modules: `/backend/internal/restaurant_table/`, `/backend/internal/restaurant_zone/`, `/backend/internal/restaurant_floor/`

**STATUS:** ✅ Tables/Stations exposed, ⚠️ Zones/Floors NOT exposed

### Required Enhancements

#### Get Tables with Status
```http
GET /api/v1/organizations/{org_id}/tables?include=current_order&zone_id={zone_id}
Authorization: Bearer {jwt_token}

Response: 200 OK
{
  "tables": [
    {
      "id": "table-uuid",
      "name": "T5",
      "zone_id": "dining-room-uuid",
      "capacity": 4,
      "status": "occupied",
      "current_order": {
        "id": "order-uuid",
        "order_number": "042",
        "total": 65.50,
        "items_count": 8,
        "opened_at": "2025-11-13T11:30:00Z",
        "elapsed_minutes": 45
      }
    }
  ]
}
```

**Enhancement Needed:**
- Add `include` parameter support
- Join with orders table
- Calculate elapsed time
- Support zone filtering
- Add availability forecast

---

## PRIORITY 10: REPORTING & ANALYTICS

### NEW Module Required: `/backend/internal/reporting/`

**STATUS:** ❌ Doesn't exist

### Required Endpoints

#### 1. Sales Report
```http
GET /api/v1/organizations/{org_id}/reports/sales?start_date={date}&end_date={date}&group_by=day
Authorization: Bearer {jwt_token}

Response: 200 OK
{
  "period": {
    "start": "2025-11-01T00:00:00Z",
    "end": "2025-11-13T23:59:59Z"
  },
  "summary": {
    "total_orders": 450,
    "gross_sales": 12500.00,
    "discounts": 250.00,
    "refunds": 150.00,
    "net_sales": 12100.00,
    "taxes": 968.00,
    "tips": 1815.00
  },
  "breakdown": [
    {
      "date": "2025-11-01",
      "orders": 35,
      "sales": 950.00
    }
  ],
  "payment_methods": [
    { "method": "Cash", "count": 200, "amount": 5500.00 },
    { "method": "Card", "count": 250, "amount": 6600.00 }
  ],
  "categories": [
    { "category": "Beverages", "count": 450, "amount": 2250.00 }
  ]
}
```

**Implementation Needed:**
- Create aggregation service
- Support multiple time ranges (day, week, month, year)
- Support grouping (day, week, month, category, product)
- Cache expensive queries
- Support CSV/PDF export

---

#### 2. Product Performance Report
```http
GET /api/v1/organizations/{org_id}/reports/products?start_date={date}&end_date={date}&limit=20&sort=revenue
Authorization: Bearer {jwt_token}

Response: 200 OK
{
  "period": {...},
  "products": [
    {
      "product_id": "product-uuid",
      "product_name": "Cheeseburger",
      "category": "Food",
      "quantity_sold": 150,
      "revenue": 2398.50,
      "cost": 900.00,
      "profit": 1498.50,
      "profit_margin": 62.5
    }
  ]
}
```

---

#### 3. Staff Performance Report
```http
GET /api/v1/organizations/{org_id}/reports/staff?start_date={date}&end_date={date}
Authorization: Bearer {jwt_token}

Response: 200 OK
{
  "staff": [
    {
      "user_id": "user-uuid",
      "name": "John Doe",
      "role": "Server",
      "hours_worked": 40.0,
      "orders_taken": 85,
      "total_sales": 2500.00,
      "average_order_value": 29.41,
      "tips_earned": 375.00
    }
  ]
}
```

---

## BACKEND ENHANCEMENTS NEEDED

### 1. Database Schema Changes

#### Add to `pos_sessions` table:
```sql
ALTER TABLE pos_sessions
ADD COLUMN opening_cash_denominations JSONB,
ADD COLUMN closing_cash_denominations JSONB,
ADD COLUMN expected_cash DECIMAL(10,2),
ADD COLUMN counted_cash DECIMAL(10,2),
ADD COLUMN cash_difference DECIMAL(10,2);
```

#### Add to all tables (for sync):
```sql
ALTER TABLE products ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE categories ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
-- etc. for all master data tables

-- Create trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

#### Create sync tracking table:
```sql
CREATE TABLE sync_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id),
  device_id VARCHAR(100) NOT NULL,
  sync_type VARCHAR(50) NOT NULL,  -- full, incremental, orders
  started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP,
  status VARCHAR(20) NOT NULL,  -- in_progress, completed, failed
  records_synced INTEGER,
  error_message TEXT
);
```

---

### 2. Configuration Changes

Add to `/backend/configs/config.yaml`:
```yaml
websocket:
  enabled: true
  ping_interval: 30s
  write_timeout: 10s
  read_timeout: 60s
  max_connections: 1000

offline_sync:
  batch_size: 100
  max_retries: 3
  idempotency_window: 24h

pos:
  session:
    max_open_duration: 24h
    auto_close_enabled: false
    require_denomination_count: true
  order:
    auto_number_format: "###"
    auto_send_to_kitchen: true
  kitchen:
    ticket_alert_threshold: 900  # 15 minutes
    auto_print_enabled: true
```

---

### 3. New Services Required

#### `/backend/internal/sync/sync_service.go`
- Bulk load master data
- Incremental sync logic
- Conflict resolution
- Idempotency checking

#### `/backend/internal/websocket/hub.go`
- WebSocket connection management
- Room-based broadcasting
- Message persistence
- Reconnection handling

#### `/backend/internal/reporting/report_service.go`
- Sales aggregations
- Product performance
- Staff metrics
- Cache management

---

## IMPLEMENTATION PHASES

### Phase 1: Quick Wins (4 hours)
1. Register 15+ existing modules in main.go
2. Test all newly exposed endpoints
3. Update API documentation

**Deliverable:** 90% of CRUD operations available

---

### Phase 2: Odoo Enhancements (12 hours)
1. Enhance POS session open/close with denominations (3h)
2. Implement nested order creation (3h)
3. Add current session endpoint (1h)
4. Add cash movement endpoints (2h)
5. Add kitchen ticket status updates (2h)
6. Add bulk session data load (1h)

**Deliverable:** Full Odoo workflow support

---

### Phase 3: Offline Sync (20 hours)
1. Add updated_at triggers to tables (2h)
2. Create sync module (6h)
3. Implement bulk order upload (4h)
4. Implement incremental sync (4h)
5. Add conflict resolution (2h)
6. Testing and optimization (2h)

**Deliverable:** Offline-first architecture

---

### Phase 4: Real-Time (12 hours)
1. Setup WebSocket infrastructure (4h)
2. Implement kitchen display WS (4h)
3. Implement POS multi-device WS (3h)
4. Testing and optimization (1h)

**Deliverable:** Real-time multi-device coordination

---

### Phase 5: Reporting (12 hours)
1. Create reporting module (3h)
2. Implement sales report (3h)
3. Implement product report (2h)
4. Implement staff report (2h)
5. Add caching (1h)
6. Add export (1h)

**Deliverable:** Management insights

---

## TOTAL EFFORT ESTIMATE

| Phase | Effort | Priority | Value |
|-------|--------|----------|-------|
| Phase 1: Quick Wins | 4h | P0 | High |
| Phase 2: Odoo | 12h | P0 | High |
| Phase 3: Offline | 20h | P1 | Medium |
| Phase 4: Real-Time | 12h | P1 | Medium |
| Phase 5: Reporting | 12h | P2 | Low |
| **Total** | **60h** | - | - |

**Recommendation:** Execute Phase 1 + 2 immediately (16 hours) to unblock frontend development. Phase 3-5 can be done in parallel with frontend work.

---

## NOTES FOR BACKEND DEVELOPERS

1. **DO NOT create new tables** - 179 modules already have comprehensive schema
2. **FOCUS on registration** - Most handlers exist, just need exposure
3. **FOLLOW Odoo patterns** - Session management, offline-first, real-time updates
4. **USE transactions** - All multi-step operations must be atomic
5. **ADD tests** - Current coverage is 0%, aim for 60%+
6. **DOCUMENT APIs** - Generate OpenAPI/Swagger docs
7. **OPTIMIZE queries** - Add indexes, use joins, cache aggressively
8. **MONITOR performance** - Add metrics to all endpoints
9. **SECURE endpoints** - Verify JWT, check permissions, validate input
10. **VERSION APIs** - Use /v1/ prefix, plan for future versions

---

**Last Updated:** 2025-11-13
**Maintained By:** Frontend Development Team
**Questions:** Contact backend team lead
