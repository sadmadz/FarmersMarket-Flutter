// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Request _$RequestFromJson(Map<String, dynamic> json) {
  return Request(
      json['id'] as int,
      json['customer'] == null
          ? null
          : Customer.fromJson(json['customer'] as Map<String, dynamic>),
      json['fruit_name'] as String,
      json['weight'] as String,
      json['description'] as String,
      json['customer_lat'] as String,
      json['customer_lng'] as String,
      json['province'] as String,
      json['city'] as String,
      json['address'] as String,
      json['offered'] as bool,
      (json['offers'] as List)
          ?.map((e) =>
              e == null ? null : Offer.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      json['created_at'] as String,
      json['updated_at'] as String);
}

Map<String, dynamic> _$RequestToJson(Request instance) => <String, dynamic>{
      'id': instance.id,
      'customer': instance.customer,
      'fruit_name': instance.fruit_name,
      'weight': instance.weight,
      'description': instance.description,
      'customer_lat': instance.customer_lat,
      'customer_lng': instance.customer_lng,
      'province': instance.province,
      'city': instance.city,
      'address': instance.address,
      'offered': instance.offered,
      'offers': instance.offers,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at
    };
