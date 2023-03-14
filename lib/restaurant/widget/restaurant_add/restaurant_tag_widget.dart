import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';
import 'package:recommend_restaurant/restaurant/widget/restaurant_add/common/restaurant_select_item_widget.dart';

import 'modal_bottom_sheet/tags_modal/restaurant_tags_modal_bottom_sheet.dart';

class RestaurantTagWidget extends StatelessWidget {
  const RestaurantTagWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: RestaurantSelectItemWidget(
        title: '태그',
        bottomSheet: const RestaurantTagsModalBottomSheet(),
        emptyText: '태그를 선택해 주세요.',
        content: context.watch<RestaurantAddProvider>().tags.join(', '),
      ),
    );
  }
}
