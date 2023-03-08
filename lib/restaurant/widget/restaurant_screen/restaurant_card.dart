import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/widget/star_rating.dart';
import 'package:recommend_restaurant/restaurant/model/restaurant_model.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_provider.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurantModel;

  const RestaurantCard({
    Key? key,
    required this.restaurantModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(restaurantModel.id ?? ''),
      background: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 10.w),
        child: Icon(
          Icons.delete_forever,
          size: 30.sp,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        bool res = false;
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: const Text('선택한 식당을 삭제할까요?'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      res = true;
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY_COLOR,
                    ),
                    child: const Text('삭제'),
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('취소'),
                  ),
                ],
              );
            });
        return Future.value(res);
      },
      onDismissed: (direction) async {
        await context.read<RestaurantProvider>().deleteRestaurantFromFirebase(
              restaurantId: restaurantModel.id!,
              imageIdList: restaurantModel.images.map((e) => e.id).toList(),
            );
      },
      child: SizedBox(
        height: 110.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 95.h,
              child: _Thumbnail(
                thumbnail: restaurantModel.thumbnail,
                id: restaurantModel.id!,
              ),
            ),
            SizedBox(
              width: 16.w,
            ),
            Expanded(
              child: SizedBox(
                height: 95.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 100.w,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            restaurantModel.category,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(
                            height: 3.h,
                          ),
                          Text(
                            restaurantModel.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StarRating(
                      rating: restaurantModel.rating,
                    ),
                    Text(
                      restaurantModel.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.drag_indicator,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String thumbnail;
  final String id;

  const _Thumbnail({
    Key? key,
    required this.thumbnail,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (thumbnail.isNotEmpty) {
      return Hero(
        tag: id,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10).r,
          child: CachedNetworkImage(
            width: 95.w,
            height: 95.h,
            fit: BoxFit.cover,
            imageUrl: thumbnail,
            placeholder: (context, url) => Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20).r,
              ),
              alignment: Alignment.center,
              child: const CircularProgressIndicator.adaptive(),
            ),
            errorWidget: (context, url, error) => Container(
              width: 95.w,
              height: 95.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20).r,
              ),
              child: Icon(
                Icons.error,
                size: 25.sp,
                color: PRIMARY_COLOR,
              ),
            ),
          ),
        ),
      );
    } else {
      return Hero(
        tag: id,
        child: Container(
          width: 95.w,
          height: 95.h,
          decoration: BoxDecoration(
            color: PRIMARY_COLOR,
            borderRadius: BorderRadius.circular(20).r,
          ),
          child: Icon(
            Icons.restaurant_menu,
            size: 25.sp,
          ),
        ),
      );
    }
  }
}
