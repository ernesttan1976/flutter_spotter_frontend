import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotter/config/routes.dart';
import 'package:spotter/config/theme.dart';
import 'package:spotter/features/auth/providers/auth_provider.dart';
import 'package:spotter/features/camera/providers/camera_provider.dart';
import 'package:spotter/shared/screens/not_found_screen.dart';
import 'package:spotter/shared/widgets/app_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
      ],
      child: MaterialApp(
        title: 'Spotter',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: Routes.initial,
        onGenerateRoute: Routes.onGenerateRoute,
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
        ),
        builder: (context, child) {
          return Scaffold(
            body: child,
            drawer: const SpotterDrawer(),
          );
        },
      ),
    );
  }
}