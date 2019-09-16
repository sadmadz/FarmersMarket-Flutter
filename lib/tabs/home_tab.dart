import 'dart:io';

import 'package:dio/dio.dart';
import 'package:final_project/farsi_number.dart';
import 'package:final_project/font_awsome/font_awesome_flutter.dart';
import 'package:final_project/models/data.dart';
import 'package:final_project/models/farmer.dart';
import 'package:final_project/models/fruit.dart';
import 'package:final_project/models/request.dart';
import 'package:final_project/models/requests.dart';
import 'package:final_project/screens/request_details_screen.dart';
import 'package:final_project/widgets/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:toast/toast.dart';

import '../date_time_modifier.dart';
import '../global.dart';

class HomeTab extends StatefulWidget {
  final Farmer farmer;

  HomeTab({Key key, @required this.farmer}) : super(key: key);

  @override
  _HomeTabState createState() => new _HomeTabState(farmer);
}

class _HomeTabState extends State<HomeTab> {
  Farmer farmer;
  bool hasData;
  bool isLoading;
  bool hasError;
  bool hasMoreItems;
  int listLength;
  int totalCount;

  Color sortButtonColor = Colors.grey[200];
  Color filterButtonColor = Colors.grey[200];

  int limit, offset;
  static String distance, date, fruit,dateOption;
  ScrollController _scrollController = new ScrollController();

  static String orderBy;

  List<Request> requestList = new List();
  static List<Fruit> fruits = [];

  static double dogAvatarSize = 150.0;

  // This is the starting value of the slider.
  static double sliderValue = 10.0;

  static bool switchOn = false;
  String sortId = "";
  static List<String> sortOptions = [
    "جدید ترین",
    "قدیمی ترین",
    "بیشترین وزن",
    "کمترین وزن"
  ];

  static List<String> dateOptions = [
    "امروز",
    "هفته گذشته",
    "ماه گذشته",
  ];

  _HomeTabState(this.farmer);

  @override
  void initState() {
    super.initState();
    initLayout();
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
    _scrollController.dispose();
  }

  initLayout() {
    hasData = false;
    isLoading = true;
    hasError = false;
    hasMoreItems = false;
    listLength = requestList.length;
    totalCount = 0;
    orderBy = "-id";
    distance = null;
    fruit = null;
    date = null;
    limit = 10;
    offset = 0;
    getFruits();
    getRequests();
    offset = offset + limit;

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (totalCount > requestList.length) {
          getRequests();
          offset = offset + limit;
        }
      }
    });
  }

  getFruits() async {
    try {
      final response = await Dio().get(Global.baseUrl + "fruits/",
          options: Options(headers: {
            "Content-Type": "application/json",
            HttpHeaders.authorizationHeader: Global.token
          }));
      final int statusCode = response.statusCode;
      print(response.statusCode);
      print(response.data);

      if (statusCode == 200) {
        setState(() {
          fruits = Data
              .fromJson(response.data)
              .fruits;
        });
      }
    } on SocketException catch (e) {
      print(e);
      Navigator.pop(context);
      Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  getRequests() async {
    List<Request> requests;

    setState(() {
      isLoading = true;
    });
    print(farmer.id.toString() +
        "-" +
        limit.toString() +
        "-" +
        offset.toString() +
        "-" +
        distance.toString() +
        "-" +
        date.toString() +
        "-" +
        fruit.toString() +
        "-" +
        orderBy.toString());

    try {
      final response = await Dio().get(Global.baseUrl + 'requests/',
          options: Options(headers: {"Content-Type": "application/json"}),
          queryParameters: {
            "fid": farmer.id,
            "limit": limit.toString(),
            "offset": offset.toString(),
//            "distance": distance,
            "date": date,
            "fruit": fruit,
            "orderBy": orderBy
          });

      setState(() {
        isLoading = false;
      });
      print("baby baby");
      print(response);
      if (response.statusCode == 200) {
        Requests _response = Requests.fromJson(response.data);
        setState(() {
          requests = _response.requests;
          requestList.addAll(requests);
          if (requestList.length > 0) {
            totalCount = _response.totalCount;
            if (requestList.length < _response.totalCount) {
              hasMoreItems = true;
              listLength = requestList.length + 1;
            } else {
              hasMoreItems = false;
              listLength = requestList.length;
            }
            hasData = true;
          } else {
            hasData = false;
          }
        });
      } else {
        if (mounted) {
          Toast.show("خطا در برقراری ارتباط با سرور", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
        setState(() {
          hasError = true;
        });
      }
    } on SocketException catch (e) {
      if (mounted) {
        Toast.show("لطفا دسترسی خود به اینترنت را بررسی نمایید", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
      setState(() {
        hasError = true;
      });
    }
  }

  Widget _requestItem(Request item) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4)),
        child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
            title: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
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
            ),
            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

            subtitle: Column(
              children: <Widget>[
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
                      'تاریخ ثبت درخواست: ',
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
                  padding:
                  EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 2),
                  child: Divider(height: 0.5, color: Colors.blueGrey[400]),
                ),
                Container(
                  height: 30,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'جزئیات درخواست',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              color: Colors.blue[400],
                              fontFamily: 'IRANYekanMobile',
                              fontSize: 15),
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
                              RequestDetailsScreen(
                                  request: item, farmer: farmer),
                        ),
                      ).then((value) {
                        initLayout();
                      });
                    },
                  ),
                )
              ],
            )),
      ),
    );
  }

  filterDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return FilterDialog();
        }).then((value) {
      if (value != null && value) {
        hasData = false;
        isLoading = true;
        hasError = false;
        hasMoreItems = false;
        requestList.clear();
        listLength = requestList.length;
        limit = 10;
        offset = 0;
        getRequests();
        offset = offset + limit;
      }
      if (distance.toString() != null ||
          date.toString() != null ||
          fruit.toString() != null) {
        filterButtonColor = Colors.blue[300];      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueGrey[800])),
                    color: filterButtonColor,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text("فیلتر نتایج")),
                        Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Icon(
                              FontAwesomeIcons.filter,
                              color: Colors.blueGrey[800],
                              size: 18,
                            ))
                      ],
                    ),
                    onPressed: () {
                      filterDialog();
                    },
                  ),
                  RaisedButton(
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueGrey[800])),
                    color: sortButtonColor,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text("مرتب سازی")),
                        Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Icon(
                              FontAwesomeIcons.sortAmountDown,
                              color: Colors.blueGrey[800],
                              size: 18,
                            ))
                      ],
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) {
                            return SortDialog();
                          }).then((value) {
                        if (value != null && value) {
                          hasData = false;
                          isLoading = true;
                          hasError = false;
                          hasMoreItems = false;
                          requestList.clear();
                          listLength = requestList.length;
                          limit = 10;
                          offset = 0;
                          getRequests();
                          offset = offset + limit;
                        }
                        if (orderBy.toString() != null) {
                          sortButtonColor = Colors.blue[300];
                      }});
                    },
                  ),
                ],
              ),
              Visibility(
                visible: hasData,
                child: Expanded(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: false,
                      scrollDirection: Axis.vertical,
                      itemCount: listLength,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == requestList.length && hasMoreItems) {
                          return progressIndicator();
                        } else {
                          return _requestItem(requestList[index]);
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
}

class FilterDialog extends StatefulWidget {
  @override
  _FilterDialogState createState() => new _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
//      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
              decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.circular(10.0)),
              alignment: AlignmentDirectional.center,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text("فاصله:",
                              textAlign: TextAlign.right,
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.blueGrey[700],
                                  fontFamily: "IRANYekanMobileBold")),
                          Slider(
                            activeColor: Colors.indigoAccent,
                            min: 0.0,
                            max: 100.0,
                            label: FarsiNumber(
                                _HomeTabState.sliderValue.toString())
                                .getNumber() +
                                " کیلومتر",
                            onChanged: (newRating) {
                              setState(
                                      () =>
                                  _HomeTabState.sliderValue = newRating);
                            },
                            value: _HomeTabState.sliderValue,
                            divisions: 5,
                          )
                        ]),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 32, right: 32, top: 8, bottom: 8),
                      child: Divider(color: Colors.blueGrey[800], height: 0.5),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                              child: Text("نمایش درخواست های انجام شده:",
                                  textAlign: TextAlign.right,
                                  style: new TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.blueGrey[700],
                                      fontFamily: "IRANYekanMobileBold"))),
                          Switch(
                            onChanged: (isOn) {
                              print(_HomeTabState.switchOn);
                              print(isOn);
                              setState(() {
                                _HomeTabState.switchOn = isOn;
                              });
                            },
                            value: _HomeTabState.switchOn,
                          )
                        ]),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 32, right: 32, top: 8, bottom: 8),
                      child: Divider(color: Colors.blueGrey[800], height: 0.5),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text("تاریخ:",
                              textAlign: TextAlign.right,
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.blueGrey[700],
                                  fontFamily: "IRANYekanMobileBold")),
                          Container(
                            margin: EdgeInsets.only(right: 4.0, left: 4.0),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 1.0, style: BorderStyle.solid),
                                borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: Container(
                                margin: EdgeInsets.only(right: 8.0),
                                height: 35,
                                child: DropdownButton<String>(
                                  onChanged: (value) {
                                    setState(() {
                                      _HomeTabState.dateOption = value;
                                      if (_HomeTabState.dateOptions
                                          .indexOf(value) ==
                                          0) {
                                        _HomeTabState.date = "day";
                                      } else if (_HomeTabState.dateOptions
                                          .indexOf(value) ==
                                          1) {
                                        _HomeTabState.date = "week";
                                      } else if (_HomeTabState.dateOptions
                                          .indexOf(value) ==
                                          2) {
                                        _HomeTabState.date = "month";
                                      }
                                    });
                                  },
                                  value: _HomeTabState.dateOption,
                                  hint: Text("تاریخ"),
                                  style: new TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.blueGrey[700],
                                      fontFamily: "IRANYekanMobileBold"),
                                  items: _HomeTabState.dateOptions
                                      .map((String option) {
                                    return new DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(option,
                                          style: new TextStyle(
                                            color: Colors.blueGrey[800],
                                            fontFamily: 'IRANYekanMobileBold',
                                          )),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          )
                        ]),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 32, right: 32, top: 8, bottom: 8),
                      child: Divider(color: Colors.blueGrey[800], height: 0.5),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text("نوع میوه:",
                              textAlign: TextAlign.right,
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.blueGrey[700],
                                  fontFamily: "IRANYekanMobileBold")),
                          Container(
                            margin: EdgeInsets.only(right: 4.0, left: 4.0),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 1.0, style: BorderStyle.solid),
                                borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: Container(
                                margin: EdgeInsets.only(right: 8.0),
                                height: 35,
                                child: DropdownButton<String>(
                                  onChanged: (value) {
                                    setState(() {
                                      _HomeTabState.fruit = value;
                                    });
                                  },
                                  value: _HomeTabState.fruit,
                                  hint: Text("انتخاب"),
                                  style: new TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.blueGrey[700],
                                      fontFamily: "IRANYekanMobileBold"),
                                  items:
                                  _HomeTabState.fruits.map((Fruit option) {
                                    return new DropdownMenuItem<String>(
                                      value: option.fruit_name,
                                      child: Text(option.fruit_name,
                                          style: new TextStyle(
                                            color: Colors.blueGrey[800],
                                            fontFamily: 'IRANYekanMobileBold',
                                          )),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          )
                        ]),
                    Padding(
                      padding: const EdgeInsets.only(top: 35),
                      child: RaisedButton(
                        shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            BorderSide(color: Colors.blueGrey[800])),
                        color: Colors.grey[200],
                        child: Text("تایید"),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }
}

class SortDialog extends StatefulWidget {
  @override
  _SortDialogState createState() => new _SortDialogState();
}

class _SortDialogState extends State<SortDialog> {
  String _sortOption = "";

  @override
  void initState() {
    super.initState();
    if (_HomeTabState.orderBy != "-id") {
      if (_HomeTabState.orderBy == "newest") {
        _sortOption = _HomeTabState.sortOptions[0];
      } else if (_HomeTabState.orderBy == "oldest") {
        _sortOption = _HomeTabState.sortOptions[1];
      } else if (_HomeTabState.orderBy == "mostWeight") {
        _sortOption = _HomeTabState.sortOptions[2];
      } else if (_HomeTabState.orderBy == "leastWeight") {
        _sortOption = _HomeTabState.sortOptions[3];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
//      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text("مرتب سازی بر اساس:",
                  textAlign: TextAlign.right,
                  style: new TextStyle(
                      fontSize: 16.0,
                      color: Colors.blueGrey[700],
                      fontFamily: "IRANYekanMobileBold")),
            ),
          ),
          Container(
              decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.circular(10.0)),
              alignment: AlignmentDirectional.center,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(_HomeTabState.sortOptions[0]),
                      leading: Radio(
                        value: _HomeTabState.sortOptions[0],
                        groupValue: _sortOption,
                        onChanged: (value) {
                          setState(() {
                            _sortOption = value;
                            _HomeTabState.orderBy = "newest";
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(_HomeTabState.sortOptions[1]),
                      leading: Radio(
                        value: _HomeTabState.sortOptions[1],
                        groupValue: _sortOption,
                        onChanged: (value) {
                          setState(() {
                            _sortOption = value;
                            _HomeTabState.orderBy = "oldest";
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(_HomeTabState.sortOptions[2]),
                      leading: Radio(
                        value: _HomeTabState.sortOptions[2],
                        groupValue: _sortOption,
                        onChanged: (value) {
                          setState(() {
                            _sortOption = value;
                            _HomeTabState.orderBy = "mostWeight";
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(_HomeTabState.sortOptions[3]),
                      leading: Radio(
                        value: _HomeTabState.sortOptions[3],
                        groupValue: _sortOption,
                        onChanged: (value) {
                          setState(() {
                            _sortOption = value;
                            _HomeTabState.orderBy = "leastWeight";
                          });
                        },
                      ),
                    ),
                    RaisedButton(
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blueGrey[800])),
                      color: Colors.grey[200],
                      child: Text("تایید"),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
