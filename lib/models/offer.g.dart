// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Offer _$OfferFromJson(Map<String, dynamic> json) {
  return Offer(
      json['id'] as int,
      json['farmer'] == null
          ? null
          : Farmer.fromJson(json['farmer'] as Map<String, dynamic>),
      json['price'] as String,
      json['accepted'] as bool,
      json['pending'] as bool,
      json['request'] == null
          ? null
          : Request.fromJson(json['request'] as Map<String, dynamic>),
      json['created_at'] as String);
}

Map<String, dynamic> _$OfferToJson(Offer instance) => <String, dynamic>{
      'id': instance.id,
      'farmer': instance.farmer,
      'price': instance.price,
      'accepted': instance.accepted,
      'pending': instance.pending,
      'request': instance.request,
      'created_at': instance.created_at
    };
