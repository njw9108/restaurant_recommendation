import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

import '../../../common/widget/custom_text_field.dart';

class RestaurantCommentWidget extends StatefulWidget {
  final String? comment;

  const RestaurantCommentWidget({
    Key? key,
    this.comment,
  }) : super(key: key);

  @override
  State<RestaurantCommentWidget> createState() =>
      _RestaurantCommentWidgetState();
}

class _RestaurantCommentWidgetState extends State<RestaurantCommentWidget> {
  final controller = TextEditingController();

  @override
  void initState() {
    controller.text = widget.comment ?? '';

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: CustomTextFormField(
        hintText: '코멘트',
        maxLine: 6,
        maxLength: 500,
        counterText: '',
        controller: controller,
        onChanged: (value) {
          context.read<RestaurantAddProvider>().comment = value;
        },
      ),
    );
  }
}
