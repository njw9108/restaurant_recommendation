import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/const/const_data.dart';
import 'package:recommend_restaurant/common/widget/overlay_loader.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

import '../../../common/util/utils.dart';

class RestaurantImageWidget extends StatelessWidget {
  const RestaurantImageWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantAddProvider>();
    final totalLength = provider.networkImage.length + provider.images.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
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
                    if (totalLength < maxImagesCount) {
                      await provider.pickImage();
                    }
                  },
                  child: _CameraIconWidget(
                    imageLength: totalLength,
                  ),
                );
              }

              return GestureDetector(
                onTap: () {
                  final newImages = makeImageList(
                    urls: provider.networkImage.map((e) => e.url).toList(),
                    fit: BoxFit.fitWidth,
                  );

                  final overlayLoader = OverlayLoader(
                    imageFiles: provider.images,
                    networkImages: newImages,
                    photoIndex: index - 1,
                  );
                  overlayLoader.showFullPhoto(context);
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    provider.networkImage.length > index - 1
                        ? SizedBox(
                            width: 70,
                            height: 70,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: provider.networkImage[index - 1].url,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 95,
                                  height: 95,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const CircularProgressIndicator
                                      .adaptive(),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 95,
                                  height: 95,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.error,
                                    size: 25,
                                    color: PRIMARY_COLOR,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            width: 70,
                            height: 70,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                provider.images[
                                    index - provider.networkImage.length - 1],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    Positioned(
                      right: -7,
                      top: -7,
                      child: GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            return;
                          }
                          if (provider.networkImage.length > index - 1) {
                            provider.removeNetworkImage(index - 1);
                          } else {
                            provider.removeImage(
                                index - provider.networkImage.length - 1);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                              color: PRIMARY_COLOR,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Icon(
                            Icons.close,
                            size: 23,
                          ),
                        ),
                      ),
                    ),
                    if (index - 1 == provider.thumbnailIndex)
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
            itemCount: totalLength + 1,
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
