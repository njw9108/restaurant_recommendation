import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('평점'),
          const SizedBox(
            height: 8,
          ),
          RatingBar.builder(
            initialRating: initRating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            glowColor: Colors.limeAccent,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
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
