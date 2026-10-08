import 'dart:io';

enum AdNetwork { admob, facebook }

class AdConfig {
  // ===========================================================================
  // CONFIGURATION: CHANGE THIS TO SWITCH AD NETWORKS
  // ===========================================================================
  static const AdNetwork activeNetwork = AdNetwork.admob; // Set to .facebook to switch
  
  // ===========================================================================
  // ADMOB KEYS (Replace with your real keys)
  // ===========================================================================
  // App IDs
  static const String admobAppIdAndroid = 'ca-app-pub-3940256099942544~3347511713'; // Test ID
  static const String admobAppIdiOS = 'ca-app-pub-3940256099942544~1458002511'; // Test ID
  
  // Banner IDs
  static String get admobBannerId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    } else {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    }
  }
  
  // Interstitial IDs
  static String get admobInterstitialId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    } else {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    }
  }

  // ===========================================================================
  // FACEBOOK AUDIENCE NETWORK KEYS
  // ===========================================================================
  static String get fbPlacementId {
    if (Platform.isAndroid) {
      return 'YOUR_ANDROID_PLACEMENT_ID'; 
    } else {
      return 'YOUR_IOS_PLACEMENT_ID';
    }
  }
  
  // Testing ID for Facebook (Optional)
  static const String fbTestingId = "37b1da9d-b48c-4103-a393-2e095e734bd6"; 
}
