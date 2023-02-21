import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/common/widget/app_icon.dart';
import 'package:recommend_restaurant/common/widget/overlay_loader.dart';
import 'package:recommend_restaurant/common/widget/star_rating.dart';
import 'package:recommend_restaurant/restaurant/model/restaurant_model.dart';
import 'package:intl/intl.dart';

class RestaurantDetailScreen extends StatefulWidget {
  static String get routeName => 'restaurantDetail';

  final RestaurantModel model;

  const RestaurantDetailScreen({
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  List<CachedNetworkImage> cacheImage = [];
  PageController pageController = PageController(initialPage: 0);
  int curPage = 0;

  @override
  void initState() {
    super.initState();
    cacheImage = _makeImageList(
      urls: widget.model.images,
      fit: BoxFit.cover,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = MediaQuery.of(context).size.height / 2.7;
    String createdAt = '';
    if (widget.model.createdAt != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(widget.model.createdAt!);
      DateFormat format = DateFormat('yyyy-MM-dd');
      createdAt = format.format(date);
    }
    return DefaultLayout(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 20.0, right: 20, bottom: 25, top: 5),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
              ),
              child: const Text('수정하기'),
            ),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              height: imageHeight,
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (value) {
                  setState(() {
                    curPage = value;
                  });
                },
                itemBuilder: (_, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GestureDetector(
                      onTap: () {
                        final newImages = _makeImageList(
                          urls: widget.model.images,
                          fit: BoxFit.fitWidth,
                        );

                        final overlayLoader = OverlayLoader(
                          networkImages: newImages,
                          photoIndex: curPage,
                        );
                        overlayLoader.showFullPhoto(context);
                      },
                      child: cacheImage[index],
                    ),
                  );
                },
                itemCount: widget.model.images.length,
              ),
            ),
          ),
          Positioned(
            top: 45,
            left: 20,
            right: 20,
            child: Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: const AppIcon(
                  icon: Icons.arrow_back_ios_new_sharp,
                  backgroundColor: Colors.white54,
                  iconColor: Colors.black54,
                  size: 35,
                  iconSize: 20,
                ),
              ),
            ),
          ),
          Positioned(
            top: imageHeight - 80,
            left: 20,
            right: 20,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15)),
                child: Text(
                  '${curPage + 1} / ${widget.model.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: imageHeight - 20,
            child: Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
              ),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(createdAt),
                    ),
                    Text(
                      widget.model.category,
                      style: const TextStyle(
                        color: BODY_TEXT_COLOR,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      widget.model.name,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    StarRating(
                      rating: widget.model.rating,
                      iconSize: 18,
                    ),
                    Text(
                      widget.model.address,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing: 20,
                                childAspectRatio: 1.7),
                        itemBuilder: (_, index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration:
                                const BoxDecoration(color: Colors.yellow),
                            alignment: Alignment.center,
                            child: Text(
                              widget.model.tags[index],
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 10),
                            ),
                          );
                        },
                        itemCount: widget.model.tags.length,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.model.comment,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            //top: (MediaQuery.of(context).size.height / 2.4) - 20,
            top: imageHeight - 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                AppIcon(icon: Icons.favorite),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<CachedNetworkImage> _makeImageList({
    required List<String> urls,
    required BoxFit fit,
  }) {
    List<CachedNetworkImage> imageList = [];
    for (int i = 0; i < urls.length; i++) {
      final image = CachedNetworkImage(
        fit: fit,
        imageUrl: urls[i],
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            color: PRIMARY_COLOR,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.restaurant_menu,
            size: 25,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
            color: PRIMARY_COLOR,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.restaurant_menu,
            size: 25,
          ),
        ),
      );
      imageList.add(image);
    }
    return imageList;
  }
}
