import 'package:recommend_restaurant/common/model/pagination_model.dart';

abstract class IBasePaginationRepository<T> {
  Future<Pagination<T>> paginate({
    required String query,
    int page = 1,
    int size = 15,
  });
}
