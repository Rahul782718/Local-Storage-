import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_storage/routes/app_router.dart';
import 'core/multi_bloc_wrapper.dart';
import 'core/service_loactor.dart';
import 'core/storage/storage_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SecureStorageService();
  await init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  final _appRouter = sl<AppRouter>();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: Multi_Bloc_Wrapper(
        child: MaterialApp.router(
          routerDelegate: _appRouter.delegate(),
          routeInformationParser: _appRouter.defaultRouteParser(),
          debugShowCheckedModeBanner: false,
          title: 'Local Storage',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
        ),
      ),
    );
  }
}
