import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

import '../../../common/widget/custom_text_field.dart';

class RestaurantCommentWidget extends StatelessWidget {
  const RestaurantCommentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
      child: CustomTextFormField(
        hintText: '코멘트',
        maxLine: 6,
        onChanged: (value) {
          context.read<RestaurantAddProvider>().comment = value;
        },
      ),
    );
  }
}
