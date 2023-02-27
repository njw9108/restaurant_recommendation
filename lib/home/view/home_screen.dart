import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';

import '../../common/const/const_data.dart';
import '../../restaurant/provider/restaurant_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '마이슐랭',
      child: Column(
        children: [
          const FavoriteRestaurantListWidget(),
        ],
      ),
    );
  }
}

class FavoriteRestaurantListWidget extends StatefulWidget {
  const FavoriteRestaurantListWidget({
    super.key,
  });

  @override
  State<FavoriteRestaurantListWidget> createState() =>
      _FavoriteRestaurantListWidgetState();
}

class _FavoriteRestaurantListWidgetState
    extends State<FavoriteRestaurantListWidget> {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: context.read<RestaurantProvider>().getRestaurantStream(
                limit: _limit,
              ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              restaurantList = snapshot.data!.docs;
              if (restaurantList.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '내가 좋아하는 식당',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 23,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          controller: controller,
                          itemBuilder: (_, index) {
                            return Container(
                              width: 160,
                              height: 160,
                              color: Colors.red,
                              child: const Text('1'),
                            );
                          },
                          itemCount: restaurantList.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(
                              width: 10,
                              height: 10,
                            );
                          },
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return const Center(child: Text("좋아하는 식당을 추가해주세요!"));
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ],
    );
  }
}
