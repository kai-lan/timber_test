import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timber_test1/app_bar.dart';
import 'package:timber_test1/home_page/dropdown_menu.dart';
import 'package:timber_test1/models/test.dart';
import 'package:timber_test1/repository/test_number.dart';
import 'location.dart';
import 'textfield.dart';

/// In main page, users fill out information specific for a
/// certain test, such as location, floor type, etc.

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _db = FirebaseFirestore.instance;

class HomePage extends StatefulWidget {
  MyTest? test;

  HomePage() {
    test = MyTest(email: _auth.currentUser!.email!, testNum: TestNum.testNum);
  }

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> entries = <Widget>[
      _getNumOfTest(context),
      _getLoc(context),
      _getFloorType(context),
      _getFloorConst(context),
      _nextStep(context),
    ];
    return Scaffold(
      appBar: MyAppBar('Home page'),
      body: ListView.separated(
        padding: const EdgeInsets.all(15),
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int i) {
          return entries[i];
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  } // build method

  Widget _getNumOfTest(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Theme.of(context).accentColor,
      child: Text('You have done ${TestNum.testNum - 1} tests.'),
    );
  }

  Widget _getLoc(BuildContext context) {
    const String title = 'Location-GPS';
    return Container(
      padding: EdgeInsets.all(10),
      //height: 130,
      color: Theme.of(context).accentColor,
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline1,
          ),
          SizedBox(
            height: 5,
          ),
          GetLocBundle(test: widget.test),
        ],
      ),
    );
  } // getLoc mthod

  Widget _getFloorType(BuildContext context) {
    const String title = 'Floor type';
    return Container(
      padding: EdgeInsets.all(10),
      //height: 120,
      color: Theme.of(context).accentColor,
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline1,
          ),
          SizedBox(
            width: 10,
            height: 10,
          ),
          Text(
            'Please select the floor type:',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          DropdownMenu(widget.test!),
        ],
      ),
    );
  } // getFloorType method

  Widget _getFloorConst(BuildContext context) {
    const String title = 'Floor construction';
    const String title1 = 'Panel type';
    const String title2 = 'Beam type';
    return Container(
      padding: EdgeInsets.all(10),
      color: Theme.of(context).accentColor,
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline1,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: 0.8 * MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue, //                   <--- border color
                width: 2.0,
              ),
              borderRadius: BorderRadius.all(
                  Radius.circular(10.0) //         <--- border radius here
                  ),
            ),
            padding: EdgeInsets.all(10),
            //color: Theme.of(context).accentColor,
            child: Column(
              children: [
                MyTextField('panel type', widget.test!),
                SizedBox(
                  height: 10,
                ),
                MyTextField('beam type', widget.test!),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  } // getFloorConstruction method

  Widget _nextStep(BuildContext context) {
    return Container(
        color: Theme.of(context).accentColor,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                widget.test!.submissionTime = DateTime.now().toString();
                _db
                    .collection('user')
                    .doc(_auth.currentUser!.email)
                    .collection('test ${TestNum.testNum}')
                    .doc('info')
                    .set(widget.test!.toJson());
              },
              child: Text('Save information'),
            ),
            SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/photo_gallery');
              },
              child: Text('Next Step: taking photo'),
            ),
          ],
        ));
  }

  Widget _goToEvaluation(BuildContext context) {
    return Container(
      color: Theme.of(context).accentColor,
      padding: EdgeInsets.all(10),
      child: ElevatedButton(
        child: Text('Go to evaluation.'),
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/evaluation_page');
        },
      ),
    );
  }
}
