import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../storage/app_storage.dart';
import '../storage/storage_providers.dart';
import 'app_context.dart';

part 'context_providers.g.dart';

/// Storage key for app context.
const String _appContextKey = 'app_context';

/// Manages the current application context.
/// This holds information about tenant, branch, device, and station.
@riverpod
class AppContextNotifier extends _$AppContextNotifier {
  @override
  Future<AppContext> build() async {
    // Try to load saved context from storage
    final storage = ref.watch(appStorageProvider).requireValue;
    final savedContext = await _loadContext(storage);

    return savedContext ?? AppContext.empty();
  }

  /// Update the application context and save it to storage.
  Future<void> updateContext(AppContext context) async {
    state = AsyncValue.data(context);
    await _saveContext(context);
  }

  /// Clear the application context.
  Future<void> clearContext() async {
    state = AsyncValue.data(AppContext.empty());
    await _clearSavedContext();
  }

  /// Update specific context fields.
  Future<void> updateFields({
    String? tenantId,
    String? tenantName,
    String? branchId,
    String? branchName,
    String? deviceId,
    String? deviceName,
    String? deviceType,
    String? stationId,
    String? stationName,
    String? stationType,
  }) async {
    final currentContext = state.valueOrNull ?? AppContext.empty();
    final updatedContext = currentContext.copyWith(
      tenantId: tenantId,
      tenantName: tenantName,
      branchId: branchId,
      branchName: branchName,
      deviceId: deviceId,
      deviceName: deviceName,
      deviceType: deviceType,
      stationId: stationId,
      stationName: stationName,
      stationType: stationType,
    );

    await updateContext(updatedContext);
  }

  Future<AppContext?> _loadContext(AppStorage storage) async {
    try {
      final jsonString = await storage.getString(_appContextKey);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AppContext.fromJson(json);
    } catch (e) {
      // If deserialization fails, clear the corrupted context
      await storage.remove(_appContextKey);
      return null;
    }
  }

  Future<void> _saveContext(AppContext context) async {
    final storage = ref.read(appStorageProvider).requireValue;
    final json = context.toJson();
    await storage.saveString(_appContextKey, jsonEncode(json));
  }

  Future<void> _clearSavedContext() async {
    final storage = ref.read(appStorageProvider).requireValue;
    await storage.remove(_appContextKey);
  }
}
