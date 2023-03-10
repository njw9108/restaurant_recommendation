import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:recommend_restaurant/home/widget/common/restaurant_card.dart';

import '../../../restaurant/model/restaurant_model.dart';
import '../../../restaurant/view/restaurant_detail_screen.dart';

class RestaurantResultWidget extends StatelessWidget {
  const RestaurantResultWidget({
    super.key,
    required this.mainController,
    required this.restaurantList,
  });

  final ScrollController mainController;
  final List<QueryDocumentSnapshot<Object?>> restaurantList;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250.h,
      child: restaurantList.isNotEmpty
          ? ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: mainController,
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
                  child: RestaurantResultCard(
                    model: model,
                  ),
                );
              },
              itemCount: restaurantList.length,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: 10.w,
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
