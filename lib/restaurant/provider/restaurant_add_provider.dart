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
  });

  final _addressModelStreamController =
      StreamController<AddressModel>.broadcast();

  Stream<AddressModel> get addressModelStream =>
      _addressModelStreamController.stream.asBroadcastStream();

  AddressModel? _curAddressModel;
  String query = '';

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

  String get category => _category;

  set category(String value) {
    _category = value;
    notifyListeners();
  }

  List<String> get tags => _tags;

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
    _category = '';
    _tags.clear();
    _name = '';
    _rating = 1;
    _comment = '';
    _address = '';
    cursorState = PaginationNotYet();
    query = '';
    _curAddressModel = null;
  }

  set tags(List<String> value) {
    _tags = value;
    notifyListeners();
  }

  final _imagePicker = ImagePicker();

  Future<List<String>> uploadImages(String restaurantId) async {
    final uid = prefs.getString(FirestoreUserConstants.id);
    String path;
    List<String> imageUrls = [];

    try {
      for (int i = 0; i < _images.length; i++) {
        path = 'restaurant/$uid/$restaurantId/image$i';
        final storageReference = FirebaseStorage.instance.ref().child(path);
        final uploadTask = await storageReference.putFile(
            images[i], SettableMetadata(contentType: 'image/jpg'));

        final url = await uploadTask.ref.getDownloadURL();
        imageUrls.add(url);
      }
    } catch (e) {
      print(e);
    }
    return imageUrls;
  }

  RestaurantModel _makeRestaurantModel(
      {required List<String> imageUrls, required String id}) {
    return RestaurantModel(
      id: id,
      name: _name,
      thumbnail: imageUrls.isNotEmpty ? imageUrls.first : '',
      rating: _rating,
      comment: _comment,
      images: imageUrls,
      address: _address,
      tags: _tags,
      category: _category,
    );
  }

  Future<void> uploadRestaurantData() async {
    const uuid = Uuid();
    final String restaurantId = uuid.v4();

    final imageUrls = await uploadImages(restaurantId);

    final model = _makeRestaurantModel(
      id: restaurantId,
      imageUrls: imageUrls,
    );

    await saveRestaurantModelToFirebase(model);

    for (int i = 0; i < _images.length; i++) {
      _images[i].delete();
    }
    _images.clear();
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
          FirestoreRestaurantConstants.images: model.images,
          FirestoreRestaurantConstants.category:
              model.category.isEmpty ? '기타' : model.category,
          FirestoreRestaurantConstants.address: model.address,
          FirestoreRestaurantConstants.createdAt:
              DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 20,
      maxWidth: 350,
      maxHeight: 500,
    );
    if (pickedFile != null) {
      File picked = File(pickedFile.path);
      final cropped = await _cropImage(picked);
      if (cropped != null) {
        images.add(File(cropped.path));
        images = List.from(images);
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
        quality: 20,
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

  void removeImage(int index) {
    images.removeAt(index);
    images = List.from(images);
  }
}
