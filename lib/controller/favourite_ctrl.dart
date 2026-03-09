import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/favourite/favourite_model.dart';

class FavouriteCtrl extends GetxController {
  static const String boxName = 'favourite_box';
  late Box<FavouriteModel> _box;
  
  var favourites = <FavouriteModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _box = Hive.box<FavouriteModel>(boxName);
    loadFavourites();
  }

  void loadFavourites() {
    favourites.value = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  bool isFavourite(int id, String category) {
    return _box.containsKey("${category}_$id");
  }

  Future<void> toggleFavourite(int id, String category) async {
    final key = "${category}_$id";
    if (_box.containsKey(key)) {
      await _box.delete(key);
    } else {
      final fav = FavouriteModel(
        targetId: id,
        category: category,
        createdAt: DateTime.now(),
      );
      await _box.put(key, fav);
    }
    loadFavourites();
    update(); // Update UI listeners
  }

  Future<void> updateNote(int id, String category, String note) async {
    final key = "${category}_$id";
    final fav = _box.get(key);
    if (fav != null) {
      fav.notes = note;
      await fav.save(); // FavouriteModel extends HiveObject
      loadFavourites();
      update();
    }
  }

  List<FavouriteModel> getRecent(int count) {
    return favourites.take(count).toList();
  }

  List<FavouriteModel> getByCategory(String category) {
    return favourites.where((f) => f.category == category).toList();
  }
}
