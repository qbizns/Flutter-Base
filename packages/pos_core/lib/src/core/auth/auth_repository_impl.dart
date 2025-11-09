import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../errors/failure.dart';
import '../errors/result.dart';
import '../network/api_client.dart';
import '../network/api_providers.dart';
import 'auth_repository.dart';
import 'auth_state.dart';

/// Concrete implementation of AuthRepository using the ApiClient.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required Ref ref}) : _ref = ref;

  final Ref _ref;

  ApiClient get _apiClient => _ref.read(apiClientProvider);

  @override
  Future<Result<AuthState>> loginWithPassword(
    LoginCredentials credentials,
  ) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'identifier': credentials.identifier,
          'password': credentials.password,
        },
      );

      final authState = _parseAuthResponse(response.data);
      _apiClient.setAuthToken(authState.authToken!);

      return Result.success(authState);
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<AuthState>> loginWithPin(
    PinLoginCredentials credentials,
  ) async {
    try {
      final response = await _apiClient.post(
        '/auth/login/pin',
        data: {
          'pin': credentials.pin,
          if (credentials.deviceId != null) 'deviceId': credentials.deviceId,
          if (credentials.branchId != null) 'branchId': credentials.branchId,
        },
      );

      final authState = _parseAuthResponse(response.data);
      _apiClient.setAuthToken(authState.authToken!);

      return Result.success(authState);
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<AuthState>> signUp(SignUpData data) async {
    try {
      final response = await _apiClient.post(
        '/auth/signup',
        data: {
          'email': data.email,
          'password': data.password,
          'name': data.name,
          if (data.phone != null) 'phone': data.phone,
        },
      );

      final authState = _parseAuthResponse(response.data);
      _apiClient.setAuthToken(authState.authToken!);

      return Result.success(authState);
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<AuthState>> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );

      final authState = _parseAuthResponse(response.data);
      _apiClient.setAuthToken(authState.authToken!);

      return Result.success(authState);
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> requestPasswordReset(String emailOrPhone) async {
    try {
      await _apiClient.post(
        '/auth/password/reset/request',
        data: {
          'identifier': emailOrPhone,
        },
      );

      return const Result.success(null);
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> verifyCode({
    required String identifier,
    required String code,
  }) async {
    try {
      await _apiClient.post(
        '/auth/verify',
        data: {
          'identifier': identifier,
          'code': code,
        },
      );

      return const Result.success(null);
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post(
        '/auth/password/reset',
        data: {
          'identifier': identifier,
          'code': code,
          'newPassword': newPassword,
        },
      );

      return const Result.success(null);
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _apiClient.post('/auth/logout');
      _apiClient.clearAuthToken();

      return const Result.success(null);
    } on DioException catch (e) {
      // Even if logout fails on server, clear local token
      _apiClient.clearAuthToken();
      return Result.failure(_handleDioError(e));
    } catch (e) {
      _apiClient.clearAuthToken();
      return Result.failure(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<AuthState>> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      final authState = _parseAuthResponse(response.data);

      return Result.success(authState);
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(Failure(message: e.toString()));
    }
  }

  /// Parse API response into AuthState.
  /// The server is expected to return user data in a consistent format.
  AuthState _parseAuthResponse(dynamic data) {
    final json = data as Map<String, dynamic>;
    final user = json['user'] as Map<String, dynamic>;

    return AuthState.authenticated(
      userId: user['id'] as String,
      tenantId: user['tenantId'] as String?,
      branchId: user['branchId'] as String?,
      email: user['email'] as String?,
      name: user['name'] as String?,
      phone: user['phone'] as String?,
      avatarUrl: user['avatarUrl'] as String?,
      roles: (user['roles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      permissions: (user['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      authToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
    );
  }

  /// Convert Dio errors to app-specific failures.
  Failure _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Failure.network(message: 'Connection timeout');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Failure.network(message: 'No internet connection');
    }

    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode;

      if (statusCode == 401) {
        return Failure.auth();
      }

      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        final message = _extractErrorMessage(response.data);
        return Failure.validation(message: message);
      }

      if (statusCode != null && statusCode >= 500) {
        final message = _extractErrorMessage(response.data);
        return Failure.server(message: message, code: statusCode.toString());
      }
    }

    return Failure.network(message: error.message ?? 'Unknown error');
  }

  /// Extract error message from API response.
  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          'An error occurred';
    }
    return 'An error occurred';
  }
}
