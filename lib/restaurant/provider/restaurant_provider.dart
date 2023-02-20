import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:recommend_restaurant/common/const/const_data.dart';
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

  Future<void> precacheFireStoreImage(BuildContext context) async {
    final uid = prefs.getString(FirestoreUserConstants.id);
    final data = await firebaseFirestore
        .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
        .doc(uid)
        .collection(FirestoreRestaurantConstants.pathRestaurantListCollection)
        .orderBy(FirestoreRestaurantConstants.createdAt, descending: true)
        .limit(firestoreDataLimit)
        .get();

    final List<QueryDocumentSnapshot> restaurantList = data.docs;

    for (int i = 0; i < restaurantList.length; i++) {
      DocumentSnapshot doc = restaurantList[i];

      final String? thumbnail = doc.get(FirestoreRestaurantConstants.thumbnail);
      if (thumbnail != null && thumbnail.isNotEmpty) {
        CachedNetworkImageProvider imageProvider = CachedNetworkImageProvider(
          thumbnail,
        );

        precacheImage(
          imageProvider,
          context,
        );
      }
    }
  }
}
