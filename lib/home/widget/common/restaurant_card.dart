import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/const/color.dart';
import '../../../common/widget/star_rating.dart';
import '../../../restaurant/model/restaurant_model.dart';

class RestaurantResultCard extends StatelessWidget {
  const RestaurantResultCard({
    super.key,
    required this.model,
  });

  final RestaurantModel model;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160.w,
            height: 160.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Hero(
                tag: model.id!,
                child: _Thumbnail(thumbnail: model.thumbnail),
              ),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 3.h,
                ),
                StarRating(rating: model.rating),
                SizedBox(
                  height: 7.h,
                ),
                Text(
                  model.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.thumbnail,
  });

  final String thumbnail;

  @override
  Widget build(BuildContext context) {
    return (thumbnail.isEmpty)
        ? Container(
            decoration: BoxDecoration(
              color: PRIMARY_COLOR,
              borderRadius: BorderRadius.circular(20).r,
            ),
            child: Icon(
              Icons.restaurant_menu,
              size: 25.sp,
            ),
          )
        : CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: thumbnail,
            placeholder: (context, url) => Container(
              width: 50.w,
              height: 50.h,
              alignment: Alignment.center,
              child: const CircularProgressIndicator.adaptive(),
            ),
            errorWidget: (context, url, error) => Container(
              color: LIGHT_GRAY_COLOR,
              child: Icon(
                Icons.error,
                size: 25.sp,
                color: PRIMARY_COLOR,
              ),
            ),
          );
  }
}
