import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'farmer.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class Farmer {
  Farmer(
      this.id,
      this.first_name,
      this.last_name,
      this.username,
      this.password,
      this.token,
      this.avatar,
      this.farmer_lat,
      this.farmer_lng,
      this.phone_number,
      this.created_at,
      this.updated_at);

  int id;
  String first_name;
  String last_name;
  String username;
  String password;
  String token;
  String avatar;
  String farmer_lat;
  String farmer_lng;
  String phone_number;
  String created_at;
  String updated_at;

  Farmer.empty();

  factory Farmer.fromJson(Map<String, dynamic> json) => _$FarmerFromJson(json);

  Map<String, dynamic> toJson() => _$FarmerToJson(this);
}
