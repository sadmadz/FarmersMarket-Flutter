import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_project/screens/theme.dart' as Theme;
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final LatLng location;

  MapScreen({Key key, @required this.location}) : super(key: key);

  @override
  _MapScreenState createState() => new _MapScreenState(location);
}

class _MapScreenState extends State<MapScreen> {
  LatLng locationParams;

  _MapScreenState(this.locationParams);


  GoogleMapController mapController;
  CameraPosition _kGooglePlex;
  Map<String, double> userLocation;
  bool hasLocationPermission = false;

  double imageSize = 50;

  BitmapDescriptor myIcon;

  getLocation() async {
    var location = new Location();

    try {
      await location.hasPermission().then((hasPermission) {
        if (!hasPermission) {
          location.requestPermission().then((permissionGot) {
            if (permissionGot) {
              //if we got permission to access user location, show the location button
              setState(() {
                hasLocationPermission = true;
              });
              location.serviceEnabled().then((value) {
                if (!value) {
                  location.requestService().then((serviceEnabled) {
                    if (serviceEnabled) {
                      location.getLocation().then((currentLocation) {
                        moveCamera(currentLocation);
                      });
                    }
                  });
                } else {
                  location.getLocation().then((currentLocation) {
                    moveCamera(currentLocation);
                  });
                }
              });
            }
          });
        } else {
          //if we had permission to access user location, show the location button
          setState(() {
            hasLocationPermission = true;
          });
          location.serviceEnabled().then((value) {
            if (!value) {
              location.requestService().then((serviceEnabled) {
                location.getLocation().then((currentLocation) {
                  moveCamera(currentLocation);
                });
              });
            } else {
              location.getLocation().then((currentLocation) {
                moveCamera(currentLocation);
              });
            }
          });
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  moveCamera(LocationData locationData) {
    locationParams = new LatLng(locationData.latitude, locationData.longitude);
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            locationParams.latitude,
            locationParams.longitude,
          ),
          zoom: 14.0,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

//    getLocation();

    if(locationParams==null){
      _kGooglePlex = CameraPosition(
        target: LatLng(32.4279,53.6880),
        zoom: 5,
      );
    }else{
      _kGooglePlex = CameraPosition(
        target: locationParams,
        zoom: 14.4746,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              title: Text('موقعیت مکانی'),
              centerTitle: true,
              leading: IconButton(
                icon: new Icon(
                  FontAwesomeIcons.chevronRight,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
//                  RaisedButton(
//                      shape: OutlineInputBorder(
//                          borderRadius: BorderRadius.circular(18),
//                          borderSide: BorderSide(color: Colors.blueGrey[800])),
//                      color: Colors.grey[200],
//                      child: Row(
//                        mainAxisSize: MainAxisSize.min,
//                        crossAxisAlignment: CrossAxisAlignment.center,
//                        children: <Widget>[
//                          Padding(
//                              padding: EdgeInsets.only(left: 8),
//                              child: Text(
//                                "موقعیت فعلی",
//                                style: TextStyle(
//                                  color: Colors.blueGrey[800],
//                                ),
//                              )),
//                          Padding(
//                              padding: EdgeInsets.only(bottom: 4),
//                              child: Icon(
//                                FontAwesomeIcons.mapMarkedAlt,
//                                color: Colors.blueGrey[800],
//                                size: 18,
//                              ))
//                        ],
//                      ),
//                      onPressed: () {
//                        getLocation();
//                      }),
                  Container(
                    height: MediaQuery.of(context).size.height - 150,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: <Widget>[
                        GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: _kGooglePlex,
                          myLocationButtonEnabled: false,
                          myLocationEnabled: hasLocationPermission,
                          onMapCreated: (GoogleMapController controller) {
                            mapController = controller;
                          },
                          onCameraMoveStarted: () {
                            setState(() {
                              imageSize = 40;
                            });
                          },
                          onCameraIdle: () {
                            setState(() {
                              imageSize = 50;
                            });
                          },
                          onCameraMove: (position) {
                            locationParams = LatLng(position.target.latitude,
                                position.target.longitude);
                          },
                        ),
                        Padding(
                            padding: EdgeInsets.only(bottom: 51),
                            child: Center(
                                child: Container(
                              height: 55,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.fastOutSlowIn,
                                    height: imageSize,
                                    width: imageSize,
                                    child: Image.asset(
                                      'assets/images/marker.png',
                                    ),
                                  ),
                                  Icon(FontAwesomeIcons.solidCircle,
                                      size: 5, color: Colors.blueGrey[800])
                                ],
                              ),
                            ))),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: FloatingActionButton(elevation: 10,
                            onPressed: () {
                              getLocation();
                            },
                            backgroundColor: Colors.white,
                            child: Icon(
                              FontAwesomeIcons.location,
                              color: Colors.blueGrey[800],
                              size: 26,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  RaisedButton(
                    elevation: 6,
                    child: Text("تایید",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: Colors.blueGrey[800])),
                    color: Colors.blueGrey[800],
                    onPressed: () {
                      Navigator.pop(context, locationParams);
                    },
                  )
                ],
              ),
            )),
        // ignore: missing_return
        onWillPop: () {
          Navigator.pop(context);
        });
  }
}
