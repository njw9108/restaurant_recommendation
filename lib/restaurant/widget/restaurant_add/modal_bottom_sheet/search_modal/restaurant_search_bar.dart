import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../common/const/color.dart';
import '../../../../provider/restaurant_add_provider.dart';

class RestaurantSearchBar extends StatelessWidget {
  final TextEditingController textController;

  const RestaurantSearchBar({
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
              controller: textController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xfffcf4e4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: '장소, 주소 검색',
                prefixIcon: const Icon(Icons.search),
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
              FocusManager.instance.primaryFocus?.unfocus();
              final String place = textController.text;
              if (place.isNotEmpty) {
                context.read<RestaurantAddProvider>().query = place;
                context.read<RestaurantAddProvider>().paginate(
                      query: place,
                      forceRefetch: true,
                    );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY_COLOR,
            ),
            child: const Text('검색'),
          ),
        ),
      ],
    );
  }
}
