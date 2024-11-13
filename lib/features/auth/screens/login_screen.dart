import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotter/features/auth/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleLogin(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final url = await authProvider.getAuthUrl();
      if (!mounted) return;
      
      final uri = Uri.parse(url);
      print(url);

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to initiate login')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister(BuildContext context) async {
    // Same as login for SingPass
    await _handleLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF42F9E5),
              Color(0xFF149DD1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'SPOT',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        // ignore: prefer_const_constructors
                        ..shader = LinearGradient(
                          colors: const [Color(0xFFFF758C), Color(0xFFFF7EB3)],
                        ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Logo
                  Image.asset(
                    'assets/images/spot-logo2.png',
                    width: 330,
                    height: 338,
                  ),
                  const SizedBox(height: 40),

                  // Login Button
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _handleLogin(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Login with Singpass app'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Register Text and Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'New to SPOT?',
                        style: TextStyle(fontFamily: 'Lato'),
                      ),
                      TextButton(
                        onPressed:
                            _isLoading ? null : () => _handleRegister(context),
                        child: const Text('Click here to register.'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Singpass Logo
                  Image.asset(
                    'assets/images/singpass.png',
                    width: MediaQuery.of(context).size.width * 0.33,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}