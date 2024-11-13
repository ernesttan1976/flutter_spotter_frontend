// lib/features/auth/providers/auth_provider.dart
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spotter/core/services/api_service.dart';
import 'package:spotter/core/models/user.dart';
import 'package:spotter/core/utils/logger.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;
  final Logger _logger;
  
  User? _user;
  Timer? _sessionTimer;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constants
  static const String _userKey = 'user';
  static const String _expiryTimeKey = 'expiryTime';
  static const int _warningThreshold = 300000; // 5 minutes in milliseconds
  static const int _maxTimeoutLimit = 43200000; // 12 hours in milliseconds

  // Constructor
  AuthProvider({
    ApiService? apiService,
    FlutterSecureStorage? storage,
    Logger? logger,
  }) : _apiService = apiService ?? ApiService(),
       _storage = storage ?? const FlutterSecureStorage(),
       _logger = logger ?? Logger() {
    _initializeAuth();
  }

  bool _isEmulator() {
    if (Platform.isAndroid) {
      return Platform.operatingSystemVersion.contains('SDK built for x86') ||
            Platform.operatingSystemVersion.contains('Android SDK built for') ||
            Platform.operatingSystemVersion.contains('google_sdk');
    }
    return false;
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userJson = await _storage.read(key: _userKey);
      final expiryTimeStr = await _storage.read(key: _expiryTimeKey);

      if (userJson != null && expiryTimeStr != null) {
        _user = User.fromJson(userJson);
        _setupSessionTimer(DateTime.parse(expiryTimeStr));
      }

      _isInitialized = true;
    } catch (e) {
      _error = 'Failed to initialize authentication';
      _logger.error('Auth initialization failed', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get authentication URL for SingPass
  Future<String> getAuthUrl() async {
    try {
      _isLoading = true;
      notifyListeners();

      final sessionId = DateTime.now().millisecondsSinceEpoch.toString() + 
                       Random().nextInt(1000000).toString();
      await _storage.write(key: 'session_id', value: sessionId);

      final response = await _apiService.get('/auth/auth-url?type=SPOTTER');
      String url = response.data['url'];
      
      // Add mobile platform and session_id parameters
      final Uri uri = Uri.parse(url);
      final newParams = Map<String, dynamic>.from(uri.queryParameters)
        ..['redirect_uri'] = '${uri.queryParameters['redirect_uri']}&platform=mobile&session_id=$sessionId';
      
      final newUrl = uri.replace(queryParameters: newParams).toString();
      return newUrl;
    } catch (e) {
      _error = 'Failed to get authentication URL';
      throw Exception('Failed to get authentication URL');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleCallback() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/auth/userinfo');
      
      if (response.data['error'] != null) {
        _error = response.data['error'];
        notifyListeners();
        return;
      }

      // Store token securely
      if (response.data['token'] != null) {
        await _storage.write(key: 'jwt_token', value: response.data['token']);
        _apiService.updateToken(response.data['token']);
      }

      _user = User.fromJson(response.data['user']);
      _setupSessionTimer(DateTime.parse(response.data['expiryTime']));
      
      notifyListeners();
    } catch (e) {
      _error = 'Authentication failed';
      _logger.error('Auth callback failed', e);
      throw Exception('Authentication failed');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle successful authentication
  Future<void> _handleSuccessfulAuth(Map<String, dynamic> data) async {
    _user = data as User?;
    
    // Store user data securely
    await _storage.write(key: _userKey, value: data.toString());
    await _storage.write(
      key: _expiryTimeKey,
      value: data['expiryTime'].toString(),
    );

    // Setup session timer
    _setupSessionTimer(DateTime.parse(data['expiryTime']));
    notifyListeners();
  }

  // Verify token
  Future<bool> verifyToken() async {
    try {
      final response = await _apiService.get('/auth/verify?type=user');
      
      if (response.data['status'] == 'Success') {
        return true;
      }
      
      if (response.data['error'] == 'Not authorised') {
        await logout();
        return false;
      }

      return false;
    } catch (e) {
      _logger.error('Token verification failed', e);
      return false;
    }
  }

  // Extend session
  Future<void> extendSession() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.put('/auth/extend-session');
      
      if (response.data['error'] != null) {
        throw Exception(response.data['error']);
      }

      await _storage.write(
        key: _expiryTimeKey,
        value: response.data['expiryTime'].toString(),
      );

      _setupSessionTimer(DateTime.parse(response.data['expiryTime']));
    } catch (e) {
      _error = 'Failed to extend session';
      _logger.error('Session extension failed', e);
      throw Exception('Failed to extend session');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Setup session timer
  void _setupSessionTimer(DateTime expiryTime) {
    _sessionTimer?.cancel();

    final timeToExpiry = expiryTime.difference(DateTime.now()).inMilliseconds;
    final warningTime = timeToExpiry - _warningThreshold;

    if (warningTime > 0) {
      _sessionTimer = Timer(Duration(milliseconds: warningTime), () {
        // Notify about impending session expiry
        _onSessionWarning();
      });
    }

    // Set timer for actual expiry
    Timer(Duration(milliseconds: timeToExpiry), () {
      // Handle session expiry
      _onSessionExpired();
    });
  }

  // Session warning handler
  void _onSessionWarning() {
    // Notify listeners about impending session expiry
    _error = 'Session will expire soon';
    notifyListeners();
  }

  // Session expiry handler
  void _onSessionExpired() {
    logout();
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.get('/auth/logout');
    } catch (e) {
      _logger.error('Logout failed', e);
    } finally {
      // Clear local data regardless of logout API success
      await _clearLocalData();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear local data
  Future<void> _clearLocalData() async {
    _sessionTimer?.cancel();
    _user = null;
    await _storage.deleteAll();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}