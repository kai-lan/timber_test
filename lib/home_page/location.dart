import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:timber_test1/models/test.dart';

/// It uses the GPS system from user's smartphone to locate
/// and display it on the screen.

class GetLocBundle extends StatefulWidget {
  MyTest? test;

  GetLocBundle({
    required this.test,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GetLocBundleState();
}

class _GetLocBundleState extends State<GetLocBundle> {

  String? _currentAddress;
  loc.Location location = new loc.Location();
  bool? _serviceEnabled;
  loc.PermissionStatus? _permissionGranted;
  loc.LocationData? _locationData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
            child: Text('Get location'),
            onPressed: () {
              setState(() {
                _currentAddress = 'Locating...';
              });
              _getCurrentLoc();
            }),
        SizedBox(
          height: 5,
        ),
        if (_currentAddress != null)
          Text(
            _currentAddress!,
            style: Theme.of(context).textTheme.bodyText1,
          )
      ],
    );
  }

  _getCurrentLoc() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        print('service not enabled');
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        print('Permission not granted');
        return;
      }
    }
    _locationData = await location.getLocation();
    _getAddressFromLatLng(_locationData!);
  }

  _getAddressFromLatLng(loc.LocationData data) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(data.latitude!, data.longitude!);

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
          widget.test!.location = _currentAddress!;
      });
    } catch (e) {
      print(e);
    }
  }
}
