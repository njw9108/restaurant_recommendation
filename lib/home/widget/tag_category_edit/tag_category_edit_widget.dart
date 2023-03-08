import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/const/color.dart';
import '../../../restaurant/widget/restaurant_add/modal_bottom_sheet/category_modal/restaurant_category_modal_bottom_sheet.dart';
import '../../../restaurant/widget/restaurant_add/modal_bottom_sheet/tags_modal/restaurant_tags_modal_bottom_sheet.dart';

class TagCategoryEditWidget extends StatelessWidget {
  const TagCategoryEditWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20).r,
                      topRight: const Radius.circular(20).r,
                    ),
                  ),
                  builder: (_) {
                    return DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.6,
                      maxChildSize: 0.8,
                      builder: (BuildContext context,
                              ScrollController scrollController) =>
                          SingleChildScrollView(
                        controller: scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: const RestaurantCategoryModalBottomSheet(
                          isHome: true,
                        ),
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
              child: const Text('카테고리 편집')),
          SizedBox(
            height: 8.h,
          ),
          ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20).r,
                      topRight: const Radius.circular(20).r,
                    ),
                  ),
                  builder: (_) {
                    return DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.6,
                      maxChildSize: 0.8,
                      builder: (BuildContext context,
                              ScrollController scrollController) =>
                          SingleChildScrollView(
                        controller: scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: RestaurantTagsModalBottomSheet(
                          title: Text(
                            '태그',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          isHome: true,
                        ),
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
              child: const Text('태그 편집')),
        ],
      ),
    );
  }
}
