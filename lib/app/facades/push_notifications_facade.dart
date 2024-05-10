import 'dart:convert';

import 'package:dotenv/dotenv.dart';
import 'package:injectable/injectable.dart';

import '../logger/i_logger.dart';
import 'package:http/http.dart' as http;

@LazySingleton()
class PushNotificationsFacade {
  final ILogger log;

  PushNotificationsFacade({
    required this.log,
  });

  Future<void> sendMessage({
    required List<String?> devices,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final request = {
        'notification': {
          'body': body,
          'title': title,
        },
        'priority': 'high',
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
          'payload': payload,
        },
      };

      final firebaseKey = env['FIREBASE_PUSH_KEY'] ?? env['firebasePushKey'];

      if (firebaseKey == null) {
        log.error('Firebase key not found');
        return;
      }

      for (var device in devices) {
        if (device != null) {
          request['to'] = device;
          log.info('Sending notification to: $device');
          final result = await http.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            body: jsonEncode(request),
            headers: {
              'Authorization': 'key=$firebaseKey',
              'Content-Type': 'application/json',
            },
          );

          final responseData = jsonDecode(result.body);

          if (responseData['failure'] == 1) {
            log.error(
                'Error sending notification to: $device, the error was: ${responseData['results']?[0]}');
          } else {
            log.info('Notification sent sucessfully to: $device');
          }
        }
      }
    } catch (e, s) {
      log.error('Erro on send notification', e, s);
    }
  }
}
