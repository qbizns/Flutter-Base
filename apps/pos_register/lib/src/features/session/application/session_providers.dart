/// Session Providers
/// Riverpod providers for session state management
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import '../domain/models/pos_session.dart';
import '../domain/repositories/session_repository.dart';
import '../data/datasources/session_remote_datasource.dart';
import '../data/repositories/session_repository_impl.dart';
import 'session_controller.dart';

/// Session remote data source provider
final sessionRemoteDataSourceProvider = Provider<SessionRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final appContext = ref.watch(appContextProvider);

  return SessionRemoteDataSource(
    apiClient: apiClient,
    appContext: appContext,
  );
});

/// Session repository provider
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final remoteDataSource = ref.watch(sessionRemoteDataSourceProvider);

  return SessionRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// Current session state provider
final currentSessionProvider = StateNotifierProvider<SessionController, AsyncValue<PosSession?>>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);

  return SessionController(
    repository: repository,
  );
});

/// Session history provider
final sessionHistoryProvider = FutureProvider.autoDispose.family<List<PosSession>, int>(
  (ref, page) async {
    final repository = ref.watch(sessionRepositoryProvider);
    final limit = 20;
    final offset = page * limit;

    final result = await repository.getSessionHistory(
      limit: limit,
      offset: offset,
    );

    return result.when(
      success: (sessions) => sessions,
      failure: (error) => throw Exception(error.message),
    );
  },
);

/// Specific session by ID provider
final sessionByIdProvider = FutureProvider.autoDispose.family<PosSession, String>(
  (ref, sessionId) async {
    final repository = ref.watch(sessionRepositoryProvider);

    final result = await repository.getSessionById(sessionId);

    return result.when(
      success: (session) => session,
      failure: (error) => throw Exception(error.message),
    );
  },
);

/// Session can be opened provider (checks if no active session)
final canOpenSessionProvider = Provider<bool>((ref) {
  final sessionState = ref.watch(currentSessionProvider);

  return sessionState.when(
    data: (session) => session == null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Session can be closed provider (checks if session is open)
final canCloseSessionProvider = Provider<bool>((ref) {
  final sessionState = ref.watch(currentSessionProvider);

  return sessionState.when(
    data: (session) => session?.status == SessionStatus.open,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Session statistics provider (for dashboard)
final sessionStatisticsProvider = Provider<SessionStatistics?>((ref) {
  final sessionState = ref.watch(currentSessionProvider);

  return sessionState.when(
    data: (session) {
      if (session == null) return null;

      return SessionStatistics(
        sessionId: session.id,
        sessionNumber: session.number,
        startedAt: session.startedAt,
        totalSales: session.totalSales,
        totalOrders: session.totalOrders,
        openingCash: session.openingCash,
        expectedClosingCash: session.expectedClosingCash,
        cashPayments: session.totalCashPayments,
        cardPayments: session.totalCardPayments,
        mobilePayments: session.totalMobilePayments,
        cashIn: session.totalCashIn,
        cashOut: session.totalCashOut,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Session statistics model
class SessionStatistics {
  final String sessionId;
  final String sessionNumber;
  final DateTime startedAt;
  final double totalSales;
  final int totalOrders;
  final double openingCash;
  final double expectedClosingCash;
  final double cashPayments;
  final double cardPayments;
  final double mobilePayments;
  final double cashIn;
  final double cashOut;

  SessionStatistics({
    required this.sessionId,
    required this.sessionNumber,
    required this.startedAt,
    required this.totalSales,
    required this.totalOrders,
    required this.openingCash,
    required this.expectedClosingCash,
    required this.cashPayments,
    required this.cardPayments,
    required this.mobilePayments,
    required this.cashIn,
    required this.cashOut,
  });

  /// Duration since session started
  Duration get duration => DateTime.now().difference(startedAt);

  /// Average order value
  double get averageOrderValue =>
      totalOrders > 0 ? totalSales / totalOrders : 0.0;

  /// Current cash in register
  double get currentCash =>
      openingCash + cashPayments + cashIn - cashOut;

  /// Total non-cash payments
  double get nonCashPayments => cardPayments + mobilePayments;
}
