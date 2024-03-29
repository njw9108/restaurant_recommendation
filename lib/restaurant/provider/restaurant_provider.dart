import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recommend_restaurant/common/const/firestore_constants.dart';
import 'package:recommend_restaurant/restaurant/model/restaurant_model.dart';

import '../../common/repository/firebase_repository.dart';
import '../../user/provider/auth_provider.dart';

enum SortType {
  dateDescending,
  dateAscending,
  ratingDescending,
  ratingAscending,
  nameDescending,
  nameAscending,
}

class RestaurantProvider with ChangeNotifier {
  final FlutterSecureStorage secureStorage;
  final FirebaseRepository firebaseRepository;
  final AuthProvider authProvider;

  RestaurantProvider({
    required this.secureStorage,
    required this.firebaseRepository,
    required this.authProvider,
  }) {
    authProvider.authStream.listen((event) {
      getSortTypeFromFirebase();
      _getTagCategoryListFromFirebase();
    });
  }

  SortType _sortType = SortType.dateDescending;
  String orderKey = '';
  bool descending = false;
  bool _curFavorite = false;
  List<String> _tagList = [];
  List<String> _categoryList = [];

  SortType get sortType => _sortType;

  set sortType(SortType value) {
    _sortType = value;
    saveSortTypeToFirebase();
    final getValue = getSortType();
    orderKey = getValue['key'];
    descending = getValue['descending'];
    notifyListeners();
  }

  bool get curFavorite => _curFavorite;

  set curFavorite(bool value) {
    _curFavorite = value;
    notifyListeners();
  }

  List<String> get tagList => _tagList;

  set tagList(List<String> value) {
    _tagList = value.toList();
    saveTagListToFirebase(_tagList);
    notifyListeners();
  }

  List<String> get categoryList => _categoryList;

  set categoryList(List<String> value) {
    _categoryList = value.toList();
    saveCategoryListToFirebase(_categoryList);
    notifyListeners();
  }

  Future<void> saveSortTypeToFirebase() async {
    try {
      await firebaseRepository.saveRestaurantToFirebase(
        collectionId: FirestoreRestaurantConstants.pathSortTypeCollection,
        docId: FirestoreRestaurantConstants.pathSortTypeCollection,
        data: {
          FirestoreRestaurantConstants.pathSortTypeCollection: _sortType.index,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getSortTypeFromFirebase() async {
    try {
      final data = await firebaseRepository.getRestaurantFromFirebase(
        collectionId: FirestoreRestaurantConstants.pathSortTypeCollection,
        docId: FirestoreRestaurantConstants.pathSortTypeCollection,
      );
      _sortType =
          data?[FirestoreRestaurantConstants.pathSortTypeCollection] == null
              ? SortType.dateDescending
              : SortType.values[
                  data?[FirestoreRestaurantConstants.pathSortTypeCollection]];
      final value = getSortType();
      orderKey = value['key'];
      descending = value['descending'];

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Stream<QuerySnapshot> getRestaurantStream({
    required int limit,
    String orderKey = FirestoreRestaurantConstants.createdAt,
    bool descending = true,
  }) {
    return firebaseRepository.getRestaurantStream(
      limit: limit,
      orderKey: orderKey,
      descending: descending,
      uid: authProvider.userModel?.id ?? '',
    );
  }

  Stream<QuerySnapshot> getFavoriteRestaurantStream({
    required int limit,
  }) {
    return firebaseRepository.getSearchRestaurantStream(
      limit: limit,
      collection: 'isFavorite',
      isEqualTo: true,
      uid: authProvider.userModel?.id ?? '',
    );
  }

  Stream<QuerySnapshot> getNotVisitedRestaurantStream({
    required int limit,
  }) {
    return firebaseRepository.getSearchRestaurantStream(
      limit: limit,
      collection: 'isVisited',
      isEqualTo: false,
      uid: authProvider.userModel?.id ?? '',
    );
  }

  Stream<QuerySnapshot> searchTagRestaurantStream({
    required int limit,
    required List<String> tags,
  }) {
    return firebaseRepository.searchTagRestaurantStream(
      limit: limit,
      collection: 'tags',
      query: tags,
      uid: authProvider.userModel?.id ?? '',
    );
  }

  Stream<QuerySnapshot> searchCategoryRestaurantStream({
    required int limit,
    required List<String> categories,
  }) {
    return firebaseRepository.searchCategoryRestaurantStream(
      limit: limit,
      collection: 'category',
      query: categories,
      uid: authProvider.userModel?.id ?? '',
    );
  }

  Future<void> saveCategoryListToFirebase(List<String> value) async {
    try {
      await firebaseRepository.saveRestaurantToFirebase(
        collectionId:
            FirestoreRestaurantConstants.pathTagCategoryListCollection,
        docId: FirestoreRestaurantConstants.pathTagCategoryListCollection,
        data: {
          FirestoreRestaurantConstants.pathCategoryList: value,
          FirestoreRestaurantConstants.pathTagList: tagList,
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveTagListToFirebase(List<String> value) async {
    try {
      await firebaseRepository.saveRestaurantToFirebase(
        collectionId:
            FirestoreRestaurantConstants.pathTagCategoryListCollection,
        docId: FirestoreRestaurantConstants.pathTagCategoryListCollection,
        data: {
          FirestoreRestaurantConstants.pathTagList: value,
          FirestoreRestaurantConstants.pathCategoryList: categoryList,
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getTagCategoryListFromFirebase() async {
    try {
      final temp = await firebaseRepository.getRestaurantFromFirebase(
        collectionId:
            FirestoreRestaurantConstants.pathTagCategoryListCollection,
        docId: FirestoreRestaurantConstants.pathTagCategoryListCollection,
      );

      _categoryList = temp?[FirestoreRestaurantConstants.pathCategoryList]
              ?.cast<String>() ??
          [];
      _tagList =
          temp?[FirestoreRestaurantConstants.pathTagList]?.cast<String>() ?? [];

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteTagItemFromFirebase(String item) async {
    _tagList.remove(item);
    tagList = List.from(_tagList);
  }

  Future<void> deleteCategoryItemFromFirebase(String item) async {
    _categoryList.remove(item);
    categoryList = List.from(_categoryList);
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

  Future<void> toggleFavorite(RestaurantModel model) async {
    _curFavorite = !_curFavorite;
    notifyListeners();
    final newModel = model.copyWith(
      isFavorite: _curFavorite,
    );

    await firebaseRepository.saveRestaurantToFirebase(
      collectionId: FirestoreRestaurantConstants.pathRestaurantListCollection,
      docId: newModel.id!,
      data: newModel.toJson(),
    );
  }

  // Future<void> precacheFireStoreImage(BuildContext context) async {
  //   final uid = prefs.getString(FirestoreUserConstants.id);
  //   final data = await firebaseFirestore
  //       .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
  //       .doc(uid)
  //       .collection(FirestoreRestaurantConstants.pathRestaurantListCollection)
  //       .orderBy(FirestoreRestaurantConstants.createdAt, descending: true)
  //       .limit(firestoreDataLimit)
  //       .get();
  //
  //   final List<QueryDocumentSnapshot> restaurantList = data.docs;
  //
  //   for (int i = 0; i < restaurantList.length; i++) {
  //     DocumentSnapshot doc = restaurantList[i];
  //
  //     final String? thumbnail = doc.get(FirestoreRestaurantConstants.thumbnail);
  //     if (thumbnail != null && thumbnail.isNotEmpty) {
  //       CachedNetworkImageProvider imageProvider = CachedNetworkImageProvider(
  //         thumbnail,
  //       );
  //
  //       precacheImage(
  //         imageProvider,
  //         context,
  //       );
  //     }
  //   }
  // }

  Future<void> deleteRestaurantFromFirebase({
    required String restaurantId,
    required List<String> imageIdList,
  }) async {
    try {
      await firebaseRepository.deleteRestaurantFromFirebase(
        restaurantId: restaurantId,
        imageIdList: imageIdList,
      );
    } catch (e) {
      print(e);
    }
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
