import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

class RestaurantVisitedWidget extends StatelessWidget {
  const RestaurantVisitedWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textValue =
        context.watch<RestaurantAddProvider>().isVisited ? '방문했어요' : '아직 안가봤어요';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Switch(
            value: context.watch<RestaurantAddProvider>().isVisited,
            onChanged: (value) {
              context.read<RestaurantAddProvider>().isVisited = value;
            },
            activeColor: PRIMARY_COLOR,
          ),
          Text(textValue),
        ],
      ),
    );
  }
}
