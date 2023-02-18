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
  @override
  Widget build(BuildContext context) {
    final restaurantAddProvider = context.watch<RestaurantAddProvider>();

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: DefaultLayout(
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
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
                      const SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      const SizedBox(
                        height: 16,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomTextFormField(
                          hintText: '가게 이름',
                          onChanged: (String value) {},
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: CustomTextFormField(
                          hintText: '주소',
                          onChanged: (String value) {},
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(
                                '카테고리',
                                style: TextStyle(
                                  color: BODY_TEXT_COLOR,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: BODY_TEXT_COLOR,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                onTap: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    builder: (context) {
                                      return _CategoryBottomSheet(
                                        onTap: (value) {
                                          restaurantAddProvider.category =
                                              value;
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  );
                                },
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                title: restaurantAddProvider.category == null
                                    ? const Text(
                                        '카테고리를 선택해 주세요.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: BODY_TEXT_COLOR,
                                        ),
                                      )
                                    : Text(
                                        restaurantAddProvider.category!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                trailing: const Icon(
                                    Icons.keyboard_arrow_right_sharp),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(
                                '태그',
                                style: TextStyle(
                                  color: BODY_TEXT_COLOR,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBottomSheet extends StatelessWidget {
  final Function(String) onTap;

  const _CategoryBottomSheet({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '카테고리를 선택해주세요.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(
            height: 8,
          ),
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _BottomSheetItemWidget(
                  title: '집근처',
                  onTap: onTap,
                ),
                _BottomSheetItemWidget(
                  title: '회사근처',
                  onTap: onTap,
                ),
                _BottomSheetItemWidget(
                  title: '데이트',
                  onTap: onTap,
                ),
                _BottomSheetItemWidget(
                  title: '친구',
                  onTap: onTap,
                ),
                _BottomSheetItemWidget(
                  title: '기타',
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetItemWidget extends StatelessWidget {
  final String title;
  final Function(String) onTap;

  const _BottomSheetItemWidget({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            onTap(title);
          },
          title: Text(
            title,
          ),
          contentPadding: EdgeInsets.zero,
          minVerticalPadding: 0,
        ),
        const Divider(
          height: 1,
        ),
      ],
    );
  }
}
