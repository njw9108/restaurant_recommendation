import 'package:json_annotation/json_annotation.dart';

part 'pagination_model.g.dart';

abstract class PaginationBase {}

class PaginationError extends PaginationBase {
  final String message;

  PaginationError({
    required this.message,
  });
}

class PaginationLoading extends PaginationBase {}

@JsonSerializable(
  genericArgumentFactories: true,
)
class Pagination<T> extends PaginationBase {
  final PaginationMeta meta;
  final List<T> documents;

  Pagination({
    required this.meta,
    required this.documents,
  });

  Pagination copyWith({
    PaginationMeta? meta,
    List<T>? documents,
  }) {
    return Pagination<T>(
      meta: meta ?? this.meta,
      documents: documents ?? this.documents,
    );
  }

  factory Pagination.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$PaginationFromJson(json, fromJsonT);
}

@JsonSerializable()
class PaginationMeta {
  @JsonKey(name: 'pageable_count')
  final int pageableCount;
  @JsonKey(name: 'is_end')
  final bool isEnd;

  PaginationMeta({
    required this.pageableCount,
    required this.isEnd,
  });

  PaginationMeta copyWith({
    int? pageableCount,
    bool? isEnd,
  }) {
    return PaginationMeta(
      pageableCount: pageableCount ?? this.pageableCount,
      isEnd: isEnd ?? this.isEnd,
    );
  }

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
}

//새로고침
class PaginationRefetching<T> extends Pagination<T> {
  PaginationRefetching({
    required super.meta,
    required super.documents,
  });
}

//리스트의 맨 아래로 내려서 추가 데이터를 요청하는 중
class PaginationFetchingMore<T> extends Pagination<T> {
  PaginationFetchingMore({
    required super.meta,
    required super.documents,
  });
}
