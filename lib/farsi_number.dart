class FarsiNumber {

  String str;
  List<String> farsiNumbers = new List.from(<String>["۰","۱","۲","۳","۴","۵","۶","۷","۸","۹"]);


  FarsiNumber(this.str);


  getNumber() {
    for(int i = 0;i<farsiNumbers.length;i++){
      str = str.replaceAll(new RegExp(r''+i.toString()), farsiNumbers[i]);
    }
    return str;
  }

}