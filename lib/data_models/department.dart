class Department {
  String id;
  String name;
  String icon;
  String status;

  Department({
    required this.id,
    required this.name,
    required this.icon,
    required this.status,
  });

  factory Department.fromJson(Map<String, dynamic> responseData) {
    return Department(
      id: responseData['id'],
      name: responseData['name'],
      icon: responseData['icon'],
      status: responseData['status'],
    );
  }
}
