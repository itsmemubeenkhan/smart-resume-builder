class AppConstants {
  static const String appName = 'AI Resume Builder';
  
  // Job Statuses
  static const String statusApplied = 'Applied';
  static const String statusInterview = 'Interview';
  static const String statusOffer = 'Offer';
  static const String statusRejected = 'Rejected';

  static const List<String> jobStatuses = [
    statusApplied,
    statusInterview,
    statusOffer,
    statusRejected,
  ];

  // Hive Boxes
  static const String jobBox = 'jobsBox';
  static const String settingsBox = 'settingsBox';
  static const String userProfileBox = 'userProfileBox';
  static const String recentActivityBox = 'recentActivityBox';
}
