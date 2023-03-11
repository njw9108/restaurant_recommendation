import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

import '../../../common/const/color.dart';

class RestaurantRatingWidget extends StatelessWidget {
  final double initRating;

  const RestaurantRatingWidget({
    Key? key,
    this.initRating = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('평점'),
          SizedBox(
            height: 8.h,
          ),
          RatingBar.builder(
            initialRating: initRating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            glowColor: Colors.limeAccent,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0.w),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: PRIMARY_COLOR,
            ),
            onRatingUpdate: (value) {
              context.read<RestaurantAddProvider>().rating = value;
            },
          ),
        ],
      ),
    );
  }
}
