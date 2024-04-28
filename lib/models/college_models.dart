class College {
  String name;
  List<String> courses;

  College({required this.name, required this.courses});

  factory College.fromJson(Map<String, dynamic> json) {
    var coursesFromJson = json['courses'];
    List<String> courseList = [];
    if (coursesFromJson != null) {
      courseList = List<String>.from(coursesFromJson);
    }
    return College(
      name: json['name'],
      courses: courseList,
    );
  }
}
