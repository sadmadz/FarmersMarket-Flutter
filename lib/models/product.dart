import 'package:final_project/models/farmer.dart';
import 'package:final_project/models/image.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'product.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class Product {
  int id;
  Farmer farmer;
  String fruit_name;
  String weight;
  String price;
  String description;
  String farm_lat;
  String farm_lng;
  String province;
  String city;
  String address;
  List<Image> images;
  String created_at;
  String updated_at;

  Product(
      this.id,
      this.farmer,
      this.fruit_name,
      this.weight,
      this.price,
      this.description,
      this.farm_lat,
      this.farm_lng,
      this.province,
      this.city,
      this.address,
      this.images,
      this.created_at,
      this.updated_at);

  Product.empty();

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
