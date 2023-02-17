import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/common/widget/custom_text_field.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

class RestaurantAddScreen extends StatelessWidget {
  static String get routeName => 'restaurantAdd';

  const RestaurantAddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<RestaurantAddProvider>(
              create: (_) => RestaurantAddProvider(),
            ),
          ],
          child: const RestaurantAddScreenBuilder(),
        );
      },
    );
  }
}

class RestaurantAddScreenBuilder extends StatefulWidget {
  const RestaurantAddScreenBuilder({Key? key}) : super(key: key);

  @override
  State<RestaurantAddScreenBuilder> createState() =>
      _RestaurantAddScreenBuilderState();
}

class _RestaurantAddScreenBuilderState
    extends State<RestaurantAddScreenBuilder> {
  double temp = 0;

  @override
  Widget build(BuildContext context) {
    final restaurantAddProvider = context.watch<RestaurantAddProvider>();

    return DefaultLayout(
      title: '식당 추가',
      appbarActions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.done,
          ),
        ),
      ],
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // InkWell(
                    //   onTap: restaurantAddProvider.thumbNail != null
                    //       ? () {
                    //           showDialog(
                    //             context: context,
                    //             barrierDismissible: true,
                    //             builder: (_) {
                    //               return AlertDialog(
                    //                 content: const Text('이미지를 삭제할까요?'),
                    //                 actions: [
                    //                   ElevatedButton(
                    //                     onPressed: () {
                    //                       restaurantAddProvider.clearImage();
                    //                       Navigator.of(context).pop();
                    //                     },
                    //                     child: const Text('예'),
                    //                   ),
                    //                   ElevatedButton(
                    //                     onPressed: () {
                    //                       Navigator.of(context).pop();
                    //                     },
                    //                     child: const Text('아니오'),
                    //                   ),
                    //                 ],
                    //               );
                    //             },
                    //           );
                    //         }
                    //       : () async {
                    //           await restaurantAddProvider.pickImage(
                    //               source: ImageSource.gallery);
                    //         },
                    //   child: Container(
                    //     height: 250,
                    //     decoration:
                    //         BoxDecoration(color: Colors.grey.withOpacity(0.5)),
                    //     alignment: Alignment.center,
                    //     child: restaurantAddProvider.thumbNail != null
                    //         ? Image.file(
                    //             restaurantAddProvider.thumbNail!,
                    //             fit: BoxFit.fill,
                    //           )
                    //         : Row(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: const [
                    //               Icon(Icons.camera_alt_outlined),
                    //               Text('대표 이미지를 추가해주세요'),
                    //             ],
                    //           ),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                      ),
                      child: Column(
                        children: [
                          CustomTextFormField(
                            hintText: '가게 이름',
                            onChanged: (String value) {},
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          CustomTextFormField(
                            hintText: '주소',
                            onChanged: (String value) {},
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('평점'),
                          const SizedBox(
                            height: 8,
                          ),
                          RatingBar.builder(
                            initialRating: 1,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: PRIMARY_COLOR,
                            ),
                            onRatingUpdate: (rating) {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 45,
              alignment: Alignment.topRight,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(width: 1.0, color: PRIMARY_COLOR),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 8),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.keyboard_alt_outlined,
                        size: 20,
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_outlined,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
