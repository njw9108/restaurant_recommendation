import 'package:flutter/material.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/common/widget/app_icon.dart';
import 'package:recommend_restaurant/common/widget/star_rating.dart';
import 'package:recommend_restaurant/restaurant/model/restaurant_model.dart';
import 'package:intl/intl.dart';

class RestaurantDetailScreen extends StatelessWidget {
  static String get routeName => 'restaurantDetail';

  final RestaurantModel model;

  const RestaurantDetailScreen({
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageHeight = MediaQuery.of(context).size.height / 2.7;
    String createdAt = '';
    if (model.createdAt != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(model.createdAt!);
      DateFormat format = DateFormat('yyyy-MM-dd');
      createdAt = format.format(date);
    }
    return DefaultLayout(
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0,right: 20,bottom: 25,top: 5),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                ),
                child: const Text('수정하기'),
              ),
            )
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: imageHeight,
                decoration: BoxDecoration(
                  image: model.images.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(model.images.first),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
            ),
            Positioned(
              top: 45,
              left: 20,
              right: 20,
              child: Row(
                children: const [
                  AppIcon(icon: Icons.arrow_back_ios),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: imageHeight - 20,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(createdAt),
                      ),
                      Text(
                        model.category,
                        style: const TextStyle(
                          color: BODY_TEXT_COLOR,
                          height: 1.5,
                        ),
                      ),
                      Text(
                        model.name,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      StarRating(
                        rating: model.rating,
                        iconSize: 18,
                      ),
                      Text(
                        model.address,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 20,
                                  childAspectRatio: 1.7),
                          itemBuilder: (_, index) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration:
                                  const BoxDecoration(color: Colors.yellow),
                              alignment: Alignment.center,
                              child: Text(
                                model.tags[index],
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 10),
                              ),
                            );
                          },
                          itemCount: model.tags.length,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        model.comment,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              //top: (MediaQuery.of(context).size.height / 2.4) - 20,
              top: imageHeight - 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  AppIcon(icon: Icons.favorite),
                ],
              ),
            ),
          ],
        ));
  }
}
