import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/models/farmer.dart';
import 'package:final_project/models/offer.dart';
import 'package:final_project/models/request.dart';
import 'package:final_project/models/request.dart';
import 'package:final_project/models/user.dart';
import 'package:final_project/screens/map_screen.dart';
import 'package:final_project/widgets/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_project/farsi_number.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toast/toast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../date_time_modifier.dart';
import '../english_number.dart';
import '../global.dart';

class RequestDetailsScreen extends StatefulWidget {
  final Request request;
  final Farmer farmer;

  RequestDetailsScreen({Key key, @required this.request, @required this.farmer})
      : super(key: key);

  @override
  _RequestDetailsScreenState createState() =>
      new _RequestDetailsScreenState(request, farmer);
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  Request request;
  final Farmer farmer;

  _RequestDetailsScreenState(this.request, this.farmer);

  var priceController = TextEditingController();

  bool pending, accepted, clickable, clickableRemove, clicked;
  bool doneRequest = false;

  var offerButtonColor = Colors.grey[300];
  var offerButtonIcon = FontAwesomeIcons.solidAddressBook;
  String offerButtonText = "پیشنهاد";

  GoogleMapController mapController;

  offer() async {
    Offer offer = Offer.empty();
    Farmer farmer = Farmer.empty();
    Request request = Request.empty();
    farmer.id = this.farmer.id;
    request.id = this.request.id;
    offer.request = request;
    offer.farmer = farmer;
    offer.accepted = false;
    offer.pending = true;
    offer.price = EnglishNumber(priceController.text).getNumber();

    String requestId = request.id.toString();
    String farmerId = farmer.id.toString();
    print(Global.baseUrl + "offer/farmer/$farmerId/request/$requestId");
    try {
      final response = await http.post(
          Global.baseUrl + "offer/farmer/$farmerId/request/$requestId",
          headers: {
            "Content-Type": "application/json",
            HttpHeaders.authorizationHeader: Global.token
          },
          body: json.encode(offer.toJson()));
      final int statusCode = response.statusCode;
      print(json.encode(offer.toJson()));
      print(response.statusCode);
      print(response.body);
      if (statusCode == 201) {
        setState(() {
          pending = true;
          offerButtonColor = Colors.green[200];
          clickable = false;
          offerButtonText = "پیشنهاد شده";
          offerButtonIcon = FontAwesomeIcons.check;
          clickableRemove = true;
        });
      } else {
        clickable = true;
      }
    } on SocketException catch (e) {
      clickable = true;
      print(e);
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  removeOffer() async {
    String requestId = request.id.toString();
    String farmerId = farmer.id.toString();

    print(Global.baseUrl + "offer/farmer/$farmerId/request/$requestId");
    try {
      final response = await http.delete(
          Global.baseUrl + "offer/farmer/$farmerId/request/$requestId",
          headers: {
            "Content-Type": "application/json",
            HttpHeaders.authorizationHeader: Global.token
          });
      final int statusCode = response.statusCode;
      print(response.statusCode);
      print(response.body);
      if (statusCode == 200) {
        setState(() {
          pending = false;
          offerButtonColor = Colors.grey[300];
          clickable = true;
          offerButtonText = "پیشنهاد";
        });
      } else {
        clickableRemove = true;
        Toast.show("خطایی رخ داده است، مجددا تلاش نمایید", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    } on SocketException catch (e) {
      clickableRemove = true;
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  String controlPriceField() {
    if (clickable && clicked) {
      if (priceController.text == "") {
        return "لطفا قیمت پیشنهادی را وارد نمایید";
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    print(request.offers.length);

    pending = false;
    accepted = false;
    clickable = true;
    clickableRemove = false;
    clicked = false;

    print("request baby");
    print(request.offers.length);

    for (int i = 0; i < request.offers.length; i++) {
      var offer = request.offers[i];
      if (farmer.id == offer.farmer.id) {
        priceController.text = FarsiNumber(offer.price).getNumber();
        if (offer.pending) {
          pending = true;
          offerButtonColor = Colors.green[200];
          clickable = false;
          offerButtonText = "پیشنهاد شده";
          offerButtonIcon = FontAwesomeIcons.check;
          clickableRemove = true;
        } else if (offer.accepted == true) {
          pending = true;
          offerButtonColor = Colors.green[200];
          clickable = false;
          offerButtonText = "پیشنهاد پذیرفته شده";
          clickableRemove = false;
        }
      }
    }
    if (request.offers.length == 1) {
      if (request.offers[0].accepted) {
        doneRequest = true;
      }
    }
    clicked = false;
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
            title: Text('جزئیات درخواست'),
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
                  Visibility(
                    visible: doneRequest,
                    child: Container(
                      child: Text(
                        'درخواست انجام شده',
                        style: TextStyle(
                            color: Colors.blueGrey[900],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 14),
                      ),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.green[400],
                          borderRadius: new BorderRadius.circular(10.0)),
                    ),
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
                      Text(
                        request.fruit_name,
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
                        'خریدار: ',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 14),
                      ),
                      Text(
                        request.customer.first_name +
                            " " +
                            request.customer.last_name,
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
                        'وزن(کیلوگرم): ',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 14),
                      ),
                      Text(
                        FarsiNumber(request.weight).getNumber(),
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
                        'توضیحات: ',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 14),
                      ),
                      Text(
                        request.description,
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
                        'شماره تماس: ',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 14),
                      ),
                      Text(
                        FarsiNumber(request.customer.phone_number).getNumber(),
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
                        'تاریخ ثبت درخواست: ',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'IRANYekanMobileBold',
                            fontSize: 14),
                      ),
                      Text(
                        DateTimeModifier(request.updated_at.toString())
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
                  Visibility(
                      visible: !doneRequest,
                      child: Column(
                        children: <Widget>[
                          Align(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: 8, top: 8, bottom: 8, left: 10),
                              child: Text(
                                "ارائه پیشنهاد",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blueGrey[800]),
                              ),
                            ),
                            alignment: Alignment.centerRight,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 8, right: 8, top: 8, bottom: 16),
                            child: TextField(
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  prefixIcon: Icon(FontAwesomeIcons.wallet,
                                      color: Colors.blueGrey[800], size: 18.0),
                                  hintText: "قیمت هر کیلوگرم(تومان)",
                                  errorText: controlPriceField()),
                              style: TextStyle(
                                  fontFamily: "IRANYekanMobile",
                                  fontSize: 14.0,
                                  color: Colors.blueGrey[800]),
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              enabled: !(pending || accepted),
                              onChanged: (text) {
                                setState(() {
                                  clicked =false;
                                  var cursorPos = priceController.selection;
                                  priceController.text =
                                      FarsiNumber(priceController.text)
                                          .getNumber();
                                  if (cursorPos.start >
                                      priceController.text.length) {
                                    cursorPos = new TextSelection.fromPosition(
                                        new TextPosition(
                                            offset:
                                                priceController.text.length));
                                  }
                                  priceController.selection = cursorPos;
                                });
                              },
                            ),
                          ),
                          IntrinsicWidth(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                RaisedButton(
                                  shape: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.blueGrey[800])),
                                  color: offerButtonColor,
                                  child: Text(offerButtonText),
                                  onPressed: () {
                                    print(clickable);
                                    if (clickable) {
                                      setState(() {
                                        clicked = true;
                                      });
                                      if (priceController.text != "") {
                                        offer();
                                        clickable = false;
                                      }
                                    }
                                  },
                                ),
                                AnimatedOpacity(
                                  // If the widget is visible, animate to 0.0 (invisible).
                                  // If the widget is hidden, animate to 1.0 (fully visible).
                                  opacity: pending ? 1.0 : 0.0,
                                  duration: Duration(milliseconds: 300),
                                  // The green box must be a child of the AnimatedOpacity widget.
                                  child: RaisedButton(
                                    shape: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.blueGrey[900])),
                                    color: Colors.red[300],
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Text(
                                              "حذف پیشنهاد",
                                              style: TextStyle(
                                                color: Colors.blueGrey[900],
                                              ),
                                            )),
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 4),
                                            child: Icon(
                                              FontAwesomeIcons.times,
                                              color: Colors.blueGrey[900],
                                              size: 18,
                                            ))
                                      ],
                                    ),
                                    onPressed: () {
                                      if (clickableRemove) {
                                        removeOffer();
                                        clickableRemove = false;
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ),
        ));
  }
}
