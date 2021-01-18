import 'package:flutter/material.dart';
import 'package:flutter_google_maps/flutter_google_maps.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:location/location.dart';
import 'package:map_demo/src/helpers/dbHelper.dart';
import 'package:map_demo/src/models/geoCordResponse.dart';

import 'constraints.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final key = GlobalKey<GoogleMapStateBase>();
  bool _polygonAdded = false;
  bool _darkMapStyle = false;
  String _mapStyle;
  double latitude;
  double longitude;
  List<GeoCoord> markedPoints = List<GeoCoord>();
  TextEditingController name = TextEditingController();
  var dbHelper = DBHelper();

  Future getLocation() async {
    try {
      var userLocation = await Location().getLocation();
      setState(() {
        longitude = userLocation.longitude;
        latitude = userLocation.latitude;
      });
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }
  }

  void saveMarkedPoints() async {
    for (var point in markedPoints) {
      GeoCordResponse _response = new GeoCordResponse(
          name: name.text,
          value: '${point.longitude}||${point.latitude}');
      await dbHelper.insertToDb(_response);
    }
  }

  Widget alertTextContainer() {
    return Container(
      height: 200.0,
      width: 300.0,
      child: Column(
        children: [
          TextFormField(
            controller: name,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(hintText: 'Enter a name'),
          ),
          SizedBox(height: 20),
          RaisedButton(
            textColor: Colors.white,
            color: Theme.of(context).primaryColor,
            child: Text('Submit'),
            onPressed: () {
              saveMarkedPoints();
              name.clear();
              Navigator.of(context).pop();
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text(
                        'Polygon saved successfully!'),
                    duration: const Duration(seconds: 2),
                  ));
            },
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: _drawer(),
        appBar: AppBar(
          title: Text('Google Maps Demo'),
        ),
        body: HawkFabMenu(
          iconColor: Colors.white,
          items: [
            HawkFabMenuItem(
              label: 'Add Polygon',
              ontap: () {
                if (!_polygonAdded) {
                  GoogleMap.of(key).addPolygon(
                    '1',
                    polygon,
                    onTap: (polygonId) async {
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Text(
                            'This dialog was opened by tapping on the polygon!\n'
                            'Polygon ID is $polygonId',
                          ),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: Navigator.of(context).pop,
                              child: Text('CLOSE'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  GoogleMap.of(key).editPolygon(
                    '1',
                    polygon,
                    fillColor: Theme.of(context).accentColor,
                    strokeColor: Colors.black,
                  );
                }
                setState(() => _polygonAdded = true);
              },
              icon: Icon(
                Icons.crop_square,
                color: Colors.white,
              ),
            ),
            HawkFabMenuItem(
              label: 'Save Polygon',
              ontap: () {
                if (_polygonAdded) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Save Marked Points'),
                          content: alertTextContainer(),
                        );
                      });
                } else {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text(
                        'Draw a polygon first, before you can save it'),
                    duration: const Duration(seconds: 2),
                  ));
                }
              },
              icon: Icon(
                Icons.save_alt_rounded,
                color: Colors.white,
              ),
            ),
          ],
          body: (latitude == null && longitude == null)
              ? Padding(
                  padding: const EdgeInsets.only(top: 100, left: 180),
                  child: Text(
                    "Loading...",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              : Stack(
                  children: <Widget>[
                    GoogleMap(
                      key: key,
                      markers: {
                        Marker(
                          GeoCoord(latitude, longitude),
                        ),
                      },
                      initialZoom: 12,
                      initialPosition: GeoCoord(latitude, longitude),
                      mapType: _mapType == null ? MapType.roadmap : _mapType,
                      mapStyle: _mapStyle,
                      interactive: true,
                      onTap: (geo) {
                        setState(() {
                          longitude = geo.longitude;
                          latitude = geo.latitude;
                          markedPoints.add(geo);
                          //save marked points to local repo
                        });
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text(geo?.toString()),
                          duration: const Duration(seconds: 2),
                        ));
                        GoogleMap.of(key)
                            .addMarkerRaw(GeoCoord(latitude, longitude));
                        polygon.add(GeoCoord(latitude, longitude));
                        print(polygon.length);
                      },
                      mobilePreferences: const MobileMapPreferences(
                          trafficEnabled: true, zoomControlsEnabled: false),
                      webPreferences: WebMapPreferences(
                        fullscreenControl: true,
                        zoomControl: true,
                      ),
                    ),
                    Positioned(
                        top: 15,
                        right: 20,
                        child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(
                                    title: Text("Map Style"),
                                    content: Container(
                                      height: mapType.length * 64.0,
                                      width: 100,
                                      child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return Card(
                                            child: ListTile(
                                              title: Text(mapTypeName[index]),
                                              onTap: () {
                                                setState(() {
                                                  _mapType = mapType[index];
                                                });
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          );
                                        },
                                        itemCount: mapType.length,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("CANCEL"),
                                      )
                                    ],
                                  );
                                });
                          },
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.filter_none,
                              color: Colors.blue,
                            ),
                          ),
                        ))
                  ],
                ),
        ));
  }

  Widget _drawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            height: 100,
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 60),
              child: Text(
                "Google Maps Demo",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.wb_sunny,
              color: _darkMapStyle
                  ? Theme.of(context).accentColor
                  : Theme.of(context).primaryColor,
            ),
            onTap: () {
              Navigator.of(context).pop();
              if (_darkMapStyle) {
                GoogleMap.of(key).changeMapStyle(null);
                _mapStyle = null;
              } else {
                GoogleMap.of(key).changeMapStyle(darkMapStyle);
                _mapStyle = darkMapStyle;
              }

              setState(() => _darkMapStyle = !_darkMapStyle);
            },
            title:
                Text(_darkMapStyle ? "Enable Light Mode" : "Enable Dark Mode"),
          ),
          Divider(
            color: Colors.grey,
          ),
          ListTile(
            title: Text("Clear Polygons"),
            leading: Icon(
              Icons.crop_square,
              color: Theme.of(context).primaryColor,
            ),
            onTap: () {
              GoogleMap.of(key).clearPolygons();
              Navigator.of(context).pop();
              setState(() {
                polygon = [];
                _polygonAdded = false;
              });
            },
          ),
          Divider(
            color: Colors.grey,
          ),
          ListTile(
            title: Text("Clear Markers"),
            leading: Icon(
              Icons.location_off,
              color: Theme.of(context).primaryColor,
            ),
            onTap: () {
              GoogleMap.of(key).clearMarkers();
              //clear all marked points
              markedPoints.clear();
              Navigator.of(context).pop();
            },
          ),
          Divider(
            color: Colors.grey,
          ),
          // ListTile(
          //   title: Text("View Saved Polygons"),
          //   leading: Icon(
          //     Icons.history_rounded,
          //     color: Theme.of(context).primaryColor,
          //   ),
          //   onTap: () {
             
          //   },
          // ),
          // Divider(
          //   color: Colors.grey,
          // ),
        ],
      ),
    );
  }
}

List<GeoCoord> polygon = <GeoCoord>[];

List<MapType> mapType = [
  MapType.hybrid,
  MapType.roadmap,
  MapType.satellite,
  MapType.terrain,
  MapType.none,
];
MapType _mapType = MapType.hybrid;
List<String> mapTypeName = [
  "Hybrid",
  "Roadmap",
  "Satellite",
  "Terrain",
  "None"
];
