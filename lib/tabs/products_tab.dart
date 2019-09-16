import 'dart:io';

import 'package:final_project/date_time_modifier.dart';
import 'package:final_project/farsi_number.dart';
import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/global.dart';
import 'package:final_project/models/data.dart';
import 'package:final_project/models/farmer.dart';
import 'package:final_project/models/product.dart';
import 'package:final_project/screens/add_product_screen.dart';
import 'package:final_project/screens/product_details_screen.dart';
import 'package:final_project/widgets/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:final_project/screens/theme.dart' as Theme;
import 'package:final_project/screens/theme.dart' as Theme;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toast/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductsTab extends StatefulWidget {
  final Farmer farmer;

  ProductsTab({Key key, @required this.farmer}) : super(key: key);

  @override
  _ProductsTabState createState() => new _ProductsTabState(farmer);
}

class _ProductsTabState extends State<ProductsTab> {
  Farmer farmer;
  bool hasData = false;
  bool isLoading = false;
  bool isEmpty = false;
  bool hasError = false;

  Future<Data> futureProducts;
  List<Product> productList = new List();

  _ProductsTabState(this.farmer);

  @override
  void initState() {
    print(farmer.token);
    if (farmer.token == null) {
      farmer.token = Global.token;
    }
    super.initState();
    futureProducts = getProducts(farmer.id.toString(), farmer.token);
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

  Future<Data> getProducts(String userId, String token) async {
    setState(() {
      hasData = false;
      isLoading = true;
      isEmpty = false;
      hasError = false;
    });
    try {
      final response = await http.get(
        Global.baseUrl + 'products/$userId',
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: token
        },
      );
      print(response.body);
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        Data _response = Data.fromJson(json.decode(response.body));
//        Data _response = Data.fromJson(json.decode(data));
        if (_response != null) {
          setState(() {
            productList = _response.products;
            if (productList.length > 0) {
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

  Widget _productItem(BuildContext context, int index) {
    Product item = productList[index];
    String imageUrl = "";
    if (item.images.length > 0) {
      imageUrl = item.images[0].image_file;
    }
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.only(top:16.0,left: 16,right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16,bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: CachedNetworkImage(
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
                        )),
              ),
            ),
            Flexible(
                child: Column(
              children: <Widget>[
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
                      item.fruit_name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'IRANYekanMobileBold',
                          fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'وزن: ',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'IRANYekanMobileBold',
                          fontSize: 14),
                    ),
                    Text(
                      FarsiNumber(item.weight).getNumber() + " کیلوگرم",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'IRANYekanMobileBold',
                          fontSize: 14),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'قیمت: ',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'IRANYekanMobileBold',
                          fontSize: 14),
                    ),
                    Text(
                      FarsiNumber(item.price).getNumber() + " تومان",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'IRANYekanMobileBold',
                          fontSize: 14),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'تاریخ ثبت محصول: ',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'IRANYekanMobileBold',
                          fontSize: 14),
                    ),
                    Flexible(
                        child: Text(
                      DateTimeModifier(item.created_at.toString())
                          .getFarsiDateTime(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'IRANYekanMobileBold',
                          fontSize: 14),
                    ))
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8,right: 8,top: 8),
                  child: Divider(height: 0.5, color: Colors.blueGrey[400]),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 40,
                        alignment: Alignment.centerRight,
                        child: Text(
                          'جزئیات و ویرایش محصول',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              color: Colors.blue[400],
                              fontFamily: 'IRANYekanMobile',
                              fontSize: 15),
                        ),
                      ),
                      Icon(
                        FontAwesomeIcons.chevronLeftRegular,
                        color: Colors.blue[400],
                        size: 17,
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(product: item),
                      ),
                    ).then((value) {
                      futureProducts =
                          getProducts(farmer.id.toString(), farmer.token);
                    });
                  },
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
          Padding(
              padding: EdgeInsets.all(8),
              child: RaisedButton(
                  elevation: 8,
                  highlightElevation: 12,
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Colors.blueGrey[800],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 30.0),
                    child: Text(
                      "افزودن محصول",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontFamily: "IRANYekanMobile"),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddProductScreen(farmer: this.farmer),
                        )).then((value) {
                      futureProducts =
                          getProducts(farmer.id.toString(), farmer.token);
                    });
                  })),
          Visibility(
            visible: hasData,
            child: Expanded(
                child: FutureBuilder(
                    future: futureProducts,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                "خطایی رخ داده است، لطفا مجددا تلاش نمایید.",
                                style: new TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.blueGrey[700],
                                    fontFamily: "IranYekanMobileBold"),
                              ),
                            ),
                          );
                        default:
                          if (snapshot.hasError)
                            return Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  "لطفا اتصال دستگاه خود به اینترنت را بررسی نموده و مجددا تلاش نمایید.",
                                  style: new TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.blueGrey[700],
                                      fontFamily: "IranYekanMobileBold"),
                                ),
                              ),
                            );
                          else {
                            if (snapshot.data != null) {
                              return ListView.builder(
                                physics: BouncingScrollPhysics(),
                                shrinkWrap: false,
                                scrollDirection: Axis.vertical,
                                itemCount: productList.length,
                                itemBuilder: _productItem,
                              );
                            } else {
                              return Text('');
                            }
                          }
                      }
                    })),
          ),
          Visibility(
              visible: isLoading,
              child: Expanded(child: Center(child: progressIndicator()))),
          Visibility(
              visible: isEmpty,
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
      itemCount: productList.length,
//                      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
    );
  }
}
