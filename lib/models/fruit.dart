import 'package:json_annotation/json_annotation.dart';

/// This allows the `Fruit` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'fruit.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class Fruit {
  Fruit(this.id, this.fruit_name);

  Fruit.empty();

  int id;
  String fruit_name;

  factory Fruit.fromJson(Map<String, dynamic> json) => _$FruitFromJson(json);

  Map<String, dynamic> toJson() => _$FruitToJson(this);
}
