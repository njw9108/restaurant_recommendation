import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/widget/bottom_sheet_wrap.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

class CategoryBottomSheet extends StatelessWidget {
  final Function(String) onTap;

  CategoryBottomSheet({
    super.key,
    required this.onTap,
  });

  final List<String> categoryList = ['집 근처', '회사 근처', '데이트', '친구', '기타'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantAddProvider>();

    return BottomSheetWrap(
      title: '카테고리를 선택해주세요',
      child: Column(
        children: [
          ...categoryList
              .map(
                (e) => BottomSheetItemWidget(
                  title: e,
                  selectedWidget: provider.category == e
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        )
                      : null,
                  onTap: onTap,
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

class TagBottomSheet extends StatelessWidget {
  final Function(String) onTap;

  TagBottomSheet({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final List<String> tagList = ['한식', '중식', '일식', '양식', '매움', '달콤함', '국물요리'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantAddProvider>();

    return BottomSheetWrap(
      title: '태그를 선택해주세요 ${provider.tags.length}/${provider.maxTagsCount}',
      child: Column(
        children: [
          ...tagList
              .map(
                (e) => BottomSheetItemWidget(
                  title: e,
                  selectedWidget: provider.tags.contains(e)
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        )
                      : null,
                  onTap: onTap,
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
