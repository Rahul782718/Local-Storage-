import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:local_storage/routes/app_router.dart';
import '../../Local_database/SyncService.dart';
import '../../Local_database/databaseHelper.dart';
import '../../core/storage/storage_service.dart';
import 'AnnouncementCardWidget.dart';
import 'bloc/announcement_bloc.dart';
import 'bloc/announcement_event.dart';
import 'bloc/announcement_state.dart';

@RoutePage()
class AnnouncementallScreen extends StatefulWidget {
  const AnnouncementallScreen({super.key});

  @override
  State<AnnouncementallScreen> createState() => _AnnouncementallScreenState();
}

class _AnnouncementallScreenState extends State<AnnouncementallScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      apiCalling();
    });
  }

  void apiCalling() async{
    await DatabaseHelper.printSyncStatus();

    print('🔄 Loading announcements...');
    context.read<AnnouncementBloc>().add(GetAnnouncementRequestedEvent("all"));
  }

  /// ✅ LOGOUT + CLEAR ALL DATA
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout', style: TextStyle(fontSize: 18.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clear all local data and logout?', style: TextStyle(fontSize: 14.sp)),
            8.verticalSpace,
            Text(
              '• Token cleared\n• Local DB cleared\n• Sync cache reset',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      print('🚪 [LOGOUT] Clearing all data...');

      // 1. Clear secure storage (token)
      final secureStorage = GetIt.instance<SecureStorageService>();
      await secureStorage.clearAll();
      print('✅ Token cleared');

      // 2. Clear local database
      await DatabaseHelper.clearAllData(); // Add this method to DatabaseHelper
      print('✅ Local DB cleared');

      // 3. Navigate to login
      context.replaceRoute(LoginRoute());
    }
  }

  /// ✅ MANUAL SYNC
  Future<void> _manualSync() async {
    print('🔄 [MANUAL] Sync button pressed');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            8.horizontalSpace,
            Text('Syncing...', style: TextStyle(fontSize: 14.sp)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );

    final syncService = GetIt.instance<SyncService>();
    try {
      await syncService.syncPendingChanges();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Sync completed!', style: TextStyle(fontSize: 14.sp)),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      apiCalling(); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Sync failed: $e', style: TextStyle(fontSize: 14.sp)),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  final  localDB = DatabaseHelper.getDirtyCount();

  @override
  Widget build(BuildContext context) {
    print("Local Data Base :${localDB.runtimeType}");
    return Scaffold(
      appBar: AppBar(
        title: Text("DashBoard"),
        actions: [
          // ✅ SYNC STATUS INDICATOR
          FutureBuilder<int>(
            future: DatabaseHelper.getDirtyCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Padding(
                padding: EdgeInsets.all(8.w),
                child: Stack(
                  children: [
                    Icon(
                      count > 0 ? Icons.sync_problem : Icons.sync,
                      color: count > 0 ? Colors.orange : Colors.green,
                      size: 24.sp,
                    ),
                    if (count > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10.w),
                          ),
                          constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          // ✅ LOGOUT BUTTON
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 24.sp),
            onSelected: (value) {
              if (value == 'logout') _handleLogout();
              if (value == 'sync') _manualSync();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.sync, size: 20.sp),
                    8.horizontalSpace,
                    Text('Manual Sync'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20.sp, color: Colors.red),
                    8.horizontalSpace,
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildTabContent()),
        ],
      ),
      // ✅ TWO FABs: Add (future) + Sync (manual)
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Manual Sync FAB
          FloatingActionButton(
            heroTag: "sync",
            mini: true,
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            onPressed: _manualSync,
            child: Icon(Icons.sync, size: 20.sp),
            tooltip: 'Manual Sync',
          ),
          8.verticalSpace,
          // // Add New FAB (future create screen)
          // FloatingActionButton(
          //   heroTag: "add",
          //   backgroundColor: Colors.green,
          //   foregroundColor: Colors.white,
          //   onPressed: () {
          //     print('➕ Create new announcement (TODO)');
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(content: Text('Create announcement feature coming soon! 👷‍♂️')),
          //     );
          //   },
          //   child: Icon(Icons.add, size: 20.sp),
          //   tooltip: 'Create Announcement',
          // ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return BlocBuilder<AnnouncementBloc, AnnouncementState>(
      builder: (context, state) {
        if (state is GetAnnouncementLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.blue),
                12.verticalSpace,
                Text('Loading announcements...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        if (state is GetAnnouncementError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                12.verticalSpace,
                Text(state.error, style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
                16.verticalSpace,
                ElevatedButton(
                  onPressed: apiCalling,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        if (state is GetAnnouncementSuccess) {
          final announcementList = state.response.data;
          print("📋 List data: ${announcementList.length}");

          if (announcementList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64.sp, color: Colors.grey),
                  16.verticalSpace,
                  Text('No announcements found', style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
                  8.verticalSpace,
                  Text('Check back later for updates', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Text("Total Count of List :${announcementList.length}"),
              12.verticalSpace,

              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  itemCount: announcementList.reversed.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey.withOpacity(0.3),
                    thickness: 1,
                    height: 20.h,
                    indent: 16.w,
                    endIndent: 16.w,
                  ),
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final announcementData = announcementList[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      child: AnnouncementCardWidget(
                        isShowComment: true,
                        announcementViewData: announcementData,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return Center(child: Text('Ready to load announcements', style: TextStyle(color: Colors.grey)));
      },
    );
  }
}
