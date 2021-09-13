import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:timber_test1/photo_page/photo_list.dart';
import 'package:timber_test1/repository/test_number.dart';
import '../app_bar.dart';

/// On this screen user is able to use their camera to take photo
/// and choose whether to upload it.

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
File? imagePath;

class TakePhotoButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TakePhotoButtonState();
}

class _TakePhotoButtonState extends State<TakePhotoButton> {
  @override
  Widget build(BuildContext context) {
    return TakePictureScreen();
  }
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initController;
  var isCameraReady = false;
  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    initCamera();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      _initController = _controller != null ? _controller!.initialize() : null;
    if (!mounted) return;
    setState(() {
      isCameraReady = true;
    });
  }

  Widget cameraWidget(context) {
    var camera = _controller!.value;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * camera.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return Transform.scale(
      scale: scale,
      child: Container(
        width: MediaQuery.of(context).size.width, // to fill the entire screen
        child: CameraPreview(_controller!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar('Taking picture'),
      body: FutureBuilder(
        future: _initController,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                cameraWidget(context),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Color(0xAA333639),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                            iconSize: 40,
                            icon: Icon(Icons.camera_alt),
                            color: Colors.white,
                            onPressed: () => captureImage(context)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      ),
    );
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);
    _initController = _controller!.initialize();
    if (!mounted) return;
    setState(() {
      isCameraReady = true;
    });
  }

  captureImage(BuildContext context) {
    _controller!.takePicture().then((file) {
      print(file.path);
      imagePath = File(file.path);
      setState(() {
        imageFile = file;
        //final directory = await getApplicationDocumentsDirectory();
        //imageFile.saveTo('/documents/timber.jpg');
      });
      if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                      image: imageFile!,
                    )));
      }
    });
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final XFile image;

  const DisplayPictureScreen({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar('Image preview'),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.file(
                File(image.path),
                width: 600,
                height: 400,
              ),
              SizedBox(
                height: 20,
              ),
              Text('Upload this photo?'),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _storage
                            .ref()
                            .child(_auth.currentUser!.email!)
                            .child('test ${TestNum.testNum}/photo${PhotoList.count}.png')
                            .putFile(imagePath!);
                      } on FirebaseException catch (e) {
                        print(e);
                      }
                      PhotoList.count ++;
                      PhotoList.itemList.add(Image.file(imagePath!));
                      Navigator.pushReplacementNamed(context, '/photo_gallery');
                    },
                    child: Text('Yes'),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('No'),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
