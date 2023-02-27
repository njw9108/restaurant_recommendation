import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../common/const/color.dart';
import '../../../common/widget/star_rating.dart';
import '../../../restaurant/model/restaurant_model.dart';

class FavoriteRestaurantCard extends StatelessWidget {
  const FavoriteRestaurantCard({
    super.key,
    required this.model,
  });

  final RestaurantModel model;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Hero(
                tag: model.id!,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: model.thumbnail,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator.adaptive(),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    size: 25,
                    color: PRIMARY_COLOR,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                StarRating(rating: model.rating),
                const SizedBox(
                  height: 7,
                ),
                Text(
                  model.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
