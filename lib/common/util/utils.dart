import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
        decoration: BoxDecoration(
          color: PRIMARY_COLOR,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.restaurant_menu,
          size: 25,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: BoxDecoration(
          color: PRIMARY_COLOR,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.restaurant_menu,
          size: 25,
        ),
      ),
    );
    imageList.add(image);
  }
  return imageList;
}