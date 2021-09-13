import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timber_test1/evaluation_page/evaluation_page.dart';
import 'package:timber_test1/home_page/home_page.dart';
import 'package:timber_test1/method_channel.dart';
import 'package:timber_test1/photo_page/photo_gallery.dart';
import 'package:timber_test1/profile_page/user_profile.dart';
import 'package:timber_test1/register_page.dart';
import 'package:timber_test1/sign_in_page.dart';
import 'package:timber_test1/verify_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const String _title = 'Timber Tester';
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    MethodHandling.initMethodHandler();
    // set up method handler for calls from Android or IOS platform
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return SomethingWrong();
        }
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: true,
            title: _title,
            navigatorKey: MethodHandling.navigatorKey,
            initialRoute: '/',
            routes: {
              '/': (context) => MySignInPage(),
              '/register_page': (context) => MyRegisterPage(),
              '/verify_page': (context) => VerifyPage(),
              '/user_profile': (context) => UserProfile(),
              '/main_page': (context) => HomePage(),
              '/photo_gallery': (context) => PhotoGallery(),
              '/evaluation_page': (context) => Evaluation()
            },
            theme: ThemeData(
              // Define the default brightness and colors.
              primaryColor: Color(0xFF3CB371),
              accentColor: Color(0xFFADE36B),
              textTheme: TextTheme(
                headline1: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                bodyText1: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
                button: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
            //home: MySignInPage(),
          );
        }
        // Otherwise, show something whilst waiting for initialization to complete
        return Loading();
      },
    );
  }
}

class SomethingWrong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning),
          SizedBox(
            height: 15,
          ),
          Text("Something went wrong"),
        ],
      ),
    )));
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(
            height: 15,
          ),
          Text("Loading..."),
        ],
      ),
    )));
  }
}
