import '../entities/announcementViewEntity.dart';
import '../repositories/announcementRepositories.dart';

class GetAnnouncementViewUseCase {
  final AnnouncementRepositories repository;

  GetAnnouncementViewUseCase(this.repository);

  Future<AnnouncementViewEntity> call(String role) {
    return repository.getAnnouncement(role);
  }
}