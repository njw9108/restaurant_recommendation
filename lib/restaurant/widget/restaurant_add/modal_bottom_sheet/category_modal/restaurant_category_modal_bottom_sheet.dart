import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

import '../../../../../common/const/color.dart';
import '../../../../../common/const/const_data.dart';
import '../common/bottom_sheet_list_item.dart';
import 'restaurant_category_add_filed.dart';

class RestaurantCategoryModalBottomSheet extends StatefulWidget {
  const RestaurantCategoryModalBottomSheet({Key? key}) : super(key: key);

  @override
  State<RestaurantCategoryModalBottomSheet> createState() =>
      _RestaurantCategoryModalBottomSheetState();
}

class _RestaurantCategoryModalBottomSheetState
    extends State<RestaurantCategoryModalBottomSheet> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCategoryList =
        context.watch<RestaurantAddProvider>().categoryList;

    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '카테고리',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          RestaurantCategoryAddFiled(
            textController: textController,
          ),
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '카테고리 목록 (${totalCategoryList.length}/$maxTotalCategoryListCount)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ...totalCategoryList
                        .map(
                          (e) => BottomSheetListItem(
                            title: e,
                            selectedWidget: context
                                        .watch<RestaurantAddProvider>()
                                        .category ==
                                    e
                                ? Row(
                                    children: [
                                      const Icon(
                                        Icons.check,
                                        color: PRIMARY_COLOR,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        e,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  )
                                : null,
                            onTap: (value) {
                              context.read<RestaurantAddProvider>().category =
                                  value;
                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
