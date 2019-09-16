import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:final_project/english_number.dart';
import 'package:final_project/farsi_number.dart';
import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/models/data.dart';
import 'package:final_project/models/farmer.dart';
import 'package:final_project/models/user.dart';
import 'package:final_project/screens/add_image_screen.dart';
import 'package:final_project/screens/change_password_screen.dart';
import 'package:final_project/screens/map_screen.dart';
import 'package:final_project/widgets/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toast/toast.dart';
import '../global.dart';

class ProfileScreen extends StatefulWidget {
  final Farmer farmer;

  ProfileScreen({Key key, @required this.farmer}) : super(key: key);

  @override
  _ProfileScreenState createState() => new _ProfileScreenState(farmer);
}

class _ProfileScreenState extends State<ProfileScreen> {
  Farmer farmer;
  String imageButtonText, mapButtonText;

  _ProfileScreenState(this.farmer);

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final usernameController = TextEditingController();

  FileImage avatar;
  File _image;
  bool removeAvatar = false;
  String defaultAvatarUrl;

  LatLng location;

  CameraPosition initialCameraPosition;

  GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    if (farmer.avatar != null) {
      defaultAvatarUrl = farmer.avatar;
      imageButtonText = "تغییر عکس";
    } else {
      imageButtonText = "افزودن عکس";
    }

    location = null;
    mapButtonText = "افزودن موقعیت مکانی";
    initialCameraPosition = CameraPosition(
      target: LatLng(32.4279, 53.6880),
      zoom: 14,
    );

    if (farmer.farmer_lat != null) {
      location = LatLng(
          double.parse(farmer.farmer_lat), double.parse(farmer.farmer_lng));
      initialCameraPosition = CameraPosition(
        target: location,
        zoom: 14,
      );
      mapButtonText = "ویرایش موقعیت مکانی";
    }

    firstNameController.text = farmer.first_name;
    lastNameController.text = farmer.last_name;
    usernameController.text = farmer.username;
    phoneNumberController.text = FarsiNumber(farmer.phone_number).getNumber();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    usernameController.dispose();
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

  avatarWidget() {
    if (_image == null) {
      return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(45)),
        child: CachedNetworkImage(
          imageUrl: farmer.avatar.toString(),
          fit: BoxFit.cover,
          width: 90.0,
          height: 90.0,
          errorWidget: (context, url, error) => ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(45)),
            child: Image.asset(
              'assets/images/user_avatar.png',
              fit: BoxFit.cover,
              width: 90,
              height: 90,
            ),
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(45)),
        child: Image.file(
          _image,
          fit: BoxFit.cover,
          width: 90,
          height: 90,
        ),
      );
    }
  }

  updateProfile(BuildContext context) async {
    print("baby");
    Farmer farmer = Farmer.empty();
    String farmerId = this.farmer.id.toString();
    farmer.first_name = firstNameController.text;
    farmer.last_name = lastNameController.text;
    farmer.username = usernameController.text;
    farmer.phone_number = EnglishNumber(phoneNumberController.text).getNumber();

    if (location != null) {
      farmer.farmer_lat = location.latitude.toStringAsFixed(6);
      farmer.farmer_lng = location.longitude.toStringAsFixed(6);
    }

    print(json.encode(farmer.toJson()));
    print(Global.baseUrl + "farmers/$farmerId");

    showLoading();
    try {
      final response = await http.put(Global.baseUrl + "farmers/$farmerId",
          headers: {"Content-Type": "application/json"},
          body: json.encode(farmer.toJson()));
      final int statusCode = response.statusCode;
      print(response.statusCode);
      print(response.body);
//      Navigator.pop(context);
      if (statusCode == 204) {
        this.farmer.first_name = farmer.first_name;
        this.farmer.last_name = farmer.last_name;
        this.farmer.username = farmer.username;
        this.farmer.phone_number = farmer.phone_number;
        this.farmer.farmer_lng = farmer.farmer_lng;
        this.farmer.farmer_lat = farmer.farmer_lat;
//        Navigator.pop(context);
        if (removeAvatar) {
          deleteAvatar();
        } else {
          uploadAvatar();
        }

//        Navigator.pushReplacement(
//            context,
//            MaterialPageRoute(
//              builder: (context) => HomeScreen(farmer: farmer),
//            ));
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

  deleteAvatar() async {
    String farmerId = farmer.id.toString();
    try {
      final response = await http.delete(
          Global.baseUrl + "image/avatar/$farmerId",
          headers: {"Content-Type": "application/json"});
      final int statusCode = response.statusCode;
      Navigator.pop(context);
      if (statusCode == 200) {
        Navigator.pop(context);
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
  }

  void uploadAvatar() async {
    print("hey baby");
    if (_image == null) {
      Navigator.pop(context);
      Navigator.pop(context);
      return;
    }
    String farmerId = farmer.id.toString();

    FormData formData = new FormData.from(
        {"image": new UploadFileInfo(_image, _image.path.split("/").last)});
    try {
      Response response = await Dio()
          .post(Global.baseUrl + "image/avatar/$farmerId", data: formData);
      Navigator.pop(context);
      print(response.statusCode);
      if (response.statusCode == 201) {
        print(response);
        farmer = Farmer.fromJson(response.data);
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  Widget mapWidget() {
    if (location != null) {
      return Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: GoogleMap(
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
            ),
          ));
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text('ویرایش پروفایل'),
              centerTitle: true,
              leading: IconButton(
                icon: new Icon(
                  FontAwesomeIcons.chevronRight,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (farmer.avatar == "") {
                    farmer.avatar = defaultAvatarUrl;
                  }
                  Navigator.pop(context);
                },
              ),
              actions: <Widget>[
                GestureDetector(
                  child: Center(
                    child: Padding(
                        padding: EdgeInsets.only(left: 12, right: 12),
                        child: Text(
                          'ذخیره',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.greenAccent[200],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 18,
                          ),
                        )),
                  ),
                  onTap: () {
                    updateProfile(context);
                  },
                )
              ],
            ),
            body: Container(
              child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (OverscrollIndicatorNotification overscroll) {
                    overscroll.disallowGlow();
                  },
                  child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Column(
                        children: <Widget>[
                          Container(
                              color: Colors.blueGrey[800],
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      RaisedButton(
                                        shape: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        color: Colors.blueGrey[800],
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8),
                                                child: Text(
                                                  imageButtonText,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'IRANYekanMobileLight'),
                                                )),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 4),
                                                child: Icon(
                                                  FontAwesomeIcons.solidImages,
                                                  color: Colors.white,
                                                  size: 18,
                                                ))
                                          ],
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddImageScreen(
                                                        type: "avatar_image",
                                                        productId: ""),
                                              )).then((value) {
                                            if (value != null) {
                                              removeAvatar = false;
                                              _image = value;
                                              imageButtonText = "تغییر عکس";
                                            }
                                          });
                                        },
                                      ),
                                      RaisedButton(
                                        shape: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        color: Colors.redAccent[200],
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8),
                                                child: Text(
                                                  "حذف عکس",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'IRANYekanMobileLight'),
                                                )),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 4),
                                                child: Icon(
                                                  FontAwesomeIcons.times,
                                                  color: Colors.white,
                                                  size: 18,
                                                ))
                                          ],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            removeAvatar = true;
                                            _image = null;
                                            farmer.avatar = "";
                                            imageButtonText = "افزودن عکس";
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 32, bottom: 32),
                                    child: Stack(
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(45)),
                                          child: Container(
                                            color: Colors.white,
                                            width: 90.0,
                                            height: 90.0,
                                          ),
                                        ),
                                        avatarWidget()
                                      ],
                                    ),
                                  )
                                ],
                              )),
                          Padding(
                            padding:
                                EdgeInsets.only(left: 12, right: 12, top: 16),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'نام: ',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: Colors.blueGrey[700],
                                      fontFamily: 'IRANYekanMobileBold',
                                      fontSize: 14),
                                ),
                                Flexible(
                                    child: TextField(
                                  decoration: InputDecoration.collapsed(
                                    border: InputBorder.none,
                                    hintText: "",
                                  ),
                                  style: TextStyle(
                                      fontFamily: "IRANYekanMobile",
                                      fontSize: 14.0,
                                      color: Colors.blueGrey[800]),
                                  controller: firstNameController,
                                  keyboardType: TextInputType.text,
                                ))
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 8, bottom: 8),
                            child: Divider(
                                height: 0.5, color: Colors.blueGrey[400]),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 12, right: 12),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'نام خانوادگی: ',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: Colors.blueGrey[700],
                                      fontFamily: 'IRANYekanMobileBold',
                                      fontSize: 14),
                                ),
                                Flexible(
                                  child: TextField(
                                    decoration: InputDecoration.collapsed(
                                      border: InputBorder.none,
                                      hintText: "",
                                    ),
                                    style: TextStyle(
                                        fontFamily: "IRANYekanMobile",
                                        fontSize: 14.0,
                                        color: Colors.blueGrey[800]),
                                    controller: lastNameController,
                                    keyboardType: TextInputType.text,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 8, bottom: 8),
                            child: Divider(
                                height: 0.5, color: Colors.blueGrey[400]),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 12, right: 12),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'نام کاربری: ',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: Colors.blueGrey[700],
                                      fontFamily: 'IRANYekanMobileBold',
                                      fontSize: 14),
                                ),
                                Flexible(
                                    child: TextField(
                                  decoration: InputDecoration.collapsed(
                                    border: InputBorder.none,
                                    hintText: "",
                                  ),
                                  style: TextStyle(
                                      fontFamily: "IRANYekanMobile",
                                      fontSize: 14.0,
                                      color: Colors.blueGrey[800]),
                                  controller: usernameController,
                                  keyboardType: TextInputType.text,
                                ))
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 8, bottom: 8),
                            child: Divider(
                                height: 0.5, color: Colors.blueGrey[400]),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 12, right: 12),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'شماره موبایل: ',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: Colors.blueGrey[700],
                                      fontFamily: 'IRANYekanMobileBold',
                                      fontSize: 14),
                                ),
                                Flexible(
                                    child: TextField(
                                  decoration: InputDecoration.collapsed(
                                    border: InputBorder.none,
                                    hintText: "",
                                  ),
                                  textAlignVertical: TextAlignVertical.bottom,
                                  style: TextStyle(
                                      fontFamily: "IRANYekanMobile",
                                      fontSize: 14.0,
                                      color: Colors.blueGrey[800]),
                                  controller: phoneNumberController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    var cursorPos =
                                        phoneNumberController.selection;
                                    phoneNumberController.text =
                                        FarsiNumber(phoneNumberController.text)
                                            .getNumber();
                                    if (cursorPos.start >
                                        phoneNumberController.text.length) {
                                      cursorPos =
                                          new TextSelection.fromPosition(
                                              new TextPosition(
                                                  offset: phoneNumberController
                                                      .text.length));
                                    }
                                    phoneNumberController.selection = cursorPos;
                                  },
                                ))
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 8, bottom: 8),
                            child: Divider(
                                height: 0.5, color: Colors.blueGrey[400]),
                          ),
                          Container(
                            margin: EdgeInsets.all(8),
                            decoration: new BoxDecoration(
                                color: Colors.blueGrey[100],
                                borderRadius:
                                    new BorderRadius.all(Radius.circular(8.0))),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 10.0, bottom: 10.0),
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
                                            fontWeight: FontWeight.w700,
                                            color: Colors.blueGrey[800]),
                                      ),
                                      Text(
                                        "(اختیاری)",
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.blueGrey[800]),
                                      )
                                    ],
                                  ),
                                ),
                                mapWidget(),
                                Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 8),
                                  child: RaisedButton(
                                    shape: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide(
                                            color: Colors.blueGrey[800])),
                                    color: Colors.grey[200],
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Text(mapButtonText)),
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 4),
                                            child: Icon(
                                              FontAwesomeIcons.mapMarkedAlt,
                                              color: Colors.blueGrey[800],
                                              size: 18,
                                            ))
                                      ],
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MapScreen(location: location),
                                        ),
                                      ).then((value) {
                                        if (value != null) {
                                          setState(() {
                                            location = value;
                                            initialCameraPosition =
                                                CameraPosition(
                                              target: location,
                                              zoom: 14,
                                            );
                                            mapButtonText =
                                                "ویرایش موقعیت مکانی";
                                            mapController.moveCamera(
                                                CameraUpdate.newLatLng(
                                                    location));
                                          });
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RaisedButton(
                            shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    BorderSide(color: Colors.blueGrey[800])),
                            color: Colors.grey[200],
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Text("تغییر پسورد")),
                                Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Icon(
                                      FontAwesomeIcons.key,
                                      color: Colors.blueGrey[800],
                                      size: 18,
                                    ))
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChangePasswordScreen(farmer: farmer),
                                  ));
                            },
                          ),
                        ],
                      ))),
            )),
        onWillPop: () {
          if (farmer.avatar == "") {
            farmer.avatar = defaultAvatarUrl;
          }
          Navigator.pop(context);
        });
  }
}
