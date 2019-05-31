import 'dart:async';
import 'dart:io';

import 'package:final_project/models/farmer.dart';
import 'package:final_project/widgets/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:final_project/screens/theme.dart' as Theme;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toast/toast.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool logedIn = false;
  bool loadingVisibility = false;
  bool loginVisibility = false;
  String token = '';
  Farmer farmer;
  final String base_url = "https://lixil.herokuapp.com/api/v1/";

  @override
  initState() {
    _getInfo();
  }

  _getInfo() async {
    print("here1");
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getString("token") != null) {
      setState(() {
        token = prefs.getString("token");
        loadingVisibility = true;
        loginVisibility = false;
        logedIn = true;
        getUserData(context, prefs.getString("userId"));
      });
    } else {
      setState(() {
        loadingVisibility = false;
        loginVisibility = true;
        logedIn = false;
      });
    }
  }

  Future<Farmer> getUserData(BuildContext context, String userId) async {
    try {
      final response = await http.get(base_url + "farmers/$userId",
          headers: {"Content-Type": "application/json",
            HttpHeaders.authorizationHeader: token});
      final int statusCode = response.statusCode;
      if (statusCode == 200) {
        farmer = Farmer.fromJson(json.decode(response.body));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(farmer: farmer),
          ),
        );
      }
    } on SocketException catch (e) {
      print(e);
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }

//    return LoginResponse.fromJson(json.decode(response.body));
  }

  _loadingOrLogin() {
    print("here3");
    if (logedIn) {
      print("here4");
      return Visibility(
        visible: loadingVisibility,
        child: Center(
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
      );
    } else {
      print("here5");

      return Visibility(
        visible: loginVisibility,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20),
              child: RaisedButton(
                  elevation: 6,
                  highlightElevation: 12,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 42.0),
                    child: Text(
                      "عضویت/ورود",
                      style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 20.0,
                          fontFamily: "IRANYekanMobile"),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  }),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Container(
              alignment: FractionalOffset.center,
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
              child: _loadingOrLogin()),
        ));
  }
}
