import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../common/layout/default_layout.dart';
import '../provider/restaurant_add_provider.dart';
import '../widget/restaurant_add/restaurant_category_widget.dart';
import '../widget/restaurant_add/restaurant_comment_widget.dart';
import '../widget/restaurant_add/restaurant_image_widget.dart';
import '../widget/restaurant_add/restaurant_name_address_widget.dart';
import '../widget/restaurant_add/restaurant_rating_widget.dart';
import '../widget/restaurant_add/restaurant_tag_widget.dart';

class RestaurantAddScreen extends StatefulWidget {
  static String get routeName => 'restaurantAdd';

  const RestaurantAddScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantAddScreen> createState() => _RestaurantAddScreenState();
}

class _RestaurantAddScreenState extends State<RestaurantAddScreen> {
  @override
  void initState() {
    context.read<RestaurantAddProvider>().clearAllData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: DefaultLayout(
            title: '식당 추가',
            appbarActions: [
              IconButton(
                onPressed: () async {
                  await context
                      .read<RestaurantAddProvider>()
                      .uploadRestaurantData();
                  context.pop();
                },
                icon: const Icon(
                  Icons.done,
                ),
              ),
            ],
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  RestaurantImageWidget(),
                  RestaurantNameAddressWidget(),
                  RestaurantCommentWidget(),
                  RestaurantCategoryWidget(),
                  RestaurantTagWidget(),
                  RestaurantRatingWidget(),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
