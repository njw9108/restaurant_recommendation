import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recommend_restaurant/common/const/firestore_constants.dart';
import 'package:recommend_restaurant/restaurant/model/restaurant_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantProvider {
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  RestaurantProvider({
    required this.prefs,
    required this.firebaseFirestore,
  });

  Future<void> saveRestaurantModelToFirebase(RestaurantModel model) async {
    try {
      final uid = prefs.getString(FirestoreUserConstants.id);
      await firebaseFirestore
          .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
          .doc(uid)
          .collection(FirestoreRestaurantConstants.pathRestaurantListCollection)
          .doc()
          .set(
        {
          FirestoreRestaurantConstants.name: model.name,
          FirestoreRestaurantConstants.thumbnail: model.thumbnail,
          FirestoreRestaurantConstants.restaurantType: model.restaurantType,
          FirestoreRestaurantConstants.rating: model.rating,
          FirestoreRestaurantConstants.comment: model.comment,
          FirestoreRestaurantConstants.images: model.images,
          FirestoreRestaurantConstants.categories: model.categories,
          FirestoreRestaurantConstants.address: model.address,
          FirestoreRestaurantConstants.createdAt:
              DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> getRestaurantStream(int limit) {
    final uid = prefs.getString(FirestoreUserConstants.id);
    return firebaseFirestore
        .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
        .doc(uid)
        .collection(FirestoreRestaurantConstants.pathRestaurantListCollection)
        .orderBy(FirestoreRestaurantConstants.createdAt, descending: true)
        .limit(limit)
        .snapshots();
  }
}
