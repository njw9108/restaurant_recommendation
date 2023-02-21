// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pagination<T> _$PaginationFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    Pagination<T>(
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
      documents: (json['documents'] as List<dynamic>).map(fromJsonT).toList(),
    );

Map<String, dynamic> _$PaginationToJson<T>(
  Pagination<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'meta': instance.meta,
      'documents': instance.documents.map(toJsonT).toList(),
    };

PaginationMeta _$PaginationMetaFromJson(Map<String, dynamic> json) =>
    PaginationMeta(
      pageableCount: json['pageable_count'] as int,
      isEnd: json['is_end'] as bool,
    );

Map<String, dynamic> _$PaginationMetaToJson(PaginationMeta instance) =>
    <String, dynamic>{
      'pageable_count': instance.pageableCount,
      'is_end': instance.isEnd,
    };
