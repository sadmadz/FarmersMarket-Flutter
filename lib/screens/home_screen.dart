import 'dart:io';

import 'package:final_project/models/farmer.dart';
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
  _HomeScreenState(this.farmer);


  TabController _tabController;
  int _currentIndex = 0;

  Color left = Colors.white;
  Color right = Colors.black;


  final String base_url = "https://lixil.herokuapp.com/api/v1/";



  @override
  void initState() {
    super.initState();

//    getUserData(context, "1");
  }

  @override
  void dispose() {
    super.dispose();
  }

  _logout() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove('token');

    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text('فروشگاه میوه'),
        ),
        body: Container(
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                  colors: [
                    Theme.Colors.loginGradientStart,
                    Theme.Colors.loginGradientEnd
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 1.0),
                  tileMode: TileMode.clamp),
            ),
            child: null),
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
                        child: Container(
                          width: 64.0,
                          height: 64.0,
                          decoration: BoxDecoration(color: Colors.yellow),
                        ),
//                        child: Image.network('https://flutter.dev/images/flutter-mono-81x100.png',
//                             width: 60,
//                            height: 60,
//                            fit: BoxFit.fill)
                      ),
                      Text("نام :"+farmer.first_name),
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                ),
              ),
              ListTile(
                title: Text('Item 1'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Item 2'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('خروج'),
                onTap: () {
                  _logout();
                },
              ),
            ],
          ),
        ));
  }
}
