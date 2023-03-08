import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

import '../../../../../common/const/color.dart';
import '../../../../../common/const/const_data.dart';
import '../../../../provider/restaurant_provider.dart';
import '../common/bottom_sheet_list_item.dart';
import 'restaurant_tag_add_filed.dart';

class RestaurantTagsModalBottomSheet extends StatefulWidget {
  final Widget? title;
  final bool isHome;

  const RestaurantTagsModalBottomSheet({
    Key? key,
    this.title,
    this.isHome = false,
  }) : super(key: key);

  @override
  State<RestaurantTagsModalBottomSheet> createState() =>
      _RestaurantTagsModalBottomSheetState();
}

class _RestaurantTagsModalBottomSheetState
    extends State<RestaurantTagsModalBottomSheet> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalTagList = context.watch<RestaurantProvider>().tagList;
    final tags = context.watch<RestaurantAddProvider>().tags;

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Padding(
        padding: EdgeInsets.only(
            left: 25.w,
            right: 25.w,
            top: 25.w,
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title == null)
              Text(
                '태그를 선택해주세요 ${tags.length}/$maxTagsCount',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (widget.title != null) widget.title!,
            SizedBox(
              height: 16.h,
            ),
            RestaurantTagAddFiled(
              textController: textController,
            ),
            SizedBox(
              height: 16.h,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '태그 목록 (${totalTagList.length}/$maxTotalTagListCount)',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),
                ...totalTagList
                    .map(
                      (e) => Dismissible(
                        key: Key(e),
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
                                  content: const Text('선택한 태그를 삭제할까요?'),
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
                              .deleteTagItemFromFirebase(e);
                        },
                        child: BottomSheetListItem(
                          title: e,
                          selectedWidget: tags.contains(e)
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
                                      e,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                          onTap: (value) {
                            if (!widget.isHome) {
                              if (tags.contains(value)) {
                                tags.remove(value);
                                context.read<RestaurantAddProvider>().tags =
                                    List.from(tags);
                              } else {
                                if (tags.length < maxTagsCount) {
                                  tags.add(value);
                                  context.read<RestaurantAddProvider>().tags =
                                      List.from(tags);
                                }
                              }
                            }
                          },
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
