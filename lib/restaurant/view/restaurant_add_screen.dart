import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/common/widget/custom_text_field.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';
import 'package:recommend_restaurant/restaurant/widget/bottom_sheet_widget.dart';
import 'package:recommend_restaurant/restaurant/widget/list_select_menu_widget.dart';

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
                      _buildName(),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildAddress(),
                      const SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomTextFormField(
                          hintText: '코멘트',
                          maxLine: 6,
                          onChanged: (String value) {},
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildCategory(
                        category: restaurantAddProvider.category,
                        onBottomSheetTap: (value) {
                          restaurantAddProvider.category = value;
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildTags(
                        tags: restaurantAddProvider.tags,
                        onBottomSheetTap: (value) {
                          if (restaurantAddProvider.tags.contains(value)) {
                            restaurantAddProvider.tags.remove(value);
                            restaurantAddProvider.tags =
                                List.from(restaurantAddProvider.tags);
                          } else {
                            if (restaurantAddProvider.tags.length <
                                int.parse(restaurantAddProvider.maxTagsCount)) {
                              restaurantAddProvider.tags.add(value);
                              restaurantAddProvider.tags =
                                  List.from(restaurantAddProvider.tags);
                            }
                          }
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildRating(),
                      const SizedBox(
                        height: 16,
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

  Padding _buildRating() {
    return Padding(
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
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: PRIMARY_COLOR,
            ),
            onRatingUpdate: (rating) {},
          ),
        ],
      ),
    );
  }

  Padding _buildName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomTextFormField(
        hintText: '가게 이름',
        onChanged: (String value) {},
      ),
    );
  }

  Padding _buildAddress() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: CustomTextFormField(
        hintText: '주소',
        onChanged: (String value) {},
      ),
    );
  }

  Padding _buildCategory({
    required String? category,
    required Function(String) onBottomSheetTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: ListSelectMenuWidget(
        title: '카테고리',
        content: category,
        emptyText: '카테고리를 선택해주세요.',
        bottomSheetWidget: CategoryBottomSheet(
          onTap: onBottomSheetTap,
        ),
      ),
    );
  }

  Padding _buildTags({
    required List<String> tags,
    required Function(String) onBottomSheetTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: ListSelectMenuWidget(
        title: '태그',
        content: tags.isEmpty ? null : tags.join(', '),
        emptyText: '태그를 선택해주세요.',
        bottomSheetWidget: TagBottomSheet(
          onTap: onBottomSheetTap,
        ),
      ),
    );
  }
}
