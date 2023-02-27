import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/common/widget/star_rating.dart';

import '../../common/const/color.dart';
import '../../common/const/const_data.dart';
import '../../restaurant/model/restaurant_model.dart';
import '../../restaurant/provider/restaurant_provider.dart';
import '../../restaurant/view/restaurant_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '마이슐랭',
      child: Column(
        children: [
          const FavoriteRestaurantListWidget(),
        ],
      ),
    );
  }
}

class FavoriteRestaurantListWidget extends StatefulWidget {
  const FavoriteRestaurantListWidget({
    super.key,
  });

  @override
  State<FavoriteRestaurantListWidget> createState() =>
      _FavoriteRestaurantListWidgetState();
}

class _FavoriteRestaurantListWidgetState
    extends State<FavoriteRestaurantListWidget> {
  final ScrollController controller = ScrollController();
  int _limit = firestoreDataLimit;
  final int _limitIncrement = 20;
  List<QueryDocumentSnapshot> restaurantList = [];

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    controller.dispose();

    super.dispose();
  }

  void _scrollListener() {
    if (!controller.hasClients) return;
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange &&
        _limit <= restaurantList.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream:
              context.read<RestaurantProvider>().getFavoriteRestaurantStream(
                    limit: _limit,
                  ),
          builder: (context, snapshot) {
            restaurantList = snapshot.data?.docs ?? [];
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '내가 좋아하는 식당',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 23,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (restaurantList.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('좋아하는 식당을 추가해주세요!'),
                      ),
                    ),
                  if (restaurantList.isNotEmpty)
                    SizedBox(
                      height: 250,
                      child: snapshot.hasData
                          ? ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              controller: controller,
                              itemBuilder: (_, index) {
                                DocumentSnapshot doc = restaurantList[index];
                                final model = RestaurantModel.fromDocument(doc);

                                return GestureDetector(
                                  onTap: () {
                                    context.goNamed(
                                      RestaurantDetailScreen.routeName,
                                      extra: model,
                                    );
                                  },
                                  child: FavoriteRestaurantCard(model: model),
                                );
                              },
                              itemCount: restaurantList.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const SizedBox(
                                  width: 10,
                                  height: 10,
                                );
                              },
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                    )
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

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
                tag: model.id ?? '',
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
