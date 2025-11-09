import '../errors/result.dart';
import 'auth_state.dart';

/// Login credentials for password-based authentication
class LoginCredentials {
  const LoginCredentials({
    required this.identifier,
    required this.password,
  });

  final String identifier; // email or phone
  final String password;
}

/// Login credentials for PIN-based authentication (for POS terminals)
class PinLoginCredentials {
  const PinLoginCredentials({
    required this.pin,
    this.deviceId,
    this.branchId,
  });

  final String pin;
  final String? deviceId;
  final String? branchId;
}

/// Sign up data
class SignUpData {
  const SignUpData({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
  });

  final String email;
  final String password;
  final String name;
  final String? phone;
}

/// Abstract repository interface for authentication operations.
abstract class AuthRepository {
  /// Login with email/phone and password
  Future<Result<AuthState>> loginWithPassword(LoginCredentials credentials);

  /// Login with PIN (for POS terminals/kiosks)
  Future<Result<AuthState>> loginWithPin(PinLoginCredentials credentials);

  /// Sign up new user
  Future<Result<AuthState>> signUp(SignUpData data);

  /// Refresh authentication token
  Future<Result<AuthState>> refreshToken(String refreshToken);

  /// Request password reset
  Future<Result<void>> requestPasswordReset(String emailOrPhone);

  /// Verify code (OTP)
  Future<Result<void>> verifyCode({
    required String identifier,
    required String code,
  });

  /// Reset password with code
  Future<Result<void>> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  });

  /// Logout
  Future<Result<void>> logout();

  /// Get current user info (refresh from server)
  Future<Result<AuthState>> getCurrentUser();
}
