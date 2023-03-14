import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      padding: EdgeInsets.symmetric(vertical: 18.0.h),
      child: SizedBox(
        height: 70.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                            width: 70.w,
                            height: 70.h,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10).r,
                              child: CachedNetworkImage(
                                imageUrl: provider.networkImage[index - 1].url,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 50.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20).r,
                                  ),
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator
                                      .adaptive(),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 70.w,
                                  height: 70.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20).r,
                                  ),
                                  child: Icon(
                                    Icons.error,
                                    size: 25.sp,
                                    color: PRIMARY_COLOR,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            width: 70.w,
                            height: 70.h,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10).r,
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
                          padding: REdgeInsets.all(1),
                          decoration: BoxDecoration(
                              color: PRIMARY_COLOR,
                              borderRadius: BorderRadius.circular(20).r),
                          child: Icon(
                            Icons.close,
                            size: 23.sp,
                          ),
                        ),
                      ),
                    ),
                    if (index - 1 == provider.thumbnailIndex)
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 70.w,
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10))
                                .r,
                          ),
                          child: Text(
                            '대표 사진',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.sp,
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
              return SizedBox(
                width: 16.w,
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
      width: 70.w,
      height: 70.h,
      decoration: BoxDecoration(
          border: Border.all(
            color: GRAY_COLOR,
          ),
          borderRadius: BorderRadius.circular(10).r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt,
            color: GRAY_COLOR,
          ),
          SizedBox(
            height: 5.h,
          ),
          Text('$imageLength/$maxImagesCount'),
        ],
      ),
    );
  }
}
