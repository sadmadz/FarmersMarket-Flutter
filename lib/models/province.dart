import 'package:json_annotation/json_annotation.dart';

/// This allows the `Province` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'province.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class Province {
  Province(this.id, this.province);

  Province.empty();

  int id;
  String province;

  factory Province.fromJson(Map<String, dynamic> json) => _$ProvinceFromJson(json);

  Map<String, dynamic> toJson() => _$ProvinceToJson(this);
}
