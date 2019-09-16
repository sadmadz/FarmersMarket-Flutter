import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/english_number.dart';
import 'package:final_project/farsi_number.dart';
import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/models/farmer.dart';
import 'package:final_project/models/user.dart';
import 'package:final_project/widgets/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toast/toast.dart';
import '../global.dart';
import 'home_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  Farmer farmer;

  ChangePasswordScreen({Key key, @required this.farmer}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() =>
      new _ChangePasswordScreenState(farmer);
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  Farmer farmer;

  _ChangePasswordScreenState(this.farmer);

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  bool isTypingOld = false;
  bool isTypingNew = false;
  bool canUpdatePassword = false;
  bool buttonPressed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  showLoading() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
            onWillPop: () {},
            child: new Material(
              type: MaterialType.transparency,
              child: Container(
                  alignment: AlignmentDirectional.center,
                  child: new Container(
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.circular(10.0)),
                      width: 300.0,
                      height: 200.0,
                      alignment: AlignmentDirectional.center,
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Center(
                            child: new SizedBox(
                              height: 50.0,
                              width: 80.0,
                              child: ColorLoader(
                                dotOneColor: Colors.blueGrey[800],
                                dotTwoColor: Color(0xFF06bc86),
                                dotThreeColor: Colors.blueGrey[800],
                                dotType: DotType.circle,
                                duration: Duration(milliseconds: 1200),
                              ),
                            ),
                          ),
                          new Padding(
                            padding: const EdgeInsets.only(top: 35),
                            child: new Text(
                              "لطفا صبر نمایید",
                              style: new TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.blueGrey[700],
                                  fontFamily: "IranYekanMobileBold"),
                            ),
                          ),
                        ],
                      ))),
            )));
  }

  updatePassword(BuildContext context) async {
    Farmer farmer = Farmer.empty();
    String farmerId = this.farmer.id.toString();
    farmer.password = newPasswordController.text;
    print(Global.baseUrl + "farmers/$farmerId");
    print(this.farmer.password.toString());
    showLoading();
    try {
      final response = await http.put(
          Global.baseUrl + "farmers/$farmerId/password/",
          headers: {"Content-Type": "application/json"},
          body: json.encode(farmer.toJson()));
      final int statusCode = response.statusCode;
      print(response.statusCode);
      print(response.body);
      Navigator.pop(context);
      if (statusCode == 200) {
        Navigator.pop(context);
        this.farmer.password = farmer.password;
      } else if (statusCode == 400) {
        final snackBar = SnackBar(backgroundColor: Colors.blueGrey[900],
          duration: Duration(seconds: 2),
          content: Text('خطا در ارتباط با سرور. لطفا مجددا تلاش نمایید',style: TextStyle(
              fontFamily: "IRANYekanMobile",
              fontSize: 16.0,
              color: Colors.white)),
//          action: SnackBarAction(
//            label: '',
//            onPressed: () {
//              // Some code to undo the change.
//            },
//          ),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      } else if (statusCode == 401) {
        final snackBar = SnackBar(backgroundColor: Colors.blueGrey[900],
          duration: Duration(seconds: 2),
          content: Text('کلمه عبور فعلی اشتباه است',style: TextStyle(
              fontFamily: "IRANYekanMobile",
              fontSize: 16.0,
              color: Colors.white),),
//          action: SnackBarAction(
//            label: '',
//            onPressed: () {
//              // Some code to undo the change.
//            },
//          ),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      }
    } on SocketException catch (e) {
      print(e);
      Navigator.pop(context);
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }

//    return ProfileResponse.fromJson(json.decode(response.body));
  }

  String oldTextFieldError() {
    if (!isTypingOld && buttonPressed) {
      if (oldPasswordController.text == "") {
        return "کلمه عبور فعلی را وارد نمایید";
      }
    }
    canUpdatePassword = false;
    return null;
  }

  String newTextFieldError() {
    canUpdatePassword = false;
    if (isTypingNew) {
      if (oldPasswordController.text == "") {
        return "ابتدا کلمه عبور فعلی را وارد نمایید";
      } else if (oldPasswordController.text != newPasswordController.text) {
        return "عدم تطابق کلمه عبور";
      } else {
        canUpdatePassword = true;
      }
    }else if(!isTypingNew && buttonPressed){
      if (newPasswordController.text == "") {
        return "کلمه عبور جدید را وارد نمایید";
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text('تغییر کلمه عبور'),
            centerTitle: true,
            leading: IconButton(
              icon: new Icon(
                FontAwesomeIcons.chevronRight,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            )),
        body: Builder(
            builder: (context) => Container(
                  child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(left: 12, right: 12, top: 16),
                            child: TextField(
                              decoration: InputDecoration(contentPadding: EdgeInsets.all(14),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  labelText: "کلمه عبور فعلی",
                                  errorText: oldTextFieldError()),
                              style: TextStyle(
                                  fontFamily: "IRANYekanMobile",
                                  fontSize: 16.0,
                                  color: Colors.blueGrey[800]),
                              onChanged: (value) {
                                setState(() {
                                  buttonPressed = false;
                                  isTypingNew = false;
                                  isTypingOld = true;
                                  if (oldPasswordController.text == "") {
                                    isTypingOld = false;
                                  }
                                });
                              },
                              controller: oldPasswordController,
                              keyboardType: TextInputType.text,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top:12,left: 12, right: 12),
                            child: TextField(
                              decoration: InputDecoration(contentPadding: EdgeInsets.all(14),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  labelText: "کلمه عبور جدید",
                                  errorText: newTextFieldError()),
                              style: TextStyle(
                                  fontFamily: "IRANYekanMobile",
                                  fontSize: 16.0,
                                  color: Colors.blueGrey[800]),
                              controller: newPasswordController,
                              keyboardType: TextInputType.text,
                              onChanged: (value) {
                                setState(() {
                                  buttonPressed = false;
                                  isTypingNew = true;
                                  isTypingOld = false;
                                  if (newPasswordController.text == "") {
                                    isTypingNew = false;
                                  }
                                });
                              },
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(8)),
                          RaisedButton(
                            shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    BorderSide(color: Colors.blueGrey[800])),
                            color: Colors.grey[200],
                            child: Padding(
                                padding: EdgeInsets.only(left: 8, right: 12),
                                child: Text("تایید")),
                            onPressed: () {
                              setState(() {
                                buttonPressed = true;
                              });
                              if (canUpdatePassword) {
                                updatePassword(context);
                              }
                            },
                          ),
                        ],
                      )),
                )));
  }
}
