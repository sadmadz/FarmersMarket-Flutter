// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customeroffers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerOffers _$CustomerOffersFromJson(Map<String, dynamic> json) {
  return CustomerOffers(
      (json['offers'] as List)
          ?.map((e) => e == null
              ? null
              : CustomerOffer.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      json['totalCount'] as int);
}

Map<String, dynamic> _$CustomerOffersToJson(CustomerOffers instance) =>
    <String, dynamic>{
      'offers': instance.offers,
      'totalCount': instance.totalCount
    };
