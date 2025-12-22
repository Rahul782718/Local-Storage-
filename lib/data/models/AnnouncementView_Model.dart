class AnnouncementViewModel {
  bool success;
  String message;
  List<AnnouncementView> data;

  AnnouncementViewModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AnnouncementViewModel.fromJson(Map<String, dynamic> json) => AnnouncementViewModel(
    success: json["success"],
    message: json["message"],
    data: List<AnnouncementView>.from(json["data"].map((x) => AnnouncementView.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class AnnouncementView {
  int id;
  String title;
  String description;
  int acknowledge;
  String? fileUrl;
  String imageUrl;

  AnnouncementView({
    required this.id,
    required this.title,
    required this.description,
    required this.acknowledge,
    required this.fileUrl,
    required this.imageUrl,
  });

  factory AnnouncementView.fromJson(Map<String, dynamic> json) => AnnouncementView(
    id: json["id"]?? 0,
    title: json["title"] ?? "",
    description: json["description"] ?? '',
    acknowledge: json["acknowledge"] ?? "",
    fileUrl: json["file_url"] ?? '',
    imageUrl: json["image_url"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "acknowledge": acknowledge,
    "file_url": fileUrl,
    "image_url": imageUrl,
  };
}
