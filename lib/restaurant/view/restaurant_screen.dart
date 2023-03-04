import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/const/const_data.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/restaurant/model/restaurant_model.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_provider.dart';
import 'package:recommend_restaurant/restaurant/view/restaurant_add_screen.dart';
import 'package:recommend_restaurant/restaurant/view/restaurant_detail_screen.dart';
import 'package:recommend_restaurant/restaurant/widget/restaurant_screen/restaurant_card.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final ScrollController controller = ScrollController();
  int _limit = firestoreDataLimit;
  final int _limitIncrement = 20;
  List<QueryDocumentSnapshot> restaurantList = [];

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    controller.dispose();
    _overlayEntry?.dispose();

    super.dispose();
  }

  void _scrollListener() {
    if (!controller.hasClients) return;
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange &&
        _limit <= restaurantList.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _createOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _sortDropdown(onRemove: _removeOverlay);
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '식당 목록',
      appbarActions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            onPressed: () {
              _createOverlay();
            },
            icon: const Icon(Icons.sort),
          ),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_COLOR,
        onPressed: () {
          context.goNamed(RestaurantAddScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Column(
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: StreamBuilder<QuerySnapshot>(
                stream: context.read<RestaurantProvider>().getRestaurantStream(
                      limit: _limit,
                      orderKey: context.watch<RestaurantProvider>().orderKey,
                      descending:
                          context.watch<RestaurantProvider>().descending,
                    ),
                builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    restaurantList = snapshot.data!.docs;
                    if (restaurantList.isNotEmpty) {
                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(10),
                        itemBuilder: (_, index) {
                          DocumentSnapshot doc = restaurantList[index];
                          final model = RestaurantModel.fromDocument(doc);

                          return GestureDetector(
                            onTap: () {
                              context.goNamed(
                                RestaurantDetailScreen.routeName,
                                extra: model,
                              );
                            },
                            child: RestaurantCard(
                              restaurantModel: model,
                            ),
                          );
                        },
                        separatorBuilder: (_, index) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 16.0),
                            child: Divider(
                              color: GRAY_COLOR,
                              height: 1,
                            ),
                          );
                        },
                        itemCount: snapshot.data?.docs.length ?? 0,
                        controller: controller,
                      );
                    } else {
                      return const Center(child: Text("식당을 추가해 주세요!"));
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  OverlayEntry _sortDropdown({required Function onRemove}) {
    List<String> values = SortType.values
        .map((e) => context.read<RestaurantProvider>().sortTypeToString(e))
        .toList();

    return OverlayEntry(
      maintainState: true,
      builder: (context) => CompositedTransformFollower(
        link: _layerLink,
        child: Material(
          color: Colors.black.withOpacity(0.4),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(children: [
                  ...values
                      .map(
                        (type) => _RestaurantSortItemWidget(
                          onTap: () {
                            final val = context
                                .read<RestaurantProvider>()
                                .stringToSortType(type);

                            context.read<RestaurantProvider>().sortType = val;
                            onRemove();
                          },
                          title: type,
                        ),
                      )
                      .toList(),
                  const SizedBox(
                    height: 16,
                  ),
                ]),
              ),
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  onRemove();
                },
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: const [],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantSortItemWidget extends StatelessWidget {
  final GestureTapCallback onTap;
  final String title;

  const _RestaurantSortItemWidget({
    required this.onTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected =
        context.read<RestaurantProvider>().stringToSortType(title) ==
            context.read<RestaurantProvider>().sortType;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.w700 : null,
                color: isSelected ? null : GRAY_COLOR,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
              ),
          ],
        ),
      ),
    );
  }
}
