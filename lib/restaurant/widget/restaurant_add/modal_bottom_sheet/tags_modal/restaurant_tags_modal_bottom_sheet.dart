import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

import '../../../../../common/const/color.dart';
import '../../../../../common/const/const_data.dart';
import '../common/bottom_sheet_list_item.dart';
import 'restaurant_tag_add_filed.dart';

class RestaurantTagsModalBottomSheet extends StatefulWidget {
  const RestaurantTagsModalBottomSheet({Key? key}) : super(key: key);

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
    final totalTagList = context.watch<RestaurantAddProvider>().tagList;
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
            height: 16,
          ),
          RestaurantTagAddFiled(
            textController: textController,
          ),
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '태그 목록 (${totalTagList.length}/$maxTotalTagListCount)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  ...totalTagList
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
                                        fontWeight: FontWeight.w700,
                                      ),
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
