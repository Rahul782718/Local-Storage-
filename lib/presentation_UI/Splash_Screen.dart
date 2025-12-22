import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_storage/routes/app_router.dart';

import '../core/storage/storage_service.dart';


@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    initlization();
  }

  Future<void> initlization() async {
    final SecureStorageService secureService = SecureStorageService();
    String? isLoggedIn = await secureService.getToken();
    debugPrint("User Login Or Not :$isLoggedIn");
    await Future.delayed(Duration(seconds: 2));
    if(isLoggedIn != null){
      context.replaceRoute(AnnouncementallRoute());
    }else{
      context.replaceRoute(LoginRoute());
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.storage,
                  size: 60,
                  color: Color(0xFF667EEA),
                ),
              ),
            ),

            SizedBox(height: 40.h),

            // App Name
            Text(
              'Local Storage',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF334155),
                letterSpacing: 1.2,
              ),
            ),

            SizedBox(height: 8.h),

            // Tagline
            Text(
              'Secure Data Management',
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 60.h),

            // Loading Indicator
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF667EEA),
              ),
              backgroundColor: const Color(0xFFF1F5F9),
            ),
          ],
        ),
      ),
    );
  }
}
