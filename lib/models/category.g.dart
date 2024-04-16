// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryImpl _$$CategoryImplFromJson(Map<String, dynamic> json) =>
    _$CategoryImpl(
      name: json['name'] as String,
      japaneseName: json['japanese_name'] as String,
      emoji: json['emoji'] as String,
      imageUrl: json['image_url'] as String?,
      isDeleting: json['is_deleting'] == true as bool?,
      isAdded: json['is_added'] == true as bool?,
      isDefault: json['is_default'] == true as bool,
      isOriginal: json['is_original'] == true as bool,
      isFormal: json['is_formal'] as bool,
    );

Map<String, dynamic> _$$CategoryImplToJson(_$CategoryImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'japanese_name': instance.japaneseName,
      'emoji': instance.emoji,
      'image_url':instance.imageUrl,
      'is_deleting': instance.isDeleting,
      'is_added': instance.isAdded == true,
      'is_default': instance.isDefault == true,
      'is_formal': instance.isFormal,
      'is_original': instance.isOriginal,
    };
