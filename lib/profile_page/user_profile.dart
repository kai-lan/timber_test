import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timber_test1/app_bar.dart';
import 'package:timber_test1/home_page/home_page.dart';
import 'package:timber_test1/models/user.dart';
import 'package:timber_test1/photo_page/photo_list.dart';
import 'package:timber_test1/repository/test_number.dart';

/// On this page users can edit their bio: name, job, etc.

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _db = FirebaseFirestore.instance;

class UserProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  Users? user;
  User? currentUser;
  bool firstTime = false;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    FirebaseFirestore.instance
        .collection('user')
        .doc(_auth.currentUser!.email)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        firstTime = false;
        user = Users.fromJson(documentSnapshot.data() as Map);
        _nameController.text = user!.name;
        _companyController.text = user!.company;
        _jobTitleController.text = user!.jobTitle;
      } else {
        firstTime = true;
        user = Users();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar('User profile'),
      body: Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Please provide a quick bio about yourself.'),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextFormField(
                    controller: _companyController,
                    decoration:
                        const InputDecoration(labelText: 'Company name'),
                  ),
                  TextFormField(
                    controller: _jobTitleController,
                    decoration: const InputDecoration(labelText: 'Job title'),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      child: Text('Save'),
                      onPressed: () {
                        if (firstTime) {
                          user = Users.fromJson({
                            'name': _nameController.text,
                            'company': _companyController.text,
                            'job title': _jobTitleController.text,
                            'email': currentUser!.email,
                            'submission time': DateTime.now().toString(),
                            'number of tests': 0
                          });
                          _db
                              .collection('user')
                              .doc(currentUser!.email)
                              .set(user!.toJson());
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Data saved'),
                          ));
                        } else {
                          user!.name = _nameController.text;
                          user!.company = _companyController.text;
                          user!.jobTitle = _jobTitleController.text;
                          _db
                              .collection('user')
                              .doc(currentUser!.email)
                              .update({
                            'name': _nameController.text,
                            'company': _companyController.text,
                            'job title': _jobTitleController.text,
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Data updated'),
                          ));
                        }
                      },
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          initTest();
                          Navigator.pushReplacementNamed(context, '/main_page');
                        },
                        child: Text('Continue'),
                      )),
                ],
              ),
            ),
          )),
    );
  }

  void initTest() {
    TestNum.testNum = user!.numOfTests + 1;
    PhotoList.count = 0;
  }
}
