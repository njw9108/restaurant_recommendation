import 'package:flutter/material.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';

import '../widget/favorite/favorite_restaurant_list_widget.dart';

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
      child: SingleChildScrollView(
        child: Column(
          children: [
            const FavoriteRestaurantListWidget(),
            const Divider(
              thickness: 8,
            ),
          ],
        ),
      ),
    );
  }
}
