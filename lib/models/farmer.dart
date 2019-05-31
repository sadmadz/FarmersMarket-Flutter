import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'farmer.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

class Farmer {

  Farmer(this.id, this.first_name, this.last_name, this.username,
      this.created_at, this.updated_at,this.token);

  int id;
  String first_name;
  String last_name;
  String username;
  String token;
  String created_at;
  String updated_at;


  factory Farmer.fromJson(Map<String, dynamic> json) => _$FarmerFromJson(json);


  Map<String, dynamic> toJson() => _$FarmerToJson(this);


}