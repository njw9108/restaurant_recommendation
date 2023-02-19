import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recommend_restaurant/common/const/firestore_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantProvider {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final SharedPreferences prefs;

  RestaurantProvider({
    required this.prefs,
  });

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
