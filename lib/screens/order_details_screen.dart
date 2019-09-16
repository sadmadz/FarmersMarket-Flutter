import 'dart:async';
import 'dart:io';

import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/models/customer.dart';
import 'package:final_project/models/farmer.dart';
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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../global.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => new _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Color left = Colors.white;
  Color right = Colors.black;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final provinceController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();

  String user_lat;
  String user_lng;

  FileImage avatar;


  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    provinceController.dispose();
    cityController.dispose();
    addressController.dispose();
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

//  Profile() async {
//    final response = await http.post(Global.baseUrl + "Profile/",
//        headers: {"Content-Type": "application/json"},
//        body: {"type": "0", "username": "mahdi", "password": "pass"});
//    print('here');
//    if (response != null && response.statusCode == 200) {
////      ProfileResponse jsonResponse =
////      ProfileResponse.fromJson(convert.jsonDecode(response.body));
//      print(response);
//    }
//    print('here');
//
//    return response;
//  }

  Future<Farmer> Profile(BuildContext context) async {
    Farmer farmer;
    User customer = new User.empty();
//    customer.username = phoneController.text;
//    customer.password = passwordController.text;
//    customer.user_type = "1";

    showLoading();
    try {
      final response = await http.post(Global.baseUrl + "Profile/",
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
            ));
      } else if (statusCode == 401) {
        Toast.show("نام کاربری یا کلمه عبور اشتباه است", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    } on SocketException catch (e) {
      print(e);
      Navigator.pop(context);
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }

//    return ProfileResponse.fromJson(json.decode(response.body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ویرایش پروفایل'),
          leading: IconButton(
            icon: new Icon(
              FontAwesomeIcons.chevronRight,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white,
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 1.0),
                tileMode: TileMode.clamp),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 8.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        fontFamily: "IRANYekanMobile",
                        fontSize: 16.0,
                        color: Colors.blueGrey[800]),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
//                  icon: Icon(
//                    FontAwesomeIcons.userAlt,
//                    color: Colors.blueGrey[800],
//                  ),
                      labelText: "نام",
                      hintStyle: TextStyle(
                          fontFamily: "IRANYekanMobile", fontSize: 16.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        fontFamily: "IRANYekanMobile",
                        fontSize: 16.0,
                        color: Colors.blueGrey[800]),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
//                  icon: Icon(
//                    FontAwesomeIcons.userAlt,
//                    color: Colors.blueGrey[800],
//                  ),
                      labelText: "نام خانوادگی",
                      hintStyle: TextStyle(
                          fontFamily: "IRANYekanMobile", fontSize: 16.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        fontFamily: "IRANYekanMobile",
                        fontSize: 16.0,
                        color: Colors.blueGrey[800]),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
//                  icon: Icon(
//                    FontAwesomeIcons.envelope,
//                    color: Colors.blueGrey[800],
//                  ),
                      labelText: "آدرس ایمیل",
                      hintStyle: TextStyle(
                          fontFamily: "IRANYekanMobile", fontSize: 16.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        fontFamily: "IRANYekanMobile",
                        fontSize: 16.0,
                        color: Colors.blueGrey[800]),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
//                  icon: Icon(
//                    FontAwesomeIcons.map,
//                    color: Colors.blueGrey[800],
//                  ),
                      labelText: "استان",
                      hintStyle: TextStyle(
                          fontFamily: "IRANYekanMobile", fontSize: 16.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        fontFamily: "IRANYekanMobile",
                        fontSize: 16.0,
                        color: Colors.blueGrey[800]),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
//                  icon: Icon(
//                    FontAwesomeIcons.mapMarkedAlt,
//                    color: Colors.blueGrey[800],
//                  ),
                      labelText: "شهر",
                      hintStyle: TextStyle(
                          fontFamily: "IRANYekanMobile", fontSize: 16.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        fontFamily: "IRANYekanMobile",
                        fontSize: 16.0,
                        color: Colors.blueGrey[800]),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
//                  icon: Icon(
//                    FontAwesomeIcons.mapMarkerAlt,
//                    color: Colors.blueGrey[800],
//                  ),
                      labelText: "آدرس",
                      hintStyle: TextStyle(
                          fontFamily: "IRANYekanMobile", fontSize: 16.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
//                  width: 100,
                  child: GoogleMap(
                    mapType: MapType.hybrid,
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                )
//                GoogleMap(
//                  mapType: MapType.hybrid,
//                  initialCameraPosition: _kGooglePlex,
//                  onMapCreated: (GoogleMapController controller) {
//                    _controller.complete(controller);
//                  },
//                ),
              ],
            ),
          ),
        ));
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
