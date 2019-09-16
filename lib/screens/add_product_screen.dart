import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/models/city.dart';
import 'package:final_project/models/data.dart';
import 'package:final_project/models/farmer.dart';
import 'package:final_project/models/fruit.dart';
import 'package:final_project/models/product.dart';
import 'package:final_project/models/province.dart';
import 'package:final_project/screens/add_image_screen.dart';
import 'package:final_project/screens/map_screen.dart';
import 'package:final_project/screens/new_product_image_screen.dart';
import 'package:final_project/widgets/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_project/farsi_number.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toast/toast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../english_number.dart';
import '../global.dart';

class AddProductScreen extends StatefulWidget {
  final Farmer farmer;

  AddProductScreen({Key key, @required this.farmer}) : super(key: key);

  @override
  _AddProductScreenState createState() => new _AddProductScreenState(farmer);
}

class _AddProductScreenState extends State<AddProductScreen> {
  Farmer farmer;

  _AddProductScreenState(this.farmer);

  Completer<GoogleMapController> _controller = Completer();
  Marker marker;
  LatLng position;

  List<City> cities = [];
  List<Province> provinces = [];
  List<Fruit> fruits = [];

  String fruitName = null;
  String city = null;
  String province = null;

  CameraPosition _kGooglePlex;

  GoogleMapController mapController;

  final weightController = TextEditingController();
  final priceController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  addProduct() async {
    Product prod = new Product.empty();
    Farmer farmer = Farmer.empty();
    farmer.id = this.farmer.id;
    prod.farmer = farmer;
    prod.fruit_name = fruitName;
    prod.weight = EnglishNumber(weightController.text).getNumber();
    prod.price = EnglishNumber(priceController.text).getNumber();
    prod.description = descriptionController.text;
    prod.farm_lat = position.latitude.toStringAsFixed(6);
    prod.farm_lng = position.longitude.toStringAsFixed(6);
    prod.province = province;
    prod.city = city;
    prod.address = addressController.text;

    String farmerId = farmer.id.toString();

    showLoading();
    print(Global.baseUrl + "products/$farmerId");
    try {
      final response = await http.post(Global.baseUrl + "products/$farmerId",
          headers: {
            "Content-Type": "application/json",
            HttpHeaders.authorizationHeader: Global.token
          },
          body: json.encode(prod.toJson()));
      final int statusCode = response.statusCode;
      print(response.statusCode);
      print(json.encode(prod.toJson()));
      print(response.body);

      Navigator.pop(context);
      if (statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NewProductImageScreen(
                product: Product.fromJson(json.decode(response.body))),
          ),
        );
      }
    } on SocketException catch (e) {
      print(e);
      Navigator.pop(context);
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }

//    return LoginResponse.fromJson(json.decode(response.body));
  }

  getFruits() async {
    try {
      final response = await http.get(Global.baseUrl + "fruits/", headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: Global.token
      });
      final int statusCode = response.statusCode;
      print(response.statusCode);
      print(response.body);

      if (statusCode == 200) {
        setState(() {
          fruits = Data.fromJson(json.decode(response.body)).fruits;
        });
      }
    } on SocketException catch (e) {
      print(e);
      Navigator.pop(context);
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  getProvinces() async {
    try {
      final response = await http.get(Global.baseUrl + "provinces/", headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: Global.token
      });
      final int statusCode = response.statusCode;
      print(response.statusCode);
      print(response.body);

      if (statusCode == 200) {
        setState(() {
          provinces = Data.fromJson(json.decode(response.body)).provinces;
        });
      }
    } on SocketException catch (e) {
      print(e);
      Navigator.pop(context);
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  getCities(String provinceId) async {
    print(Global.baseUrl + "cities/$provinceId");
    try {
      final response =
          await http.get(Global.baseUrl + "cities/$provinceId", headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: Global.token
      });
      final int statusCode = response.statusCode;
      print(response.statusCode);
      print(response.body);

      if (statusCode == 200) {
        setState(() {
          cities = Data.fromJson(json.decode(response.body)).cities;
        });
      }
    } on SocketException catch (e) {
      print(e);
      Navigator.pop(context);
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
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

  @override
  void initState() {
    super.initState();

    getFruits();
    getProvinces();

    position = LatLng(31.8974, 54.3569);

    if (farmer.farmer_lat != null) {
      position = LatLng(
          double.parse(farmer.farmer_lat), double.parse(farmer.farmer_lng));
    }

    _kGooglePlex = CameraPosition(
      target: position,
      zoom: 14.0,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text('افزودن محصول'),
            centerTitle: true,
            leading: IconButton(
              icon: new Icon(
                FontAwesomeIcons.chevronRight,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            )),
        body: Container(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: 8.0),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      RaisedButton(
                        shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                                BorderSide(color: Colors.blueGrey[800])),
                        color: Colors.green[300],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(left: 8, right: 16),
                                child: Text(
                                  "تایید",
                                  style: TextStyle(color: Colors.blueGrey[900]),
                                )),
                            Padding(
                                padding: EdgeInsets.only(bottom: 4, left: 16),
                                child: Icon(
                                  FontAwesomeIcons.check,
                                  color: Colors.blueGrey[900],
                                  size: 18,
                                ))
                          ],
                        ),
                        onPressed: () {
                          addProduct();
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'نوع میوه: ',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 14),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.only(right: 10.0, left: 10.0),
                          width: double.infinity,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1.0, style: BorderStyle.solid),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: Container(
                              margin: EdgeInsets.only(left: 10.0, right: 10.0),
                              height: 35,
                              child: DropdownButton<String>(
                                onChanged: (value) {
                                  setState(() {
                                    fruitName = value;
                                  });
                                },
                                value: fruitName,
                                style: new TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.blueGrey[800]),
                                hint: Text("انتخاب",
                                    style: new TextStyle(
                                        fontFamily: 'IRANYekanMobileBold',
                                        color: Colors.blueGrey[800])),
                                items: fruits.map((Fruit map) {
                                  return new DropdownMenuItem<String>(
                                    value: map.fruit_name,
                                    child: Text(map.fruit_name,
                                        style: new TextStyle(
                                          color: Colors.blueGrey[800],
                                          fontFamily: 'IRANYekanMobileBold',
                                        )),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Divider(height: 0.5, color: Colors.blueGrey[400]),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'وزن محصول (کیلوگرم): ',
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
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        onChanged: (text) {
                          var cursorPos = weightController.selection;
                          weightController.text =
                              FarsiNumber(weightController.text).getNumber();
                          if (cursorPos.start > weightController.text.length) {
                            cursorPos = new TextSelection.fromPosition(
                                new TextPosition(
                                    offset: weightController.text.length));
                          }
                          weightController.selection = cursorPos;
                        },
                      ))
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Divider(height: 0.5, color: Colors.blueGrey[400]),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'قیمت (تومان): ',
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
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          onChanged: (text) {
                            var cursorPos = priceController.selection;
                            priceController.text =
                                FarsiNumber(priceController.text).getNumber();
                            if (cursorPos.start > priceController.text.length) {
                              cursorPos = new TextSelection.fromPosition(
                                  new TextPosition(
                                      offset: priceController.text.length));
                            }
                            priceController.selection = cursorPos;
                          },
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Divider(height: 0.5, color: Colors.blueGrey[400]),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'استان: ',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 14),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.only(right: 10.0, left: 10.0),
                          width: double.infinity,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1.0, style: BorderStyle.solid),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: Container(
                              margin: EdgeInsets.only(left: 10.0, right: 10.0),
                              height: 35,
                              child: DropdownButton<String>(
                                onChanged: (value) {
                                  setState(() {
                                    province = value;
                                    getCities("1");
                                  });
                                },
                                value: province,
                                style: new TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.blueGrey[800]),
                                hint: Text("انتخاب",
                                    style: new TextStyle(
                                        fontFamily: 'IRANYekanMobileBold',
                                        color: Colors.blueGrey[800])),
                                items: provinces.map((Province map) {
                                  return new DropdownMenuItem<String>(
                                    value: map.province,
                                    child: Text(map.province,
                                        style: new TextStyle(
                                          color: Colors.blueGrey[800],
                                          fontFamily: 'IRANYekanMobileBold',
                                        )),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(left: 4, right: 4)),
                      Text(
                        'شهر: ',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 14),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.only(right: 10.0, left: 10.0),
                          width: double.infinity,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1.0, style: BorderStyle.solid),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: Container(
                              margin: EdgeInsets.only(left: 10.0, right: 10.0),
                              height: 35,
                              child: DropdownButton<String>(
                                onChanged: (value) {
                                  setState(() {
                                    city = value;
                                  });
                                },
                                value: city,
                                style: new TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.blueGrey[800]),
                                hint: Text("انتخاب",
                                    style: new TextStyle(
                                        fontFamily: 'IRANYekanMobileBold',
                                        color: Colors.blueGrey[800])),
                                items: cities.map((City map) {
                                  return new DropdownMenuItem<String>(
                                    value: map.city,
                                    child: Text(map.city,
                                        style: new TextStyle(
                                          color: Colors.blueGrey[800],
                                          fontFamily: 'IRANYekanMobileBold',
                                        )),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Divider(height: 0.5, color: Colors.blueGrey[400]),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'آدرس کشاورز: ',
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
                        controller: addressController,
                        keyboardType: TextInputType.text,
                      ))
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Divider(height: 0.5, color: Colors.blueGrey[400]),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'توضیحات: ',
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
                        controller: descriptionController,
                        keyboardType: TextInputType.text,
                      ))
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                  ),
                  Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: <Widget>[
                          GoogleMap(
                            mapType: MapType.normal,
//                            markers: _markers.values.toSet(),
                            initialCameraPosition: _kGooglePlex,
                            scrollGesturesEnabled: false,
                            zoomGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
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
                      )),
                  RaisedButton(
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: Colors.blueGrey[800])),
                    color: Colors.grey[200],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text("تعیین موقعیت مکانی")),
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
                          builder: (context) => MapScreen(location: position),
                        ),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            position = value;
                            mapController
                                .moveCamera(CameraUpdate.newLatLng(position));
                          });
                        }
                      });
                    },
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
