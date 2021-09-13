import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timber_test1/app_bar.dart';
import 'accelerometer.dart';
/// Build the page for Accelerometer.
class Walking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar('Walking test'),
      body: Accelerometer(),
    );
  } // build method


}
