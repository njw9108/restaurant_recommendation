import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:recommend_restaurant/common/const/const_data.dart';
import 'package:recommend_restaurant/common/const/firestore_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantProvider with ChangeNotifier {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final SharedPreferences prefs;

  RestaurantProvider({
    required this.prefs,
  }) {
    getFavoriteRestaurantList();
  }

  List<String> _favoriteRestaurantList = [];

  List<String> get favoriteRestaurantList => _favoriteRestaurantList;

  set favoriteRestaurantList(List<String> value) {
    _favoriteRestaurantList = value;
    saveFavoriteRestaurantList();
    notifyListeners();
  }

  Future<void> saveFavoriteRestaurantList() async {
    try {
      final uid = prefs.getString(FirestoreUserConstants.id);
      await firebaseFirestore
          .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
          .doc(uid)
          .collection(FirestoreRestaurantConstants.pathFavoriteListCollection)
          .doc(FirestoreRestaurantConstants.pathFavoriteListCollection)
          .set(
        {
          FirestoreRestaurantConstants.pathFavoriteListCollection:
              _favoriteRestaurantList,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getFavoriteRestaurantList() async {
    final uid = prefs.getString(FirestoreUserConstants.id);
    final data = await firebaseFirestore
        .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
        .doc(uid)
        .collection(FirestoreRestaurantConstants.pathFavoriteListCollection)
        .doc(FirestoreRestaurantConstants.pathFavoriteListCollection)
        .get();
    final temp = data.data();

    _favoriteRestaurantList =
        temp?[FirestoreRestaurantConstants.pathFavoriteListCollection]
                ?.cast<String>() ??
            [];
    notifyListeners();
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

  Future<void> deleteRestaurantFromFirebase({
    required String restaurantId,
    required List<String> imageIdList,
  }) async {
    final uid = prefs.getString(FirestoreUserConstants.id);
    //delete image from firebase storage
    for (int i = 0; i < imageIdList.length; i++) {
      final path = 'restaurant/$uid/$restaurantId/${imageIdList[i]}';
      final storageReference = FirebaseStorage.instance.ref().child(path);
      await storageReference.delete();
    }

    //delete data from firebase store
    await firebaseFirestore
        .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
        .doc(uid)
        .collection(FirestoreRestaurantConstants.pathRestaurantListCollection)
        .doc(restaurantId)
        .delete();
  }
}
