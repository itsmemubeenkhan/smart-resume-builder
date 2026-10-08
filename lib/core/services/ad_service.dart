import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../../features/onboarding/data/models/user_profile_model.dart';
import '../config/ad_config.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  static AdService get instance => _instance;

  InterstitialAd? _adMobInterstitialAd;
  bool _isAdMobInterstitialReady = false;
  bool _isFbInterstitialReady = false;

  AdService._internal();

  Future<void> initialize() async {
    // Initialize AdMob
    await MobileAds.instance.initialize();
    
    // Initialize Facebook Audience Network
    await FacebookAudienceNetwork.init(
      testingId: AdConfig.fbTestingId, 
      iOSAdvertiserTrackingEnabled: true,
    );
    
    _loadInterstitial();
  }

  // Check if user is free
  bool _isFreeUser() {
    final box = Hive.box<UserProfileModel>(AppConstants.userProfileBox);
    final profile = box.get('current_profile');
    return profile == null || !profile.isPremium;
  }

  // --- Interstitial Ads ---

  void _loadInterstitial() {
    if (!_isFreeUser()) return;

    if (AdConfig.activeNetwork == AdNetwork.admob) {
      InterstitialAd.load(
        adUnitId: AdConfig.admobInterstitialId, 
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _adMobInterstitialAd = ad;
            _isAdMobInterstitialReady = true;
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdMob Interstitial failed to load: $error');
            _isAdMobInterstitialReady = false;
          },
        ),
      );
    } else {
      FacebookInterstitialAd.loadInterstitialAd(
        placementId: AdConfig.fbPlacementId,
        listener: (result, value) {
          if (result == InterstitialAdResult.LOADED) {
            _isFbInterstitialReady = true;
          } else if (result == InterstitialAdResult.DISMISSED && value["invalidated"] == true) {
             _isFbInterstitialReady = false;
             _loadInterstitial();
          }
        },
      );
    }
  }

  void showInterstitial() {
    if (!_isFreeUser()) return;

    if (AdConfig.activeNetwork == AdNetwork.admob) {
      if (_isAdMobInterstitialReady && _adMobInterstitialAd != null) {
        _adMobInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _loadInterstitial(); // Reload
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _loadInterstitial();
          },
        );
        _adMobInterstitialAd!.show();
        _isAdMobInterstitialReady = false;
        _adMobInterstitialAd = null;
      } else {
        _loadInterstitial();
      }
    } else {
      if (_isFbInterstitialReady) {
        FacebookInterstitialAd.showInterstitialAd();
        _isFbInterstitialReady = false;
        _loadInterstitial();
      } else {
        _loadInterstitial();
      }
    }
  }

  // --- Banner Ads ---

  Widget getBannerAd() {
    if (!_isFreeUser()) return const SizedBox.shrink();

    if (AdConfig.activeNetwork == AdNetwork.admob) {
      return const AdMobBannerWidget();
    } else {
      return FacebookBannerAd(
        placementId: AdConfig.fbPlacementId,
        bannerSize: BannerSize.STANDARD,
        listener: (result, value) {
          switch (result) {
            case BannerAdResult.ERROR:
              debugPrint("Error: $value");
              break;
            case BannerAdResult.LOADED:
              debugPrint("Loaded: $value");
              break;
            case BannerAdResult.CLICKED:
              debugPrint("Clicked: $value");
              break;
            case BannerAdResult.LOGGING_IMPRESSION:
              debugPrint("Logging Impression: $value");
              break;
          }
        },
      );
    }
  }

  // --- Native Ads ---
  
  Widget getNativeAd() {
    if (!_isFreeUser()) return const SizedBox.shrink();

    if (AdConfig.activeNetwork == AdNetwork.admob) {
      // AdMob Native is complex to setup (requires factory). 
      // Returning a Medium Rectangle Banner as a fallback for "Native" feel.
      return const AdMobBannerWidget(size: AdSize.mediumRectangle);
    } else {
      return FacebookNativeAd(
        placementId: AdConfig.fbPlacementId,
        adType: NativeAdType.NATIVE_AD,
        width: double.infinity,
        height: 300,
        backgroundColor: Colors.blue,
        titleColor: Colors.white,
        descriptionColor: Colors.white,
        buttonColor: Colors.deepPurple,
        buttonTitleColor: Colors.white,
        buttonBorderColor: Colors.white,
        listener: (result, value) {
          debugPrint("Native Ad: $result --> $value");
        },
        keepAlive: true,
      );
    }
  }
}

class AdMobBannerWidget extends StatefulWidget {
  final AdSize size;
  const AdMobBannerWidget({super.key, this.size = AdSize.banner});

  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdConfig.admobBannerId,
      size: widget.size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('AdMob Banner failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }
}
