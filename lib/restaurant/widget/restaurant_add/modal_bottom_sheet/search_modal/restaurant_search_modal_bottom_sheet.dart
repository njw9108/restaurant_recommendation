import 'package:flutter/material.dart';
import 'restaurant_search_bar.dart';
import 'restaurant_search_pagination_widget.dart';

class RestaurantSearchModalBottomSheet extends StatefulWidget {
  const RestaurantSearchModalBottomSheet({
    super.key,
  });

  @override
  State<RestaurantSearchModalBottomSheet> createState() =>
      _RestaurantSearchModalBottomSheetState();
}

class _RestaurantSearchModalBottomSheetState
    extends State<RestaurantSearchModalBottomSheet> {
  final TextEditingController textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        //타이틀
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            '식당 검색',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        //검색창
        RestaurantSearchBar(
          textController: textController,
        ),
        const SizedBox(
          height: 32,
        ),
        //검색 결과 리스트
        const RestaurantSearchPaginationWidget(),
      ],
    );
  }
}
