// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Data _$DataFromJson(Map<String, dynamic> json) {
  return Data(
      (json['products'] as List)
          ?.map((e) =>
              e == null ? null : Product.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      (json['requests'] as List)
          ?.map((e) =>
              e == null ? null : Request.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      (json['cities'] as List)
          ?.map((e) =>
              e == null ? null : City.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      (json['provinces'] as List)
          ?.map((e) =>
              e == null ? null : Province.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      (json['fruits'] as List)
          ?.map((e) =>
              e == null ? null : Fruit.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'products': instance.products,
      'requests': instance.requests,
      'cities': instance.cities,
      'provinces': instance.provinces,
      'fruits': instance.fruits
    };
