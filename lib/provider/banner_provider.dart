
import 'package:flutter/material.dart';
import '../models/banner_model.dart';
import '../services/banner_services.dart';

class BannerProvider with ChangeNotifier{
  List<BannerModel> banners = [];

  final BannerServices _bannerServices = BannerServices();


  Future<void> fetchBanners() async {
    banners = await _bannerServices.getBanners();
    notifyListeners();
  }

}