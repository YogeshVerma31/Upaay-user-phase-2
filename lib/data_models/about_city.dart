class AboutCity {
  bool? status;
  String? message;
  List<Data>? data;

  AboutCity({this.status, this.message, this.data});

  factory AboutCity.fromJson(Map<String, dynamic> json) => AboutCity(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Data.fromJson(e))
          .toList());
}

class Data {
  String? id;
  String? cid;
  String? image;
  String? content;
  String? photo;

  Data({this.id, this.cid, this.image, this.content, this.photo});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
      id: json['id'],
      cid: json['cid'],
      image: json['image'],
      content: json['content'],
      photo: json['photo']);
}
