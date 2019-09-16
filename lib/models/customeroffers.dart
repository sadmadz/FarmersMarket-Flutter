import 'package:json_annotation/json_annotation.dart';

import 'customeroffer.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'customeroffers.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

class CustomerOffers {

  List<CustomerOffer> offers;
  int totalCount;


  CustomerOffers(this.offers, this.totalCount);


  factory CustomerOffers.fromJson(Map<String, dynamic> json) => _$CustomerOffersFromJson(json);


  Map<String, dynamic> toJson() => _$CustomerOffersToJson(this);



}