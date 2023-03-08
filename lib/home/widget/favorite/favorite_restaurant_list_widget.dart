import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../common/const/const_data.dart';
import '../../../restaurant/model/restaurant_model.dart';
import '../../../restaurant/provider/restaurant_provider.dart';
import '../../../restaurant/view/restaurant_detail_screen.dart';
import '../common/restaurant_card.dart';

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
  String heroKey = '';
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
              padding: REdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '내가 좋아하는 식당',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 23.sp,
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  if (restaurantList.isEmpty)
                    Center(
                      child: Padding(
                        padding: REdgeInsets.all(16.0),
                        child: Text('좋아하는 식당을 추가해주세요!'),
                      ),
                    ),
                  if (restaurantList.isNotEmpty)
                    SizedBox(
                      height: 250.h,
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
                                  child: RestaurantResultCard(model: model),
                                );
                              },
                              itemCount: restaurantList.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  width: 10.w,
                                  height: 10.h,
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
