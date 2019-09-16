class EnglishNumber {

  String str;
  List<String> englishNumbers = new List.from(<String>["0","1","2","3","4","5","6","7","8","9"]);
  List<String> farsiNumbers = new List.from(<String>["۰","۱","۲","۳","۴","۵","۶","۷","۸","۹"]);


  EnglishNumber(this.str);


  getNumber() {
    for(int i = 0;i<englishNumbers.length;i++){
      str = str.replaceAll(new RegExp(r''+farsiNumbers[i]), englishNumbers[i]);
    }
    return str;
  }
}