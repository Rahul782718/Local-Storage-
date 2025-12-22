import '../../core/network/NetworkInfo.dart';
import '../../domain/entities/announcementViewEntity.dart';
import '../../domain/repositories/announcementRepositories.dart';
import '../datasources/announcementRemoteDataSource.dart';
import '../localDataSource/AnnouncementLocalDataSource.dart';

class AnnouncementRepositoryImp implements AnnouncementRepositories {
  final AnnouncementRemoteDataSource remoteDataSource;
  final AnnouncementLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AnnouncementRepositoryImp({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<AnnouncementViewEntity> getAnnouncement(String role) async {
    // 1. Always try local first (offline-first)
    final localAnnouncements = await localDataSource.getAnnouncements();

    if (localAnnouncements.isNotEmpty) {
      // 2. Background sync if online
      _backgroundSync(role);
      return AnnouncementViewEntity(
        success: true,
        message: 'Loaded from cache',
        data: localAnnouncements.map((e) => e.toEntity()).toList(),
      );
    }

    // 3. No local data, try remote
    if (await networkInfo.isConnected) {
      try {
        final remoteResult = await remoteDataSource.getAnnouncement(role);
        if (remoteResult.success) {
          await localDataSource.insertAnnouncements(remoteResult.data);
          return AnnouncementViewEntity(
            success: remoteResult.success,
            message: remoteResult.message,
            data: remoteResult.data,
          );
        }
      } catch (e) {
        // Remote failed, return empty
      }
    }

    // 4. Both failed, return empty
    return AnnouncementViewEntity(
      success: false,
      message: 'No data available offline',
      data: [],
    );
  }

  /// Background sync when online
  Future<void> _backgroundSync(String role) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteResult = await remoteDataSource.getAnnouncement(role);
        if (remoteResult.success) {
          await localDataSource.insertAnnouncements(remoteResult.data);
        }
      } catch (e) {
        // Silent fail for background sync
      }
    }
  }
}
