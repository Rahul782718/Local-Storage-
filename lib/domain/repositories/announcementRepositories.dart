
import '../entities/announcementViewEntity.dart';

abstract class AnnouncementRepositories{
  Future<AnnouncementViewEntity> getAnnouncement(String role);

}