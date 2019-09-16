// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) {
  return Product(
      json['id'] as int,
      json['farmer'] == null
          ? null
          : Farmer.fromJson(json['farmer'] as Map<String, dynamic>),
      json['fruit_name'] as String,
      json['weight'] as String,
      json['price'] as String,
      json['description'] as String,
      json['farm_lat'] as String,
      json['farm_lng'] as String,
      json['province'] as String,
      json['city'] as String,
      json['address'] as String,
      (json['images'] as List)
          ?.map((e) =>
              e == null ? null : Image.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      json['created_at'] as String,
      json['updated_at'] as String);
}

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'farmer': instance.farmer,
      'fruit_name': instance.fruit_name,
      'weight': instance.weight,
      'price': instance.price,
      'description': instance.description,
      'farm_lat': instance.farm_lat,
      'farm_lng': instance.farm_lng,
      'province': instance.province,
      'city': instance.city,
      'address': instance.address,
      'images': instance.images,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at
    };
