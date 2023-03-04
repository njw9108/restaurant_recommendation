import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../restaurant/model/restaurant_model.dart';
import '../const/firestore_constants.dart';

class FirebaseRepository {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  FirebaseRepository({
    required this.prefs,
  });

  Future<void> saveRestaurantToFirebase({
    required String collectionId,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final uid = prefs.getString(FirestoreUserConstants.uid);
      await firebaseFirestore
          .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
          .doc(uid)
          .collection(collectionId)
          .doc(docId)
          .set(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getRestaurantFromFirebase({
    required String collectionId,
    required String docId,
  }) async {
    try {
      final uid = prefs.getString(FirestoreUserConstants.uid);
      final data = await firebaseFirestore
          .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
          .doc(uid)
          .collection(collectionId)
          .doc(docId)
          .get();
      return data.data();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRestaurantToFirebase({
    required String collectionId,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final uid = prefs.getString(FirestoreUserConstants.uid);

      await firebaseFirestore
          .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
          .doc(uid)
          .collection(collectionId)
          .doc(docId)
          .update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRestaurantFromFirebase({
    required String restaurantId,
    required List<String> imageIdList,
  }) async {
    final uid = prefs.getString(FirestoreUserConstants.uid);
    //delete image from firebase storage
    for (int i = 0; i < imageIdList.length; i++) {
      await deleteImageFromStorage(
        restaurantId: restaurantId,
        imageId: imageIdList[i],
      );
    }

    //delete data from firebase store
    await firebaseFirestore
        .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
        .doc(uid)
        .collection(FirestoreRestaurantConstants.pathRestaurantListCollection)
        .doc(restaurantId)
        .delete();
  }

  Future<ImageIdUrlData> saveImageToStorage({
    required String restaurantId,
    required File file,
  }) async {
    final uid = prefs.getString(FirestoreUserConstants.uid);
    const uuid = Uuid();

    try {
      final String imageId = uuid.v4();
      final path =
          '${FirestoreRestaurantConstants.pathRestaurantCollection}/$uid/$restaurantId/$imageId';
      final storageReference = FirebaseStorage.instance.ref().child(path);
      final uploadTask = await storageReference.putFile(
          file, SettableMetadata(contentType: 'image/jpg'));

      final url = await uploadTask.ref.getDownloadURL();
      return ImageIdUrlData(
        id: imageId,
        url: url,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteImageFromStorage({
    required String restaurantId,
    required String imageId,
  }) async {
    final uid = prefs.getString(FirestoreUserConstants.uid);
    final path =
        '${FirestoreRestaurantConstants.pathRestaurantCollection}/$uid/$restaurantId/$imageId';
    final storageReference = FirebaseStorage.instance.ref().child(path);
    await storageReference.delete();
  }

  Stream<QuerySnapshot> getRestaurantStream({
    required int limit,
    required String orderKey,
    required bool descending,
  }) {
    final uid = prefs.getString(FirestoreUserConstants.uid);

    return firebaseFirestore
        .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
        .doc(uid)
        .collection(FirestoreRestaurantConstants.pathRestaurantListCollection)
        .orderBy(orderKey, descending: descending)
        .limit(limit)
        .snapshots();
  }

  Stream<QuerySnapshot> getSearchRestaurantStream({
    required int limit,
    required String collection,
    required bool isEqualTo,
  }) {
    final uid = prefs.getString(FirestoreUserConstants.uid);

    return firebaseFirestore
        .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
        .doc(uid)
        .collection(FirestoreRestaurantConstants.pathRestaurantListCollection)
        .where(
          collection,
          isEqualTo: isEqualTo,
        )
        .limit(limit)
        .snapshots();
  }

  // Stream<QuerySnapshot> getNotVisitedRestaurantStream({
  //   required int limit,
  // }) {
  //   final uid = prefs.getString(FirestoreUserConstants.id);
  //
  //   return firebaseFirestore
  //       .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
  //       .doc(uid)
  //       .collection(FirestoreRestaurantConstants.pathRestaurantListCollection)
  //       .where(
  //     'isVisited',
  //     isEqualTo: false,
  //   )
  //       .limit(limit)
  //       .snapshots();
  // }

  Stream<QuerySnapshot> searchTagRestaurantStream({
    required int limit,
    required String collection,
    required List<String> query,
  }) {
    final uid = prefs.getString(FirestoreUserConstants.uid);

    return firebaseFirestore
        .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
        .doc(uid)
        .collection(FirestoreRestaurantConstants.pathRestaurantListCollection)
        .where(
          collection,
          arrayContainsAny: query,
        )
        .limit(limit)
        .snapshots();
  }

  Stream<QuerySnapshot> searchCategoryRestaurantStream({
    required int limit,
    required String collection,
    required List<String> query,
  }) {
    final uid = prefs.getString(FirestoreUserConstants.uid);

    return firebaseFirestore
        .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
        .doc(uid)
        .collection(FirestoreRestaurantConstants.pathRestaurantListCollection)
        .where(
          collection,
          whereIn: query,
        )
        .limit(limit)
        .snapshots();
  }
}
