import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/restaurant/model/restaurant_model.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_provider.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final model = RestaurantModel(
            name: '백반집',
            thumbnail: '',
            restaurantType: '타입',
            rating: 4.5,
            comment: '아주 맛있었다. 담에 또가야지',
            images: [],
            categories: ['한식', '갈비탕'],
            address: '서울 강남구',
          );

          context
              .read<RestaurantProvider>()
              .saveRestaurantModelToFirebase(model);
        },
        child: const Icon(Icons.add),
      ),
      child: Column(
        children: [],
      ),
    );
  }
}
