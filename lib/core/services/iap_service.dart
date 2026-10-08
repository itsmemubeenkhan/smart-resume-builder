import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../../features/onboarding/data/models/user_profile_model.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  static IAPService get instance => _instance;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Define your product IDs here. These must match what you set up in Google Play Console.
  static const String _monthlySubscriptionId = 'premium_monthly';
  static const String _weeklySubscriptionId = 'premium_weekly';
  
  final List<String> _productIds = [_monthlySubscriptionId, _weeklySubscriptionId];
  
  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;
  
  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  // Callback for purchase updates
  Function(bool isPremium)? onPremiumStatusChanged;
  Function(String error)? onPurchaseError;
  Function()? onPurchasePending;

  IAPService._internal();

  Future<void> initialize() async {
    _subscription?.cancel(); // Cancel existing subscription if any

    _isAvailable = await _iap.isAvailable();
    if (_isAvailable) {
      final ProductDetailsResponse response = await _iap.queryProductDetails(_productIds.toSet());
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
      }
      _products = response.productDetails;
      debugPrint('Loaded products: ${_products.length}');
    } else {
      debugPrint('IAP not available');
    }

    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      debugPrint('IAP Error: $error');
      if (onPurchaseError != null) onPurchaseError!(error.toString());
    });
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        if (onPurchasePending != null) onPurchasePending!();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase error: ${purchaseDetails.error}');
          if (onPurchaseError != null) onPurchaseError!(purchaseDetails.error?.message ?? 'Unknown error');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          
          await _verifyAndDeliverProduct(purchaseDetails);
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchaseDetails) async {
    // In a real app, you should verify the purchase with your backend server here.
    // For this local-only app, we'll trust the purchase and unlock premium locally.
    
    await _setPremiumStatus(true);
  }

  Future<void> _setPremiumStatus(bool isPremium) async {
    final box = Hive.box<UserProfileModel>(AppConstants.userProfileBox);
    final currentProfile = box.get('current_profile');
    
    if (currentProfile != null) {
      final updatedProfile = UserProfileModel(
        fullName: currentProfile.fullName,
        email: currentProfile.email,
        phone: currentProfile.phone,
        jobTitle: currentProfile.jobTitle,
        address: currentProfile.address,
        selectedTemplateId: currentProfile.selectedTemplateId,
        isPremium: isPremium,
      );
      await box.put('current_profile', updatedProfile);
      
      if (onPremiumStatusChanged != null) {
        onPremiumStatusChanged!(isPremium);
      }
    }
  }

  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
