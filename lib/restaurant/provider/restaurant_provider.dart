import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:recommend_restaurant/common/const/const_data.dart';
import 'package:recommend_restaurant/common/const/firestore_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SortType {
  dateDescending,
  dateAscending,
  ratingDescending,
  ratingAscending,
  nameDescending,
  nameAscending,
}

class RestaurantProvider with ChangeNotifier {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final SharedPreferences prefs;

  RestaurantProvider({
    required this.prefs,
  }) {
    getFavoriteRestaurantListFromFirebase();
    getSortTypeFromFirebase();
  }

  List<String> _favoriteRestaurantList = [];
  SortType _sortType = SortType.dateDescending;
  String orderKey = '';
  bool descending = false;

  List<String> get favoriteRestaurantList => _favoriteRestaurantList;

  set favoriteRestaurantList(List<String> value) {
    _favoriteRestaurantList = value;
    saveFavoriteRestaurantListToFirebase();
    notifyListeners();
  }

  SortType get sortType => _sortType;

  set sortType(SortType value) {
    _sortType = value;
    saveSortTypeToFirebase();
    final getValue = getSortType();
    orderKey = getValue['key'];
    descending = getValue['descending'];
    notifyListeners();
  }

  Future<void> saveFavoriteRestaurantListToFirebase() async {
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

  Future<void> getFavoriteRestaurantListFromFirebase() async {
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

  Future<void> saveSortTypeToFirebase() async {
    try {
      final uid = prefs.getString(FirestoreUserConstants.id);
      await firebaseFirestore
          .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
          .doc(uid)
          .collection(FirestoreRestaurantConstants.pathSortTypeCollection)
          .doc(FirestoreRestaurantConstants.pathSortTypeCollection)
          .set(
        {
          FirestoreRestaurantConstants.pathSortTypeCollection: _sortType.index,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getSortTypeFromFirebase() async {
    final uid = prefs.getString(FirestoreUserConstants.id);
    final data = await firebaseFirestore
        .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
        .doc(uid)
        .collection(FirestoreRestaurantConstants.pathSortTypeCollection)
        .doc(FirestoreRestaurantConstants.pathSortTypeCollection)
        .get();
    final temp = data.data();

    _sortType = temp?[FirestoreRestaurantConstants.pathSortTypeCollection] ==
            null
        ? SortType.dateDescending
        : SortType
            .values[temp?[FirestoreRestaurantConstants.pathSortTypeCollection]];
    final value = getSortType();
    orderKey = value['key'];
    descending = value['descending'];

    notifyListeners();
  }

  Stream<QuerySnapshot> getRestaurantStream({
    required int limit,
    required String orderKey,
    required bool descending,
  }) {
    final uid = prefs.getString(FirestoreUserConstants.id);

    return firebaseFirestore
        .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
        .doc(uid)
        .collection(FirestoreRestaurantConstants.pathRestaurantListCollection)
        .orderBy(orderKey, descending: descending)
        .limit(limit)
        .snapshots();
  }

  Map<String, dynamic> getSortType() {
    switch (_sortType) {
      case SortType.dateAscending:
        return {
          'key': FirestoreRestaurantConstants.createdAt,
          'descending': false,
        };
      case SortType.dateDescending:
        return {
          'key': FirestoreRestaurantConstants.createdAt,
          'descending': true,
        };
      case SortType.ratingAscending:
        return {
          'key': FirestoreRestaurantConstants.rating,
          'descending': false,
        };
      case SortType.ratingDescending:
        return {
          'key': FirestoreRestaurantConstants.rating,
          'descending': true,
        };
      case SortType.nameAscending:
        return {
          'key': FirestoreRestaurantConstants.name,
          'descending': false,
        };
      case SortType.nameDescending:
        return {
          'key': FirestoreRestaurantConstants.name,
          'descending': true,
        };
      default:
        return {
          'key': FirestoreRestaurantConstants.createdAt,
          'descending': true,
        };
    }
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

  String sortTypeToString(SortType type) {
    switch (type) {
      case SortType.dateDescending:
        return '날짜 내림차순';
      case SortType.dateAscending:
        return '날짜 오름차순';
      case SortType.ratingDescending:
        return '별점 내림차순';
      case SortType.ratingAscending:
        return '별점 오름차순';
      case SortType.nameDescending:
        return '이름 내림차순';
      case SortType.nameAscending:
        return '이름 오름차순';
    }
  }

  SortType stringToSortType(String value) {
    switch (value) {
      case '날짜 내림차순':
        return SortType.dateDescending;
      case '날짜 오름차순':
        return SortType.dateAscending;
      case '별점 내림차순':
        return SortType.ratingDescending;
      case '별점 오름차순':
        return SortType.ratingAscending;
      case '이름 내림차순':
        return SortType.nameDescending;
      case '이름 오름차순':
        return SortType.nameAscending;
      default:
        return SortType.dateDescending;
    }
  }
}
