import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../ad_helper.dart';

class AdService extends GetxService {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  // İnterstitial reklam durumu
  final isInterstitialAdReady = false.obs;
  
  // Rewarded reklam durumu
  final isRewardedAdReady = false.obs;

  Future<AdService> init() async {
    // Reklamları ön yükleme
    _loadInterstitialAd();
    _loadRewardedAd();
    
    return this;
  }

  // İnterstitial reklam yükleme
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          isInterstitialAdReady.value = true;
          
          // Reklam kapatıldığında yeni reklam yükle
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              isInterstitialAdReady.value = false;
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('İnterstitial reklamı gösterilirken hata: $error');
              ad.dispose();
              _interstitialAd = null;
              isInterstitialAdReady.value = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('İnterstitial reklamı yüklenemedi: ${error.message}');
          isInterstitialAdReady.value = false;
          
          // Hata durumunda tekrar yüklemeyi dene
          Future.delayed(const Duration(minutes: 1), _loadInterstitialAd);
        },
      ),
    );
  }

  // İnterstitial reklamı gösterme
  Future<bool> showInterstitialAd() async {
    if (_interstitialAd == null) {
      return false;
    }

    try {
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      debugPrint('İnterstitial reklamı gösterilirken hata: $e');
      return false;
    }
  }

  // Rewarded reklam yükleme
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isRewardedAdReady.value = true;

          // Reklam kapatıldığında yeni reklam yükle
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              isRewardedAdReady.value = false;
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Rewarded reklamı gösterilirken hata: $error');
              ad.dispose();
              _rewardedAd = null;
              isRewardedAdReady.value = false;
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded reklamı yüklenemedi: ${error.message}');
          isRewardedAdReady.value = false;
          
          // Hata durumunda tekrar yüklemeyi dene
          Future.delayed(const Duration(minutes: 1), _loadRewardedAd);
        },
      ),
    );
  }

  // Rewarded reklamı gösterme ve ödül verme
  Future<bool> showRewardedAd({required Function onUserEarnedReward}) async {
    if (_rewardedAd == null) {
      return false;
    }

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          onUserEarnedReward();
        },
      );
      return true;
    } catch (e) {
      debugPrint('Rewarded reklamı gösterilirken hata: $e');
      return false;
    }
  }

  @override
  void onClose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.onClose();
  }
} 