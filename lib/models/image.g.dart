// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Image _$ImageFromJson(Map<String, dynamic> json) {
  return Image(json['id'] as int, json['image_file'] as String);
}

Map<String, dynamic> _$ImageToJson(Image instance) =>
    <String, dynamic>{'id': instance.id, 'image_file': instance.image_file};
