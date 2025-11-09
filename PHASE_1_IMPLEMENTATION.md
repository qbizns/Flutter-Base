# Phase 1: Core UX & Identity - Implementation Complete ✅

This document describes the Phase 1 implementation for the POS ecosystem foundation.

## Overview

Phase 1 adds the essential authentication, onboarding, and navigation infrastructure needed for all 16+ apps in the POS ecosystem.

---

## What Was Implemented

### 1. Core Auth Module (`core/auth/`)

Complete authentication system with session management:

**Files Created:**
- `auth_state.dart` - AuthState class with user session data
  - User info (userId, email, name, phone, avatar)
  - Multi-tenancy support (tenantId, branchId)
  - RBAC (roles, permissions arrays)
  - Auth tokens (access + refresh)
  - JSON serialization for persistence

- `auth_repository.dart` - Abstract repository interface
  - `loginWithPassword()` - Email/phone + password auth
  - `loginWithPin()` - PIN auth for POS terminals
  - `signUp()` - New user registration
  - `refreshToken()` - Token refresh
  - `requestPasswordReset()` - Password recovery
  - `verifyCode()` - OTP verification
  - `resetPassword()` - Password reset
  - `logout()` - Sign out
  - `getCurrentUser()` - Fetch user info

- `auth_repository_impl.dart` - Concrete implementation using ApiClient
  - All methods use Result<T> for error handling
  - Automatic DioException to Failure conversion
  - Auth token injection into ApiClient

- `session_manager.dart` - Session persistence
  - Save/load auth state from local storage
  - Clear session on logout
  - Handle corrupted session data

- `auth_providers.dart` - Riverpod providers
  - `sessionManagerProvider` - Session management
  - `authRepositoryProvider` - Repository instance
  - `authStateNotifierProvider` - Global auth state (StateNotifier)
    - Login methods (password, PIN)
    - Sign up
    - Token refresh
    - Logout
    - Update user info
    - Auto session restoration on app start

**Benefits:**
- Single source of truth for auth state
- Type-safe error handling with Result<T>
- Session persistence across app restarts
- Supports both email/password and PIN auth
- Multi-tenant aware
- RBAC ready

---

### 2. Core Context Module (`core/context/`)

Application context for multi-tenancy:

**Files Created:**
- `app_context.dart` - AppContext class
  - Tenant info (tenantId, tenantName)
  - Branch info (branchId, branchName)
  - Device info (deviceId, deviceName, deviceType)
  - Station info (stationId, stationName, stationType)
  - JSON serialization
  - Helper methods (hasTenant, hasBranch, etc.)

- `context_providers.dart` - Riverpod provider
  - `appContextNotifierProvider` - Global context state
  - Auto-loads saved context on app start
  - Update context (full or partial)
  - Clear context

**Benefits:**
- Support for multi-tenant POS systems
- Track branch/device/station info
- Persistent across app restarts
- Easy to update specific fields

---

### 3. Features/Auth (`features/auth/`)

Complete authentication UI flow:

**Files Created:**
- `splash_page.dart` - App initialization screen
  - Checks for existing session
  - Auto-navigates to home (if logged in) or sign-in
  - Branded splash with gradient background

- `sign_in_page.dart` - Sign-in screen
  - Segmented button to switch between email/password and PIN modes
  - Form validation
  - Error handling with snackbars
  - Link to sign-up and forgot password
  - Loading states

- `sign_up_page.dart` - User registration
  - Full name, email, phone (optional), password fields
  - Password confirmation validation
  - Email regex validation
  - Auto sign-in after successful registration

- `forgot_password_page.dart` - Password recovery
  - Request reset code via email/phone
  - Navigates to verification page

- `verification_page.dart` - OTP verification
  - Enter verification code
  - Used for password reset flow
  - Shows new password form after verification
  - Resend code option

**Benefits:**
- Complete auth flow out of the box
- Supports both email/password and PIN auth
- Responsive layouts (mobile/tablet/desktop)
- Consistent Material 3 design
- Error handling with user feedback

---

### 4. Features/Onboarding (`features/onboarding/`)

First-time user onboarding:

**Files Created:**
- `onboarding_page.dart` - Swipeable onboarding slides
  - 3 slides with icons, titles, descriptions
  - Page indicators
  - Skip button
  - Next/Get Started button
  - Marks onboarding as completed in storage

**Benefits:**
- First-run experience
- Easy to customize slides
- Persists completion state
- Smooth page transitions

---

### 5. Features/Home Shell (`features/home_shell/`)

Main app container with navigation:

**Files Created:**
- `home_shell_page.dart` - Bottom navigation shell
  - 4 tabs: Home, Analytics, Orders, More
  - Material 3 NavigationBar
  - Profile button in app bar
  - Tab-specific content (placeholders for now)

**Benefits:**
- Single navigation structure for all apps
  - Tabs can be configured per app via JSON
  - Each app can show/hide specific tabs
  - Consistent UX across all 16+ apps

---

### 6. Features/Profile (`features/profile/`)

User profile and settings:

**Files Created:**
- `profile_page.dart` - Profile information display
  - User avatar (with fallback)
  - Name, email, phone
  - Account info (userId, tenantId, branchId)
  - Roles as chips
  - Permissions as chips
  - Edit profile button (placeholder)
  - Logout with confirmation dialog

**Benefits:**
- Shows all auth state info
- RBAC visibility (roles/permissions)
- Logout functionality
- Material 3 cards and chips

---

### 7. Updated Routing (`core/routing/`)

Integrated all new pages:

**Changes:**
- `routes.dart` - Added route constants
  - Auth routes (splash, signIn, signUp, forgotPassword, verification)
  - Main routes (home, profile, onboarding)

- `app_router.dart` - Added route definitions
  - All auth pages
  - Onboarding page
  - Home shell page
  - Profile page
  - Changed initial route to `/` (splash)
  - Verification route accepts parameters via `extra`

**Benefits:**
- Type-safe navigation
- Centralized route definitions
- Deep linking ready

---

## Required Before Running

### 1. Code Generation

You must run code generation to create `.g.dart` files:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `auth_providers.g.dart`
- `context_providers.g.dart`
- `app_router.g.dart`
- All other `*.g.dart` files for Riverpod providers

### 2. Update pubspec.yaml (if needed)

Ensure these dependencies are present:

```yaml
dependencies:
  equatable: ^2.0.5
  dio: ^5.7.0
  # ... all existing dependencies
```

---

## Flow Diagrams

### App Start Flow

```
App Starts
   ↓
Splash Page
   ↓
Check Auth State
   ↓
   ├─→ Authenticated? → Home Shell
   └─→ Not Authenticated? → Sign In
```

### Sign In Flow

```
Sign In Page
   ↓
Choose Mode: Email/Password or PIN
   ↓
Enter Credentials
   ↓
Tap "Sign In"
   ↓
AuthStateNotifier.loginWithPassword() or loginWithPin()
   ↓
AuthRepositoryImpl makes API call
   ↓
   ├─→ Success → Save session → Navigate to Home
   └─→ Failure → Show error snackbar
```

### Password Reset Flow

```
Sign In Page
   ↓
Tap "Forgot Password?"
   ↓
Forgot Password Page → Enter email/phone → Send Code
   ↓
Verification Page
   ↓
Enter Code → Verify
   ↓
   ├─→ Valid → Show new password form
   └─→ Invalid → Show error
   ↓
Enter new password → Reset Password
   ↓
Success → Navigate to Sign In
```

---

## Architecture Notes

### Clean Architecture Compliance

✅ **Domain Layer** (core/auth/auth_repository.dart)
- Abstract repository interface
- No dependencies on data layer

✅ **Data Layer** (core/auth/auth_repository_impl.dart)
- Implements domain interface
- Depends on core/network (infrastructure)

✅ **Presentation Layer** (features/auth/presentation/)
- Depends on domain layer (auth_repository)
- Uses providers for state management

### State Management

- **Riverpod** for dependency injection and state
- **StateNotifier** for mutable state (auth, context)
- **FutureProvider** for async initialization
- **Provider overrides** in bootstrap for config

### Error Handling

- **Result<T>** pattern for all repository methods
- No exceptions for control flow
- Typed failures (network, server, auth, validation)
- User-friendly error messages

---

## Testing Checklist

Before pushing, test these flows:

- [ ] App starts → Splash → Sign In (if not logged in)
- [ ] Sign In with email/password
- [ ] Sign In with PIN (if backend supports)
- [ ] Sign Up new user
- [ ] Forgot Password → Verify Code → Reset Password
- [ ] Navigate to Profile
- [ ] Logout
- [ ] Session persistence (close app, reopen → should stay logged in)
- [ ] Onboarding (first run only)

---

## API Contract

The implementation expects the backend to follow this contract:

### POST /auth/login
**Request:**
```json
{
  "identifier": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "user": {
    "id": "user123",
    "email": "user@example.com",
    "name": "John Doe",
    "phone": "+1234567890",
    "avatarUrl": "https://...",
    "tenantId": "tenant123",
    "branchId": "branch456",
    "roles": ["cashier", "manager"],
    "permissions": ["view_orders", "create_orders"]
  }
}
```

### POST /auth/login/pin
**Request:**
```json
{
  "pin": "1234",
  "deviceId": "device123",
  "branchId": "branch456"
}
```

**Response:** Same as `/auth/login`

### POST /auth/signup
**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe",
  "phone": "+1234567890"
}
```

**Response:** Same as `/auth/login`

### POST /auth/refresh
**Request:**
```json
{
  "refreshToken": "eyJ..."
}
```

**Response:** Same as `/auth/login`

### POST /auth/password/reset/request
**Request:**
```json
{
  "identifier": "user@example.com"
}
```

**Response:**
```json
{
  "message": "Code sent successfully"
}
```

### POST /auth/verify
**Request:**
```json
{
  "identifier": "user@example.com",
  "code": "123456"
}
```

**Response:**
```json
{
  "message": "Code verified"
}
```

### POST /auth/password/reset
**Request:**
```json
{
  "identifier": "user@example.com",
  "code": "123456",
  "newPassword": "newpassword123"
}
```

**Response:**
```json
{
  "message": "Password reset successfully"
}
```

### POST /auth/logout
**Request:** (empty or with token)

**Response:**
```json
{
  "message": "Logged out successfully"
}
```

### GET /auth/me
**Request:** (with auth token in header)

**Response:** Same user object as login

---

## File Structure

```
lib/src/
├── core/
│   ├── auth/
│   │   ├── auth_state.dart
│   │   ├── auth_repository.dart
│   │   ├── auth_repository_impl.dart
│   │   ├── session_manager.dart
│   │   └── auth_providers.dart (.g.dart generated)
│   ├── context/
│   │   ├── app_context.dart
│   │   └── context_providers.dart (.g.dart generated)
│   └── routing/
│       ├── routes.dart (updated)
│       └── app_router.dart (updated)
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       └── pages/
│   │           ├── splash_page.dart
│   │           ├── sign_in_page.dart
│   │           ├── sign_up_page.dart
│   │           ├── forgot_password_page.dart
│   │           └── verification_page.dart
│   ├── onboarding/
│   │   └── presentation/
│   │       └── pages/
│   │           └── onboarding_page.dart
│   ├── home_shell/
│   │   └── presentation/
│   │       └── pages/
│   │           └── home_shell_page.dart
│   └── profile/
│       └── presentation/
│           └── pages/
│               └── profile_page.dart
```

---

## Next Steps (Phase 2-4)

Phase 1 is now complete! The foundation is ready for:

**Phase 2: Communication & Money**
- Notifications module
- Messaging/chat
- Payments integration

**Phase 3: POS Power Features**
- Realtime sync
- Offline support
- Advanced RBAC
- Analytics

**Phase 4: Device Bridge & Polish**
- Hardware abstraction (via Go service)
- screen_utils for responsive design
- Form builders

---

## Summary

✅ **Core Modules**: auth, context
✅ **Features**: auth flow, onboarding, home shell, profile
✅ **Routing**: All pages integrated
✅ **State Management**: Riverpod providers
✅ **Error Handling**: Result<T> pattern
✅ **Multi-tenancy**: AppContext support
✅ **RBAC**: Roles and permissions in AuthState

**Status**: Phase 1 Complete - Ready for Code Generation & Testing 🚀
