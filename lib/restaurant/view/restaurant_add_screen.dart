import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../common/layout/default_layout.dart';
import '../model/restaurant_model.dart';
import '../provider/restaurant_add_provider.dart';
import '../widget/restaurant_add/restaurant_category_widget.dart';
import '../widget/restaurant_add/restaurant_comment_widget.dart';
import '../widget/restaurant_add/restaurant_image_widget.dart';
import '../widget/restaurant_add/restaurant_name_address_widget.dart';
import '../widget/restaurant_add/restaurant_rating_widget.dart';
import '../widget/restaurant_add/restaurant_tag_widget.dart';

class RestaurantAddScreen extends StatefulWidget {
  static String get routeName => 'restaurantAdd';

  final RestaurantModel? model;

  const RestaurantAddScreen({
    Key? key,
    this.model,
  }) : super(key: key);

  @override
  State<RestaurantAddScreen> createState() => _RestaurantAddScreenState();
}

class _RestaurantAddScreenState extends State<RestaurantAddScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    context.read<RestaurantAddProvider>().clearAllData();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (widget.model != null) {
          context
              .read<RestaurantAddProvider>()
              .setModelForUpdate(widget.model!);
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Form(
            key: _formKey,
            child: DefaultLayout(
              title: '식당 추가',
              appbarActions: [
                IconButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (widget.model != null) {
                        //update
                        if (widget.model!.id == null) {
                          print('id null');
                          context.pop();
                          return;
                        }
                        await context
                            .read<RestaurantAddProvider>()
                            .updateRestaurantModelToFirebase(widget.model!.id!);
                      } else {
                        //create
                        await context
                            .read<RestaurantAddProvider>()
                            .uploadRestaurantData();
                      }
                      context.pop();
                    }
                  },
                  icon: const Icon(
                    Icons.done,
                  ),
                ),
              ],
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RestaurantImageWidget(),
                    RestaurantNameAddressWidget(
                      name: widget.model?.name,
                      address: widget.model?.address,
                    ),
                    RestaurantCommentWidget(
                      comment: widget.model?.comment,
                    ),
                    const RestaurantCategoryWidget(),
                    const RestaurantTagWidget(),
                    RestaurantRatingWidget(
                      initRating: widget.model?.rating ?? 1,
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
