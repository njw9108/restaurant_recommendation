import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

import '../../../../../common/const/color.dart';
import '../../../../../common/const/const_data.dart';
import '../common/bottom_sheet_list_item.dart';

final List<String> tagList = ['한식', '중식', '일식', '양식', '매움', '달콤함', '국물요리'];

class RestaurantTagsModalBottomSheet extends StatelessWidget {
  const RestaurantTagsModalBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tags = context.watch<RestaurantAddProvider>().tags;

    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '태그를 선택해주세요 ${tags.length}/$maxTagsCount',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  ...tagList
                      .map(
                        (e) => BottomSheetListItem(
                          title: e,
                          selectedWidget: tags.contains(e)
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
                          },
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
