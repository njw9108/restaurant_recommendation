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
import 'package:recommend_restaurant/restaurant/model/restaurant_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class RestaurantAddProvider with ChangeNotifier {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final SharedPreferences prefs;

  RestaurantAddProvider({
    required this.prefs,
  });

  String maxImagesCount = '3';
  List<File> _images = [];

  List<File> get images => _images;

  set images(List<File> value) {
    _images = value;
    notifyListeners();
  }

  String? _category;

  String? get category => _category;

  set category(String? value) {
    _category = value;
    notifyListeners();
  }

  String maxTagsCount = '5';
  List<String> _tags = [];

  List<String> get tags => _tags;

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
        print(url);
      }
    } catch (e) {
      print(e);
    }
    return imageUrls;
  }

  Future<void> uploadRestaurantData(RestaurantModel model) async {
    const uuid = Uuid();
    final String restaurantId = uuid.v4();

    final imageUrls = await uploadImages(restaurantId);

    model = model.copyWith(
      id: restaurantId,
      thumbnail: imageUrls.isNotEmpty ? imageUrls.first : '',
      images: imageUrls,
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
          FirestoreRestaurantConstants.category: model.category,
          FirestoreRestaurantConstants.address: model.address,
          FirestoreRestaurantConstants.createdAt:
              DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pickImage({required ImageSource source}) async {
    final pickedFile =
        await _imagePicker.pickImage(source: source, imageQuality: 20);
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

  void clearImage() {
    images.clear();
  }

  void removeImage(int index) {
    images.removeAt(index);
    images = List.from(images);
  }
}
