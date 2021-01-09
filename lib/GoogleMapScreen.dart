import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(GoogleMapScreen());

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  List<Marker> myMarker = [];
  double screenHeight, screenWidth;
  String _homeloc = "Searching...";
  Position _currentPosition;
  String gmaploc = "";
  double latitude, longitude;
  Geolocator geolocator = Geolocator();
  String address = "";
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController gmcontroller;
  CameraPosition _home;
  double zoomVal = 5.0;
  MarkerId markerId1 = MarkerId("12");
  Set<Marker> markers = {};
  LatLng _currentMapPosition = _center;
  static final LatLng _center = const LatLng(6.4676929, 100.5067673);

  @override
  void initState() {
    super.initState();

    _getLocation();
    _showDefaultMarker();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey[200],
              title: Text('Google Map',
                  style: TextStyle(color: Colors.blueAccent)),
            ),
            body: StatefulBuilder(builder: (context, newSetState) {
              return Container(
                  child: Stack(children: <Widget>[
                Column(
                  children: [
                    Container(
                      decoration: new BoxDecoration(
                        color: Colors.red,
                      ),
                      height: screenHeight / 1.5,
                      width: screenWidth / 0.4,
                      child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition:
                              CameraPosition(target: _center, zoom: 17),
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                          markers: markers.toSet(),
                          onTap: (newLatLng) {
                            _loadLoc(newLatLng, newSetState);
                          }),
                    ),
                    Padding(padding: EdgeInsets.all(3)),
                    Container(
                      alignment: Alignment.center,
                      child: Text("Your Current:",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold)),
                    ),
                    Column(children: [
                      SizedBox(width: 4),
                      Padding(padding: EdgeInsets.all(4)),
                      Table(
                          border: TableBorder(
                              horizontalInside: BorderSide(
                            width: 0.25,
                            color: Colors.white,
                          )),
                          defaultColumnWidth: FlexColumnWidth(1.0),
                          columnWidths: {
                            1: FlexColumnWidth(3),
                            2: FlexColumnWidth(5),
                          },
                          children: [
                            TableRow(children: [
                              TableCell(
                                child: Container(
                                    color: Colors.white,
                                    alignment: Alignment.centerLeft,
                                    height: 50,
                                    child: Text("Address",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black))),
                              ),
                              TableCell(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 50,
                                  child: Text(_homeloc,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black)),
                                ),
                              ),
                            ]),
                            TableRow(children: [
                              TableCell(
                                child: Container(
                                    color: Colors.white,
                                    alignment: Alignment.centerLeft,
                                    height: 30,
                                    child: Text("Latitude",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black))),
                              ),
                              TableCell(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 30,
                                  child: Text(latitude.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black)),
                                ),
                              ),
                            ]),
                            TableRow(children: [
                              TableCell(
                                child: Container(
                                    color: Colors.white,
                                    alignment: Alignment.centerLeft,
                                    height: 30,
                                    child: Text("Longitude",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black))),
                              ),
                              TableCell(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 30,
                                  child: Text(longitude.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black)),
                                ),
                              ),
                            ]),
                          ]),
                    ])
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: FloatingActionButton(
                      onPressed: _showDefaultMarker,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.map, size: 30.0),
                    ),
                  ),
                ),
              ]));
            })));
  }

  void _showDefaultMarker() {
    setState(() {
      markers.add(Marker(
        markerId: MarkerId(_currentMapPosition.toString()),
        position: _currentMapPosition,
        infoWindow:
            InfoWindow(title: 'You are here', snippet: 'Welcome to Malaysia'),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  

  Future<void> _getLocation() async {
    try {
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) async {
        _currentPosition = position;
        if (_currentPosition != null) {
          final coordinates = new Coordinates(
              _currentPosition.latitude, _currentPosition.longitude);
          var addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
          setState(() {
            var first = addresses.first;
            _homeloc = first.addressLine;
            if (_homeloc != null) {
              latitude = _currentPosition.latitude;
              longitude = _currentPosition.longitude;
              return;
            }
          });
        }
      }).catchError((e) {
        print(e);
      });
    } catch (exception) {
      print(exception.toString());
    }
  }

  void _loadLoc(LatLng loc, newSetState) async {
    newSetState(() {
      markers.clear();
      latitude = loc.latitude;
      longitude = loc.longitude;
      _getLocationfromlatlng(latitude, longitude, newSetState);

      _home = CameraPosition(
        target: loc,
        zoom: 17,
      );
      markers.add(Marker(
        markerId: markerId1,
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: 'New Location',
          snippet: 'New Delivery Location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });

    _newhomeLocation();
  }

  _getLocationfromlatlng(double lat, double lng, newSetState) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    //debugPrint('location: ${_currentPosition.latitude}');
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    newSetState(() {
      _homeloc = first.addressLine;
      if (_homeloc != null) {
        latitude = lat;
        longitude = lng;

        return;
      }
    });
    setState(() {
      _homeloc = first.addressLine;
      if (_homeloc != null) {
        latitude = lat;
        longitude = lng;

        return;
      }
    });
  }

  Future<void> _newhomeLocation() async {
    gmcontroller = await _controller.future;
    gmcontroller.animateCamera(CameraUpdate.newCameraPosition(_home));
  }
}
