import 'package:flutter/material.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      child: Column(
        children: [],
      ),
    );
  }
}
