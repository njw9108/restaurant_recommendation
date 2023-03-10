import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../const/color.dart';

List<CachedNetworkImage> makeImageList({
  required List<String> urls,
  required BoxFit fit,
}) {
  List<CachedNetworkImage> imageList = [];
  for (int i = 0; i < urls.length; i++) {
    final image = CachedNetworkImage(
      fit: fit,
      imageUrl: urls[i],
      placeholder: (context, url) => Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: const CircularProgressIndicator.adaptive(),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.error,
          size: 25,
          color: PRIMARY_COLOR,
        ),
      ),
    );
    imageList.add(image);
  }
  return imageList;
}
