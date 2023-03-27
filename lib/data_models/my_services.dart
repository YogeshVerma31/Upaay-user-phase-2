class MyServices {
  String id;
  String departmentid;
  String image;
  String title;
  String description;
  String vibhag;

  MyServices({
    required this.id,
    required this.departmentid,
    required this.image,
    required this.title,
    required this.description,
    required this.vibhag,
  });

  factory MyServices.fromJson(Map<String, dynamic> responseData) {
    return MyServices(
      id: responseData['id'],
      departmentid: responseData['department_id'],
      description: responseData['descr'],
      image: responseData['image'],
      title: responseData['title'],
      vibhag: responseData['vibhag'],
    );
  }
}
