import 'package:flutter/material.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';

import '../widget/favorite/favorite_restaurant_list_widget.dart';
import '../widget/search_categories/search_categories_list_widget.dart';
import '../widget/search_tags/search_tags_list_widget.dart';
import '../widget/visited/visited_restaurant_list_widget.dart';

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
          children: const [
            SearchCategoriesListWidget(),
            Divider(
              thickness: 8,
            ),
            SearchTagsListWidget(),
            Divider(
              thickness: 8,
            ),
            FavoriteRestaurantListWidget(),
            Divider(
              thickness: 8,
            ),
            VisitedRestaurantListWidget(),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
