import 'package:final_project/models/customer.dart';
import 'package:final_project/models/offer.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'request.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class Request {
  int id;
  Customer customer;
  String fruit_name;
  String weight;
  String description;
  String customer_lat;
  String customer_lng;
  String province;
  String city;
  String address;
  bool offered;
  List<Offer> offers;
  String created_at;
  String updated_at;


  Request(this.id, this.customer, this.fruit_name, this.weight,
      this.description, this.customer_lat, this.customer_lng, this.province,
      this.city, this.address,this.offered,this.offers, this.created_at, this.updated_at);

  Request.empty();

  factory Request.fromJson(Map<String, dynamic> json) => _$RequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestToJson(this);
}
