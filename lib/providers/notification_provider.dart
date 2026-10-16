import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationApiService _apiService;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  NotificationProvider({NotificationApiService? apiService})
      : _apiService = apiService ?? NotificationApiService();

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  Future<void> loadNotifications({bool unreadOnly = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final list = await _apiService.getNotifications(unreadOnly: unreadOnly);
      _notifications = list;
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
      notifyListeners();
    }
    await _apiService.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
    notifyListeners();
    await _apiService.markAllAsRead();
  }
}
