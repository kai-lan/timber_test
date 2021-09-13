import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timber_test1/app_bar.dart';
import 'package:timber_test1/photo_page/photo_list.dart';
import 'package:timber_test1/photo_page/photo_taking.dart';
import 'package:timber_test1/repository/test_number.dart';
import 'package:timber_test1/walking_test_page/bluetooth_connection.dart';

class PhotoGallery extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar('Photo gallery'),
        body: Stack(
          children: [
            GridView.count(
              crossAxisCount: 2,
              children: PhotoList.itemList, // this is dynamic
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TakePhotoButton()));
                        },
                        child: Text('Add a photo'),
                      ),
                      Padding(padding: EdgeInsets.all(10)),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Metawear()));
                        },
                        child: Text('Continue to walking test'),
                      ),
                    ],
                  ))
                )
          ],
        ));
  }
}
