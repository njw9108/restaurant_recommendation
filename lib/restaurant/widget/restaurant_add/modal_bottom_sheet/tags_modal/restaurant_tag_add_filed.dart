import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            height: 60.h,
            child: TextField(
              maxLength: 8,
              controller: textController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xfffcf4e4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8).r,
                  borderSide: BorderSide.none,
                ),
                counterText: '',
                hintText: 'ํ๊ทธ ์๋ ฅ',
                prefixIcon: const Icon(Icons.add),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 20.w,
        ),
        SizedBox(
          height: 40.h,
          child: ElevatedButton(
            onPressed: () {
              FocusScope.of(context).unfocus();

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
                        content: const Text('ํ๊ทธ ๋ชฉ๋ก์ด ๊ฐ๋ ์ฐผ์ต๋๋ค.'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('ํ์ธ'),
                          ),
                        ],
                      );
                    });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY_COLOR,
            ),
            child: const Text('์ถ๊ฐ'),
          ),
        ),
      ],
    );
  }
}
