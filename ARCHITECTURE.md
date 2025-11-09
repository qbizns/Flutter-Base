# Architecture Documentation

## Overview

This Flutter starter template follows **Clean Architecture** principles with a **feature-first** approach. The architecture is designed to be scalable, maintainable, and testable.

## Table of Contents

- [Architectural Principles](#architectural-principles)
- [Layer Structure](#layer-structure)
- [Feature Organization](#feature-organization)
- [Dependency Flow](#dependency-flow)
- [State Management](#state-management)
- [Navigation](#navigation)
- [Data Flow](#data-flow)
- [Testing Strategy](#testing-strategy)

---

## Architectural Principles

### 1. Separation of Concerns

Each layer has a specific responsibility and doesn't know about the layers above it:

- **Presentation**: UI and user interaction
- **Application**: Application logic and state management
- **Domain**: Business logic and entities
- **Data**: Data access and external services

### 2. Dependency Rule

Dependencies flow **inward**:
```
Presentation → Application → Domain ← Data
```

- Outer layers depend on inner layers
- Inner layers never depend on outer layers
- Domain layer has no dependencies on other layers

### 3. Feature-First Organization

Each feature is self-contained with all its layers:

```
features/
└── feature_name/
    ├── presentation/
    ├── application/
    ├── domain/
    └── data/
```

Benefits:
- Easy to locate feature code
- Features can be developed independently
- Clear boundaries between features
- Easy to remove or add features

### 4. Testability

Each layer can be tested independently:
- **Unit tests**: Domain and data layers
- **Widget tests**: Presentation layer
- **Integration tests**: Full feature flows

---

## Layer Structure

### 1. Presentation Layer (`presentation/`)

**Responsibility**: UI and user interaction

**Components**:
- **Pages**: Full-screen views
- **Widgets**: Reusable UI components
- **View Models** (optional): UI state

**Dependencies**:
- Can use: Application layer (controllers)
- Cannot use: Domain or Data layers directly

**Example**:
```dart
// presentation/pages/welcome_page.dart
class WelcomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(welcomeControllerProvider);
    // Build UI based on state
  }
}
```

### 2. Application Layer (`application/`)

**Responsibility**: Application logic and orchestration

**Components**:
- **Controllers**: Manage feature state (Riverpod)
- **Providers**: Dependency injection
- **State Classes**: Application state definitions

**Dependencies**:
- Can use: Domain layer (use cases, entities)
- Cannot use: Presentation or Data layers

**Example**:
```dart
// application/welcome_controller.dart
@riverpod
class WelcomeController extends _$WelcomeController {
  @override
  WelcomeState build() {
    loadWelcomeMessage();
    return const WelcomeState(isLoading: true);
  }

  Future<void> loadWelcomeMessage() async {
    final useCase = ref.read(loadWelcomeContentProvider);
    final message = await useCase.execute();
    state = WelcomeState(message: message);
  }
}
```

### 3. Domain Layer (`domain/`)

**Responsibility**: Business logic and core entities

**Components**:
- **Entities**: Business objects
- **Use Cases**: Business operations
- **Repository Interfaces**: Data contracts

**Dependencies**:
- No dependencies on other layers
- Pure Dart code (no Flutter dependencies)

**Example**:
```dart
// domain/entities/welcome_message.dart
class WelcomeMessage extends Equatable {
  const WelcomeMessage({
    required this.title,
    required this.tagline,
    // ...
  });

  final String title;
  final String tagline;
}

// domain/usecases/load_welcome_content.dart
class LoadWelcomeContent {
  const LoadWelcomeContent({required this.repository});

  final WelcomeRepository repository;

  Future<WelcomeMessage> execute() async {
    return await repository.getWelcomeMessage();
  }
}
```

### 4. Data Layer (`data/`)

**Responsibility**: Data access and external services

**Components**:
- **Repositories**: Implementation of domain interfaces
- **Data Sources**: API clients, local storage, etc.
- **Models/DTOs**: Data transfer objects
- **Mappers**: Convert DTOs to entities

**Dependencies**:
- Can use: Domain layer (entities, repository interfaces)
- Cannot use: Presentation or Application layers

**Example**:
```dart
// data/sources/local_welcome_source.dart
class LocalWelcomeSource {
  Future<WelcomeMessage> getWelcomeMessage() async {
    // Fetch from local storage, API, etc.
    return const WelcomeMessage(...);
  }
}

// data/repositories/welcome_repository_impl.dart
class WelcomeRepositoryImpl implements WelcomeRepository {
  const WelcomeRepositoryImpl({required this.localSource});

  final LocalWelcomeSource localSource;

  @override
  Future<WelcomeMessage> getWelcomeMessage() async {
    return await localSource.getWelcomeMessage();
  }
}
```

---

## Feature Organization

### Adding a New Feature

1. **Create feature directory**:
   ```
   lib/src/features/your_feature/
   ├── presentation/
   │   ├── pages/
   │   └── widgets/
   ├── application/
   ├── domain/
   │   ├── entities/
   │   └── usecases/
   └── data/
       ├── repositories/
       └── sources/
   ```

2. **Start with Domain layer**:
   - Define entities
   - Create use cases
   - Define repository interfaces

3. **Implement Data layer**:
   - Create data sources
   - Implement repositories

4. **Build Application layer**:
   - Create controllers
   - Setup providers

5. **Create Presentation layer**:
   - Build pages
   - Create widgets

6. **Add Routes**:
   - Update `core/routing/routes.dart`
   - Update `core/routing/app_router.dart`

7. **Write Tests**:
   - Unit tests for domain/data
   - Widget tests for presentation

### Feature Communication

Features should communicate through:

1. **Navigation**: Use router to navigate between features
2. **Shared State**: Use global providers if needed
3. **Events**: Use event bus or stream controllers
4. **Parameters**: Pass data through route parameters

**Avoid**:
- Direct imports between features
- Shared mutable state
- Tight coupling

---

## Dependency Flow

### Correct Flow

```
┌─────────────────────────────────────┐
│     Presentation (Pages/Widgets)    │
│                                     │
│  - Watches controllers              │
│  - Displays UI                      │
│  - Handles user input               │
└──────────────┬──────────────────────┘
               │ depends on
               ↓
┌─────────────────────────────────────┐
│     Application (Controllers)       │
│                                     │
│  - Manages state                    │
│  - Calls use cases                  │
│  - Handles app logic                │
└──────────────┬──────────────────────┘
               │ depends on
               ↓
┌─────────────────────────────────────┐
│     Domain (Entities/Use Cases)     │
│                                     │
│  - Business logic                   │
│  - No dependencies                  │
│  - Pure Dart                        │
└──────────────┬──────────────────────┘
               ↑ implements
               │
┌─────────────────────────────────────┐
│     Data (Repositories/Sources)     │
│                                     │
│  - Data access                      │
│  - API/DB integration               │
│  - Implements domain interfaces     │
└─────────────────────────────────────┘
```

### Code Example

```dart
// ✅ CORRECT: Presentation → Application
class WelcomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(welcomeControllerProvider.notifier);
    final state = ref.watch(welcomeControllerProvider);

    return Scaffold(
      body: Column(
        children: [
          Text(state.message?.title ?? ''),
          ElevatedButton(
            onPressed: controller.onGetStarted,
            child: Text('Get Started'),
          ),
        ],
      ),
    );
  }
}

// ✅ CORRECT: Application → Domain
class WelcomeController extends _$WelcomeController {
  @override
  WelcomeState build() {
    final useCase = ref.read(loadWelcomeContentProvider);
    // Use case is from domain layer
    return WelcomeState();
  }
}

// ❌ WRONG: Presentation → Data (skipping Application/Domain)
class WelcomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Don't access data sources directly!
    final source = ref.watch(localWelcomeSourceProvider);
    // ...
  }
}
```

---

## State Management

### Riverpod Architecture

This template uses **Riverpod** with code generation for:

1. **Dependency Injection**: Provide dependencies
2. **State Management**: Manage feature state
3. **Reactivity**: Rebuild UI on state changes

### Provider Types

```dart
// 1. Simple Provider (stateless)
@riverpod
LocalWelcomeSource localWelcomeSource(LocalWelcomeSourceRef ref) {
  return const LocalWelcomeSource();
}

// 2. Stateful Provider (with state)
@riverpod
class WelcomeController extends _$WelcomeController {
  @override
  WelcomeState build() {
    return const WelcomeState();
  }

  void updateState() {
    state = state.copyWith(...);
  }
}
```

### Watching Providers

```dart
// In Widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state (rebuilds on changes)
    final state = ref.watch(welcomeControllerProvider);

    // Read once (no rebuild)
    final controller = ref.read(welcomeControllerProvider.notifier);

    return Text(state.message?.title ?? '');
  }
}
```

---

## Navigation

### Router Architecture

Using **go_router** for type-safe navigation:

```dart
// 1. Define routes
class Routes {
  static const String welcome = '/';
  static const String profile = '/profile';
}

// 2. Configure router
@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: Routes.welcome,
    routes: [
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      // Add more routes...
    ],
  );
}

// 3. Navigate
context.go(Routes.profile);
context.push(Routes.profile);
context.pop();
```

### Passing Data

```dart
// Via route parameters
GoRoute(
  path: '/profile/:id',
  builder: (context, state) {
    final id = state.pathParameters['id'];
    return ProfilePage(id: id);
  },
)

// Via query parameters
context.go('/search?query=flutter');
```

---

## Data Flow

### Complete Data Flow Example

```
User Action
    ↓
[Presentation] Button pressed
    ↓
[Application] Controller method called
    ↓
[Application] Use case executed
    ↓
[Domain] Business logic processed
    ↓
[Data] Repository fetches data
    ↓
[Data] Data source (API/DB) accessed
    ↓
[Data] Returns entity to domain
    ↓
[Application] Updates state
    ↓
[Presentation] UI rebuilds
```

### Code Flow

```dart
// 1. User taps button (Presentation)
ElevatedButton(
  onPressed: () => controller.loadData(),
  child: Text('Load'),
)

// 2. Controller handles action (Application)
class DataController extends _$DataController {
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);

    // 3. Execute use case (Domain)
    final useCase = ref.read(loadDataUseCaseProvider);
    final result = await useCase.execute();

    // 4. Update state
    state = state.copyWith(
      data: result,
      isLoading: false,
    );
  }
}

// 3. Use case processes (Domain)
class LoadDataUseCase {
  Future<DataEntity> execute() async {
    // 4. Call repository (Data)
    return await repository.getData();
  }
}

// 4. Repository fetches (Data)
class DataRepositoryImpl implements DataRepository {
  Future<DataEntity> getData() async {
    // 5. Access data source
    final dto = await dataSource.fetch();

    // 6. Convert to entity
    return dto.toEntity();
  }
}
```

---

## Testing Strategy

### Unit Tests (Domain & Data Layers)

```dart
// Test use cases
test('LoadWelcomeContent executes successfully', () async {
  final useCase = LoadWelcomeContent(repository: mockRepository);
  final result = await useCase.execute();

  expect(result, isA<WelcomeMessage>());
});

// Test repositories
test('WelcomeRepository returns data', () async {
  final repository = WelcomeRepositoryImpl(
    localSource: mockLocalSource,
  );

  final result = await repository.getWelcomeMessage();

  expect(result.title, isNotEmpty);
});
```

### Widget Tests (Presentation Layer)

```dart
testWidgets('WelcomePage displays content', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        welcomeControllerProvider.overrideWith(
          (ref) => TestWelcomeController(),
        ),
      ],
      child: MaterialApp(home: WelcomePage()),
    ),
  );

  expect(find.text('Flutter Starter'), findsOneWidget);
});
```

### Integration Tests

```dart
testWidgets('Complete user flow', (tester) async {
  // Test full feature interaction
  await tester.pumpWidget(MyApp());

  // Interact with UI
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();

  // Verify result
  expect(find.byType(NextPage), findsOneWidget);
});
```

---

## Best Practices

### Do's ✅

- Keep layers separated
- Use interfaces for dependencies
- Write tests for each layer
- Use const constructors
- Follow naming conventions
- Document complex logic
- Use code generation for Riverpod

### Don'ts ❌

- Don't skip layers
- Don't put business logic in widgets
- Don't access data sources from UI
- Don't tightly couple features
- Don't ignore test coverage
- Don't use mutable state
- Don't forget error handling

---

## Scaling the Architecture

### When to Split Features

Split a feature when:
- Feature becomes too large (>10 files per layer)
- Multiple developers work on the same feature
- Feature has distinct sub-domains
- Testing becomes difficult

### When to Add Layers

Add layers when:
- Need caching between repository and source
- Need complex data transformations
- Need middleware for requests
- Need event sourcing

### When to Refactor

Refactor when:
- Code duplication across features
- Unclear dependencies
- Difficult to test
- Performance issues
- Team feedback indicates confusion

---

## Additional Resources

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Riverpod Documentation](https://riverpod.dev/)
- [Flutter go_router Documentation](https://pub.dev/packages/go_router)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

---

**Last Updated**: 2025-01-09
