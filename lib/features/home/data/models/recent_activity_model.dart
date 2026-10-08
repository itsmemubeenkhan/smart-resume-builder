import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'recent_activity_model.g.dart';

@HiveType(typeId: 2)
class RecentActivityModel extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String subtitle;

  @HiveField(2)
  final int iconCode;

  @HiveField(3)
  final int colorValue;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String? targetRoute;

  RecentActivityModel({
    required this.title,
    required this.subtitle,
    required this.iconCode,
    required this.colorValue,
    required this.timestamp,
    this.targetRoute,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
}
