import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'image.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

class Image {

  int id;
  String image_file;


  Image(this.id, this.image_file);

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);


  Map<String, dynamic> toJson() => _$ImageToJson(this);



}