import 'package:final_project/english_number.dart';
import 'package:final_project/farsi_number.dart';
import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/screens/register_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class VerifySmsScreen extends StatelessWidget {
  final phoneNumber;
  final verifyCodeController = TextEditingController();

  VerifySmsScreen({Key key, @required this.phoneNumber}) : super(key: key);


  verifyCode(BuildContext context){
    if(EnglishNumber(verifyCodeController.text).getNumber() == "12345"){
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterDetailsScreen(phoneNumber: "0"+phoneNumber),
          ));
    }else{
      Toast.show("کد وارد شده صحیح نمی باشد", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.blueGrey[800],
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 12.0, right: 12.0, top: 30.0, bottom: 10.0),
                child: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.timesRegular,
                    color: Colors.white,
                    size: 30.0,
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ),
              Center(
                  child: Padding(
                padding: EdgeInsets.only(top: 23.0),
                child: Card(
                  elevation: 2.0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    width: 300.0,
                    height: 250,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                "شماره موبایل",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.blueGrey[700],
                                    fontFamily: 'IRANYekanMobileBold',
                                    fontSize: 14),
                              ),
                              Text(
                                  ": "+FarsiNumber("0"+phoneNumber).getNumber(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.blueGrey[700],
                                    fontFamily: 'IRANYekanMobileBold',
                                    fontSize: 14),
                              ),
//                              Text(
//                                "۹۸+",
//                                overflow: TextOverflow.ellipsis,
//                                maxLines: 1,
//                                style: TextStyle(
//                                    color: Colors.blueGrey[700],
//                                    fontFamily: 'IRANYekanMobileBold',
//                                    fontSize: 14),
//                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                hintText: "کد تایید",
                                counterText: ""),
                            style: TextStyle(
                                fontFamily: "IRANYekanMobile",
                                fontSize: 14.0,
                                color: Colors.blueGrey[800]),
                            maxLength: 5,
                            textAlign: TextAlign.center,
                            controller: verifyCodeController,
                            keyboardType: TextInputType.number,
                            onChanged: (text) {
                              var cursorPos = verifyCodeController.selection;
                              verifyCodeController.text =
                                  FarsiNumber(verifyCodeController.text)
                                      .getNumber();
                              if (cursorPos.start >
                                  verifyCodeController.text.length) {
                                cursorPos = new TextSelection.fromPosition(
                                    new TextPosition(
                                        offset:
                                            verifyCodeController.text.length));
                              }
                              verifyCodeController.selection = cursorPos;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: RaisedButton(
                              elevation: 6,
                              highlightElevation: 12,
                              shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide:
                                      BorderSide(color: Colors.blueGrey[800])),
                              color: Colors.grey[200],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 42.0),
                                child: Text(
                                  "تایید",
                                  style: TextStyle(
                                      color: Colors.blueGrey[800],
                                      fontSize: 18.0,
                                      fontFamily: "IRANYekanMobileLight"),
                                ),
                              ),
                              onPressed: () {
                                verifyCode(context);
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
            ],
          ),
        )),
        onWillPop: (){
          return Navigator.pushReplacementNamed(context, '/login');
        });
  }
}
