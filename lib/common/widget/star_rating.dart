import 'package:flutter/material.dart';
import 'package:recommend_restaurant/common/const/color.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double iconSize;

  const StarRating({Key? key, required this.rating, this.iconSize = 15})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int star = rating.floor();
    bool isHalfStar = rating - star > 0;

    return Row(
      children: [
        ...List.generate(
          star,
          (index) => Icon(
            Icons.star,
            color: PRIMARY_COLOR,
            size: iconSize,
          ),
        ),
        if (isHalfStar)
          Icon(
            Icons.star_half_outlined,
            color: PRIMARY_COLOR,
            size: iconSize,
          ),
        ...List.generate(
          isHalfStar ? 4 - star : 5 - star,
          (index) => Icon(
            Icons.star_border_outlined,
            color: PRIMARY_COLOR,
            size: iconSize,
          ),
        ),
      ],
    );
  }
}
