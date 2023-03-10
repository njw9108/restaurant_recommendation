import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../common/const/color.dart';
import '../../../../../common/model/pagination_model.dart';
import '../../../../model/address_model.dart';
import '../../../../provider/restaurant_add_provider.dart';

class RestaurantSearchPaginationWidget extends StatefulWidget {
  const RestaurantSearchPaginationWidget({
    super.key,
  });

  @override
  State<RestaurantSearchPaginationWidget> createState() =>
      _RestaurantSearchPaginationWidgetState();
}

class _RestaurantSearchPaginationWidgetState
    extends State<RestaurantSearchPaginationWidget> {
  final ScrollController controller = ScrollController();

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
    if (controller.offset > controller.position.maxScrollExtent - 150) {
      context.read<RestaurantAddProvider>().paginate(
            query: context.read<RestaurantAddProvider>().query,
            fetchMore: true,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RestaurantAddProvider>().cursorState;

    if (state is PaginationNotYet) {
      return const Center(
        child: Text('식당을 검색해주세요.'),
      );
    }

    if (state is PaginationLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is PaginationError) {
      final pState = state;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            pState.message,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 16.h,
          ),
          const Text('검색이 실패했습니다. 다시 시도해주세요.'),
        ],
      );
    }

    final cp = state as Pagination<AddressModel>;

    return Expanded(
      child: ListView.separated(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (_, index) {
          if (index == cp.documents.length) {
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8.h,
              ),
              child: Center(
                child: cp is PaginationFetchingMore
                    ? const CircularProgressIndicator()
                    : const Text('마지막 데이터 입니다.'),
              ),
            );
          }

          final info = cp.documents[index];

          return GestureDetector(
            onTap: () {
              context.read<RestaurantAddProvider>().curAddressModel = info;
              Navigator.pop(context);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${index + 1}.'),
                SizedBox(height: 8.h),
                _RestaurantSearchResultWidget(info: info),
              ],
            ),
          );
        },
        itemCount: cp.documents.length + 1,
        separatorBuilder: (_, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0.h),
            child: const Divider(
              color: GRAY_COLOR,
            ),
          );
        },
      ),
    );
  }
}

class _RestaurantSearchResultWidget extends StatelessWidget {
  const _RestaurantSearchResultWidget({
    super.key,
    required this.info,
  });

  final AddressModel info;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              info.place ?? '',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(
              width: 10.w,
            ),
            Text(
              info.categoryName ?? '',
              style: TextStyle(
                fontSize: 15.sp,
                color: GRAY_COLOR,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5.h,
        ),
        Text(
          info.roadAddressName ?? '',
          style: TextStyle(
            fontSize: 15.sp,
            color: GRAY_COLOR,
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Text(
          "(지번) ${info.address ?? ''}",
          style: TextStyle(
            fontSize: 15.sp,
            color: GRAY_COLOR,
          ),
        ),
      ],
    );
  }
}
