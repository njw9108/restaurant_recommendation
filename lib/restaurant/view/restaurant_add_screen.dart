import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/common/widget/custom_text_field.dart';
import 'package:recommend_restaurant/common/widget/overlay_loader.dart';
import 'package:recommend_restaurant/restaurant/model/restaurant_model.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_provider.dart';
import 'package:recommend_restaurant/restaurant/repository/kakao_address_repository.dart';
import 'package:recommend_restaurant/restaurant/widget/bottom_sheet_widget.dart';
import 'package:recommend_restaurant/restaurant/widget/list_select_menu_widget.dart';

import '../../common/const/const_data.dart';

class RestaurantAddScreen extends StatelessWidget {
  static String get routeName => 'restaurantAdd';

  const RestaurantAddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProxyProvider<KakaoAddressRepository,
                RestaurantAddProvider?>(
              create: (_) => null,
              update: (context, repository, previous) {
                if (previous == null) {
                  final provider = RestaurantAddProvider(
                    prefs: context.read<RestaurantProvider>().prefs,
                    addressRepository: repository,
                  );
                  return provider;
                } else {
                  return previous;
                }
              },
            ),
          ],
          child: const RestaurantAddScreenBuilder(),
        );
      },
    );
  }
}

class RestaurantAddScreenBuilder extends StatefulWidget {
  const RestaurantAddScreenBuilder({Key? key}) : super(key: key);

  @override
  State<RestaurantAddScreenBuilder> createState() =>
      _RestaurantAddScreenBuilderState();
}

class _RestaurantAddScreenBuilderState
    extends State<RestaurantAddScreenBuilder> {
  String name = '';
  String address = '';
  String comment = '';
  double rating = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantAddProvider = context.watch<RestaurantAddProvider>();

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: DefaultLayout(
        title: '식당 추가',
        appbarActions: [
          IconButton(
            onPressed: () async {
              RestaurantModel model = RestaurantModel(
                name: name,
                thumbnail: '',
                rating: rating,
                comment: comment,
                images: [],
                address: address,
                tags: restaurantAddProvider.tags,
                category: restaurantAddProvider.category ?? '',
              );
              await restaurantAddProvider.uploadRestaurantData(model);
              context.pop();
            },
            icon: const Icon(
              Icons.done,
            ),
          ),
        ],
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            restaurantAddProvider.getAddress('김밥');
                          },
                          child: Text('test')),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildImages(
                        images: restaurantAddProvider.images,
                        maxImages: int.parse(maxImagesCount),
                        onTap: () async {
                          if (restaurantAddProvider.images.length <
                              int.parse(maxImagesCount)) {
                            await restaurantAddProvider.pickImage(
                                source: ImageSource.gallery);
                          }
                        },
                        onRemove: (index) {
                          restaurantAddProvider.removeImage(index);
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildName(
                        onChanged: (value) {
                          name = value;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildAddress(
                        onChanged: (value) {
                          address = value;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildComment(
                        onChanged: (value) {
                          comment = value;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildCategory(
                        category: restaurantAddProvider.category,
                        onBottomSheetTap: (value) {
                          restaurantAddProvider.category = value;
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildTags(
                        tags: restaurantAddProvider.tags,
                        onBottomSheetTap: (value) {
                          if (restaurantAddProvider.tags.contains(value)) {
                            restaurantAddProvider.tags.remove(value);
                            restaurantAddProvider.tags =
                                List.from(restaurantAddProvider.tags);
                          } else {
                            if (restaurantAddProvider.tags.length <
                                int.parse(restaurantAddProvider.maxTagsCount)) {
                              restaurantAddProvider.tags.add(value);
                              restaurantAddProvider.tags =
                                  List.from(restaurantAddProvider.tags);
                            }
                          }
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildRating(),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _buildImages({
    required VoidCallback onTap,
    required Function(int) onRemove,
    required int maxImages,
    required List<File> images,
  }) {
    return SizedBox(
      height: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index) {
            if (index == 0) {
              return GestureDetector(
                onTap: onTap,
                child: _CameraIconWidget(
                  imageLength: images.length,
                  maxImagesCount: maxImages,
                ),
              );
            }

            return GestureDetector(
              onTap: () {
                final overlayLoader = OverlayLoader(
                  photos: images,
                  photoIndex: index - 1,
                );
                overlayLoader.showFullPhoto(context);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        images[index - 1],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -7,
                    top: -7,
                    child: GestureDetector(
                      onTap: () {
                        if (index - 1 >= 0) {
                          onRemove(index - 1);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                            color: PRIMARY_COLOR,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  if (index - 1 == 0)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 70,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10)),
                        ),
                        child: const Text(
                          '대표 사진',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          separatorBuilder: (_, index) {
            return const SizedBox(
              width: 16,
            );
          },
          itemCount: images.length + 1,
        ),
      ),
    );
  }

  Padding _buildComment({
    required ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomTextFormField(
        hintText: '코멘트',
        maxLine: 6,
        onChanged: onChanged,
      ),
    );
  }

  Padding _buildRating() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('평점'),
          const SizedBox(
            height: 8,
          ),
          RatingBar.builder(
            initialRating: 1,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            glowColor: Colors.limeAccent,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: PRIMARY_COLOR,
            ),
            onRatingUpdate: (value) {
              rating = value;
            },
          ),
        ],
      ),
    );
  }

  Padding _buildName({
    required ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomTextFormField(
        hintText: '가게 이름',
        onChanged: onChanged,
      ),
    );
  }

  Padding _buildAddress({
    required ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: CustomTextFormField(
        hintText: '주소',
        onChanged: onChanged,
      ),
    );
  }

  Padding _buildCategory({
    required String? category,
    required Function(String) onBottomSheetTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: ListSelectMenuWidget(
        title: '카테고리',
        content: category,
        emptyText: '카테고리를 선택해주세요.',
        bottomSheetWidget: CategoryBottomSheet(
          onTap: onBottomSheetTap,
        ),
      ),
    );
  }

  Padding _buildTags({
    required List<String> tags,
    required Function(String) onBottomSheetTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: ListSelectMenuWidget(
        title: '태그',
        content: tags.isEmpty ? null : tags.join(', '),
        emptyText: '태그를 선택해주세요.',
        bottomSheetWidget: TagBottomSheet(
          onTap: onBottomSheetTap,
        ),
      ),
    );
  }
}

class _CameraIconWidget extends StatelessWidget {
  final int imageLength;
  final int maxImagesCount;

  const _CameraIconWidget({
    required this.imageLength,
    required this.maxImagesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
          border: Border.all(
            color: BODY_TEXT_COLOR,
          ),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt,
            color: BODY_TEXT_COLOR,
          ),
          const SizedBox(
            height: 5,
          ),
          Text('$imageLength/$maxImagesCount'),
        ],
      ),
    );
  }
}
