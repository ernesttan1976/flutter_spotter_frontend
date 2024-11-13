import 'package:flutter/material.dart';
import 'package:spotter/features/camera/screens/camera_screen.dart';
import 'package:spotter/features/auth/screens/login_screen.dart';
import 'package:spotter/features/auth/screens/callback_screen.dart';
import 'package:spotter/features/auth/screens/success_screen.dart';
import 'package:spotter/features/reports/screens/add_report_screen.dart';
import 'package:spotter/features/reports/screens/view_reports_screen.dart';
import 'package:spotter/features/reports/screens/edit_report_screen.dart';
import 'package:spotter/shared/screens/error_screen.dart';
import 'package:spotter/shared/screens/not_found_screen.dart';

class Routes {
  // Development flag to bypass auth
  static const bool bypassAuth = true; // Toggle this to enable/disable auth

  // Routes
  static String get initial => bypassAuth ? addReport : login;
  static const String login = '/';
  static const String callback = '/callback';
  static const String addReport = '/add_report';
  static const String viewReports = '/view';
  static const String editReport = '/edit';
  static const String camera = '/camera';
  static const String error = '/error';
  static const String success = '/success';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // If bypassing auth and trying to access auth routes, redirect to add report
    if (bypassAuth && 
        [login, callback, success].contains(settings.name)) {
      return MaterialPageRoute(
        builder: (_) => const AddReportScreen(),
        settings: RouteSettings(
          name: addReport,
          arguments: settings.arguments,
        ),
      );
    }

    // Normal routing logic
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case callback:
        return MaterialPageRoute(
          builder: (_) => const CallbackScreen(),
          settings: settings,
        );

      case success:
        return MaterialPageRoute(
          builder: (_) => const SuccessScreen(),
          settings: settings,
        );

      case addReport:
        return MaterialPageRoute(
          builder: (_) => const AddReportScreen(),
          settings: settings,
        );

      case viewReports:
        return MaterialPageRoute(
          builder: (_) => const ViewReportsScreen(),
          settings: settings,
        );

      case editReport:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EditReportScreen(
            reportId: args?['reportId'],
            defaultLocation: args?['defaultLocation'],
            defaultBearing: args?['defaultBearing'],
            defaultRemarks: args?['defaultRemarks'],
            defaultPhoto: args?['defaultPhoto'],
            reportTime: args?['reportTime'],
          ),
          settings: settings,
        );

      case camera:
        return MaterialPageRoute(
          builder: (_) => const CameraScreen(),
          settings: settings,
        );

      case error:
        final error = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ErrorScreen(error: error),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }

  // Helper methods remain unchanged
  static Future<T?> navigateTo<T extends Object?>(
    BuildContext context,
    String route, {
    Object? arguments,
  }) async {
    try {
      return await Navigator.pushNamed<T>(
        context,
        route,
        arguments: arguments,
      );
    } catch (e) {
      Navigator.pushNamed(
        context,
        error,
        arguments: 'Navigation error: ${e.toString()}',
      );
      return null;
    }
  }

  static Future<T?> navigateToReplace<T extends Object?>(
    BuildContext context,
    String route, {
    Object? arguments,
  }) async {
    try {
      return await Navigator.pushReplacementNamed<T, void>(
        context,
        route,
        arguments: arguments,
      );
    } catch (e) {
      Navigator.pushNamed(
        context,
        error,
        arguments: 'Navigation error: ${e.toString()}',
      );
      return null;
    }
  }
}