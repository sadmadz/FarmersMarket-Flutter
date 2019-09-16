import 'package:final_project/farsi_number.dart';
import 'package:shamsi_date/shamsi_date.dart';

class DateTimeModifier {
  String dateTime = '';
  String date = '';
  String time = '';
  static String baseUrl = "http://52.14.168.188/api/v1/";

  DateTimeModifier(this.dateTime){
    this.date = dateTime.split("T")[0];
    this.time = dateTime.split("T")[1];
  }

  getFarsiDate(){
    int year=int.parse(this.date.split("-")[0]);
    int month=int.parse(this.date.split("-")[1]);
    int date=int.parse(this.date.split("-")[2]);

    final gregorianDate = Gregorian(year,month,date);
    final persianDate = Jalali.fromGregorian(gregorianDate);
    return "تاریخ "+FarsiNumber(persianDate.toString()).getNumber();
  }

  getFarsiTime(){
    String newTime = "ساعت "+time.split(":")[0]+":"+time.split(":")[1];
    return FarsiNumber(newTime).getNumber();
  }

  getFarsiDateTime(){
    return getFarsiDate()+" "+getFarsiTime();
  }
}
