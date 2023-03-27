class ServiceCount {
  String title;
  int count;
  int depId;
  String vibhag;
  String id;

  ServiceCount({
    required this.title,
    required this.depId,
    required this.vibhag,
    required this.id,
    this.count = 0,
  });

  factory ServiceCount.fromJson(Map<String, dynamic> responseData) {
    return ServiceCount(
        title: responseData['title'],
        depId: int.parse(responseData['department_id']),
        id: responseData['id'],
        vibhag: responseData['vibhag']);
  }
}
