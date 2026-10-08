import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ai_resume_builder/core/constants/app_constants.dart';
import 'package:ai_resume_builder/features/home/data/models/recent_activity_model.dart';

class ActivityService {
  static Future<void> addActivity({
    required String title,
    required String subtitle,
    required IconData icon,
    Color color = Colors.blue,
    String? targetRoute,
  }) async {
    // Ensure box is open
    if (!Hive.isBoxOpen(AppConstants.recentActivityBox)) {
      await Hive.openBox<RecentActivityModel>(AppConstants.recentActivityBox);
    }
    
    final box = Hive.box<RecentActivityModel>(AppConstants.recentActivityBox);
    final activity = RecentActivityModel(
      title: title,
      subtitle: subtitle,
      iconCode: icon.codePoint,
      // ignore: deprecated_member_use
      colorValue: color.value, // Using value for storage - standard way to get ARGB integer
      timestamp: DateTime.now(),
      targetRoute: targetRoute,
    );
    
    await box.add(activity);
    
    // Keep only last 20 activities
    if (box.length > 20) {
      await box.deleteAt(0);
    }
  }

  static Future<void> clearActivities() async {
    if (!Hive.isBoxOpen(AppConstants.recentActivityBox)) return;
    final box = Hive.box<RecentActivityModel>(AppConstants.recentActivityBox);
    await box.clear();
  }
}
