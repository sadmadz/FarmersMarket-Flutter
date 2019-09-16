import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/models/product.dart';
import 'package:final_project/widgets/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../global.dart';

class AddImageScreen extends StatefulWidget {
  final String type,productId;

  AddImageScreen({Key key, @required this.type, @required this.productId}) : super(key: key);

  @override
  _AddImageScreenState createState() => new _AddImageScreenState(type,productId);
}

class _AddImageScreenState extends State<AddImageScreen> {
  String type,productId;

  _AddImageScreenState(this.type,this.productId);

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  File _image;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  showLoading(String input) {
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
                              input,
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


  void uploadProductImage() async {
    print("start uploading");
    if (_image == null) {
      Navigator.pop(context);
      return;
    }

    showLoading("در حال آپلود عکس");

    FormData formData = new FormData.from({
      "image": new UploadFileInfo(
          _image, DateTime.now().toString()+"_"+productId+".jpg")
    });
    try {
      Response response =
      await Dio().post(Global.baseUrl + "image/product/$productId/add/", data: formData);
      Navigator.pop(context);
      if (response.statusCode == 201) {
        Navigator.pop(context,Product.fromJson(response.data));
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  imageHolder() {
    if (_image != null) {
      return Image.file(_image);
    } else {
      return Text('');
    }
  }

  Future selectPicture() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  Future takePicture() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  Future<File> compressImage(File file, String targetPath) async {
    showLoading("در حال فشرده سازی");
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 50,
    );

    Navigator.pop(context);

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('انتخاب عکس'),
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
                compressImage(_image, _image.path);
                if(type == "product_image"){
                  uploadProductImage();
                }else if (type == "avatar_image"){
                  Navigator.pop(context, _image);
                }

              },
            )
          ],
        ),
        body: Container(
          child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 12, right: 12, top: 16),
                    child: Row(
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
                          child: Padding(
                              padding: EdgeInsets.only(left: 8, right: 12),
                              child: Text("گالری")),
                          onPressed: () {
                            selectPicture();
                          },
                        ),
                        RaisedButton(
                          shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide:
                              BorderSide(color: Colors.blueGrey[800])),
                          color: Colors.grey[200],
                          child: Padding(
                              padding: EdgeInsets.only(left: 8, right: 12),
                              child: Text("دوربین")),
                          onPressed: () {
                            takePicture();
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width - 16,
                        decoration: new BoxDecoration(
                            color: Colors.black,
                            borderRadius:
                            new BorderRadius.all(Radius.circular(12))),
                        child: imageHolder()),
                  ),
                ],
              )),
        ));
  }
}
