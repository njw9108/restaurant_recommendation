import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/widget/star_rating.dart';
import 'package:recommend_restaurant/restaurant/model/restaurant_model.dart';
import 'package:collection/collection.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: const Icon(
          Icons.delete_forever,
          size: 30,
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
                  const SizedBox(
                    width: 8,
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
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Thumbnail(
              thumbnail: restaurantModel.thumbnail,
              id: restaurantModel.id!,
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
                  StarRating(
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
            const Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.drag_indicator,
              ),
            ),
            const SizedBox(
              width: 5,
            )
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: const CircularProgressIndicator.adaptive(),
            ),
            errorWidget: (context, url, error) => Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error,
                size: 25,
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
