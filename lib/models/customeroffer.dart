import 'package:final_project/models/customer.dart';
import 'package:final_project/models/product.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'customeroffer.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class CustomerOffer {
  int id;
  Customer customer;
  String price;
  String weight;
  bool accepted;
  bool pending;
  bool declined;
  Product product;
  String created_at;

  CustomerOffer(this.id, this.customer, this.price,this.weight, this.accepted, this.pending,
      this.declined, this.product, this.created_at);

  CustomerOffer.empty();

  factory CustomerOffer.fromJson(Map<String, dynamic> json) =>
      _$CustomerOfferFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerOfferToJson(this);
}
