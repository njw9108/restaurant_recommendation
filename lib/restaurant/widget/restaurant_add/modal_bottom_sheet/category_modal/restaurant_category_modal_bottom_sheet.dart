import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

import '../../../../../common/const/color.dart';
import '../../../../../common/const/const_data.dart';
import '../../../../provider/restaurant_provider.dart';
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
                          (e) => Dismissible(
                            key: Key(e),
                            background: Container(
                              color: Colors.red.shade400,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: const Icon(
                                Icons.delete_forever,
                                size: 25,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              bool res = false;
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: const Text('선택한 카테고리를 삭제할까요?'),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            res = true;
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: PRIMARY_COLOR,
                                          ),
                                          child: const Text('삭제'),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey,
                                          ),
                                          child: const Text('취소'),
                                        ),
                                      ],
                                    );
                                  });
                              return Future.value(res);
                            },
                            onDismissed: (direction) async {
                              await context
                                  .read<RestaurantAddProvider>()
                                  .deleteCategoryItemFromFirebase(e);
                            },
                            child: BottomSheetListItem(
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
                                context
                                    .read<RestaurantAddProvider>()
                                    .category = value;
                                Navigator.pop(context);
                              },
                            ),
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
