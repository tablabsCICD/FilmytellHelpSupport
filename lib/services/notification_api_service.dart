import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationApiService {
  final ApiClient _apiClient;

  NotificationApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get current user's in-app notifications
  Future<List<AppNotification>> getNotifications({bool unreadOnly = false}) async {
    try {
      final responseJson = await _apiClient.get(
        ApiEndpoints.notifications,
        queryParameters: {'unreadOnly': unreadOnly},
      );

      if (responseJson != null && responseJson is Map<String, dynamic>) {
        final data = responseJson['data'];
        if (data is List) {
          return data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  /// Mark single notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiClient.patch(ApiEndpoints.notificationRead(notificationId));
    } catch (_) {}
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.patch(ApiEndpoints.notificationReadAll);
    } catch (_) {}
  }
}
