import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/home/view/home_screen.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_provider.dart';
import 'package:recommend_restaurant/restaurant/view/restaurant_screen.dart';
import 'package:recommend_restaurant/user/view/profile_screen.dart';

class RootTab extends StatefulWidget {
  static String routeName = 'home';

  const RootTab({Key? key}) : super(key: key);

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  late TabController controller;

  List<Widget> screenList = [
    const HomeScreen(),
    const RestaurantScreen(),
    const ProfileScreen(),
  ];

  int index = 0;

  @override
  void initState() {
    super.initState();
    //context.read<RestaurantProvider>().precacheFireStoreImage(context);
    controller = TabController(length: screenList.length, vsync: this);

    controller.addListener(tabListener);
  }

  void tabListener() {
    setState(() {
      index = controller.index;
    });
  }

  @override
  void dispose() {
    controller.removeListener(tabListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 10,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          controller.animateTo(index);
        },
        backgroundColor: SECONDARY_COLOR,
        unselectedItemColor: GRAY_COLOR,
        selectedItemColor: Colors.white,
        currentIndex: index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              size: 26,
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.restaurant,
              size: 26,
            ),
            label: '식당',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
              size: 26,
            ),
            label: '프로필',
          ),
        ],
      ),
      child: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: screenList,
      ),
    );
  }
}
