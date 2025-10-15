import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user_model.dart';
import '../../models/chat_history_model.dart';

class HiveService {
  static const String userBoxName = 'userBox';
  static const String settingsBoxName = 'settings';
  static const String chatHistoryBoxName = 'chatHistory';
  
  static Box<UserModel>? _userBox;
  static Box? _settingsBox;
  static Box<ChatHistoryModel>? _chatHistoryBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChatHistoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ChatMessageAdapter());
    }
  }

  static Future<void> openBoxes() async {
    _userBox = await Hive.openBox<UserModel>(userBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
    _chatHistoryBox = await Hive.openBox<ChatHistoryModel>(chatHistoryBoxName);
  }

  static Box<UserModel> get userBox {
    if (_userBox == null || !_userBox!.isOpen) {
      throw Exception('User box is not open. Call openBoxes() first.');
    }
    return _userBox!;
  }

  static Box get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw Exception('Settings box is not open. Call openBoxes() first.');
    }
    return _settingsBox!;
  }

  static Box<ChatHistoryModel> get chatHistoryBox {
    if (_chatHistoryBox == null || !_chatHistoryBox!.isOpen) {
      throw Exception('Chat history box is not open. Call openBoxes() first.');
    }
    return _chatHistoryBox!;
  }

  static Future<void> saveUser(UserModel user) async {
    await userBox.put('currentUser', user);
  }

  static UserModel? getCurrentUser() {
    return userBox.get('currentUser');
  }

  static bool isUserLoggedIn() {
    final user = getCurrentUser();
    return user != null && user.isLoggedIn;
  }

  static Future<void> updateLoginStatus(bool status) async {
    final user = getCurrentUser();
    if (user != null) {
      user.isLoggedIn = status;
      await user.save();
    }
  }

  static Future<void> saveSelectedTheme(String country) async {
    await settingsBox.put('selectedTheme', country);
  }

  static String getSelectedTheme() {
    return settingsBox.get('selectedTheme', defaultValue: 'India');
  }

  static Future<void> saveLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    final user = getCurrentUser();
    if (user != null) {
      user.latitude = latitude;
      user.longitude = longitude;
      user.address = address;
      await user.save();
    }
  }

  static Future<void> updateProfileImage(String imagePath) async {
    final user = getCurrentUser();
    if (user != null) {
      user.profileImagePath = imagePath;
      await user.save();
    }
  }

  static Future<void> saveChatHistory(ChatHistoryModel chat) async {
    await chatHistoryBox.put(chat.id, chat);
  }

  static List<ChatHistoryModel> getAllChatHistory() {
    return chatHistoryBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static Future<void> deleteChatHistory(String id) async {
    await chatHistoryBox.delete(id);
  }

  static Future<void> clearUserData() async {
    await userBox.clear();
  }

  static Future<void> closeBoxes() async {
    await _userBox?.close();
    await _settingsBox?.close();
    await _chatHistoryBox?.close();
  }
}
