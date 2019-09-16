import 'package:final_project/screens/home_screen.dart';
import 'package:final_project/screens/login_screen.dart';
import 'package:final_project/screens/profile_screen.dart';
import 'package:final_project/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MaterialApp(
    title: 'تبافی',
    theme: ThemeData(
      fontFamily: 'IRANYekanMobile',
//      primarySwatch: Colors.blueGrey,

//      brightness: Brightness.dark,
      primaryColor: Colors.blueGrey[800],
      accentColor: Colors.blueGrey[800],
    ),
    debugShowCheckedModeBanner: false,
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: [
//        const Locale('en'), // English
      const Locale('fa'),
    ],
    // Start the app with the "/" named route. In our case, the app will start
    // on the FirstScreen Widget
    initialRoute: '/',
    routes: {
      // When we navigate to the "/" route, build the FirstScreen Widget
      '/': (context) => SplashScreen(),
      // When we navigate to the "/second" route, build the SecondScreen Widget
      '/home': (context) => HomeScreen(farmer: null),
      '/login':(context) =>LoginScreen(),
      '/profile':(context) =>ProfileScreen(),
    },
  ));
}

