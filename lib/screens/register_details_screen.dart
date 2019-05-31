import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Screen"),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Go Home!'),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
            // Navigate back to first screen when tapped!
          },
        ),
      ),
    );
  }
}
