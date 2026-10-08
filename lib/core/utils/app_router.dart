import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ai_resume_builder/features/home/presentation/screens/home_screen.dart';
import 'package:ai_resume_builder/features/job_tracker/domain/entities/job_application.dart';
import 'package:ai_resume_builder/features/job_tracker/presentation/screens/add_job_screen.dart';
import 'package:ai_resume_builder/features/job_tracker/presentation/screens/job_detail_screen.dart';
import 'package:ai_resume_builder/features/job_tracker/presentation/screens/job_tracker_screen.dart';
import 'package:ai_resume_builder/features/onboarding/presentation/screens/profile_setup_screen.dart';
import 'package:ai_resume_builder/features/onboarding/presentation/screens/template_selection_screen.dart';
import 'package:ai_resume_builder/features/onboarding/presentation/screens/workspace_ready_screen.dart';
import 'package:ai_resume_builder/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:ai_resume_builder/features/resume/presentation/screens/resume_generator_screen.dart';
import 'package:ai_resume_builder/features/resume/presentation/screens/resume_preview_screen.dart';
import 'package:ai_resume_builder/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:ai_resume_builder/features/settings/presentation/screens/settings_screen.dart';
import 'package:ai_resume_builder/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:ai_resume_builder/shared/widgets/main_scaffold.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/subscription',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/template-selection',
        builder: (context, state) {
          final isEditMode = state.extra as bool? ?? false;
          return TemplateSelectionScreen(isEditMode: isEditMode);
        },
      ),
      GoRoute(
        path: '/workspace-ready',
        builder: (context, state) => const WorkspaceReadyScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'edit-profile',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/resume',
                builder: (context, state) => const ResumeGeneratorScreen(),
                routes: [
                  GoRoute(
                    path: 'preview',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const ResumePreviewScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tracker',
                builder: (context, state) => const JobTrackerScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const AddJobScreen(),
                  ),
                  GoRoute(
                    path: 'detail',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final job = state.extra as JobApplication;
                      return JobDetailScreen(job: job);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}