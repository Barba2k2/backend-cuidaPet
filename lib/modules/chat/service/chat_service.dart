import 'package:cuidapet_api/app/facades/push_notifications_facade.dart';
import 'package:cuidapet_api/entities/chat.dart';
import 'package:cuidapet_api/modules/chat/view_models/chat_notify_view_model.dart';
import 'package:injectable/injectable.dart';

import '../data/i_chat_repository.dart';
import 'i_chat_service.dart';

@LazySingleton(as: IChatService)
class ChatService implements IChatService {
  final IChatRepository repository;
  final PushNotificationsFacade pushNotificationsFacade;

  ChatService({
    required this.repository,
    required this.pushNotificationsFacade,
  });

  @override
  Future<int> startChat(int scheduleId) => repository.startChat(scheduleId);

  @override
  Future<void> notifyChat(ChatNotifyViewModel model) async {
    final chat = await repository.findChatById(model.chat);

    if (chat != null) {
      switch (model.notificationUserType) {
        case NotificationUserType.user:
          _notifyUser(
            chat.userDeviceToken?.tokens,
            model,
            chat,
          );
          break;
        case NotificationUserType.supplier:
          _notifyUser(
            chat.supplierDeviceToken?.tokens,
            model,
            chat,
          );
          break;
        default:
          throw Exception('Notification type not found');
      }
    }

    throw UnimplementedError();
  }

  void _notifyUser(
    List<String?>? tokens,
    ChatNotifyViewModel model,
    Chat chat,
  ) {
    final payload = <String, dynamic>{
      'type': 'CHAT MESSAGE',
      'chat': {
        'id': chat.id,
        'nome': chat.name,
        'fornecedor': {
          'nome': chat.supplier.name,
          'logo': chat.supplier.logo,
        }
      }
    };

    pushNotificationsFacade.sendMessage(
      devices: tokens ?? [],
      title: 'Nova mensagem',
      body: model.message,
      payload: payload,
    );
  }

  @override
  Future<List<Chat>> getChatsByUser(int user) => repository.getChatByUser(user);
  
  @override
  Future<List<Chat>> getChatsBySupplier(int user) => repository.getChatsBySupplier(user);
}
