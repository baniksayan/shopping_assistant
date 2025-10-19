import 'package:hive/hive.dart';

part 'search_history_model.g.dart';

@HiveType(typeId: 3)
class SearchHistoryModel extends HiveObject {
  @HiveField(0)
  String productName;

  @HiveField(1)
  String productId;

  @HiveField(2)
  DateTime searchedAt;

  @HiveField(3)
  int searchCount;

  SearchHistoryModel({
    required this.productName,
    required this.productId,
    required this.searchedAt,
    this.searchCount = 1,
  });
}
