import 'package:cuidapet_api/modules/chat/view_models/chat_notify_view_model.dart';
import 'package:injectable/injectable.dart';

import '../data/i_chat_repository.dart';
import 'i_chat_service.dart';

@LazySingleton(as: IChatService)
class ChatService implements IChatService {
  final IChatRepository repository;

  ChatService({
    required this.repository,
  });

  @override
  Future<int> startChat(int scheduleId) => repository.startChat(scheduleId);

  @override
  Future<void> notifyChat(ChatNotifyViewModel model) async {
    final chat = await repository.findChatById(model.chat);

    switch (model.notificationUserType) {
      case NotificationUserType.user:
        // TODO: Handle this case.
        break;
      case NotificationUserType.supplier:
        // TODO: Handle this case.
        break;
      default:
        throw Exception('Notification type not found');
    }

    throw UnimplementedError();
  }
}
