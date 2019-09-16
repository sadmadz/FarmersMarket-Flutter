// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Requests _$RequestsFromJson(Map<String, dynamic> json) {
  return Requests(
      (json['requests'] as List)
          ?.map((e) =>
              e == null ? null : Request.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      json['totalCount'] as int);
}

Map<String, dynamic> _$RequestsToJson(Requests instance) => <String, dynamic>{
      'requests': instance.requests,
      'totalCount': instance.totalCount
    };
