// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      bearing: (json['bearing'] as num?)?.toDouble(),
      remarks: json['remarks'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      'id': instance.id,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'bearing': instance.bearing,
      'remarks': instance.remarks,
      'photoUrl': instance.photoUrl,
      'created_at': instance.createdAt.toIso8601String(),
    };
