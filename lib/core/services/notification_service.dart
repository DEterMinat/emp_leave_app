import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService extends ChangeNotifier {
  HubConnection? _hubConnection;
  bool _isConnected = false;
  void Function(String title, String message)? onNotificationReceived;

  bool get isConnected => _isConnected;

  Future<void> initSignalR() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.token);
    final userId = prefs.getString(StorageKeys.userId);
    final role = prefs.getString(StorageKeys.roleName);

    if (token == null || userId == null) return;

    final hubUrl = "${ApiConstants.baseUrl}/notificationHub";

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(accessTokenFactory: () async => token),
        )
        .withAutomaticReconnect()
        .build();

    _hubConnection?.onclose(({error}) {
      _isConnected = false;
      notifyListeners();
      debugPrint("❌ SignalR Connection closed: $error");
    });

    _hubConnection?.onreconnecting(({error}) {
      _isConnected = false;
      notifyListeners();
      debugPrint("🔄 SignalR Reconnecting...");
    });

    _hubConnection?.onreconnected(({connectionId}) {
      _isConnected = true;
      notifyListeners();
      debugPrint("✅ SignalR Reconnected.");
    });

    // Listen for notifications
    _hubConnection?.on("ReceiveNotification", (arguments) {
      if (arguments != null && arguments.length >= 2) {
        final title = arguments[0] as String;
        final message = arguments[1] as String;
        _showLocalNotification(title, message);
        onNotificationReceived?.call(title, message);
      }
    });

    try {
      await _hubConnection?.start();
      _isConnected = true;
      notifyListeners();
      debugPrint("✅ SignalR Connected.");

      // Join user group
      await _hubConnection?.invoke("JoinUserGroup", args: [userId]);

      // Join Managers group if applicable
      final normalizedRole = role?.toLowerCase();
      if (normalizedRole == 'manager' ||
          normalizedRole == 'hr' ||
          normalizedRole == 'admin') {
        await _hubConnection?.invoke("JoinUserGroup", args: ["Managers"]);
      }
    } catch (e) {
      debugPrint("❌ SignalR Connection Error: $e");
    }
  }

  void _showLocalNotification(String title, String message) {
    // In a real app, use flutter_local_notifications
    // For now, we can use a callback or a stream to show a snackbar in the UI
    debugPrint("🔔 Notification Received: $title - $message");
  }

  Future<void> stopConnection() async {
    await _hubConnection?.stop();
    _isConnected = false;
    notifyListeners();
  }
}
