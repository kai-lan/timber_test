class Users {
  String name;
  String company;
  String jobTitle;
  String email; // Used as a uid
  String submissionTime;
  int numOfTests;

  Users(
      {this.name = "",
      this.company = "",
      this.jobTitle = "",
      this.email = "",
      this.submissionTime = "",
      this.numOfTests = 0});

  //A factory constructor to create a User from JSON
  factory Users.fromJson(Map<dynamic, dynamic> json) => _userFromJson(json);

  Map<String, dynamic> toJson() => _userToJson(this);

  @override
  String toString() => "";
}

Users _userFromJson(Map<dynamic, dynamic> json) {
  return Users(
      name: json['name'] as String,
      company: json['company'] as String,
      jobTitle: json['job title'] as String,
      email: json['email'] as String,
      submissionTime: json['submission time'] as String,
      numOfTests: json['number of tests'] as int);
}

Map<String, dynamic> _userToJson(Users user) {
  return <String, dynamic>{
    'name': user.name,
    'company': user.company,
    'job title': user.jobTitle,
    'email': user.email,
    'submission time': user.submissionTime,
    'number of tests': user.numOfTests
  };
}
