import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/home/provider/home_provider.dart';

import '../../../common/const/color.dart';
import '../../../common/const/const_data.dart';
import '../../../restaurant/provider/restaurant_provider.dart';
import '../common/expandable_tag_list.dart';
import '../common/restaurant_result_widget.dart';

class SearchTagsListWidget extends StatefulWidget {
  const SearchTagsListWidget({Key? key}) : super(key: key);

  @override
  State<SearchTagsListWidget> createState() => _SearchTagsListWidgetState();
}

class _SearchTagsListWidgetState extends State<SearchTagsListWidget> {
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
    final tagList = context.watch<RestaurantProvider>().tagList;

    return Column(
      children: [
        Container(
          padding: REdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '태그로 검색 (${(context.watch<HomeProvider>().selectedTagList.length)}/ 10)',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 23.sp,
                ),
              ),
              SizedBox(
                height: 5.h,
              ),
              Text(
                '#${context.watch<HomeProvider>().selectedTagList.join(', #')}',
                style: const TextStyle(
                  color: GRAY_COLOR,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              ExpandableTagList(
                tagController: tagController,
                tagList: tagList,
                title: '태그 리스트 보기',
                selectedList: context.watch<HomeProvider>().selectedTagList,
                onChanged: (value, index) {
                  final temp = context.read<HomeProvider>().selectedTagList;

                  if (!value) {
                    temp.remove(tagList[index]);
                  } else {
                    if (temp.length < 10) {
                      temp.add(tagList[index]);
                    }
                  }
                  context.read<HomeProvider>().selectedTagList =
                      List.from(temp.toSet());
                },
              ),
              SizedBox(
                height: 20.h,
              ),
              if (context.watch<HomeProvider>().selectedTagList.isEmpty)
                Center(
                  child: Padding(
                    padding: REdgeInsets.all(16.0),
                    child: const Text('일치하는 식당이 없습니다.'),
                  ),
                ),
              if (context.watch<HomeProvider>().selectedTagList.isNotEmpty)
                StreamBuilder<QuerySnapshot>(
                  stream: context
                      .read<RestaurantProvider>()
                      .searchTagRestaurantStream(
                        limit: _limit,
                        tags: context.watch<HomeProvider>().selectedTagList,
                      ),
                  builder: (context, snapshot) {
                    restaurantList = snapshot.data?.docs ?? [];
                    if (restaurantList.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: REdgeInsets.all(16.0),
                          child: const Text('일치하는 식당이 없습니다.'),
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
