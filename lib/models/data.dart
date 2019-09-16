import 'package:final_project/models/city.dart';
import 'package:final_project/models/farmer.dart';
import 'package:final_project/models/fruit.dart';
import 'package:final_project/models/product.dart';
import 'package:final_project/models/province.dart';
import 'package:final_project/models/request.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'data.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class Data {
  List<Product> products;
  List<Request> requests;
  List<City> cities;
  List<Province> provinces;
  List<Fruit> fruits;

  Data(this.products, this.requests, this.cities, this.provinces, this.fruits);

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
