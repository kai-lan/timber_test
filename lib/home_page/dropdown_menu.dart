import 'package:flutter/material.dart';
import 'package:timber_test1/models/test.dart';

/// Implement drop down menu so that user can choose from
/// the given options.

class DropdownMenu extends StatefulWidget {
  MyTest test;
  DropdownMenu(this.test);
  @override
  State<StatefulWidget> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<DropdownMenu> {
  String dropdownVal = 'Select';

  @override
  Widget build(BuildContext context) {
    widget.test.floorType = dropdownVal;
    return DropdownButton<String>(
      value: dropdownVal,
      items: <String>['Select', 'Type 1', 'Type 2', 'Type 3', 'Type 4']
          .map((String value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          dropdownVal = newValue!;
          widget.test.floorType = dropdownVal;
        });
      },
    );
  }
}
