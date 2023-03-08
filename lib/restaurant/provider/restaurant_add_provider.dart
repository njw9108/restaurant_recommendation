import 'dart:async';
import 'dart:io';

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
import 'package:uuid/uuid.dart';

import '../../common/repository/firebase_repository.dart';

class RestaurantAddProvider
    extends PaginationProvider<AddressModel, KakaoAddressRepository> {
  final FirebaseRepository firebaseRepository;

  RestaurantAddProvider({
    required super.repository,
    required this.firebaseRepository,
  });

  final _addressModelStreamController =
      StreamController<AddressModel>.broadcast();

  Stream<AddressModel> get addressModelStream =>
      _addressModelStreamController.stream.asBroadcastStream();

  AddressModel? _curAddressModel;
  String query = '';
  int _thumbnailIndex = 0;

  bool _isFavorite = false;
  bool _isVisited = false;

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

  bool get isVisited => _isVisited;

  set isVisited(bool value) {
    _isVisited = value;
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
    _isFavorite = false;
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
    _isFavorite = model.isFavorite;

    notifyListeners();
  }

  final _imagePicker = ImagePicker();

  Future<List<ImageIdUrlData>> uploadImages(String restaurantId) async {
    List<ImageIdUrlData> imageUrls = [];

    try {
      for (int i = 0; i < _images.length; i++) {
        final data = await firebaseRepository.saveImageToStorage(
          restaurantId: restaurantId,
          file: _images[i],
        );
        imageUrls.add(data);
      }
    } catch (e) {
      print(e);
    }
    return imageUrls;
  }

  RestaurantModel _makeRestaurantModel(
      {required List<ImageIdUrlData> imageUrls,
      required String id,
      String? thumbnail}) {
    return RestaurantModel(
      id: id,
      name: _name,
      thumbnail: thumbnail ??
          (imageUrls.isNotEmpty ? imageUrls[thumbnailIndex].url : ''),
      rating: _rating,
      comment: _comment,
      images: imageUrls,
      address: _address,
      tags: _tags,
      category: _category.isNotEmpty ? _category : '기타',
      isVisited: _isVisited,
      isFavorite: _isFavorite,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> uploadRestaurantData() async {
    try {
      const uuid = Uuid();
      final String restaurantId = uuid.v4();

      final imageIdUrls = await uploadImages(restaurantId);

      final model = _makeRestaurantModel(
        id: restaurantId,
        imageUrls: imageIdUrls,
      );

      await firebaseRepository.saveRestaurantToFirebase(
        collectionId: FirestoreRestaurantConstants.pathRestaurantListCollection,
        docId: restaurantId,
        data: model.toJson(),
      );

      for (int i = 0; i < _images.length; i++) {
        _images[i].delete();
      }
      _images.clear();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateRestaurantModelToFirebase(String restaurantId) async {
    try {
      //delete Image from firebase storage
      for (int i = 0; i < _deletedNetworkImageList.length; i++) {
        await firebaseRepository.deleteImageFromStorage(
          restaurantId: restaurantId,
          imageId: _deletedNetworkImageList[i],
        );
      }

      //upload image from local
      final imageUrls = await uploadImages(restaurantId);

      String thumbnail = '';
      if (_networkImage.length > thumbnailIndex) {
        thumbnail = _networkImage[thumbnailIndex].url;
      } else {
        thumbnail = imageUrls[thumbnailIndex - _networkImage.length].url;
      }

      final model = _makeRestaurantModel(
        id: restaurantId,
        imageUrls: [
          ...networkImage,
          ...imageUrls,
        ],
        thumbnail: thumbnail,
      );

      await firebaseRepository.updateRestaurantToFirebase(
        collectionId: FirestoreRestaurantConstants.pathRestaurantListCollection,
        docId: restaurantId,
        data: model.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteImageFromFirebaseStorage(String restaurantId) async {
    try {
      for (int i = 0; i < _deletedNetworkImageList.length; i++) {
        await firebaseRepository.deleteImageFromStorage(
          restaurantId: restaurantId,
          imageId: _deletedNetworkImageList[i],
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 40,
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
