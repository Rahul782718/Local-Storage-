import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:local_storage/core/api_Url/app_Url.dart';
import 'package:local_storage/core/storage/storage_service.dart';

import '../Local_database/AutoSyncService.dart';
import '../Local_database/SyncService.dart';
import '../Local_database/databaseHelper.dart';
import '../data/datasources/announcementRemoteDataSource.dart';
import '../data/localDataSource/AnnouncementLocalDataSource.dart';
import '../data/repositories_impl/announcementRepositoryImp.dart';
import '../domain/repositories/announcementRepositories.dart';
import '../domain/usecases/getAnnouncementView_UseCase.dart';
import '../presentation_UI/announcements/bloc/announcement_bloc.dart';
import '../routes/app_router.dart';
import 'api_service.dart';
import 'network/NetworkInfo.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ---------------------------
  // External / Core (Order matters!)
  // ---------------------------

  // Register AppRouter FIRST (needed by AuthInterceptor)
  sl.registerLazySingleton<AppRouter>(() => AppRouter());

  // ✅ Register Dio FIRST with interceptor
  sl.registerLazySingleton(() {
    final dio = Dio(BaseOptions(
      baseUrl: App_URL.baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
    ));

    // Add Auth Interceptor
    // dio.interceptors.add(AuthInterceptor(sl<SecureStorageService>()));
    //
    // // Optional: Add Pretty Dio Logger for debugging
    // dio.interceptors.add(PrettyDioLogger(
    //   requestHeader: true,
    //   requestBody: true,
    //   responseBody: true,
    //   responseHeader: false,
    //   error: true,
    //   compact: true,
    // ));

    return dio;
  });

  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ✅ NEW: Register Database Helper (initialize DB)
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // ---------------------------
  // API Service
  // ---------------------------
  sl.registerLazySingleton<Api_Service>(
        () => Api_Service(sl<Dio>(), sl<NetworkInfo>(), sl<SecureStorageService>()),
  );

  // ---------------------------
  // Data Sources (Local + Remote)
  // ---------------------------
  sl.registerLazySingleton<AnnouncementLocalDataSource>(
        () => AnnouncementLocalDataSourceImpl(),  // ✅ ADD THIS
  );

  sl.registerLazySingleton<AnnouncementRemoteDataSource>(
        () => AnnouncementRemoteDateSourceImpl(sl<Api_Service>()),
  );

  // Add these AFTER existing registrations:
  sl.registerLazySingleton<SyncService>(() => SyncService());
  sl.registerLazySingleton<AutoSyncService>(() => AutoSyncService());
  sl<AutoSyncService>().init();  // ✅ Auto start sync

  // ---------------------------
  // Repository (needs both data sources)
  // ---------------------------
  sl.registerLazySingleton<AnnouncementRepositories>(
        () => AnnouncementRepositoryImp(
      remoteDataSource: sl<AnnouncementRemoteDataSource>(),  // ✅ Fixed: specify type
      localDataSource: sl<AnnouncementLocalDataSource>(),    // ✅ Fixed: specify type
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // ---------------------------
  // Use Cases
  // ---------------------------
  sl.registerLazySingleton(() => GetAnnouncementViewUseCase(sl<AnnouncementRepositories>()));

  // ---------------------------
  // BLoC
  // ---------------------------
  sl.registerFactory(() => AnnouncementBloc(sl<GetAnnouncementViewUseCase>()));
}
