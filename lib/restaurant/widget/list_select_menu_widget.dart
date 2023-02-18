import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

class ListSelectMenuWidget extends StatelessWidget {
  final String title;
  final String? content;
  final String emptyText;
  final Widget bottomSheetWidget;

  const ListSelectMenuWidget({
    super.key,
    required this.title,
    required this.content,
    required this.emptyText,
    required this.bottomSheetWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            title,
            style: const TextStyle(
              color: BODY_TEXT_COLOR,
              fontSize: 12,
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: BODY_TEXT_COLOR,
              ),
            ),
          ),
          child: ListTile(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                builder: (_) {
                  return ChangeNotifierProvider.value(
                    value: context.watch<RestaurantAddProvider>(),
                    child: SizedBox(
                      height: 400,
                      child: bottomSheetWidget,
                    ),
                  );
                },
              );
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 5),
            title: content == null
                ? Text(
              emptyText,
              style: const TextStyle(
                fontSize: 16,
                color: BODY_TEXT_COLOR,
              ),
            )
                : Text(
              content!,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right_sharp),
          ),
        ),
      ],
    );
  }
}
