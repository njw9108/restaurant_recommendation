import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

import 'common/restaurant_select_item_widget.dart';
import 'modal_bottom_sheet/category_modal/restaurant_category_modal_bottom_sheet.dart';

class RestaurantCategoryWidget extends StatelessWidget {
  const RestaurantCategoryWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: RestaurantSelectItemWidget(
        title: '카테고리',
        bottomSheet: const RestaurantCategoryModalBottomSheet(),
        emptyText: '카테고리를 선택해 주세요.',
        content: context.watch<RestaurantAddProvider>().category,
      ),
    );
  }
}
