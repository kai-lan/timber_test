class MyTest {
  String email;
  int testNum;
  String location;
  String floorType;
  String panelType;
  String beamType;
  String submissionTime;

  MyTest(
      {this.email = "", // User email
      this.testNum = 1, // By default, the first test for the user
      this.location = "",
      this.floorType = "",
      this.panelType = "",
      this.beamType = "",
      this.submissionTime = ""});

  //A factory constructor to create a User from JSON
  factory MyTest.fromJson(Map<dynamic, dynamic> json) => _testFromJson(json);

  Map<String, dynamic> toJson() => _testToJson(this);

  @override
  String toString() => "";
}

MyTest _testFromJson(Map<dynamic, dynamic> json) {
  return MyTest(
      email: json['email'] as String,
      testNum: json['test number'] as int,
      location: json['location'] as String,
      floorType: json['floor type'] as String,
      panelType: json['panel type'] as String,
      beamType: json['beam type'] as String,
      submissionTime: json['submission time'] as String);
}

Map<String, dynamic> _testToJson(MyTest test) {
  return <String, dynamic>{
    'email': test.email,
    'test number': test.testNum,
    'location': test.location,
    'floor type': test.floorType,
    'panel type': test.panelType,
    'beam type': test.beamType,
    'submission time': test.submissionTime
  };
}
