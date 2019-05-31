import 'package:flutter/widgets.dart';

class IconDataBrands extends IconData {
  const IconDataBrands(int codePoint)
      : super(
    codePoint,
    fontFamily: 'FontAwesomeBrands',
  );
}

class IconDataSolid extends IconData {
  const IconDataSolid(int codePoint)
      : super(
    codePoint,
    fontFamily: 'FontAwesomeSolid',
  );
}

class IconDataRegular extends IconData {
  const IconDataRegular(int codePoint)
      : super(
    codePoint,
    fontFamily: 'FontAwesomeRegular',
  );
}

class IconDataLight extends IconData {
  const IconDataLight(int codePoint)
      : super(
    codePoint,
    fontFamily: 'FontAwesomeLight',
  );
}