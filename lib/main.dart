import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ai_resume_builder/core/constants/app_constants.dart';
import 'package:ai_resume_builder/core/theme/app_theme.dart';
import 'package:ai_resume_builder/core/utils/app_router.dart';
import 'package:ai_resume_builder/features/job_tracker/data/models/job_application_model.dart';
import 'package:ai_resume_builder/features/onboarding/data/models/user_profile_model.dart';
import 'package:ai_resume_builder/features/home/data/models/recent_activity_model.dart';
import 'package:ai_resume_builder/features/settings/presentation/providers/theme_provider.dart';
import 'package:ai_resume_builder/core/services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(JobApplicationModelAdapter());
  Hive.registerAdapter(UserProfileModelAdapter());
  Hive.registerAdapter(RecentActivityModelAdapter());
  
  // Open Boxes
  await Hive.openBox(AppConstants.settingsBox);
  await Hive.openBox<JobApplicationModel>(AppConstants.jobBox);
  await Hive.openBox<UserProfileModel>(AppConstants.userProfileBox);
  await Hive.openBox<RecentActivityModel>(AppConstants.recentActivityBox);

  // Initialize Ads
  await AdService.instance.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
