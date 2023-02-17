import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';

class RestaurantAddProvider with ChangeNotifier {
  File? thumbNail;
  final _imagePicker = ImagePicker();

  Future<void> pickImage({required ImageSource source}) async {
    final pickedFile =
        await _imagePicker.pickImage(source: source, imageQuality: 20);
    if (pickedFile != null) {
      File picked = File(pickedFile.path);
      final cropped = await _cropImage(picked);
      if (cropped != null) {
        thumbNail = File(cropped.path);
        notifyListeners();
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
        '${directory.path}/restaurant_thumbnail.jpg',
        quality: 20,
      );
    } else {
      cropImage = await FlutterImageCompress.compressAndGetFile(
        file.path,
        '${directory.path}/restaurant_thumbnail.jpg',
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
    thumbNail = null;
    notifyListeners();
  }
}
