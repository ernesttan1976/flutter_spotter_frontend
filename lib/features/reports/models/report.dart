// lib/features/reports/models/report.dart
import 'package:json_annotation/json_annotation.dart';

part 'report.g.dart';

@JsonSerializable()
class Report {
  final String id;
  final double latitude;
  final double longitude;
  final double? bearing;
  final String? remarks;
  final String? photoUrl;
  
  @JsonKey(name: 'created_at')
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;

  Report({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.bearing,
    this.remarks,
    this.photoUrl,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);

  // Custom DateTime converter
  static DateTime _dateTimeFromJson(String value) => DateTime.parse(value);
  static String _dateTimeToJson(DateTime value) => value.toIso8601String();
}