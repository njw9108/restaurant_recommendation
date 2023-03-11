import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

import '../../../../../common/const/color.dart';
import '../../../../../common/const/const_data.dart';
import '../../../../provider/restaurant_provider.dart';
import '../common/bottom_sheet_list_item.dart';
import 'restaurant_category_add_filed.dart';

class RestaurantCategoryModalBottomSheet extends StatefulWidget {
  final bool isHome;

  const RestaurantCategoryModalBottomSheet({
    Key? key,
    this.isHome = false,
  }) : super(key: key);

  @override
  State<RestaurantCategoryModalBottomSheet> createState() =>
      _RestaurantCategoryModalBottomSheetState();
}

class _RestaurantCategoryModalBottomSheetState
    extends State<RestaurantCategoryModalBottomSheet> {
  final textController = TextEditingController();
  String tempSelect = '';

  @override
  void initState() {
    tempSelect = context.read<RestaurantAddProvider>().category;
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCategoryList = context.watch<RestaurantProvider>().categoryList;

    return Container(
      padding: EdgeInsets.only(
          left: 25.w,
          right: 25.w,
          top: 8.w,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 80,
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: PRIMARY_COLOR,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Text(
                  '카테고리',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 16.h,
                ),
                RestaurantCategoryAddFiled(
                  textController: textController,
                ),
                SizedBox(
                  height: 16.h,
                ),
                Text(
                  '카테고리 목록 (${totalCategoryList.length}/$maxTotalCategoryListCount)',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),
              ],
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: totalCategoryList.length,
                      (_, index) {
                        return Dismissible(
                          key: Key(totalCategoryList[index]),
                          background: Container(
                            color: Colors.red.shade400,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 10.h),
                            child: Icon(
                              Icons.delete_forever,
                              size: 25.sp,
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
                                      SizedBox(
                                        width: 8.w,
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
                                .read<RestaurantProvider>()
                                .deleteCategoryItemFromFirebase(
                                    totalCategoryList[index]);
                          },
                          child: BottomSheetListItem(
                            title: totalCategoryList[index],
                            selectedWidget: (widget.isHome)
                                ? null
                                : tempSelect == totalCategoryList[index]
                                    ? Row(
                                        children: [
                                          const Icon(
                                            Icons.check,
                                            color: PRIMARY_COLOR,
                                          ),
                                          SizedBox(
                                            width: 8.w,
                                          ),
                                          Text(
                                            totalCategoryList[index],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      )
                                    : null,
                            onTap: (value) {
                              if (!widget.isHome) {
                                setState(() {
                                  tempSelect = value;
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (!widget.isHome)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<RestaurantAddProvider>().category = tempSelect;
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY_COLOR,
                  ),
                  child: const Text('선택'),
                ),
              ),
            SizedBox(
              height: 20.h,
            ),
          ],
        ),
      ),
    );
  }
}
