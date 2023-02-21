import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:recommend_restaurant/common/const/color.dart';

class OverlayLoader {
  final List<File>? photos;
  final List<CachedNetworkImage>? networkImages;
  final int photoIndex;

  final OverlayEntry _overlayLoading =
      OverlayEntry(builder: (_) => const LoadingOverlayWidget());

  late OverlayEntry _overlayFullPhoto;

  OverlayLoader({
    this.photos,
    this.networkImages,
    this.photoIndex = 0,
  }) {
    if (photos != null) {
      _overlayFullPhoto = OverlayEntry(
        builder: (_) => FullPhotoOverlayWidget(
          files: photos!,
          onRemove: removeFullPhoto,
          photoIndex: photoIndex,
        ),
      );
    } else if (networkImages != null) {
      _overlayFullPhoto = OverlayEntry(
        builder: (_) => FullPhotoOverlayWidget(
          networkImages: networkImages,
          onRemove: removeFullPhoto,
          photoIndex: photoIndex,
        ),
      );
    }
  }

  void showLoading(BuildContext context) {
    Navigator.of(context).overlay!.insert(_overlayLoading);
  }

  void removeLoading() {
    _overlayLoading.remove();
  }

  void showFullPhoto(BuildContext context) {
    Navigator.of(context).overlay!.insert(_overlayFullPhoto);
  }

  void removeFullPhoto() {
    _overlayFullPhoto.remove();
  }
}

class LoadingOverlayWidget extends StatelessWidget {
  const LoadingOverlayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.7),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}

class FullPhotoOverlayWidget extends StatefulWidget {
  final List<File>? files;
  final List<CachedNetworkImage>? networkImages;
  final Function onRemove;
  final int photoIndex;

  const FullPhotoOverlayWidget({
    Key? key,
    this.files,
    this.networkImages,
    required this.onRemove,
    required this.photoIndex,
  }) : super(key: key);

  @override
  State<FullPhotoOverlayWidget> createState() => _FullPhotoOverlayWidgetState();
}

class _FullPhotoOverlayWidgetState extends State<FullPhotoOverlayWidget> {
  late PageController pageController;
  int curPage = 0;

  @override
  void initState() {
    super.initState();

    curPage = widget.photoIndex;
    pageController = PageController(
      initialPage: curPage,
    );
    pageController.addListener(() {
      setState(() {
        if (pageController.page!.round() != curPage) {
          curPage = pageController.page!.toInt();
        }
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.vertical,
      key: const Key('key'),
      onDismissed: (_) {
        widget.onRemove();
      },
      child: Container(
        color: Colors.black.withOpacity(0.9),
        alignment: Alignment.center,
        child: Stack(
          children: [
            PageView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: pageController,
              children:
                  _buildImages(isNetworkImages: widget.networkImages != null),
            ),
            Positioned(
              right: 20,
              top: 50,
              child: GestureDetector(
                onTap: () {
                  widget.onRemove();
                },
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      color: PRIMARY_COLOR,
                      borderRadius: BorderRadius.circular(30)),
                  child: const Icon(
                    Icons.close,
                    size: 30,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    '${curPage + 1}/${widget.networkImages != null ? widget.networkImages!.length : widget.files!.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildImages({
    required bool isNetworkImages,
  }) {
    if (isNetworkImages) {
      return widget.networkImages!;
    } else {
      return widget.files!
          .map(
            (e) => Image.file(
              e,
              fit: BoxFit.fitWidth,
            ),
          )
          .toList();
    }
  }
}
