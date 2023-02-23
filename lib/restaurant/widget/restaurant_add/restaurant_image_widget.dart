import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/const/const_data.dart';
import 'package:recommend_restaurant/common/widget/overlay_loader.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

class RestaurantImageWidget extends StatelessWidget {
  const RestaurantImageWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantAddProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        height: 70,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: () async {
                    if (provider.images.length < maxImagesCount) {
                      await provider.pickImage();
                    }
                  },
                  child: _CameraIconWidget(
                    imageLength: provider.images.length,
                  ),
                );
              }

              return GestureDetector(
                onTap: () {
                  final overlayLoader = OverlayLoader(
                    photos: provider.images,
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
                          provider.images[index - 1],
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
                            provider.removeImage(index - 1);
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
            itemCount: provider.images.length + 1,
          ),
        ),
      ),
    );
  }
}

class _CameraIconWidget extends StatelessWidget {
  final int imageLength;

  const _CameraIconWidget({
    required this.imageLength,
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
