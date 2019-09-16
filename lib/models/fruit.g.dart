// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fruit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fruit _$FruitFromJson(Map<String, dynamic> json) {
  return Fruit(json['id'] as int, json['fruit_name'] as String);
}

Map<String, dynamic> _$FruitToJson(Fruit instance) =>
    <String, dynamic>{'id': instance.id, 'fruit_name': instance.fruit_name};
