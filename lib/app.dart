import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview_app/route/route_name.dart';
import 'package:interview_app/route/router_config.dart';
import 'core/theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 12 Pro size
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'e-Signature',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: RouteName.login,
          onGenerateRoute: RouteConfig.generateRoute,
        );
      },
    );
  }
}
