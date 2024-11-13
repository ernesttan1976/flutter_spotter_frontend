import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotter/config/routes.dart';
import 'package:spotter/features/auth/providers/auth_provider.dart';

class CallbackScreen extends StatefulWidget {
  const CallbackScreen({super.key});

  @override
  State<CallbackScreen> createState() => _CallbackScreenState();
}

class _CallbackScreenState extends State<CallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    final authProvider = context.read<AuthProvider>();
    
    try {
      await authProvider.handleCallback();
      
      if (!mounted) return;
      
      if (authProvider.error?.contains('Registration pending') ?? false) {
        // Registration case
        Navigator.pushReplacementNamed(context, Routes.success);
      } else if (authProvider.isAuthenticated) {
        // Successful login
        Navigator.pushReplacementNamed(context, Routes.addReport);
      } else {
        // Error case
        Navigator.pushReplacementNamed(context, Routes.error);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        Routes.error,
        arguments: 'Authentication failed: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}