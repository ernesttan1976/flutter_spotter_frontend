import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:spotter/core/services/api_service.dart';
import 'package:spotter/features/reports/models/report.dart';

class ReportProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Report> _reports = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ReportProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<void> fetchReports() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/users/me/reports');
      final List<dynamic> data = response.data;
      _reports = data.map((json) => Report.fromJson(json)).toList();
      
    } catch (e) {
      _error = 'Failed to fetch reports';
      _reports = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendReport(Map<String, dynamic> formData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.post('/reports', data: formData);
      return true;
    } catch (e) {
      _error = 'Failed to send report';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editReport(String reportId, Map<String, dynamic> formData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.put('/reports/spotter/$reportId', data: formData);
      return true;
    } catch (e) {
      _error = 'Failed to edit report';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadMedia(String reportId, FormData mediaData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.post('/reports/media/$reportId', data: mediaData);
      return true;
    } catch (e) {
      _error = 'Failed to upload media';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}