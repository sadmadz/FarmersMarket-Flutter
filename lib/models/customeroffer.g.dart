// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customeroffer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerOffer _$CustomerOfferFromJson(Map<String, dynamic> json) {
  return CustomerOffer(
      json['id'] as int,
      json['customer'] == null
          ? null
          : Customer.fromJson(json['customer'] as Map<String, dynamic>),
      json['price'] as String,
      json['weight'] as String,
      json['accepted'] as bool,
      json['pending'] as bool,
      json['declined'] as bool,
      json['product'] == null
          ? null
          : Product.fromJson(json['product'] as Map<String, dynamic>),
      json['created_at'] as String);
}

Map<String, dynamic> _$CustomerOfferToJson(CustomerOffer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer': instance.customer,
      'price': instance.price,
      'weight': instance.weight,
      'accepted': instance.accepted,
      'pending': instance.pending,
      'declined': instance.declined,
      'product': instance.product,
      'created_at': instance.created_at
    };
