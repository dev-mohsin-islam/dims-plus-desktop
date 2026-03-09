import 'package:hive/hive.dart';

part 'favourite_model.g.dart';

@HiveType(typeId: 10)
class FavouriteModel extends HiveObject {
  @HiveField(0)
  final int targetId;

  @HiveField(1)
  final String category; // 'brand', 'generic', etc.

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  String? notes; // 👈 Individual note for this item

  FavouriteModel({
    required this.targetId,
    required this.category,
    required this.createdAt,
    this.notes,
  });

  // Unique key generator
  String get uniqueKey => "${category}_$targetId";
}
