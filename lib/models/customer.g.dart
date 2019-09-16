// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return Customer(
      json['id'] as int,
      json['first_name'] as String,
      json['last_name'] as String,
      json['username'] as String,
      json['phone_number'] as String,
      json['created_at'] as String,
      json['updated_at'] as String,
      json['shop_name'] as String,
      json['password'] as String,
      json['avatar'] as String,
      json['token'] as String);
}

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
      'id': instance.id,
      'first_name': instance.first_name,
      'last_name': instance.last_name,
      'username': instance.username,
      'phone_number': instance.phone_number,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
      'shop_name': instance.shop_name,
      'password': instance.password,
      'avatar': instance.avatar,
      'token': instance.token
    };
