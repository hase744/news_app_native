import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class Category with _$Category {
  
  const factory Category({
    required String name,
    required String japaneseName,
    required String emoji,
    required String? imageUrl,
    required bool isDefault,
    required bool isFormal,
    required bool isOriginal,
    bool? isDeleting,
    bool? isAdded,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}