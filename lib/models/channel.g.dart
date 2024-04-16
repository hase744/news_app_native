// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChannelImpl _$$ChannelImplFromJson(Map<String, dynamic> json) =>
    _$ChannelImpl(
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      youtubeId: json['youtube_id'] as String,
    );

Map<String, dynamic> _$$ChannelImplToJson(_$ChannelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'image_url': instance.imageUrl,
      'youtube_id': instance.youtubeId,
    };
