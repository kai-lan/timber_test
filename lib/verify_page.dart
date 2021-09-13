import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timber_test1/app_bar.dart';

///  First time user after they create their account need to
///  verify their email address, this will send a link to the
///  email they provide. By clicking on the link a user can
///  verify their email, and it will direct user to the user
///  profile page wiht quick bio.

final FirebaseAuth _auth = FirebaseAuth.instance;

class VerifyPage extends StatelessWidget {
  final String header = 'Verify email address';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(header),
        body: Center(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                      'In order to proceed, you need to verify your email address'),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: () {
                      _verifyEmailAddress();
                    },
                    child: Text('Click here to verify your email address'),
                  ),
                  SizedBox(height: 20,),
                  TextButton(
                    onPressed: () async {
                      User user = (await _auth.currentUser)!;
                      await user.reload();
                      user = (await _auth.currentUser)!;
                      if (_auth.currentUser!.emailVerified) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Email verified successfully.')));
                        Navigator.pushReplacementNamed(context, '/user_profile');
                      } else
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('Please verify your email address.')));
                    },
                    child: Text('Already verified? Click here to continue.'),
                  ),
                ],
              )),
        ));
  }

  Future<void> _verifyEmailAddress() async {
    User? user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}
