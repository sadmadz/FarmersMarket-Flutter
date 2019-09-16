import 'package:final_project/models/farmer.dart';
import 'package:final_project/models/image.dart';
import 'package:final_project/models/request.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'offer.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class Offer {
  int id;
  Farmer farmer;
  String price;
  bool accepted;
  bool pending;
  Request request;
  String created_at;


  Offer(this.id, this.farmer, this.price, this.accepted,
      this.pending, this.request, this.created_at);

  Offer.empty();

  factory Offer.fromJson(Map<String, dynamic> json) =>
      _$OfferFromJson(json);

  Map<String, dynamic> toJson() => _$OfferToJson(this);
}
