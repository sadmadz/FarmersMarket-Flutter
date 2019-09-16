import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/models/farmer.dart';
import 'package:final_project/screens/profile_screen.dart';
import 'package:final_project/tabs/home_tab.dart';
import 'package:final_project/tabs/offers_tab.dart';
import 'package:final_project/tabs/products_tab.dart';
import 'package:final_project/widgets/custom_tab_Indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_project/screens/theme.dart' as Theme;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toast/toast.dart';

class HomeScreen extends StatefulWidget {
  final Farmer farmer;

  HomeScreen({Key key, @required this.farmer}) : super(key: key);

  @override
  _HomeScreenState createState() => new _HomeScreenState(farmer);
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Farmer farmer;
  bool hasRequest = false;

  Future<Farmer> futureRequests;
  List<Farmer> requestList = new List();

  _HomeScreenState(this.farmer);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _logout() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove('token');
    prefs.remove('userId');
    Navigator.pushReplacementNamed(context, '/');
  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  _navOptions(int index) {
    if (index == 0) {
      return HomeTab(farmer: farmer);
    } else if (index == 1) {
      return ProductsTab(farmer: farmer);
    }
    else if (index == 2) {
      return OffersTab(farmer: farmer);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  showLogoutDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            WillPopScope(
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
                                          "آیا می خواهید از حساب کاربری خود خارج شوید؟"))),
                              new Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    RaisedButton(
                                        elevation: 6,
                                        highlightElevation: 12,
                                        shape: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                18),
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
                                          _logout();
                                        }),
                                    RaisedButton(
                                        elevation: 6,
                                        highlightElevation: 12,
                                        shape: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                18),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('تبافی'),
              Text('(کشاورز)',
                style: TextStyle(color: Colors.white, fontSize: 10),)
            ],),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(FontAwesomeIcons.bars, color: Colors.white),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              }),
        ),
        body: Center(
          child: _navOptions(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.solidClipboardListCheck,
                    color: Color(0xFF90A4AE)),
                title: Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Text('درخواست ها'),
                ),
                activeIcon: Icon(FontAwesomeIcons.solidClipboardListCheck,
                    color: Color(0xFF37474F))),
            BottomNavigationBarItem(
                icon:
                Icon(FontAwesomeIcons.appleCrate, color: Color(0xFF90A4AE)),
                title: Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Text('محصولات من'),
                ),
                activeIcon:
                Icon(FontAwesomeIcons.appleCrate, color: Color(0xFF37474F))),
            BottomNavigationBarItem(
                icon:
                Icon(FontAwesomeIcons.tasksAlt, color: Color(0xFF90A4AE)),
                title: Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Text('پیشنهاد ها'),
                ),
                activeIcon:
                Icon(FontAwesomeIcons.tasksAlt, color: Color(0xFF37474F)))
          ],
          selectedFontSize: 16,
          iconSize: 22,
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFF37474F),
          type: BottomNavigationBarType.shifting,
          onTap: _onItemTapped,
        ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the Drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(45)),
                        child: CachedNetworkImage(
                          imageUrl: farmer.avatar.toString(),
                          fit: BoxFit.cover,
                          width: 90.0,
                          height: 90.0,
                          errorWidget: (context, url, error) =>
                              ClipRRect(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(45)),
                                child: Image.asset(
                                  'assets/images/user_avatar.png',
                                  fit: BoxFit.cover,
                                  width: 90,
                                  height: 90,
                                ),
                              ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "نام :" + farmer.first_name,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[800],
                ),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.userAlt,
                    color: Colors.blueGrey[800], size: 22.0),
                title: Text('ویرایش حساب کاربری',
                    style: TextStyle(color: Colors.blueGrey[800])),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(farmer: farmer),
                    ),
                  ).then((value) {
                    setState(() {

                    });
                  });
                },
              ),
//              ListTile(
//                leading: Icon(FontAwesomeIcons.cog,
//                    color: Colors.blueGrey[800], size: 22.0),
//                title: Text('تنظیمات',
//                    style: TextStyle(color: Colors.blueGrey[800])),
//                onTap: () {
//                  // Update the state of the app
//                  // ...
//                  // Then close the drawer
//                  Navigator.pop(context);
//                },
//              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.signOutAlt,
                    color: Colors.blueGrey[800], size: 22.0),
                title: Text(
                  'خروج از حساب کاربری',
                  style: TextStyle(color: Colors.blueGrey[800]),
                ),
                onTap: () {
                  showLogoutDialog();
                },
              ),
            ],
          ),
        ));
  }
}
