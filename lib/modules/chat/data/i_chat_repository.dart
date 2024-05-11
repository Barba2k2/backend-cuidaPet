import '../../../entities/chat.dart';

abstract class IChatRepository {
  Future<int> startChat(int scheduleId);
  Future<Chat?> findChatById(int chatId);
  Future<List<Chat>> getChatByUser(int user);
  Future<List<Chat>> getChatsBySupplier(int supplier);
}
