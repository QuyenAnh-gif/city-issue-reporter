import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String userId;
  final String typeLabel;
  final IconData typeIcon;
  final Color typeColor;
  final String description;
  final List<String> imagePaths;
  final DateTime createdAt;
  final LatLng location;
  final String status;

  final List<String> upvotedBy;
  final List<Map<String, dynamic>> comments;

  const ReportModel({
    required this.id,
    required this.userId,
    required this.typeLabel,
    required this.typeIcon,
    required this.typeColor,
    required this.description,
    required this.imagePaths,
    required this.createdAt,
    required this.location,
    this.status = 'active',
    this.upvotedBy = const [],
    this.comments = const [],
  });

  ReportModel copyWith({String? status}) => ReportModel(
        id: id,
        userId: userId,
        typeLabel: typeLabel,
        typeIcon: typeIcon,
        typeColor: typeColor,
        description: description,
        imagePaths: imagePaths,
        createdAt: createdAt,
        location: location,
        status: status ?? this.status,
        upvotedBy: upvotedBy,
        comments: comments,
      );

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'typeLabel': typeLabel,
        'typeIconCode': typeIcon.codePoint,
        'typeFontFamily': typeIcon.fontFamily ?? 'MaterialIcons',
        'typeColorValue': typeColor.value,
        'description': description,
        'imagePaths': imagePaths,
        'createdAt': Timestamp.fromDate(createdAt),
        'latitude': location.latitude,
        'longitude': location.longitude,
        'status': status,
        'upvotedBy': upvotedBy,
        'comments': comments,
      };

  factory ReportModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ReportModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      typeLabel: data['typeLabel'] as String? ?? '',
      typeIcon: IconData(
        (data['typeIconCode'] as num?)?.toInt() ?? Icons.report.codePoint,
        fontFamily: data['typeFontFamily'] as String? ?? 'MaterialIcons',
      ),
      typeColor:
          Color((data['typeColorValue'] as num?)?.toInt() ?? Colors.red.value),
      description: data['description'] as String? ?? '',
      imagePaths: List<String>.from(data['imagePaths'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: LatLng(
        (data['latitude'] as num?)?.toDouble() ?? 10.7769,
        (data['longitude'] as num?)?.toDouble() ?? 106.6953,
      ),
      status: data['status'] as String? ?? 'pending',
      upvotedBy: List<String>.from(data['upvotedBy'] as List? ?? []),
      comments:
          List<Map<String, dynamic>>.from(data['comments'] as List? ?? []),
    );
  }
}
