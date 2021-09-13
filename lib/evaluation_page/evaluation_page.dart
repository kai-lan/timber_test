import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timber_test1/app_bar.dart';
import 'package:timber_test1/repository/test_number.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _db = FirebaseFirestore.instance;

class Evaluation extends StatelessWidget {
  final String _title = 'Timber Tester: user evaluation';
  List<Widget> entries = [
    Column(
      children: [
        Text('Please select one of the following'),
        //UserType(),
      ],
    ),
    MyTextField(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(_title),
      body: ListView.separated(
        padding: const EdgeInsets.all(15),
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int i) {
          return entries[i];
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}

class MyTextField extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyTextFieldState();
}

class MyTextFieldState extends State<MyTextField> {
  final TextEditingController _controllerMajor = TextEditingController();

  @override
  void initState() {
    super.initState();
    //_controller.addListener(_printValue);
  }

  @override
  void dispose() {
    _controllerMajor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controllerMajor,
          decoration: InputDecoration(
              border: OutlineInputBorder(), hintText: 'To be implemented'),
        ),
        MaterialButton(
          onPressed: () {
            TestNum.testNum ++;
            _db
                .collection('user')
                .doc(_auth.currentUser!.email)
                .update({
              'number of tests': TestNum.testNum - 1
            });
            showDialog<String>(
              context: context,
              builder: (BuildContext context) =>
                  AlertDialog(
                    title: const Text('Continue to next test?'),
                    content: const Text('User will sign out otherwise'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(
                                context, '/main_page'),
                        child: const Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          _auth.signOut();
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        child: const Text('No'),
                      ),

                    ],
                  ),);
          },
          child: Text(
            "Submit",
          ),
        ),
        MaterialButton(onPressed: () {
          Navigator.pushReplacementNamed(context, '/main_page');
        })
      ],
    );
  }
}
