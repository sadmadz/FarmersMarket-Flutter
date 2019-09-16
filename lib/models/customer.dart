import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'customer.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class Customer {


  Customer.empty();

  int id;
  String first_name;
  String last_name;
  String username;
  String phone_number;
  String created_at;
  String updated_at;
  String shop_name;
  String password;
  String avatar;
  String token;


  Customer(this.id, this.first_name, this.last_name, this.username,
      this.phone_number, this.created_at, this.updated_at, this.shop_name,
      this.password, this.avatar, this.token);

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);


  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}
