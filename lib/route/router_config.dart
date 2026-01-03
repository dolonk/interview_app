import 'package:flutter/material.dart';
import 'package:interview_app/route/route_name.dart';
import '../features/authentication/presentation/views/login_screen.dart';
import '../features/authentication/presentation/views/register_screen.dart';

class RouteConfig {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteName.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case RouteName.home:
        return MaterialPageRoute(
          // Temporary placeholder until Home phase is started
          builder: (_) => const Scaffold(body: Center(child: Text('Home Screen'))),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
