import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../common/const/color.dart';
import '../../common/layout/default_layout.dart';
import '../../common/util/utils.dart';
import '../model/restaurant_model.dart';
import '../provider/restaurant_add_provider.dart';
import '../widget/restaurant_add/restaurant_category_widget.dart';
import '../widget/restaurant_add/restaurant_comment_widget.dart';
import '../widget/restaurant_add/restaurant_image_widget.dart';
import '../widget/restaurant_add/restaurant_name_address_widget.dart';
import '../widget/restaurant_add/restaurant_rating_widget.dart';
import '../widget/restaurant_add/restaurant_tag_widget.dart';
import 'package:collection/collection.dart';

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
              appbarActions: _buildAppbarActions(),
              bottomNavigationBar: _BottomNavBar(
                formKey: _formKey,
                model: widget.model,
              ),
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

  List<Widget> _buildAppbarActions() {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: PopupMenuButton(
          //initialValue: selectedMenu,
          child: const Icon(
            Icons.more_vert,
          ),
          onSelected: (item) async {
            if (item == '대표') {
              List<Widget> imageList = [
                ...makeImageList(
                  urls: context
                      .read<RestaurantAddProvider>()
                      .networkImage
                      .map((e) => e.url)
                      .toList(),
                  fit: BoxFit.cover,
                ),
                ...context.read<RestaurantAddProvider>().images.map(
                      (e) => Image.file(
                        e,
                        fit: BoxFit.cover,
                      ),
                    ),
              ];

              final selectedIndex = await showDialog(
                context: context,
                builder: (context) {
                  if (imageList.isEmpty) {
                    return AlertDialog(
                      content: const Text('사진이 없습니다.'),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PRIMARY_COLOR,
                          ),
                          child: const Text('확인'),
                        ),
                      ],
                    );
                  }

                  return AlertDialog(
                    content: const Text('대표사진 설정'),
                    actionsAlignment: MainAxisAlignment.spaceAround,
                    actions: imageList.mapIndexed((index, e) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context, index);
                        },
                        child: SizedBox(
                          width: 70,
                          height: 70,
                          child: e,
                        ),
                      );
                    }).toList(),
                  );
                },
              );

              if (selectedIndex != null) {
                context.read<RestaurantAddProvider>().thumbnailIndex =
                    selectedIndex;
              }
            }
          },
          itemBuilder: (_) => <PopupMenuEntry>[
            const PopupMenuItem(
              value: '대표',
              child: Text('대표사진 설정'),
            ),
          ],
        ),
      ),
    ];
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required GlobalKey<FormState> formKey,
    required this.model,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final RestaurantModel? model;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 20.0, right: 20, bottom: 25, top: 5),
          child: ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (model != null) {
                  //update
                  if (model!.id == null) {
                    print('id null');
                    context.pop();
                    return;
                  }
                  await context
                      .read<RestaurantAddProvider>()
                      .updateRestaurantModelToFirebase(model!.id!);
                } else {
                  //create
                  await context
                      .read<RestaurantAddProvider>()
                      .uploadRestaurantData();
                }
                context.pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY_COLOR,
            ),
            child: const Text('작성완료'),
          ),
        )
      ],
    );
  }
}
