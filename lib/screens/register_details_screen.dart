import 'dart:io';
import 'dart:ui';

import 'package:final_project/farsi_number.dart';
import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/models/farmer.dart';
import 'package:final_project/models/user.dart';
import 'package:final_project/screens/home_screen.dart';
import 'package:final_project/screens/map_screen.dart';
import 'package:final_project/widgets/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'dart:convert';

import '../global.dart';
import 'login_screen.dart';

class RegisterDetailsScreen extends StatefulWidget {
  final phoneNumber;

  RegisterDetailsScreen({Key key, @required this.phoneNumber})
      : super(key: key);

  @override
  _RegisterDetailsScreen createState() =>
      new _RegisterDetailsScreen(phoneNumber);
}

class _RegisterDetailsScreen extends State<RegisterDetailsScreen> {
  String phoneNumber;

  _RegisterDetailsScreen(this.phoneNumber);

  Farmer farmer = Farmer.empty();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  TextEditingController phoneNumberController;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  final fNameFocus = FocusNode();
  final lNameFocus = FocusNode();
  final usernameFocus = FocusNode();
  final passwordFocus = FocusNode();
  final repeatPasswordFocus = FocusNode();

  bool hasFirstName, hasLastName, hasUserName, hasPassword, hasRepeatPassword;

  LatLng location;

  CameraPosition initialCameraPosition;

  GoogleMapController mapController;

  createFarmer(BuildContext context) async {
    showLoading();

    farmer.first_name = firstNameController.text;
    farmer.last_name = lastNameController.text;
    farmer.phone_number = phoneNumberController.text;
    farmer.username = usernameController.text;
    farmer.password = passwordController.text;
    if (location != null) {
      farmer.farmer_lat = location.latitude.toString();
      farmer.farmer_lng = location.longitude.toString();
    }

    print(Global.baseUrl + "farmers/");
    try {
      final response = await http.post(Global.baseUrl + "farmers/",
          headers: {"Content-Type": "application/json"},
          body: json.encode(farmer.toJson()));
      final int statusCode = response.statusCode;
      print(response.statusCode);
      print(response.body);
//      Navigator.pop(context);
      if (statusCode == 201) {
        farmer = Farmer.fromJson(json.decode(response.body));
        getToken();
      } else {
        String errorText = "";
        if (response.body.toString().contains("username")) {
          errorText = '"نام کاربری" وارد شده توسط کاربر دیگری گرفته شده است';
        } else if (response.body.toString().contains("phone")) {
          errorText = 'در حال حاضر کاربری با شماره موبایل وارد شده وجود دارد';
        }
        Navigator.pop(context);

        final snackBar = SnackBar(
          backgroundColor: Colors.blueGrey[900],
          duration: Duration(seconds: 2),
          content: Text(errorText,
              style: TextStyle(
                  fontFamily: "IRANYekanMobile",
                  fontSize: 14.0,
                  color: Colors.white)),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      }
    } on SocketException catch (e) {
      print(e);
      Navigator.pop(context);
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  getToken() async {
    User customer = new User.empty();
    customer.username = farmer.username;
    customer.password = farmer.password;
    customer.user_type = "1";

    try {
      final response = await http.post(Global.baseUrl + "login/",
          headers: {"Content-Type": "application/json"},
          body: json.encode(customer.toJson()));
      final int statusCode = response.statusCode;
      print(response.statusCode);
      print(json.decode(response.body));
      Navigator.pop(context);
      if (statusCode == 200) {
        farmer = Farmer.fromJson(json.decode(response.body));
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', farmer.token);
        prefs.setString('userId', farmer.id.toString());

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(farmer: farmer),
            ));
//        Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
      }
    } on SocketException catch (e) {
      print(e);
      Navigator.pop(context);
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  Widget mapWidget() {
    if (location != null) {
      return Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              GoogleMap(
                mapType: MapType.normal,
//                            markers: _markers.values.toSet(),
                initialCameraPosition: initialCameraPosition,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
              ),
              Padding(
                  padding: EdgeInsets.only(bottom: 35),
                  child: Center(
                      child: Image.asset(
                    'assets/images/marker.png',
                    height: 35,
                    width: 35,
                  )))
            ],
          ));
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
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
//                          new CircularProgressIndicator(
//                            value: null,
//                            strokeWidth: 7.0,
//                          ),
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

  String controlFirstNameField() {
    if (hasFirstName) {
      if (firstNameController.text == "") {
        return "لطفا نام را وارد نمایید";
      }
    }
    return null;
  }

  String controlLastNameField() {
    if (hasLastName) {
      if (lastNameController.text == "") {
        return "لطفا نام خانوادگی را وارد نمایید";
      }
    }
    return null;
  }

  String controlUsernameField() {
    if (hasUserName) {
      if (usernameController.text == "") {
        return "لطفا نام کاربری را وارد نمایید";
      }
    }
    return null;
  }

  String controlPasswordField() {
    if (hasPassword) {
      if (passwordController.text == "") {
        return "لطفا کلمه عبور را وارد نمایید";
      }
    }
    return null;
  }

  String controlRepeatPasswordField() {
    if (hasRepeatPassword) {
      if (repeatPasswordController.text == "") {
        return "لطفا کلمه عبور را وارد نمایید";
      } else if (repeatPasswordController.text != passwordController.text) {
        return "تکرار کلمه عبور صحیح نمی باشد";
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    phoneNumberController =
        TextEditingController(text: FarsiNumber(phoneNumber).getNumber());
    location = null;

    hasFirstName = false;
    hasLastName = false;
    hasUserName = false;
    hasPassword = false;
    hasRepeatPassword = false;

    initialCameraPosition = CameraPosition(
      target: LatLng(32.4279, 53.6880),
      zoom: 8,
    );
  }

  @override
  build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Builder(
              builder: (context) => Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.blueGrey[800],
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Container(
                      padding: EdgeInsets.only(top: 60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
//                  margin: EdgeInsets.only(top: 60),
                            width: 300,
//                  height: MediaQuery.of(context).size.height - 120,
                            child: Card(
                                elevation: 4.0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 20.0, left: 25.0, right: 25.0),
                                      child: Text(
                                        "مشخصات کاربر",
                                        style: new TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.blueGrey[700],
                                            fontFamily: "IranYekanMobileBold"),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 20.0,
                                          bottom: 20.0,
                                          left: 25.0,
                                          right: 25.0),
                                      child: TextField(
                                        decoration: InputDecoration(
                                            errorText: controlFirstNameField(),
                                            contentPadding: EdgeInsets.all(0),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            prefixIcon: Icon(
                                                FontAwesomeIcons.userAlt,
                                                color: Colors.blueGrey[800],
                                                size: 18.0),
                                            labelText: "نام"),
                                        style: TextStyle(
                                            fontFamily: "IRANYekanMobile",
                                            fontSize: 14.0,
                                            color: Colors.blueGrey[800]),
                                        controller: firstNameController,
                                        keyboardType: TextInputType.text,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        focusNode: fNameFocus,
                                        textInputAction: TextInputAction.next,
                                        onSubmitted: (v) {
                                          FocusScope.of(context)
                                              .requestFocus(lNameFocus);
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 10.0,
                                          bottom: 20.0,
                                          left: 25.0,
                                          right: 25.0),
                                      child: TextField(
                                        decoration: InputDecoration(
                                            errorText: controlLastNameField(),
                                            contentPadding: EdgeInsets.all(0),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            prefixIcon: Icon(
                                                FontAwesomeIcons.userAlt,
                                                color: Colors.blueGrey[800],
                                                size: 18.0),
                                            labelText: "نام خانوادگی"),
                                        style: TextStyle(
                                            fontFamily: "IRANYekanMobile",
                                            fontSize: 14.0,
                                            color: Colors.blueGrey[800]),
                                        controller: lastNameController,
                                        keyboardType: TextInputType.text,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        focusNode: lNameFocus,
                                        textInputAction: TextInputAction.next,
                                        onSubmitted: (v) {
                                          FocusScope.of(context)
                                              .requestFocus(usernameFocus);
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 10.0,
                                          bottom: 20.0,
                                          left: 25.0,
                                          right: 25.0),
                                      child: TextField(
                                        decoration: InputDecoration(
                                            errorText: controlUsernameField(),
                                            contentPadding: EdgeInsets.all(0),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            prefixIcon: Icon(
                                                FontAwesomeIcons.userAlt,
                                                color: Colors.blueGrey[800],
                                                size: 18.0),
                                            labelText: "نام کاربری"),
                                        style: TextStyle(
                                            fontFamily: "IRANYekanMobile",
                                            fontSize: 14.0,
                                            color: Colors.blueGrey[800]),
                                        controller: usernameController,
                                        keyboardType: TextInputType.text,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        focusNode: usernameFocus,
                                        textInputAction: TextInputAction.next,
                                        onSubmitted: (v) {
                                          FocusScope.of(context)
                                              .requestFocus(passwordFocus);
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 10.0,
                                          bottom: 20.0,
                                          left: 25.0,
                                          right: 25.0),
                                      child: TextField(
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.only(left: 8),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            prefixIcon: Icon(
                                                FontAwesomeIcons
                                                    .mobileAndroidAltSolid,
                                                color: Colors.blueGrey[800],
                                                size: 18.0),
                                            labelText: "شماره موبایل"),
                                        style: TextStyle(
                                            fontFamily: "IRANYekanMobile",
                                            fontSize: 14.0,
                                            color: Colors.blueGrey[800]),
                                        controller: phoneNumberController,
                                        keyboardType: TextInputType.text,
                                        textDirection: TextDirection.ltr,
                                        enabled: false,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 10.0,
                                          bottom: 20.0,
                                          left: 25.0,
                                          right: 25.0),
                                      child: TextField(
                                        decoration: InputDecoration(
                                            errorText: controlPasswordField(),
                                            contentPadding: EdgeInsets.all(0),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            prefixIcon: Icon(
                                                FontAwesomeIcons.lock,
                                                color: Colors.blueGrey[800],
                                                size: 18.0),
                                            labelText: "کلمه عبور"),
                                        style: TextStyle(
                                            fontFamily: "IRANYekanMobile",
                                            fontSize: 14.0,
                                            color: Colors.blueGrey[800]),
                                        controller: passwordController,
                                        keyboardType: TextInputType.text,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        focusNode: passwordFocus,
                                        textInputAction: TextInputAction.next,
                                        onSubmitted: (v) {
                                          FocusScope.of(context).requestFocus(
                                              repeatPasswordFocus);
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 10.0,
                                          bottom: 20.0,
                                          left: 25.0,
                                          right: 25.0),
                                      child: TextField(
                                        decoration: InputDecoration(
                                            errorText:
                                                controlRepeatPasswordField(),
                                            contentPadding: EdgeInsets.all(0),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            prefixIcon: Icon(
                                                FontAwesomeIcons.lock,
                                                color: Colors.blueGrey[800],
                                                size: 18.0),
                                            labelText: "تکرار کلمه عبور"),
                                        style: TextStyle(
                                            fontFamily: "IRANYekanMobile",
                                            fontSize: 14.0,
                                            color: Colors.blueGrey[800]),
                                        controller: repeatPasswordController,
                                        focusNode: repeatPasswordFocus,
                                        keyboardType: TextInputType.text,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(8),
                                      decoration: new BoxDecoration(
                                          color: Colors.blueGrey[100],
                                          borderRadius: new BorderRadius.all(
                                              Radius.circular(8.0))),
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10.0,
                                                bottom: 20.0,
                                                left: 25.0,
                                                right: 25.0),
                                            child: Row(
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 8,
                                                      top: 8,
                                                      bottom: 8,
                                                      left: 10),
                                                  child: Icon(
                                                    FontAwesomeIcons.mapPin,
                                                    color: Colors.blueGrey[800],
                                                    size: 18,
                                                  ),
                                                ),
                                                Text(
                                                  "موقعیت مکانی",
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          Colors.blueGrey[800]),
                                                ),
                                                Text(
                                                  "(اختیاری)",
                                                  style: TextStyle(
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          Colors.blueGrey[800]),
                                                )
                                              ],
                                            ),
                                          ),
                                          mapWidget(),
                                          RaisedButton(
                                            shape: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.blueGrey[800])),
                                            color: Colors.grey[200],
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 8),
                                                    child: Text(
                                                        "افزودن موقعیت مکانی")),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 4),
                                                    child: Icon(
                                                      FontAwesomeIcons
                                                          .mapMarkedAlt,
                                                      color:
                                                          Colors.blueGrey[800],
                                                      size: 18,
                                                    ))
                                              ],
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MapScreen(
                                                          location: location),
                                                ),
                                              ).then((value) {
                                                if (value != null) {
                                                  setState(() {
                                                    location = value;
                                                    mapController.moveCamera(
                                                        CameraUpdate.newLatLng(
                                                            location));
                                                  });
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(bottom: 8, left: 20, right: 20),
                            child: RaisedButton(
                                elevation: 6,
                                highlightElevation: 12,
                                shape: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(
                                        color: Colors.blueGrey[900])),
                                color: Colors.green[200],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 42.0),
                                  child: Text(
                                    "تکمیل ثبت نام",
                                    style: TextStyle(
                                        color: Colors.blueGrey[900],
                                        fontSize: 18.0,
                                        fontFamily: "IRANYekanMobileLight"),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    hasFirstName = true;
                                    hasLastName = true;
                                    hasUserName = true;
                                    hasPassword = true;
                                    hasRepeatPassword = true;
                                  });
                                  if (firstNameController.text != "" &&
                                      lastNameController.text != "" &&
                                      usernameController.text != "" &&
                                      passwordController.text != "" &&
                                      repeatPasswordController.text != "" &&
                                      passwordController.text ==
                                          repeatPasswordController.text) {
                                    createFarmer(context);
                                  }
                                }),
                          )
                        ],
                      ),
                    ),
                  ))),
        ),
        onWillPop: () {
          return Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ));
        });
  }
}
