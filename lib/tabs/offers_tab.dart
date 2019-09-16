import 'dart:io';

import 'package:final_project/date_time_modifier.dart';
import 'package:final_project/farsi_number.dart';
import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/global.dart';
import 'package:final_project/models/customeroffer.dart';
import 'package:final_project/models/customeroffers.dart';
import 'package:final_project/models/data.dart';
import 'package:final_project/models/farmer.dart';
import 'package:final_project/models/offer.dart';
import 'package:final_project/models/product.dart';
import 'package:final_project/screens/add_product_screen.dart';
import 'package:final_project/screens/product_details_screen.dart';
import 'package:final_project/widgets/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:final_project/screens/theme.dart' as Theme;
import 'package:final_project/screens/theme.dart' as Theme;
import 'package:flutter/material.dart' as prefix0;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toast/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OffersTab extends StatefulWidget {
  final Farmer farmer;

  OffersTab({Key key, @required this.farmer}) : super(key: key);

  @override
  _OffersTabState createState() => new _OffersTabState(farmer);
}

class _OffersTabState extends State<OffersTab> {
  Farmer farmer;
  bool hasData = false;
  bool isLoading = false;
  bool isEmpty = false;
  bool hasError = false;
  bool hasMoreItems = false;
  int listLength;
  int totalCount;

  Color sortButtonColor = Colors.grey[200];
  Color filterButtonColor = Colors.grey[200];

  int limit, offset;

  List<CustomerOffer> offers = new List();

  ScrollController _scrollController = new ScrollController();


  _OffersTabState(this.farmer);

  @override
  void initState() {
    initLayout();
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  initLayout() {
    hasData = false;
    isLoading = true;
    hasError = false;
    hasMoreItems = false;
    listLength = offers.length;
    totalCount = 0;
    limit = 10;
    offset = 0;
    getOffers();
    offset = offset + limit;

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (totalCount > offers.length) {
          getOffers();
          offset = offset + limit;
        }
      }
    });
  }

  getOffers() async {
    String farmerId = farmer.id.toString();
    setState(() {
      hasData = false;
      isLoading = true;
      isEmpty = false;
      hasError = false;
    });
    print(Global.baseUrl + "customerOffer/$farmerId");
    try {
      final response = await http.get(Global.baseUrl + "customerOffer/$farmerId",
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: Global.token
        },
      );
      print(response.body);
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        CustomerOffers _response = CustomerOffers.fromJson(json.decode(response.body));
        if (_response != null) {
          setState(() {
            offers = _response.offers;
            if (offers.length > 0) {
              hasData = true;
            } else {
              isEmpty = true;
            }
          });
        } else {
          isEmpty = true;
        }
        return Data.fromJson(json.decode(response.body));
      } else {
        print(response.statusCode);
        if (mounted) {
          Toast.show("خطا در برقراری ارتباط با سرور", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
      }
    } on SocketException catch (e) {
      if (mounted) {
        Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
      setState(() {
        hasError = true;
        isLoading = false;
        hasData = false;
        isEmpty = false;
      });
    }
    return null;
  }


  deleteOffer(BuildContext context, Offer offer) async {
    String offerId = offer.id.toString();
    print(Global.baseUrl + "offers/$offerId");
    try {
      final response =
      await http.delete(Global.baseUrl + "customerOffer/$offerId/", headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: Global.token
      });
      final int statusCode = response.statusCode;
      print(response.statusCode);
      if (statusCode == 200) {
        setState(() {
          offers.remove(offer);
        });
      }
    } on SocketException catch (e) {
      print(e);
      Navigator.pop(context);
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  acceptOffer(BuildContext context, Offer offer) async {
    String farmerId = farmer.id.toString();

    CustomerOffer acceptOffer = CustomerOffer.empty();
    acceptOffer.accepted = true;
    acceptOffer.pending = false;
    acceptOffer.price = offer.price;

    print(Global.baseUrl + "customerOffer/$farmerId");
    try {
      final response = await http.put(Global.baseUrl + "customerOffer/$farmerId/",
          headers: {
            "Content-Type": "application/json",
            HttpHeaders.authorizationHeader: Global.token
          },
          body: json.encode(acceptOffer.toJson()));
      final int statusCode = response.statusCode;
      print(response.statusCode);
      print(response.body);
      if (statusCode == 200) {
        setState(() {
          for (CustomerOffer i in offers) {
            if (i.id != offer.id) {
              offers.remove(i);
            }
          }
//          showDeleteButton = false;
//          accepted = true;
//          acceptButtonText = "تایید شده";
        });
      }
    } on SocketException catch (e) {
      print(e);
      Navigator.pop(context);
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  Widget progressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: SizedBox(
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
    );
  }

  Widget offerItem(CustomerOffer item) {
    String price = item.price;
    print(price);
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(45)),
                    child: CachedNetworkImage(
                      imageUrl: item.customer.avatar.toString(),
                      fit: BoxFit.cover,
                      width: 60.0,
                      height: 60.0,
                      errorWidget: (context, url, error) => ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(45)),
                        child: Container(
                          alignment: Alignment.center,
                          width: 60.0,
                          height: 60.0,
                          color: Colors.grey[500],
                          child: Icon(
                            FontAwesomeIcons.user,
                            color: Colors.white,
                            size: 30,

                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "قیمت پیشنهاد شده:" + FarsiNumber(price).getNumber(),
                            style: new TextStyle(
                                fontSize: 14.0,
                                color: Colors.blueGrey[900],
                                fontFamily: "IRANYekanMobileBold"),
                          ),
                          Padding(padding: EdgeInsets.all(4)),
                          Container(
                              decoration: new BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: new BorderRadius.circular(16.0)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: 12, right: 12, bottom: 12, left: 4),
                                      child: Text("مشاهده جزییات محصول",
                                          style: new TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.blueGrey[900],
                                              fontFamily: "IRANYekanMobileBold"))),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(
                                      FontAwesomeIcons.chevronLeft,
                                      color: Colors.blueGrey[900],
                                      size: 12,
                                    ),
                                  )
                                ],
                              ))
                        ])),
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                      width: 60,
                      child: RaisedButton(
                        shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            BorderSide(color: Colors.blueGrey[900])),
                        color: Colors.green[200],
                        child: Text(
                            "تایید",
                            style: new TextStyle(
                                fontSize: 12.0,
                                color: Colors.blueGrey[900],
                                fontFamily: "IRANYekanMobileBold")),
                        onPressed: () {
//                          if (showDeleteButton) {
//                            acceptOffer(context, item);
//                          }
                        },
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(4)),
                    Visibility(
                      visible: true,
                      child: SizedBox(
                          height: 30,
                          width: 60,
                          child: RaisedButton(
                            shape: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                BorderSide(color: Colors.blueGrey[900])),
                            color: Colors.red[200],
                            child: Text("حذف",
                                style: new TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.blueGrey[900],
                                    fontFamily: "IRANYekanMobileBold")),
                            onPressed: () {
//                              deleteOffer(context, item);
                            },
                          )),
                    )
                  ],
                )

//        Text(item.accepted.toString())
              ],
            ),
          ),
        ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Visibility(
                visible: hasData,
                child: Expanded(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: false,
                      scrollDirection: Axis.vertical,
                      itemCount: offers.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == offers.length && hasMoreItems) {
                          return progressIndicator();
                        } else {
                          return offerItem(offers[index]);
                        }
                      },
                      controller: _scrollController,
                    )),
              ),
              Visibility(
                  visible: isLoading && !hasData,
                  child: Expanded(child: progressIndicator())),
              Visibility(
                  visible: !hasData && !isLoading,
                  child: Expanded(
                      child: Center(
                          child: Text(
                            "اطلاعاتی برای نمایش وجود ندارد",
                            style: new TextStyle(
                                fontSize: 14.0,
                                color: Colors.blueGrey[700],
                                fontFamily: "IranYekanMobileBold"),
                          )))),
              Visibility(
                  visible: hasError,
                  child: Expanded(
                      child: Center(
                          child: Text(
                            "لطفا اتصال دستگاه خود به اینترنت را بررسی نموده و مجددا تلاش نمایید",
                            style: new TextStyle(
                                fontSize: 14.0,
                                color: Colors.blueGrey[700],
                                fontFamily: "IranYekanMobileBold"),
                          ))))
        ]));
  }

  _listItem(Product item) {
    String imageUrl = "";
    if (item.images.length > 0) {
      imageUrl = item.images[0].image_file;
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    width: 80.0,
                    height: 80.0,
                    errorWidget: (context, url, error) => Container(
                          width: 80.0,
                          height: 80.0,
                          color: Colors.grey[500],
                          child: Center(
                            child: Icon(
                              FontAwesomeIcons.appleCrate,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ))
              ],
            ));
      },
      itemCount: offers.length,
//                      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
    );
  }
}
