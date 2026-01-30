import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/notification_service.dart';

final notificationServiceProvider = ChangeNotifierProvider(
  (ref) => NotificationService(),
);
