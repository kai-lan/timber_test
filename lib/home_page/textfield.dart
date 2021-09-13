import 'package:flutter/material.dart';
import 'package:timber_test1/models/test.dart';

/// The textfield record user's response and upload to the database.

class MyTextField extends StatefulWidget {
  MyTest test;
  String type;
  MyTextField(this.type, this.test);
  @override
  State<StatefulWidget> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField>{
  final myController = TextEditingController();
  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 200,
      height: 60,
      padding: const EdgeInsets.all(2.0),
      child: TextField(
        controller: myController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: widget.type,
          hintText: 'Enter ' + widget.type,
        ),
        onChanged: (text){
          if(widget.type == 'panel type'){
            widget.test.panelType = text;
          }
          if(widget.type == 'beam type'){
            widget.test.beamType = text;
          }
        },
      ),
    );
  }
}