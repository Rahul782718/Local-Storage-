import 'package:get_it/get_it.dart';
import '../Local_database/Local_Model/announcementLocalModel.dart';
import '../data/datasources/announcementRemoteDataSource.dart';
import '../data/localDataSource/AnnouncementLocalDataSource.dart';

class SyncService {
  final AnnouncementLocalDataSource localDataSource = GetIt.instance<AnnouncementLocalDataSource>();
  final AnnouncementRemoteDataSource remoteDataSource = GetIt.instance<AnnouncementRemoteDataSource>();

  Future<void> syncPendingChanges() async {
    print('🔄 [SYNC] Starting...');
    final dirty = await localDataSource.getDirtyAnnouncements();

    if (dirty.isEmpty) {
      print('✅ [SYNC] No pending changes');
      return;
    }

    print('📊 [SYNC] ${dirty.length} dirty records');
    for (final item in dirty) {
      try {
        print('📤 Syncing #${item.id} (${item.operationType ?? 'unknown'})');
        // TODO: Implement create/update API calls
        await localDataSource.updateSyncStatus(item.id, 'synced');
        print('✅ Synced #${item.id}');
      } catch (e) {
        print('❌ Failed #${item.id}: $e');
      }
    }
  }
}
