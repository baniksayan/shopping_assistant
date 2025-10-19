import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user_model.dart';
import '../../models/chat_history_model.dart';
import '../../models/search_history_model.dart';

class HiveService {
  static const String userBoxName = 'userBox';
  static const String settingsBoxName = 'settings';
  static const String chatHistoryBoxName = 'chatHistory';
  static const String searchHistoryBoxName = 'searchHistory';
  
  static Box<UserModel>? _userBox;
  static Box? _settingsBox;
  static Box<ChatHistoryModel>? _chatHistoryBox;
  static Box<SearchHistoryModel>? _searchHistoryBox;

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
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SearchHistoryModelAdapter());
    }
  }

  static Future<void> openBoxes() async {
    _userBox = await Hive.openBox<UserModel>(userBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
    _chatHistoryBox = await Hive.openBox<ChatHistoryModel>(chatHistoryBoxName);
    _searchHistoryBox = await Hive.openBox<SearchHistoryModel>(searchHistoryBoxName);
  }

  static Box<UserModel> get userBox {
    if (_userBox == null || !_userBox!.isOpen) {
      throw Exception('User box is not open.');
    }
    return _userBox!;
  }

  static Box get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw Exception('Settings box is not open.');
    }
    return _settingsBox!;
  }

  static Box<ChatHistoryModel> get chatHistoryBox {
    if (_chatHistoryBox == null || !_chatHistoryBox!.isOpen) {
      throw Exception('Chat history box is not open.');
    }
    return _chatHistoryBox!;
  }

  static Box<SearchHistoryModel> get searchHistoryBox {
    if (_searchHistoryBox == null || !_searchHistoryBox!.isOpen) {
      throw Exception('Search history box is not open.');
    }
    return _searchHistoryBox!;
  }

  // User methods
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

  // Theme methods
  static Future<void> saveSelectedTheme(String country) async {
    await settingsBox.put('selectedTheme', country);
  }

  static String getSelectedTheme() {
    return settingsBox.get('selectedTheme', defaultValue: 'India');
  }

  // Location methods
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

  // Profile methods
  static Future<void> updateProfileImage(String imagePath) async {
    final user = getCurrentUser();
    if (user != null) {
      user.profileImagePath = imagePath;
      await user.save();
    }
  }

  // Chat history methods
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

  // Search history methods
  static Future<void> saveSearchHistory(String productName, String productId) async {
    final existing = searchHistoryBox.get(productId);
    
    if (existing != null) {
      existing.searchCount += 1;
      existing.searchedAt = DateTime.now();
      await existing.save();
    } else {
      final searchHistory = SearchHistoryModel(
        productName: productName,
        productId: productId,
        searchedAt: DateTime.now(),
      );
      await searchHistoryBox.put(productId, searchHistory);
    }
  }

  static SearchHistoryModel? getLastSearchedProduct() {
    if (searchHistoryBox.isEmpty) return null;
    
    final searches = searchHistoryBox.values.toList()
      ..sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
    
    return searches.first;
  }

  static List<SearchHistoryModel> getAllSearchHistory() {
    return searchHistoryBox.values.toList()
      ..sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
  }

  static Future<void> markAsSearched() async {
    await settingsBox.put('has_searched', true);
  }

  static bool hasSearched() {
    return settingsBox.get('has_searched', defaultValue: false);
  }

  // Clear methods
  static Future<void> clearUserData() async {
    await userBox.clear();
  }

  static Future<void> closeBoxes() async {
    await _userBox?.close();
    await _settingsBox?.close();
    await _chatHistoryBox?.close();
    await _searchHistoryBox?.close();
  }
}
