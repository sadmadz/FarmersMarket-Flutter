import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/models/product.dart';
import 'package:final_project/screens/add_image_screen.dart';
import 'package:final_project/screens/image_screen.dart';
import 'package:final_project/widgets/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

import '../global.dart';

class NewProductImageScreen extends StatefulWidget {
  Product product;

  NewProductImageScreen({Key key, @required this.product}) : super(key: key);

  @override
  _NewProductImageScreenState createState() =>
      new _NewProductImageScreenState(product);
}

class _NewProductImageScreenState extends State<NewProductImageScreen> {
  Product product;

  _NewProductImageScreenState(this.product);

  int imagesLength;

  @override
  void initState() {
    super.initState();
    product.images = [];
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
        child: Stack(
      children: <Widget>[
        Padding(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[300],
                    blurRadius: 12.0,
                    spreadRadius: 2.0,
                    offset: Offset(0.0, 2.0)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          padding: EdgeInsets.all(20),
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

  Widget imagesGrid() {
    if (product.images == null) {
      imagesLength = 1;
    } else {
      imagesLength = product.images.length + 1;
    }

    return GridView.count(
      physics: BouncingScrollPhysics(),
      crossAxisCount: 2,
      children: List.generate(imagesLength, (index) {
        if (index == 0) {
          return _addButton();
        }
        return Padding(
            padding: const EdgeInsets.all(0.0),
            child: GestureDetector(
                child: imageWidget(product.images[index - 1].id.toString(),
                    product.images[index - 1].image_file),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageScreen(
                          url: product.images[index - 1].image_file),
                    ),
                  );
                }));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('افزودن عکس'),
          centerTitle: true,
          leading: IconButton(
            icon: new Icon(
              FontAwesomeIcons.chevronRight,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            GestureDetector(
              child: Center(
                child: Padding(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    child: Text(
                      'تایید',
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
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'محصول وارد شده با موفقیت ثبت شد.',
                style: TextStyle(
                    color: Colors.green[500],
                    fontSize: 16,
                    fontFamily: "IranYekanMobileBold"),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'در صورت تمایل میتوانید تصاویر محصول را اضافه نمایید.',
                style: TextStyle(color: Colors.blueGrey[800], fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: imagesGrid(),
            ),
          ],
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
        child: Padding(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[300],
                    blurRadius: 12.0,
                    spreadRadius: 2.0,
                    offset: Offset(0.0, 2.0)),
              ],
            ),
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
          padding: EdgeInsets.all(20),
        ));
  }
}
