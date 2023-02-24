import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:recommend_restaurant/common/model/pagination_model.dart';
import 'package:recommend_restaurant/common/repository/base_pagination_repository.dart';

class _PaginationInfo {
  String query;
  int size;
  int page;
  bool fetchMore;
  bool forceRefetch;

  _PaginationInfo({
    required this.query,
    this.size = 20,
    this.page = 1,
    this.fetchMore = false,
    this.forceRefetch = false,
  });
}

class PaginationProvider<T, U extends IBasePaginationRepository<T>>
    with ChangeNotifier {
  final U repository;
  final paginationThrottle = Throttle(
    const Duration(seconds: 1),
    initialValue: _PaginationInfo(query: ''),
    checkEquality: false,
  );

  PaginationProvider({
    required this.repository,
  }) {
    paginationThrottle.values.listen((state) {
      _throttlePagination(state);
    });
  }

  PaginationBase cursorState = PaginationNotYet();
  int page = 1;

  Future<void> paginate({
    required String query,
    int size = 15,
    int page = 1,
    //true인 경우 추가로 데이터 더 가져오기,
    //false는 새로고침(현재상태를 덮어 씌움)
    bool fetchMore = false,
    //강제로 다시 로딩
    //true-CursorPaginationLoading()
    bool forceRefetch = false,
  }) async {
    paginationThrottle.setValue(
      _PaginationInfo(
        query: query,
        size: size,
        page: page,
        forceRefetch: forceRefetch,
        fetchMore: fetchMore,
      ),
    );
  }

  Future<void> _throttlePagination(_PaginationInfo info) async {
    String query = info.query;
    int size = info.size;
    bool fetchMore = info.fetchMore;
    bool forceRefetch = info.forceRefetch;
    try {
      //5가지 가능성
      //State의 상태
      //상태가
      //1)CursorPagination - 정상적으로 데이터가 있는 상태

      //2)CursorPaginationLoading - 데이터가 로딩중인 상태(현재 캐시 없음 - forceRefetch)

      //3)CursorPaginationError - 에러가 있는 상태

      //4)CursorPaginationRefetching - 첫번째 페이지부터 다시 데이터 가져올때

      //5)CursorPaginationFetchMore - 추가 데이터를 pagination 하라는 요청을 받았을때

      //바로 반환하는 상황
      //1) hasMore = false(기존 상태에서 이미 다음 데이터가 없다는 값을 들고 있다면)
      //2) 로딩중 - featchMore가 true일때(추가 데이터를 가져오는 상황)
      //        - fetchMore가 false일때는 기존 요청을 멈추고 새로고침을 한다.
      if (forceRefetch) {
        page = 1;
      } else if (page == 3) {
        return;
      }

      if (cursorState is Pagination<T> && !forceRefetch) {
        final pState = cursorState as Pagination<T>;
        if (pState.meta.isEnd) {
          return;
        }
      }

      //3가지 로딩 상태
      final isLoading = cursorState is PaginationLoading;
      final isRefetching = cursorState is PaginationRefetching;
      final isFetchingMore = cursorState is PaginationFetchingMore;

      //2번 반환 상황
      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }

      // Pagination Params 생성
      //PaginationParams params = PaginationParams(count: size);

      // fetching More 상황
      // 데이터를 추가로 더 가져오는 상황
      if (fetchMore) {
        final pState = cursorState as Pagination<T>;

        cursorState = PaginationFetchingMore<T>(
          meta: pState.meta,
          documents: pState.documents,
        );
        notifyListeners();

        page += 1;

        // params = params.copyWith(
        //   after: pState.data.last.id,
        // );
      }
      //데이터를 처음부터 가져오는 상황
      else {
        //만약 데이터가 있는 상황이라면
        //기존 데이터를 보존한채로 Fetch(API요청) 진행
        if (cursorState is Pagination<T> && !forceRefetch) {
          final pState = cursorState as Pagination<T>;

          cursorState = PaginationRefetching<T>(
            meta: pState.meta,
            documents: pState.documents,
          );
          notifyListeners();
        } else {
          //나머지 상황
          cursorState = PaginationLoading();
          notifyListeners();
        }
      }

      final resp = await repository.paginate(
        query: query,
        size: size,
        page: page,
      );

      if (cursorState is PaginationFetchingMore) {
        final pState = cursorState as PaginationFetchingMore<T>;

        //기존 데이터에 새로운 데이터 추가
        cursorState = pState.copyWith(
          documents: [
            ...pState.documents,
            ...resp.documents,
          ],
        );
        notifyListeners();
      } else {
        cursorState = resp;
        notifyListeners();
      }
    } catch (e, stack) {
      print(e);
      print(stack);
      cursorState = PaginationError(message: '가게 데이터를 가져오지 못했습니다.');
      notifyListeners();
    }
  }
}
