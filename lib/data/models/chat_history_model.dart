import 'package:hive/hive.dart';

part 'chat_history_model.g.dart';

@HiveType(typeId: 1)
class ChatHistoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String lastMessage;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  List<ChatMessage> messages;

  ChatHistoryModel({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.messages,
  });
}

@HiveType(typeId: 2)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String message;

  @HiveField(1)
  bool isUser;

  @HiveField(2)
  DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}
