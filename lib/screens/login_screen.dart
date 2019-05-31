import 'dart:io';

import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/models/customer.dart';
import 'package:final_project/models/farmer.dart';
import 'package:final_project/models/loginResponse.dart';
import 'package:final_project/models/user.dart';
import 'package:final_project/widgets/custom_tab_Indicator.dart';
import 'package:final_project/widgets/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_project/screens/theme.dart' as Theme;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toast/toast.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _currentIndex = 0;

  Color left = Colors.white;
  Color right = Colors.black;

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  //***********************************************

  final String base_url = "https://lixil.herokuapp.com/api/v1/";

  //***********************************************

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.animation.addListener(() {
      if (_tabController.index == 0) {
        if (_tabController.animation.value > 0.5 &&
            left == Colors.white &&
            right == Colors.black) {
          setState(() {
            print('con1');
            left = Colors.black;
            right = Colors.white;
          });
        } else if (_tabController.animation.value < 0.5 &&
            left == Colors.black &&
            right == Colors.white) {
          setState(() {
            print('con2');
            left = Colors.white;
            right = Colors.black;
          });
        }
      } else {
        if (_tabController.animation.value < 0.5 &&
            left == Colors.black &&
            right == Colors.white) {
          setState(() {
            print('con3');
            left = Colors.white;
            right = Colors.black;
          });
        } else if (_tabController.animation.value >= 0.5 &&
            left == Colors.white &&
            right == Colors.black) {
          setState(() {
            print('con4');
            left = Colors.black;
            right = Colors.white;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    passwordController.dispose();
    phoneController.dispose();
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
                                dotOneColor: Colors.pink,
                                dotTwoColor: Colors.amber,
                                dotThreeColor: Colors.pink,
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

//  login() async {
//    final response = await http.post(base_url + "login/",
//        headers: {"Content-Type": "application/json"},
//        body: {"type": "0", "username": "mahdi", "password": "pass"});
//    print('here');
//    if (response != null && response.statusCode == 200) {
////      LoginResponse jsonResponse =
////      LoginResponse.fromJson(convert.jsonDecode(response.body));
//      print(response);
//    }
//    print('here');
//
//    return response;
//  }

  Future<Farmer> login(BuildContext context) async {
    Farmer farmer;
    User customer = new User.empty();
    customer.username = phoneController.text;
    customer.password = passwordController.text;
    customer.user_type = "1";

    if (phoneController.text == "") {
      Toast.show("لطفا شماره موبایل را وارد نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    } else if (passwordController.text == "") {
      Toast.show("لطفا رمز عبور را وارد نمایید ", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    } else {
      showLoading();
      try {
        final response = await http.post(base_url + "login/",
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
//          Navigator.pushReplacementNamed(context, '/home');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(farmer: farmer),
            )
          );


        } else if (statusCode == 401) {
          Toast.show("نام کاربری یا رمز عبور اشتباه است", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
      } on SocketException catch (e) {
        print(e);
        Navigator.pop(context);
        Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    }

//    return LoginResponse.fromJson(json.decode(response.body));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
        body: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  Theme.Colors.loginGradientStart,
                  Theme.Colors.loginGradientEnd
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 1.0),
                tileMode: TileMode.clamp),
          ),
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 12.0, top: 30.0, bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                FontAwesomeIcons.timesRegular,
                                color: Colors.white,
                                size: 30.0,
                              ),
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/');
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 50.0,
                          decoration: BoxDecoration(
                            color: Color(0x552B2B2B),
                            borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            tabs: [
                              Tab(
//                              icon: Icon(Icons.directions_car)
                                child: Text("ورود",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontFamily: "IRANYekanMobile",
                                        color: right)),
                              ),
                              Tab(
                                child: Text(
                                  "عضویت",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: "IRANYekanMobile",
                                      color: left),
                                ),
//                              icon: Icon(Icons.directions_transit)
                              ),
                            ],
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: new CustomTabIndicator(
                              indicatorHeight: 40,
                              indicatorRadius: 25,
                              indicatorColor: Colors.white,
                              tabBarIndicatorSize: TabBarIndicatorSize.tab,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  preferredSize: Size.fromHeight(140)),
              body: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowGlow();
                  },
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSignIn(context),
                      _buildSignUp(context),
                    ],
                  )),
            ),
          ),
        )), onWillPop: (){
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  Widget _buildSignIn(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              fontFamily: "IRANYekanMobile",
                              fontSize: 16.0,
                              color: Colors.blueGrey[800]),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: Colors.blueGrey[800],
                              size: 22.0,
                            ),
                            hintText: "آدرس ایمیل",
                            hintStyle: TextStyle(
                                fontFamily: "IRANYekanMobile", fontSize: 17.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          controller: passwordController,
                          style: TextStyle(
                              fontFamily: "IRANYekanMobile",
                              fontSize: 16.0,
                              color: Colors.blueGrey[800]),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              size: 22.0,
                              color: Colors.blueGrey[800],
                            ),
                            hintText: "رمز عبور",
                            hintStyle: TextStyle(
                                fontFamily: "IRANYekanMobile", fontSize: 17.0),
                            suffixIcon: GestureDetector(
                              onTap: null,
                              child: Icon(
                                FontAwesomeIcons.eye,
                                size: 15.0,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: RaisedButton(
                            elevation: 6,
                            highlightElevation: 12,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10.0)),
                            color: Theme.Colors.loginGradientEnd,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 42.0),
                              child: Text(
                                "ورود",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontFamily: "IRANYekanMobile"),
                              ),
                            ),
                            onPressed: () {
                              login(context);
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: FlatButton(
                onPressed: () {},
                child: Text(
                  "فراموشی رمز عبور",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: 16.0,
                      fontFamily: "IRANYekanMobile"),
                )),
          ),
//          Padding(
//            padding: EdgeInsets.only(top: 10.0),
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                Container(
//                  decoration: BoxDecoration(
//                    gradient: new LinearGradient(
//                        colors: [
//                          Colors.white10,
//                          Colors.white,
//                        ],
//                        begin: const FractionalOffset(0.0, 0.0),
//                        end: const FractionalOffset(1.0, 1.0),
//                        stops: [0.0, 1.0],
//                        tileMode: TileMode.clamp),
//                  ),
//                  width: 100.0,
//                  height: 1.0,
//                ),
//                Padding(
//                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
//                  child: Text(
//                    "Or",
//                    style: TextStyle(
//                        color: Colors.white,
//                        fontSize: 16.0,
//                        fontFamily: "IRANYekanMobile"),
//                  ),
//                ),
//                Container(
//                  decoration: BoxDecoration(
//                    gradient: new LinearGradient(
//                        colors: [
//                          Colors.white,
//                          Colors.white10,
//                        ],
//                        begin: const FractionalOffset(0.0, 0.0),
//                        end: const FractionalOffset(1.0, 1.0),
//                        stops: [0.0, 1.0],
//                        tileMode: TileMode.clamp),
//                  ),
//                  width: 100.0,
//                  height: 1.0,
//                ),
//              ],
//            ),
//          ),
//          Row(
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: <Widget>[
//              Padding(
//                padding: EdgeInsets.only(top: 10.0, right: 40.0),
//                child: GestureDetector(
//                  onTap: null,
//                  child: Container(
//                    padding: const EdgeInsets.all(15.0),
//                    decoration: new BoxDecoration(
//                      shape: BoxShape.circle,
//                      color: Colors.white,
//                    ),
//                    child: new Icon(
//                      Icons.wb_cloudy,
//                      color: Color(0xFF0084ff),
//                    ),
//                  ),
//                ),
//              ),
//              Padding(
//                padding: EdgeInsets.only(top: 10.0),
//                child: GestureDetector(
//                  onTap: null,
//                  child: Container(
//                    padding: const EdgeInsets.all(15.0),
//                    decoration: new BoxDecoration(
//                      shape: BoxShape.circle,
//                      color: Colors.white,
//                    ),
//                    child: new Icon(
//                      Icons.ac_unit,
//                      color: Color(0xFF0084ff),
//                    ),
//                  ),
//                ),
//              ),
//            ],
//          ),
        ],
      ),
    );
  }

  Widget _buildSignUp(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                              fontFamily: "IRANYekanMobile",
                              fontSize: 16.0,
                              color: Colors.blueGrey[800]),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.user,
                              color: Colors.blueGrey[800],
                            ),
                            hintText: "نام",
                            hintStyle: TextStyle(
                                fontFamily: "IRANYekanMobile", fontSize: 16.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              fontFamily: "IRANYekanMobile",
                              fontSize: 16.0,
                              color: Colors.blueGrey[800]),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: Colors.blueGrey[800],
                            ),
                            hintText: "آدرس ایمیل",
                            hintStyle: TextStyle(
                                fontFamily: "IRANYekanMobile", fontSize: 16.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          style: TextStyle(
                              fontFamily: "IRANYekanMobile",
                              fontSize: 16.0,
                              color: Colors.blueGrey[800]),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              color: Colors.blueGrey[800],
                            ),
                            hintText: "رمز عبور",
                            hintStyle: TextStyle(
                                fontFamily: "IRANYekanMobile", fontSize: 16.0),
                            suffixIcon: GestureDetector(
                              onTap: null,
                              child: Icon(
                                FontAwesomeIcons.eye,
                                size: 15.0,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          style: TextStyle(
                              fontFamily: "IRANYekanMobile",
                              fontSize: 16.0,
                              color: Colors.blueGrey[800]),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              color: Colors.blueGrey[800],
                            ),
                            hintText: "تایید رمز عبور",
                            hintStyle: TextStyle(
                                fontFamily: "IRANYekanMobile", fontSize: 16.0),
                            suffixIcon: GestureDetector(
                              onTap: null,
                              child: Icon(
                                FontAwesomeIcons.eye,
                                size: 15.0,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: RaisedButton(
                            elevation: 6,
                            highlightElevation: 12,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10.0)),
                            color: Theme.Colors.loginGradientEnd,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 42.0),
                              child: Text(
                                "عضویت",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontFamily: "IRANYekanMobile"),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
