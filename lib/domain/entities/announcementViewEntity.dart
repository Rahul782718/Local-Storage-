import '../../data/models/AnnouncementView_Model.dart';

class AnnouncementViewEntity {
  bool success;
  String message;
  List<AnnouncementView> data;

  AnnouncementViewEntity({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AnnouncementViewEntity.fromModel(AnnouncementViewModel model) {
    return AnnouncementViewEntity(
      success: model.success,
      message: model.message,
      data: model.data,
    );
  }
}
