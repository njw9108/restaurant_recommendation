import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/const/const_data.dart';
import '../../../restaurant/model/restaurant_model.dart';
import '../../../restaurant/provider/restaurant_provider.dart';

class SearchTagsListWidget extends StatefulWidget {
  const SearchTagsListWidget({Key? key}) : super(key: key);

  @override
  State<SearchTagsListWidget> createState() => _SearchTagsListWidgetState();
}

class _SearchTagsListWidgetState extends State<SearchTagsListWidget> {
  final ScrollController controller = ScrollController();
  int _limit = firestoreDataLimit;
  String heroKey = '';
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
          stream: context.read<RestaurantProvider>().searchTagRestaurantStream(
            limit: _limit,
            tags: ['뉴'],
          ),
          builder: (context, snapshot) {
            restaurantList = snapshot.data?.docs ?? [];
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '태그로 검색',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 23,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (restaurantList.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('일치하는 식당이 없습니다.'),
                      ),
                    ),
                  if (restaurantList.isNotEmpty)
                    SizedBox(
                      height: 250,
                      child: snapshot.hasData
                          ? ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              controller: controller,
                              itemBuilder: (_, index) {
                                DocumentSnapshot doc = restaurantList[index];
                                final model = RestaurantModel.fromDocument(doc);
                                return Text('1');
                              },
                              itemCount: restaurantList.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const SizedBox(
                                  width: 10,
                                  height: 10,
                                );
                              },
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                    )
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
