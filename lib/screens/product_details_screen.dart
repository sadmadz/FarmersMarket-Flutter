import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/date_time_modifier.dart';
import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/models/city.dart';
import 'package:final_project/models/data.dart';
import 'package:final_project/models/fruit.dart';
import 'package:final_project/models/product.dart';
import 'package:final_project/models/province.dart';
import 'package:final_project/screens/add_image_screen.dart';
import 'package:final_project/screens/image_screen.dart';
import 'package:final_project/screens/map_screen.dart';
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

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  ProductDetailScreen({Key key, @required this.product}) : super(key: key);

  @override
  _ProductDetailScreenState createState() =>
      new _ProductDetailScreenState(product);
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product product;

  _ProductDetailScreenState(this.product);

  Completer<GoogleMapController> _controller = Completer();
  Marker marker;
  LatLng position;

  CameraPosition _kGooglePlex;

  GoogleMapController mapController;

  List<City> cities = [];
  List<Province> provinces = [];
  List<Fruit> fruits = [];

  String fruitName = null;
  String city = null;
  String province = null;

  final weightController = TextEditingController();
  final priceController = TextEditingController();
  final addressController = TextEditingController();

  final descriptionController = TextEditingController();

  // ignore: missing_return
  updateProduct(BuildContext context) async {
    Product prod = new Product.empty();
    prod.fruit_name = fruitName;
    prod.weight = EnglishNumber(weightController.text).getNumber();
    prod.price = EnglishNumber(priceController.text).getNumber();
    prod.description = descriptionController.text;
    prod.farm_lat = position.latitude.toStringAsFixed(6);
    prod.farm_lng = position.longitude.toStringAsFixed(6);
    prod.province = province;
    prod.city = city;
    prod.address = addressController.text;

    String prodId = product.id.toString();
    String farmerId = product.farmer.id.toString();

    showLoading();
    print(Global.baseUrl + "farmers/$farmerId/product/$prodId");
    try {
      final response =
          await http.put(Global.baseUrl + "farmers/$farmerId/product/$prodId",
              headers: {
                "Content-Type": "application/json",
                HttpHeaders.authorizationHeader: Global.token
              },
              body: json.encode(prod.toJson()));
      final int statusCode = response.statusCode;
      print(json.encode(prod.toJson()));
      print(statusCode);
      print(response.body);
      Navigator.pop(context);
      if (statusCode == 200 || statusCode == 204) {
        product.fruit_name = prod.fruit_name;
        Navigator.pop(context);
      }
    } on SocketException catch (e) {
      print(e);
      Navigator.pop(context);
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  deleteProduct(BuildContext context) async {
    String prodId = product.id.toString();
    String farmerId = product.farmer.id.toString();

    showLoading();
    print(Global.baseUrl + "farmers/$farmerId/product/$prodId");
    try {
      final response = await http.delete(
          Global.baseUrl + "farmers/$farmerId/product/$prodId",
          headers: {
            "Content-Type": "application/json",
            HttpHeaders.authorizationHeader: Global.token
          });
      final int statusCode = response.statusCode;
      print(response.statusCode);
      Navigator.pop(context);
      if (statusCode == 200 || statusCode == 204) {
        Navigator.pop(context, prodId);
      }
    } on SocketException catch (e) {
      print(e);
      Navigator.pop(context);
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  deleteProductImage(String imageId) async {
//    showLoading();
    print(Global.baseUrl + "image/product/$imageId/remove/");
    try {
      final response = await http
          .delete(Global.baseUrl + "image/product/$imageId/remove/", headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: Global.token
      });
      final int statusCode = response.statusCode;
      print(response.statusCode);
      print(response.body);
      Navigator.pop(context);
      if (statusCode == 200) {
//        Navigator.pop(context);
        setState(() {
          product.images.removeWhere((item) => item.id.toString() == imageId);
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
        for(Province pr in provinces){
          if(pr.province == product.province){
            getCities(pr.id.toString());
            break;
          }
        }
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
      final response = await http.get(Global.baseUrl + "cities/$provinceId", headers: {
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

  showDeleteImageDialog(String imageId) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
            onWillPop: () {
              Navigator.pop(context);
            },
            child: new Material(
              type: MaterialType.transparency,
              child: Container(
                  alignment: AlignmentDirectional.center,
                  child: new Container(
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.circular(10.0)),
                      width: 300.0,
                      height: 150.0,
                      alignment: AlignmentDirectional.center,
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          new Center(
                              child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 20, left: 10, right: 10),
                                  child: Text(
                                      "از حذف عکس مورد نظر مطمئن هستید؟"))),
                          new Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                RaisedButton(
                                    elevation: 6,
                                    highlightElevation: 12,
                                    shape: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide(
                                            color: Colors.blueGrey[800])),
                                    color: Colors.grey[200],
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 30.0),
                                      child: Text(
                                        "بله",
                                        style: TextStyle(
                                            color: Colors.blueGrey[800],
                                            fontSize: 16.0,
                                            fontFamily: "IRANYekanMobileLight"),
                                      ),
                                    ),
                                    onPressed: () {
                                      deleteProductImage(imageId);
                                    }),
                                RaisedButton(
                                    elevation: 6,
                                    highlightElevation: 12,
                                    shape: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide(
                                            color: Colors.blueGrey[800])),
                                    color: Colors.grey[200],
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 30.0),
                                      child: Text(
                                        "خیر",
                                        style: TextStyle(
                                            color: Colors.blueGrey[800],
                                            fontSize: 16.0,
                                            fontFamily: "IRANYekanMobileLight"),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ))),
            )));
  }

  imageWidget(String imageId, String imageUrl) {
    return Container(
        height: 120.0,
        width: 120.0,
        child: Stack(
          children: <Widget>[
            Padding(
              child: Container(
                alignment: Alignment.center,
                height: 105.0,
                width: 105.0,
//      padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[300],
                        blurRadius: 12.0,
                        spreadRadius: 2.0,
                        offset: Offset(0.0, 2.0)),
                    // BoxShadow(color: Colors.white, blurRadius: 20.0, spreadRadius: 10.5)
                  ],
                ),
//      child: Image.asset('assets/images/user_avatar.png'),

                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: 105.0,
                    height: 105.0,
//        errorWidget: (context, url, error) => ClipRRect(
//          borderRadius: BorderRadius.all(Radius.circular(45)),
//          child: Image.asset(
//            'assets/images/user_avatar.png',
//            fit: BoxFit.cover,
//            width: 90,
//            height: 90,
//          ),
//        ),
                  ),
                ),
              ),
              padding: EdgeInsets.only(right: 20, top: 20),
            ),
            GestureDetector(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Stack(
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.solidCircle,
                      color: Colors.white,
                      size: 30,
                    ),
                    Icon(
                      FontAwesomeIcons.solidTimesCircle,
                      color: Colors.red[400],
                      size: 30,
                    )
                  ],
                ),
              ),
              onTap: () {
                showDeleteImageDialog(imageId);
              },
            ),
          ],
        ));
  }

  @override
  void initState() {
    super.initState();

    fruitName = product.fruit_name;
    weightController.text = FarsiNumber(product.weight).getNumber();
    priceController.text = FarsiNumber(product.price).getNumber();
    descriptionController.text = product.description;
    province = product.province;
    city = product.city;
    addressController.text = product.address;

    getFruits();
    getProvinces();


    position =
        LatLng(double.parse(product.farm_lat), double.parse(product.farm_lng));

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
        appBar: AppBar(
            title: Text('جزئیات محصول'),
            centerTitle: true,
            leading: IconButton(
              icon: new Icon(
                FontAwesomeIcons.chevronRight,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            )),
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
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: 8.0),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    BorderSide(color: Colors.blueGrey[800])),
                            color: Colors.grey[200],
                            child: Row(
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Text("اعمال تغییرات")),
                                Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Icon(
                                      FontAwesomeIcons.check,
                                      color: Colors.blueGrey[800],
                                      size: 18,
                                    ))
                              ],
                            ),
                            onPressed: () {
                              updateProduct(context);
                            },
                          ),
                          RaisedButton(
                            shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    BorderSide(color: Colors.blueGrey[800])),
                            color: Colors.grey[200],
                            child: Row(
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Text("حذف محصول")),
                                Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Icon(
                                      FontAwesomeIcons.solidTrashAlt,
                                      color: Colors.blueGrey[800],
                                      size: 18,
                                    ))
                              ],
                            ),
                            onPressed: () {
                              deleteProduct(context);
                            },
                          ),
                        ],
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
                          margin: EdgeInsets.only(
                              right: 10.0, left: 10.0),
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
                              margin: EdgeInsets.only(left: 10.0, right: 10.0),height: 35,
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
                        buildCounter: (BuildContext context,
                                {int currentLength,
                                int maxLength,
                                bool isFocused}) =>
                            null,
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        inputFormatters: [
                          new BlacklistingTextInputFormatter(
                              new RegExp('[\\.|\\,]')),
                        ],
                        maxLengthEnforced: true,
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
                          inputFormatters: [
                            new BlacklistingTextInputFormatter(
                                new RegExp('[\\.|\\,]')),
                          ],
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
                          margin: EdgeInsets.only(
                              right: 10.0, left: 10.0),
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
                              margin: EdgeInsets.only(left: 10.0, right: 10.0),height: 35,
                              child: DropdownButton<String>(
                                onChanged: (value) {
                                  setState(() {
                                    province = value;
//                                    getCities("1");
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
                      Padding(padding: EdgeInsets.only(left: 4,right: 4)),
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
                          margin: EdgeInsets.only(
                              right: 10.0, left: 10.0),
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
                              margin: EdgeInsets.only(left: 10.0, right: 10.0),height: 35,
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
                        'آدرس: ',
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
                    child: Divider(height: 0.5, color: Colors.blueGrey[400]),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'فروشنده: ',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 14),
                      ),
                      Text(
                        product.farmer.first_name +
                            " " +
                            product.farmer.last_name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 14),
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
                        'زمان ثبت محصول: ',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 14),
                      ),
                      Text(
                        DateTimeModifier(product.created_at.toString())
                            .getFarsiDateTime(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 14),
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
                        'زمان ویرایش محصول: ',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 14),
                      ),
                      Text(
                        DateTimeModifier(product.updated_at.toString()).getFarsiDateTime(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 14),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Divider(height: 0.5, color: Colors.blueGrey[400]),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            right: 8, top: 8, bottom: 8, left: 10),
                        child: Icon(
                          FontAwesomeIcons.images,
                          color: Colors.blueGrey[800],
                          size: 18,
                        ),
                      ),
                      Text(
                        "تصاویر محصول",
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueGrey[800]),
                      )
                    ],
                  ),
                  Container(
                    height: 150.0,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 15),
                            child: _addButton(),
                          );
                        }
                        return Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: GestureDetector(
                                child: imageWidget(
                                    product.images[index - 1].id.toString(),
                                    product.images[index - 1].image_file),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageScreen(
                                          url: product
                                              .images[index - 1].image_file),
                                    ),
                                  );
                                }));
                      },
                      itemCount: product.images.length + 1,
//                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                    ),
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
                            child: Text("ویرایش آدرس")),
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

  Widget _addButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddImageScreen(
                type: "product_image", productId: product.id.toString()),
          ),
        ).then((value) {
          if (value != null) {
            setState(() {
              product = value;
            });
          }
        });
      },
      child: Container(
        margin: EdgeInsets.all(12.0),
        alignment: Alignment.center,
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
                color: Colors.black54, width: 0.5, style: BorderStyle.solid)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              FontAwesomeIcons.plusCircle,
              color: Color(0xFF06bc86),
              size: 26,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                "افزودن تصویر",
                style: TextStyle(
                    fontSize: 14.0, fontFamily: "IranYekanMobileBold"),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
