import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/restaurant/model/restaurant_model.dart';
import 'package:collection/collection.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurantModel;

  const RestaurantCard({
    Key? key,
    required this.restaurantModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumbnail(
            thumbnail: restaurantModel.thumbnail,
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 100,
                  ),
                  child: Text(
                    restaurantModel.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StarRating(
                  rating: restaurantModel.rating,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  restaurantModel.address,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                _Tags(
                  tags: restaurantModel.tags,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String thumbnail;

  const _Thumbnail({Key? key, required this.thumbnail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (thumbnail.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          width: 95,
          height: 95,
          fit: BoxFit.cover,
          imageUrl: thumbnail,
          placeholder: (context, url) => Container(
            width: 95,
            height: 95,
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
            width: 95,
            height: 95,
            decoration: BoxDecoration(
              color: PRIMARY_COLOR,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              size: 25,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 95,
        height: 95,
        decoration: BoxDecoration(
          color: PRIMARY_COLOR,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.restaurant_menu,
          size: 25,
        ),
      );
    }
  }
}

class _Category extends StatelessWidget {
  final String category;

  const _Category({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 28,
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 5,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.limeAccent),
      alignment: Alignment.center,
      child: Text(
        category,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  final double iconSize = 15;

  const _StarRating({
    Key? key,
    required this.rating,
  }) : super(key: key);

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

class _Tags extends StatelessWidget {
  final List<String> tags;
  final int _maxCategoryCount = 3;

  const _Tags({
    Key? key,
    required this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...tags.mapIndexed(
          (index, e) {
            if (index < _maxCategoryCount) {
              return Padding(
                padding: index == tags.length - 1
                    ? EdgeInsets.zero
                    : const EdgeInsets.only(right: 8.0),
                child: _Category(
                  category: e,
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ).toList(),
        if (tags.length > _maxCategoryCount)
          const Text(
            '···',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}
