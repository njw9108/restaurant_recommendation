import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/home/provider/home_provider.dart';

import '../../../common/const/const_data.dart';
import '../../../restaurant/provider/restaurant_provider.dart';
import '../common/expandable_tag_list.dart';
import '../common/restaurant_result_widget.dart';

class SearchCategoriesListWidget extends StatefulWidget {
  const SearchCategoriesListWidget({Key? key}) : super(key: key);

  @override
  State<SearchCategoriesListWidget> createState() =>
      _SearchCategoriesListWidgetState();
}

class _SearchCategoriesListWidgetState extends State<SearchCategoriesListWidget> {
  final ScrollController mainController = ScrollController();
  final ScrollController tagController = ScrollController();
  int _limit = firestoreDataLimit;
  String heroKey = '';
  final int _limitIncrement = 20;
  List<QueryDocumentSnapshot> restaurantList = [];

  @override
  void initState() {
    super.initState();
    mainController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    mainController.removeListener(_scrollListener);
    mainController.dispose();
    tagController.dispose();

    super.dispose();
  }

  void _scrollListener() {
    if (!mainController.hasClients) return;
    if (mainController.offset >= mainController.position.maxScrollExtent &&
        !mainController.position.outOfRange &&
        _limit <= restaurantList.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categoryList =
        List.from(context.watch<RestaurantProvider>().categoryList);
    if (!categoryList.contains('기타')) {
      categoryList.insert(0, '기타');
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '카테고리 검색 (${(context.watch<HomeProvider>().selectedCategoryList.length)}/ 5)',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 23,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                '#${context.watch<HomeProvider>().selectedCategoryList.join(', #')}',
                style: const TextStyle(
                  color: GRAY_COLOR,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ExpandableTagList(
                tagController: tagController,
                tagList: categoryList,
                title: '카테고리 리스트 보기',
                selectedList:
                    context.watch<HomeProvider>().selectedCategoryList,
                onChanged: (value, index) {
                  final temp =
                      context.read<HomeProvider>().selectedCategoryList;

                  if (!value) {
                    temp.remove(categoryList[index]);
                  } else {
                    if (temp.length < 5) {
                      temp.add(categoryList[index]);
                    }
                  }
                  context.read<HomeProvider>().selectedCategoryList =
                      List.from(temp.toSet());
                },
              ),
              const SizedBox(
                height: 20,
              ),
              if (context.watch<HomeProvider>().selectedCategoryList.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('일치하는 식당이 없습니다.'),
                  ),
                ),
              if (context.watch<HomeProvider>().selectedCategoryList.isNotEmpty)
                StreamBuilder<QuerySnapshot>(
                  stream: context
                      .read<RestaurantProvider>()
                      .searchCategoryRestaurantStream(
                        limit: _limit,
                        categories:
                            context.watch<HomeProvider>().selectedCategoryList,
                      ),
                  builder: (context, snapshot) {
                    restaurantList = snapshot.data?.docs ?? [];
                    if (restaurantList.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('일치하는 식당이 없습니다.'),
                        ),
                      );
                    }
                    return RestaurantResultWidget(
                      mainController: mainController,
                      restaurantList: restaurantList,
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
