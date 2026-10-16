import '../core/constants/api_endpoints.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/user_session.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepository({
    ApiClient? apiClient,
    StorageService? storageService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _storageService = storageService ?? StorageService();

  Future<UserSession?> getCurrentSession() async {
    await _storageService.init();
    final json = _storageService.getJson(AppConstants.keyUserSession);
    if (json != null && json is Map<String, dynamic>) {
      final session = UserSession.fromJson(json);
      ApiClient.currentAccessToken = session.accessToken;
      ApiClient.currentRefreshToken = session.refreshToken;
      return session;
    }
    return null;
  }

  /// Login strictly via backend POST /api/v1/auth/login.
  Future<UserSession> login({required String email, required String password}) async {
    await _storageService.init();

    final responseJson = await _apiClient.post(
      ApiEndpoints.login,
      body: {
        'usernameOrEmail': email.trim(),
        'password': password.trim(),
      },
      retryOnAuthError: false,
    );

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      final data = responseJson['data'] ?? responseJson;
      final session = UserSession.fromJson(data as Map<String, dynamic>);

      ApiClient.currentAccessToken = session.accessToken;
      ApiClient.currentRefreshToken = session.refreshToken;

      await _storageService.setJson(AppConstants.keyUserSession, session.toJson());
      await _storageService.setString(AppConstants.keyAccessToken, session.accessToken);
      await _storageService.setString(AppConstants.keyRefreshToken, session.refreshToken);

      return session;
    }

    throw ApiException(message: 'Authentication failed. Please check your credentials.');
  }

  Future<bool> refreshToken() async {
    await _storageService.init();
    final refreshToken = ApiClient.currentRefreshToken ??
        _storageService.getString(AppConstants.keyRefreshToken);

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final responseJson = await _apiClient.post(
        ApiEndpoints.refresh,
        body: {'refreshToken': refreshToken},
        retryOnAuthError: false,
      );

      if (responseJson != null && responseJson is Map<String, dynamic>) {
        final data = responseJson['data'] ?? responseJson;
        if (data is Map && data.containsKey('accessToken')) {
          final newAccessToken = data['accessToken'].toString();
          ApiClient.currentAccessToken = newAccessToken;
          await _storageService.setString(AppConstants.keyAccessToken, newAccessToken);

          if (data.containsKey('refreshToken') && data['refreshToken'] != null) {
            final newRefreshToken = data['refreshToken'].toString();
            ApiClient.currentRefreshToken = newRefreshToken;
            await _storageService.setString(AppConstants.keyRefreshToken, newRefreshToken);
          }

          // Update current session object in storage
          final currentSession = await getCurrentSession();
          if (currentSession != null) {
            final updatedSession = currentSession.copyWith(
              accessToken: newAccessToken,
              refreshToken: ApiClient.currentRefreshToken,
            );
            await _storageService.setJson(AppConstants.keyUserSession, updatedSession.toJson());
          }
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.init();
    ApiClient.currentAccessToken = null;
    ApiClient.currentRefreshToken = null;
    await _storageService.remove(AppConstants.keyUserSession);
    await _storageService.remove(AppConstants.keyAccessToken);
    await _storageService.remove(AppConstants.keyRefreshToken);
  }
}
