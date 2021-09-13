import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timber_test1/walking_test_page/bluetooth_connection.dart';
import 'package:timber_test1/method_channel.dart';
import '../models/user.dart';

// hold, retrieve and save your data
class DataRepository {
  static Users? user;
  static DocumentReference? reference;
  static String? imagePath;
  static File? image;

  // Top level is user, and we store a reference to this.
  static CollectionReference collection =
      FirebaseFirestore.instance.collection('user');
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //Sensor data file
  static Future<String> localFilePath(String type) async {
    final path = await _localPath;
    if (type == 'phone') {
      new Directory(path + '/phone').create()
          // The created directory is returned as a Future.
          .then((Directory dir) {
      });
      return '$path/phone/test.txt';
    } else if (type == 'metawear') {
      return await MethodHandling.platform.invokeMethod('boardLocalPath');
    }
    return "";
  }

  static Future<File> clearFile(String filePath) async {
    final file = File(filePath);
    return file.writeAsString('');
  }

  static Future<File> writeToFile(String filePath, String data) async {
    final file = File(filePath);
    // Write the file
    return file.writeAsString('$data\n', mode: FileMode.append);
  }

  static Future<String> readFromFile(String filePath) async {
    try {
      final file = File(filePath);
      // Read the file
      final contents = await file.readAsLines();
      String result = "";
      for (String line in contents) {
        result += line + '\n';
      }
      return result;
    } catch (e) {
      // If encountering an error, return 0
      return 'error';
    }
  }

  static Future<void> uploadFile(
      String localFilePath, String cloudFilePath) async {
    File file = File(localFilePath);
    try {
      await storage.ref().child(cloudFilePath).putFile(file);
    } on FirebaseException catch (e) {
      print(e);
    }
  }

}
