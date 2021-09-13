import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:sensors/sensors.dart';
import 'package:timber_test1/repository/test_number.dart';
import '../event_channel.dart';
import '../method_channel.dart';
import '../repository/dataRepository.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Accelerometer extends StatefulWidget {
  @override
  _AccelerometerState createState() => _AccelerometerState();
}

class _AccelerometerState extends State<Accelerometer> {
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  StreamSubscription? downloadFinishedStream;
  List<double> _accelData = List.filled(3, 0.0);
  List<double> _metawearData = List.filled(3, 0.0);
  List<double> traceX = [];
  List<double> traceY = [];
  List<double> traceZ = [];
  Timer? timer;
  bool executing = false;
  bool downloadFinished = false;
  bool requestingData = false;

  @override
  Widget build(BuildContext context) {
    // Create A Scope Display
    Oscilloscope scopeX = Oscilloscope(
      margin: EdgeInsets.all(5),
      backgroundColor: Colors.black,
      traceColor: Colors.yellow,
      yAxisMax: 15.0,
      yAxisMin: -15.0,
      dataSet: traceX,
    );
    Oscilloscope scopeY = Oscilloscope(
      margin: EdgeInsets.all(5),
      backgroundColor: Colors.black,
      traceColor: Colors.blue,
      yAxisMax: 15.0,
      yAxisMin: -15.0,
      dataSet: traceY,
    );
    Widget phone_data = Column(
      children: [
        Text('Phone data'),
        Padding(padding: EdgeInsets.only(top: 10.0)),
        Text(
          "[0](X) = ${_accelData[0]}",
          textAlign: TextAlign.center,
        ),
        Padding(padding: EdgeInsets.only(top: 5.0)),
        Text(
          "[1](Y) = ${_accelData[1]}",
          textAlign: TextAlign.center,
        ),
        Padding(padding: EdgeInsets.only(top: 5.0)),
        Text(
          "[2](Z) = ${_accelData[2]}",
          textAlign: TextAlign.center,
        ),
      ],
    );
    Widget metawear_data = Column(
      children: [
        Text('Metawear data'),
        Padding(padding: EdgeInsets.only(top: 10.0)),
        Text(
          "[0](X) = ${_metawearData[0]}",
          textAlign: TextAlign.center,
        ),
        Padding(padding: EdgeInsets.only(top: 5.0)),
        Text(
          "[1](Y) = ${_metawearData[1]}",
          textAlign: TextAlign.center,
        ),
        Padding(padding: EdgeInsets.only(top: 5.0)),
        Text(
          "[2](Z) = ${_metawearData[2]}",
          textAlign: TextAlign.center,
        ),
      ],
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          "Accelerometer Test",
          style: Theme.of(context).textTheme.headline1,
          textAlign: TextAlign.center,
        ),
        //Padding(padding: EdgeInsets.only(top: 5.0)),
        Text('Phone data in z axis'),
        Container(
          height: 80,
          child: scopeX,
        ),
        Text('Metawear data in z axis'),
        Container(
          height: 80,
          child: scopeY,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            phone_data,
            Padding(
              padding: EdgeInsets.all(5.0),
            ),
            metawear_data
          ],
        ),
        //Padding(padding: EdgeInsets.only(top: 16.0)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
                child: Text("Start"),
                color: Colors.green,
                onPressed: () {
                  requestingData = false;
                  if (!executing) {
                    _startAccelerometer();
                    _startSensor();
                  }
                }),
            Padding(
              padding: EdgeInsets.all(8.0),
            ),
            MaterialButton(
                child: Text("Stop"),
                color: Colors.red,
                onPressed: () {
                  if (executing) {
                    _stopAccelerometer();
                    _stopSensor();
                  }
                }),
          ],
        ),
        MaterialButton(
            child: Text("Upload data"),
            color: Colors.blue,
            onPressed: () {
              showLoadingIndicator();
              requestingData = true;
            }),
        Text('Download finished: '+downloadFinished.toString()),
        MaterialButton(
            child: Text("Go to evaluation"),
            color: Colors.blue,
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/evaluation_page');
            }),
      ],
    );
  }

  @override
  void dispose() {
    downloadFinishedStream!.cancel();
    if (executing) _stopAccelerometer();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    downloadFinishedStream = EventHandling.dataReady
        .receiveBroadcastStream()
        .listen((dynamic finished) async {
      setState(() {
        downloadFinished = finished;
      });
      if(requestingData && finished) {
        requestingData = false;
        hideOpenDialog();
        DataRepository.uploadFile(
            await DataRepository.localFilePath('phone'),
      '${_auth.currentUser!.email}/test ${TestNum.testNum}/phone.txt');
      DataRepository.uploadFile(
      await DataRepository.localFilePath('metawear'),
      '${_auth.currentUser!.email}/test ${TestNum.testNum}/metawear.txt');
    }
    });
  }

  Future<void> _startAccelerometer() async {
    executing = true;
    String filePath = await DataRepository.localFilePath('phone');
    DataRepository.clearFile(filePath);
    timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        double dataX = _accelData[0],
            dataY = _accelData[1],
            dataZ = _accelData[2];
        traceX.add(dataZ);
        traceY.add(_metawearData[2]*9.8);
        // Add the data to the database storage
        String data =
            dataX.toString() + ' ' + dataY.toString() + ' ' + dataZ.toString();
        DataRepository.writeToFile(filePath, data);
      });
    });
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelData = <double>[event.x, event.y, event.z];
      });
    }));

    _streamSubscriptions.add(EventHandling.dataStream
        .receiveBroadcastStream()
        .listen((dynamic values) {
      setState(() {
        _metawearData[0] = values[0];
        _metawearData[1] = values[1];
        _metawearData[2] = values[2];
      });
    }));
  }

  void _stopAccelerometer() {
    executing = false;
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    timer!.cancel();
  }

  Future<void> _startSensor() async {
    try {
      final String result =
          await MethodHandling.platform.invokeMethod('startSensor');
    } on PlatformException catch (e) {
      print("Failed to start sensor: '${e.message}'.");
    }
  }

  Future<void> _stopSensor() async {
    try {
      final String result =
          await MethodHandling.platform.invokeMethod('stopSensor');
    } on PlatformException catch (e) {
      print("Failed to stop sensor: '${e.message}'.");
    }
  }
  // Show a dialog to indicate progress of downloading log data from board
  void showLoadingIndicator() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: 100,
            height: 100,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10,),
                Text('Downloading data')
              ],
            ),
          )
        );
      },
    );
  }
  // Dismiss the dialog when log data download is finished
  void hideOpenDialog() {
    Navigator.of(context).pop();
  }
}
