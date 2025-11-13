# Phase 1 Implementation Plan - Odoo-Pattern POS System
## Enterprise-Grade Restaurant POS MVP

**Last Updated:** 2025-11-13
**Status:** Ready to Execute
**Approach:** Following Odoo POS workflow and UI/UX patterns

---

## Odoo Research Summary

### Key Odoo POS Patterns Identified

1. **Session Management (CRITICAL)**
   - Must open session before any transactions
   - Opening balance with coin/bill denomination counting
   - Cash in/out tracking during session
   - Closing balance with reconciliation showing differences (short/over)
   - Multiple users can use same session simultaneously
   - Auto-close after configurable duration (default: don't auto-close)

2. **Order Workflow**
   - Order stages: New → In Progress → Ready → Completed
   - Orders sent to kitchen on "Order Click" or "Validate Order"
   - Order changes trigger notifications to kitchen
   - Line-level status tracking (each item can be in different stage)
   - Customer notes, kitchen notes, special instructions all separate

3. **Kitchen Display System**
   - Real-time order display with instant updates
   - Stage-based workflow with color coding
   - Elapsed time with visual alerts for delayed orders (>15 min)
   - Station-based filtering (Grill, Fryer, Bar, Cold, Hot, Dessert, Expo)
   - Manual stage transitions by kitchen staff
   - Token/ticket number system for customer pickup

4. **Offline Mode**
   - Load ALL master data (products, categories, modifiers, tables) at session start
   - Store in browser/local storage
   - Work fully offline
   - Auto-sync when connection restored
   - No manual sync needed

5. **Cash Reconciliation**
   - Count expected vs actual by payment method
   - Show differences with percentage variance
   - Detailed denomination breakdown
   - Cash movements (in/out) tracked separately
   - Z-report generation at session close

---

## Backend Status Review

### ✅ What Exists (179 modules, only 10 exposed)

**Strong Foundation:**
- Complete database schema with 25+ migrations
- 1,041 Go files with enterprise-grade code
- Clean architecture (handler → service → repository)
- Multi-tenant support with RLS
- JWT authentication
- All core POS modules implemented but NOT registered

**Critical Issue:**
- 169 modules exist but aren't accessible via API
- Missing module registration in `/backend/cmd/api/main.go`
- Missing Odoo-specific workflow endpoints
- No offline sync infrastructure
- No WebSocket for real-time updates

### ⚠️ What's Needed

**Documented in `missing_api.md`:**
1. Register existing modules (2-4 hours) - **PRIORITY 0**
2. Add Odoo session workflow endpoints (8-12 hours)
3. Add nested order creation (3 hours)
4. Add kitchen ticket API (4 hours)
5. Implement offline sync (16-20 hours)
6. Add WebSocket real-time updates (8-12 hours)
7. Add reporting APIs (12 hours)

**Total Backend Work:** ~60 hours

**Frontend can proceed with mock data until backend Phase 1+2 complete**

---

## Frontend Status Review

### Apps Assessment

| App | Current | Odoo-Ready | Work Needed |
|-----|---------|------------|-------------|
| **pos_register** | 60% | 50% | Session fix, offline mode, order integration |
| **kds** | 50% | 30% | Real-time WS, persistence, Odoo workflow |
| **waiter_app** | 55% | 40% | Complete order flow, table mgmt |
| **manager_dashboard** | 100% | 90% | Add Odoo-style reporting |
| **online_ordering** | 25% | 20% | Complete implementation |

### What Already Follows Odoo Patterns

**Session Management (pos_register):**
- ✅ Denomination counting widget (bills + coins)
- ✅ Opening balance calculation
- ✅ Cash count models (CashCount, CashDenomination)
- ✅ Session open page with proper UI
- ✅ Session close page with reconciliation
- ⚠️ Missing: Backend integration, denomination persistence

**UI/UX Patterns:**
- ✅ Vodo theme (matches Odoo's clean aesthetic)
- ✅ Card-based layouts
- ✅ Color-coded status indicators
- ✅ Proper form validation
- ✅ Loading states and error handling

### What Needs Odoo Alignment

**Order Flow:**
- ❌ No kitchen routing on order create
- ❌ No stage-based workflow
- ❌ No real-time notifications
- ❌ Mock data instead of API integration

**KDS:**
- ❌ Mock WebSocket instead of real backend
- ❌ No persistence (in-memory only)
- ❌ Missing Odoo's exact stage workflow
- ❌ No sound notifications (placeholder)

**Offline Mode:**
- ⚠️ Partial: Has sync queue and local DB
- ❌ Doesn't load all data at session start
- ❌ Manual sync instead of automatic
- ❌ No incremental sync

---

## Phase 1 Execution Plan (2 Weeks)

### Week 1: Backend Critical Path + pos_register Core

#### Day 1-2: Backend Foundation (Do Not Modify - Document Only)
**Objective:** Document missing APIs, don't create backend code

**Tasks:**
1. ✅ DONE: Created `missing_api.md` with all requirements
2. Review backend modules that need registration
3. Document WebSocket requirements
4. Document offline sync requirements

**Deliverable:** Complete API documentation for backend team

---

#### Day 3-5: pos_register - Odoo Session Workflow (CURRENT FOCUS)
**Objective:** Full Odoo-compliant session management

**Tasks:**

**A. Session Open Enhancement (6 hours)**
1. Update SessionController to handle denomination details
2. Add device registration (get device_id from platform)
3. Check for existing open session before opening
4. Auto-generate session_number (format: YYYY-MM-DD-NNN)
5. Save denomination breakdown to local DB
6. Load organization settings at session start
7. Implement "session guard" - block POS if no session

Files to modify:
- `packages/pos_core/lib/features/auth/data/repositories/session_repository_impl.dart`
- `apps/pos_register/lib/src/features/session/application/session_controller.dart`
- `apps/pos_register/lib/src/data/database/local_database.dart`

**B. Cash In/Out Flow (3 hours)**
1. Create cash movement page
2. Add movement types (cash_in, cash_out, safe_deposit, bank_deposit, expense)
3. Add reason codes and descriptions
4. Update session balance in real-time
5. Add approval workflow for large amounts (>$500)
6. Audit trail

New files:
- `apps/pos_register/lib/src/features/session/presentation/pages/cash_movement_page.dart`
- `apps/pos_register/lib/src/features/session/presentation/widgets/cash_movement_dialog.dart`

**C. Session Close Enhancement (4 hours)**
1. Calculate expected cash (opening + payments + movements)
2. Count closing cash with denominations
3. Calculate differences (short/over) by payment method
4. Show variance percentage
5. Generate session summary (Z-report preview)
6. Prevent operations after close
7. Save complete session data locally

Update:
- `apps/pos_register/lib/src/features/session/presentation/pages/session_close_page.dart`
- Add reconciliation breakdown widget
- Add difference highlighting (red for short, green for over)

**D. Session History & Reports (3 hours)**
1. Load past sessions from local DB
2. Display session cards with key metrics
3. Drill-down to full session report
4. Export to PDF (future)
5. Search and filter

Update:
- `apps/pos_register/lib/src/features/session/presentation/pages/session_history_page.dart`

**Deliverable:** Full Odoo-style session management working offline

---

#### Day 6-7: Offline-First Data Loading (Odoo Pattern)
**Objective:** Load all master data at session start

**Tasks:**

**A. Session Start Data Load (4 hours)**
1. Create `SessionDataLoader` service
2. On session open, load from backend:
   - All products (with modifiers)
   - All categories
   - All tables (with zones)
   - All payment methods
   - Tax settings
   - Organization branding
3. Save to local Drift database
4. Cache timestamp
5. Show loading progress (splash screen)

New file:
- `apps/pos_register/lib/src/data/services/session_data_loader.dart`

**B. Enhanced Local Database (6 hours)**
1. Expand schema:
   - Products cache table
   - Categories cache table
   - Modifiers cache table
   - Tables cache table
   - Payment methods cache table
   - Settings cache table
2. Add indexes for fast lookup
3. Add cache metadata (loaded_at, version)
4. Implement cache invalidation
5. Add cache size limits (max 50MB)

Update:
- `apps/pos_register/lib/src/data/database/local_database.dart`

**C. Offline Detection & Mode (2 hours)**
1. Enhanced connectivity monitoring
2. Offline banner UI
3. Disable features requiring connectivity
4. Queue all mutations
5. Auto-sync queue when online
6. Show sync status

Update:
- `apps/pos_register/lib/src/data/services/sync_service.dart`
- Add offline banner widget to shell

**D. Smart Cache Strategy (4 hours)**
1. On app start: Check cache age
2. If cache < 30 min old: Use cached data
3. If cache > 30 min old: Background refresh
4. If no cache: Force load before session
5. Manual refresh option
6. Show cache age in UI

**Deliverable:** True offline-first POS following Odoo pattern

---

### Week 2: Order Flow + Testing

#### Day 8-9: Order Creation with Kitchen Routing
**Objective:** Odoo-compliant order workflow

**Tasks:**

**A. Enhanced Order Creation (6 hours)**
1. Create nested order DTO (order + items + modifiers)
2. Add kitchen station routing logic
3. Auto-send to kitchen on validate
4. Generate order number (session-scoped)
5. Calculate totals (subtotal, tax, total)
6. Support special instructions per item
7. Save order locally + queue for sync

New:
- `packages/pos_core/lib/features/orders/data/dtos/create_order_request_dto.dart`
- Add kitchen_station_id to products table

**B. Order Status Workflow (4 hours)**
1. Implement state machine: New → In Progress → Ready → Completed
2. Status transition validation
3. Update timestamps per status
4. Notify kitchen on status change
5. Update table status based on order

**C. Order Modifications (4 hours)**
1. Add items to existing order
2. Remove items (if not yet preparing)
3. Modify items (if not yet preparing)
4. Add notes/special instructions
5. Handle modified orders in kitchen

**D. Mock API Fallback (2 hours)**
Until backend ready, use enhanced mocks:
1. Mock order creation with realistic delays
2. Mock kitchen ticket creation
3. Mock status updates
4. Return realistic responses

**Deliverable:** Complete order flow ready for backend integration

---

#### Day 10: Integration & Testing
**Objective:** E2E testing and polish

**Tasks:**

**A. End-to-End Scenarios (4 hours)**
1. Complete flow: Open session → Create order → Process payment → Close session
2. Offline mode: Work offline for 2 hours → Go online → Verify sync
3. Multi-order: Create 20 orders rapidly
4. Cash management: Open → Cash in → Cash out → Close with variance
5. Hardware: Print receipts, scan barcodes

**B. Performance Testing (2 hours)**
1. Load 1000 products - measure time
2. Test with 50 open orders
3. Test database queries
4. Optimize slow operations
5. Reduce app startup time to <3s

**C. Bug Fixes & Polish (2 hours)**
1. Fix UI glitches
2. Improve error messages
3. Add haptic feedback
4. Smooth animations
5. Loading indicators

**Deliverable:** Stable pos_register v1.0 following Odoo patterns

---

## Phase 1 Deliverables

### Applications
- ✅ **pos_register** - 100% Odoo-compliant, offline-first, production-ready

### Infrastructure
- ✅ Offline-first data loading
- ✅ Enhanced local database
- ✅ Session management (Odoo pattern)
- ✅ Order workflow (Odoo pattern)
- ✅ Mock APIs for development

### Documentation
- ✅ missing_api.md - Complete backend requirements
- ✅ PHASE1_PLAN.md - This document
- ✅ Odoo pattern documentation

### Testing
- ✅ E2E scenarios validated
- ✅ Offline mode tested
- ✅ Performance benchmarked

---

## Success Criteria

1. ✅ Session opens with denomination counting
2. ✅ Session closes with reconciliation showing variances
3. ✅ Cash in/out tracked during session
4. ✅ Orders created with kitchen routing
5. ✅ All data loaded at session start (offline-ready)
6. ✅ Works offline for 8+ hours
7. ✅ Auto-syncs when online
8. ✅ Hardware integration (printer, scanner)
9. ✅ Clean, Odoo-style UI/UX
10. ✅ Ready for backend API integration

---

## Next Phases Preview

### Phase 2: Kitchen Display System (Week 3-4)
- KDS with real-time WebSocket
- Odoo stage-based workflow
- Sound notifications
- Multi-station support
- Kitchen ticket printing

### Phase 3: Multi-Device & Polish (Week 5-6)
- Waiter app
- Manager reports
- Online ordering
- Production deployment
- Staff training

---

## Notes

**Backend Team:**
- Use `missing_api.md` as complete specification
- Priority: Register existing modules first (quick win)
- Then implement Odoo-specific endpoints
- WebSocket can wait until Phase 2

**Frontend Team:**
- Follow Odoo patterns strictly
- Use mocks until backend ready
- Document any pattern deviations
- Focus on offline-first
- Test extensively with bad network

**Design Team:**
- Reference Odoo 18 POS UI
- Keep Vodo branding but follow Odoo UX
- Color-coded status indicators
- Clean, card-based layouts
- Mobile-first responsive design

---

**Let's build this! 🚀**
