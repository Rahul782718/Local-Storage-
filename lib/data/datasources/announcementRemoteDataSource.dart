
import '../../core/api_Url/app_Url.dart';
import '../../core/api_service.dart';
import '../models/AnnouncementView_Model.dart';

abstract class AnnouncementRemoteDataSource{
  Future<AnnouncementViewModel> getAnnouncement(String role);
}

class AnnouncementRemoteDateSourceImpl implements AnnouncementRemoteDataSource{
  final Api_Service apiService;
  AnnouncementRemoteDateSourceImpl(this.apiService);

  /// this is Announcement
  @override
  Future<AnnouncementViewModel> getAnnouncement(String role )async {
    print("Api Hit Announcement :${role}");
    final data = await apiService.get(role == "all" ? App_URL.getAll_Announcement : App_URL.getAll_Announcement);
    print("Announcement Response : $data");
    return AnnouncementViewModel.fromJson(data);
  }


}