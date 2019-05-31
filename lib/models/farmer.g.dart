// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Farmer _$FarmerFromJson(Map<String, dynamic> json) {
  return Farmer(
      json['id'] as int,
      json['first_name'] as String,
      json['last_name'] as String,
      json['username'] as String,
      json['created_at'] as String,
      json['updated_at'] as String,
      json['token'] as String);
}

Map<String, dynamic> _$FarmerToJson(Farmer instance) => <String, dynamic>{
      'id': instance.id,
      'first_name': instance.first_name,
      'last_name': instance.last_name,
      'username': instance.username,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at
    };
