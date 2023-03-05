import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../common/const/color.dart';
import '../../../../../common/const/const_data.dart';
import '../../../../provider/restaurant_provider.dart';

class RestaurantTagAddFiled extends StatelessWidget {
  final TextEditingController textController;

  const RestaurantTagAddFiled({
    super.key,
    required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            height: 60,
            child: TextField(
              maxLength: 8,
              controller: textController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xfffcf4e4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
                hintText: '태그 입력',
                prefixIcon: const Icon(Icons.add),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isEmpty) {
                return;
              }
              final tagList = context.read<RestaurantProvider>().tagList;

              if (tagList.length < maxTotalTagListCount) {
                FocusManager.instance.primaryFocus?.unfocus();
                tagList.add(textController.text);

                context.read<RestaurantProvider>().tagList =
                    List.from(tagList.toSet());

                textController.text = '';
              } else {
                FocusManager.instance.primaryFocus?.unfocus();
                showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        content: Text('태그 목록이 가득 찼습니다.'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('확인'),
                          ),
                        ],
                      );
                    });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY_COLOR,
            ),
            child: const Text('추가'),
          ),
        ),
      ],
    );
  }
}
