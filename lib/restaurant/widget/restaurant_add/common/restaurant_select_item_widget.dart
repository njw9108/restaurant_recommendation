import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            title,
            style: const TextStyle(
              color: GRAY_COLOR,
              fontSize: 12,
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
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                builder: (_) {
                  return bottomSheet;
                },
              );
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 5),
            title: content.trim().isEmpty
                ? Text(
                    emptyText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: GRAY_COLOR,
                    ),
                  )
                : Text(
                    content,
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
