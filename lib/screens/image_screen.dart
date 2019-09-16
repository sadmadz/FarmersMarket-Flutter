import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/widgets/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class ImageScreen extends StatefulWidget {
  final String url;

  ImageScreen({Key key, @required this.url}) : super(key: key);

  @override
  _ImageScreenState createState() => new _ImageScreenState(url);
}

class _ImageScreenState extends State<ImageScreen> {
  String url;

  _ImageScreenState(this.url);

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
      quality: 88,
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
            title: Text('مشاهده عکس'),
            centerTitle: true,
            leading: IconButton(
              icon: new Icon(
                FontAwesomeIcons.chevronRight,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            )),
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: Center(
              child: PhotoView(
                imageProvider: CachedNetworkImageProvider(url),
              ),
            )));
  }
}
