import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Customized appbar that includes a sign-out button that
/// can sign out the current user.

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyAppBar extends AppBar {
  MyAppBar(String title)
      : super(
          title: Text(title),
          actions: <Widget>[
            Builder(builder: (BuildContext context) {
              return FlatButton(
                textColor: Theme.of(context).buttonColor,
                onPressed: () async {
                  final User? user = _auth.currentUser;
                  if (user == null) {
                    Scaffold.of(context).showSnackBar(const SnackBar(
                      content: Text('No one has signed in.'),
                    ));
                    return;
                  }
                  await _auth.signOut();

                  final String uid = user.uid;
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('$uid has successfully signed out.'),
                  ));

                  Navigator.pushReplacementNamed(context, '/');
                },
                child: const Text(
                  'Sign out',
                  style: TextStyle(color: Colors.black),
                ),
              );
            })
          ],
        );
}
