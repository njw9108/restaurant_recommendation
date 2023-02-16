import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/firestore_constants.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/restaurant/model/restaurant_model.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_provider.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final ScrollController controller = ScrollController();
  int _limit = 20;
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
    return DefaultLayout(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final model = RestaurantModel(
            name: '백반집',
            thumbnail: '',
            restaurantType: '타입',
            rating: 4.5,
            comment: '아주 맛있었다. 담에 또가야지',
            images: [],
            categories: ['한식', '갈비탕'],
            address: '서울 강남구',
          );

          context
              .read<RestaurantProvider>()
              .saveRestaurantModelToFirebase(model);
        },
        child: const Icon(Icons.add),
      ),
      child: Column(
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: StreamBuilder<QuerySnapshot>(
              stream: context
                  .read<RestaurantProvider>()
                  .getRestaurantStream(_limit),
              builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  restaurantList = snapshot.data!.docs;
                  if (restaurantList.isNotEmpty) {
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (_, index) {
                        final date = DateTime.fromMillisecondsSinceEpoch(
                            snapshot.data?.docs[index]
                                .get(FirestoreRestaurantConstants.createdAt));
                        return Column(
                          children: [
                            Text(
                                '${date.month}/${date.day} - ${date.hour}:${date.minute}:${date.second}'),
                            Text(snapshot.data?.docs[index]
                                .get(FirestoreRestaurantConstants.name)),
                            Text(snapshot.data?.docs[index].get(
                                FirestoreRestaurantConstants.restaurantType)),
                            Text(snapshot.data?.docs[index]
                                .get(FirestoreRestaurantConstants.comment)),
                          ],
                        );
                      },
                      separatorBuilder: (_, index) {
                        return const SizedBox(
                          height: 20,
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
    );
  }
}
