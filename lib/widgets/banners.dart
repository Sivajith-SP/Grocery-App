import 'package:carousel_slider/carousel_slider.dart';
import 'package:grocery_app/models/banner_model.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/provider/banner_provider.dart';
import 'package:provider/provider.dart';

import '../services/banner_services.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
   final bannerProvider = Provider.of<BannerProvider>(context,listen: false);
   await bannerProvider.fetchBanners();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bannerProvider = Provider.of<BannerProvider>(context);

    if (isLoading) {
      return Center(child: CircularProgressIndicator(color:  const Color(0xffFF7A00)));
    }

    if (bannerProvider.banners.isEmpty) {
      return Center(child: Text("No banners available"));
    }
    return CarouselSlider(
      options: CarouselOptions(
        height: 150,
        autoPlay: true,
        enlargeCenterPage: true,
        autoPlayInterval: const Duration(seconds: 3),
      ),
      items: bannerProvider.banners.map((banner) {
        return ClipRRect(
          borderRadius: .circular(15),
          child: Stack(
            fit: .expand,
            children: [
              Image.network(
                banner.image,
                fit: BoxFit.fill,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
              if(banner.title.isNotEmpty)
              Positioned(left:10,bottom:10,child: Text(banner.title,style: TextStyle(color: Colors.white),)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
