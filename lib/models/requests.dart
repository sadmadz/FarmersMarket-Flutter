import 'package:final_project/models/request.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'requests.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

class Requests {

  List<Request> requests;
  int totalCount;


  Requests(this.requests, this.totalCount);


  factory Requests.fromJson(Map<String, dynamic> json) => _$RequestsFromJson(json);


  Map<String, dynamic> toJson() => _$RequestsToJson(this);



}