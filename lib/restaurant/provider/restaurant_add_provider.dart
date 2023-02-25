import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/const/firestore_constants.dart';
import 'package:recommend_restaurant/common/model/pagination_model.dart';
import 'package:recommend_restaurant/common/provider/pagination_provider.dart';
import 'package:recommend_restaurant/restaurant/model/address_model.dart';
import 'package:recommend_restaurant/restaurant/model/restaurant_model.dart';
import 'package:recommend_restaurant/restaurant/repository/kakao_address_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class RestaurantAddProvider
    extends PaginationProvider<AddressModel, KakaoAddressRepository> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final SharedPreferences prefs;

  RestaurantAddProvider({
    required this.prefs,
    required super.repository,
  }) {
    _getTagCategoryListFromFirebase();
  }

  final _addressModelStreamController =
      StreamController<AddressModel>.broadcast();

  Stream<AddressModel> get addressModelStream =>
      _addressModelStreamController.stream.asBroadcastStream();

  AddressModel? _curAddressModel;
  String query = '';
  int _thumbnailIndex = 0;

  bool _isVisited = false;
  List<String> _tagList = [];
  List<String> _categoryList = [];
  final List<String> _deletedNetworkImageList = [];
  List<ImageIdUrlData> _networkImage = [];
  List<File> _images = [];
  String _category = '';
  List<String> _tags = [];
  String _name = '';
  double _rating = 1;
  String _comment = '';
  String _address = '';

  String get name => _name;

  set name(String value) {
    _name = value;
    notifyListeners();
  }

  double get rating => _rating;

  set rating(double value) {
    _rating = value;
    notifyListeners();
  }

  String get comment => _comment;

  set comment(String value) {
    _comment = value;
    notifyListeners();
  }

  String get address => _address;

  set address(String value) {
    _address = value;
    notifyListeners();
  }

  List<File> get images => _images;

  set images(List<File> value) {
    _images = value;
    notifyListeners();
  }

  List<ImageIdUrlData> get networkImage => _networkImage;

  set networkImage(List<ImageIdUrlData> value) {
    _networkImage = value;
    notifyListeners();
  }

  String get category => _category;

  set category(String value) {
    _category = value;
    notifyListeners();
  }

  List<String> get tags => _tags;

  set tags(List<String> value) {
    _tags = value;
    notifyListeners();
  }

  int get thumbnailIndex => _thumbnailIndex;

  set thumbnailIndex(int value) {
    _thumbnailIndex = value;
    notifyListeners();
  }

  List<String> get tagList => _tagList;

  set tagList(List<String> value) {
    _tagList = value.toList();
    saveTagListToFirebase(_tagList);
    notifyListeners();
  }

  List<String> get categoryList => _categoryList;

  bool get isVisited => _isVisited;

  set isVisited(bool value) {
    _isVisited = value;
    notifyListeners();
  }

  set categoryList(List<String> value) {
    _categoryList = value.toList();
    saveCategoryListToFirebase(_categoryList);
    notifyListeners();
  }

  set curAddressModel(AddressModel? value) {
    if (value != null) {
      _addressModelStreamController.sink.add(value);
      _address = "${value.roadAddressName}\n(지번)${value.address}";
      _name = value.place ?? '';
    }
    _curAddressModel = value;
  }

  AddressModel? get curAddressModel => _curAddressModel;

  void clearAllData() {
    _images.clear();
    _networkImage.clear();
    _category = '';
    _tags.clear();
    _deletedNetworkImageList.clear();
    _name = '';
    _rating = 1;
    _comment = '';
    _address = '';
    cursorState = PaginationNotYet();
    query = '';
    _curAddressModel = null;
    _thumbnailIndex = 0;
    _isVisited = false;
  }

  void setModelForUpdate(RestaurantModel model) {
    _tags = model.tags;
    _category = model.category;
    _rating = model.rating;
    _networkImage = model.images;
    _name = model.name;
    _comment = model.comment;
    _address = model.address;
    _isVisited = model.isVisited;

    notifyListeners();
  }

  final _imagePicker = ImagePicker();

  Future<List<ImageIdUrlData>> uploadImages(String restaurantId) async {
    final uid = prefs.getString(FirestoreUserConstants.id);
    List<ImageIdUrlData> imageUrls = [];

    const uuid = Uuid();

    try {
      for (int i = 0; i < _images.length; i++) {
        final String imageId = uuid.v4();
        final path = 'restaurant/$uid/$restaurantId/$imageId';
        final storageReference = FirebaseStorage.instance.ref().child(path);
        final uploadTask = await storageReference.putFile(
            images[i], SettableMetadata(contentType: 'image/jpg'));

        final url = await uploadTask.ref.getDownloadURL();
        imageUrls.add(
          ImageIdUrlData(
            id: imageId,
            url: url,
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
    return imageUrls;
  }

  RestaurantModel _makeRestaurantModel(
      {required List<ImageIdUrlData> imageUrls, required String id}) {
    return RestaurantModel(
      id: id,
      name: _name,
      thumbnail: imageUrls.isNotEmpty ? imageUrls[thumbnailIndex].url : '',
      rating: _rating,
      comment: _comment,
      images: imageUrls,
      address: _address,
      tags: _tags,
      category: _category,
      isVisited: _isVisited,
    );
  }

  Future<void> uploadRestaurantData() async {
    const uuid = Uuid();
    final String restaurantId = uuid.v4();

    final imageIdUrls = await uploadImages(restaurantId);

    final model = _makeRestaurantModel(
      id: restaurantId,
      imageUrls: imageIdUrls,
    );

    await saveRestaurantModelToFirebase(model);

    for (int i = 0; i < _images.length; i++) {
      _images[i].delete();
    }
    _images.clear();
  }

  Future<void> saveCategoryListToFirebase(List<String> value) async {
    try {
      final uid = prefs.getString(FirestoreUserConstants.id);
      await firebaseFirestore
          .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
          .doc(uid)
          .collection(
              FirestoreRestaurantConstants.pathTagCategoryListCollection)
          .doc(FirestoreRestaurantConstants.pathTagCategoryListCollection)
          .set(
        {
          FirestoreRestaurantConstants.pathCategoryList: value,
          FirestoreRestaurantConstants.pathTagList: tagList,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveTagListToFirebase(List<String> value) async {
    try {
      final uid = prefs.getString(FirestoreUserConstants.id);
      await firebaseFirestore
          .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
          .doc(uid)
          .collection(
              FirestoreRestaurantConstants.pathTagCategoryListCollection)
          .doc(FirestoreRestaurantConstants.pathTagCategoryListCollection)
          .set(
        {
          FirestoreRestaurantConstants.pathTagList: value,
          FirestoreRestaurantConstants.pathCategoryList: categoryList,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _getTagCategoryListFromFirebase() async {
    final uid = prefs.getString(FirestoreUserConstants.id);
    final data = await firebaseFirestore
        .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
        .doc(uid)
        .collection(FirestoreRestaurantConstants.pathTagCategoryListCollection)
        .doc(FirestoreRestaurantConstants.pathTagCategoryListCollection)
        .get();
    final temp = data.data();

    _categoryList =
        temp?[FirestoreRestaurantConstants.pathCategoryList]?.cast<String>() ??
            [];
    _tagList =
        temp?[FirestoreRestaurantConstants.pathTagList]?.cast<String>() ?? [];
    notifyListeners();
  }

  Future<void> saveRestaurantModelToFirebase(RestaurantModel model) async {
    try {
      final uid = prefs.getString(FirestoreUserConstants.id);
      await firebaseFirestore
          .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
          .doc(uid)
          .collection(FirestoreRestaurantConstants.pathRestaurantListCollection)
          .doc(model.id)
          .set(
        {
          FirestoreRestaurantConstants.restaurantId: model.id,
          FirestoreRestaurantConstants.name: model.name,
          FirestoreRestaurantConstants.thumbnail: model.thumbnail,
          FirestoreRestaurantConstants.tags: model.tags,
          FirestoreRestaurantConstants.rating: model.rating,
          FirestoreRestaurantConstants.comment: model.comment,
          FirestoreRestaurantConstants.images:
              model.images.map((e) => e.toJson()).toList(),
          FirestoreRestaurantConstants.category:
              model.category.isEmpty ? '기타' : model.category,
          FirestoreRestaurantConstants.address: model.address,
          FirestoreRestaurantConstants.isVisited: model.isVisited,
          FirestoreRestaurantConstants.createdAt:
              DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRestaurantModelToFirebase(String restaurantId) async {
    try {
      final uid = prefs.getString(FirestoreUserConstants.id);

      //delete Image from firebase storage
      await deleteImageFromFirebaseStorage(restaurantId);

      //upload image from local
      final imageUrls = await uploadImages(restaurantId);

      String thumbnail = '';
      if (_networkImage.length > thumbnailIndex) {
        thumbnail = _networkImage[thumbnailIndex].url;
      } else {
        thumbnail = imageUrls[thumbnailIndex - _networkImage.length].url;
      }

      await firebaseFirestore
          .collection(FirestoreRestaurantConstants.pathRestaurantCollection)
          .doc(uid)
          .collection(FirestoreRestaurantConstants.pathRestaurantListCollection)
          .doc(restaurantId)
          .update(
        {
          FirestoreRestaurantConstants.restaurantId: restaurantId,
          FirestoreRestaurantConstants.name: _name,
          FirestoreRestaurantConstants.thumbnail: thumbnail,
          FirestoreRestaurantConstants.tags: _tags,
          FirestoreRestaurantConstants.rating: _rating,
          FirestoreRestaurantConstants.comment: _comment,
          FirestoreRestaurantConstants.images: [
            ..._networkImage.map((e) => e.toJson()).toList(),
            ...imageUrls.map((e) => e.toJson()).toList(),
          ],
          FirestoreRestaurantConstants.category:
              _category.isEmpty ? '기타' : _category,
          FirestoreRestaurantConstants.address: _address,
          FirestoreRestaurantConstants.isVisited: _isVisited,
          FirestoreRestaurantConstants.createdAt:
              DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      rethrow;
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

  Future<void> deleteImageFromFirebaseStorage(String restaurantId) async {
    final uid = prefs.getString(FirestoreUserConstants.id);

    for (int i = 0; i < _deletedNetworkImageList.length; i++) {
      final path =
          'restaurant/$uid/$restaurantId/${_deletedNetworkImageList[i]}';
      final storageReference = FirebaseStorage.instance.ref().child(path);
      await storageReference.delete();
    }
  }

  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 40,
      maxWidth: 500,
      maxHeight: 500,
    );
    if (pickedFile != null) {
      File picked = File(pickedFile.path);
      final cropped = await _cropImage(picked);
      if (cropped != null) {
        _images.add(File(cropped.path));
        images = List.from(_images);
      }
    }
  }

  Future<CroppedFile?> _cropImage(File file) async {
    final bytes = await file.readAsBytes();
    final kb = bytes.lengthInBytes / 1024;
    final directory = await getApplicationDocumentsDirectory();
    File? cropImage;

    if (kb > 200) {
      cropImage = await FlutterImageCompress.compressAndGetFile(
        file.path,
        '${directory.path}/restaurant_img.jpg',
        quality: 40,
      );
    } else {
      cropImage = await FlutterImageCompress.compressAndGetFile(
        file.path,
        '${directory.path}/restaurant_img.jpg',
        quality: 100,
      );
    }

    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: cropImage!.path,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: PRIMARY_COLOR,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedImage != null) {
      return croppedImage;
    } else {
      return null;
    }
  }

  void removeNetworkImage(int index) async {
    _deletedNetworkImageList.add(_networkImage[index].id);
    _networkImage.removeAt(index);
    networkImage = List.from(_networkImage);
  }

  void removeImage(int index) {
    _images.removeAt(index);
    images = List.from(images);
  }
}
