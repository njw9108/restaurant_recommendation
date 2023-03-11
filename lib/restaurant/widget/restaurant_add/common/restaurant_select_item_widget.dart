import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/const/color.dart';

class RestaurantSelectItemWidget extends StatelessWidget {
  final String title;
  final String emptyText;
  final String content;
  final Widget bottomSheet;

  const RestaurantSelectItemWidget({
    Key? key,
    required this.title,
    required this.bottomSheet,
    required this.emptyText,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0.w),
          child: Text(
            title,
            style: TextStyle(
              color: GRAY_COLOR,
              fontSize: 12.sp,
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: GRAY_COLOR,
              ),
            ),
          ),
          child: ListTile(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                isDismissible: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20).r,
                    topRight: const Radius.circular(20).r,
                  ),
                ),
                builder: (_) {
                  return DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.8,
                    maxChildSize: 0.8,
                    builder: (BuildContext context,
                            ScrollController scrollController) =>
                        bottomSheet,
                  );
                },
              );
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 5.w),
            title: content.trim().isEmpty
                ? Text(
                    emptyText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: GRAY_COLOR,
                    ),
                  )
                : Text(
                    content,
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
            trailing: const Icon(Icons.keyboard_arrow_right_sharp),
          ),
        ),
      ],
    );
  }
}
