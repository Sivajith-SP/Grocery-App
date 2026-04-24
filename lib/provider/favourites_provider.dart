import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/favourite_model.dart';
import '../services/favourite_services.dart';
import '../services/cart_services.dart';

class FavouriteProvider with ChangeNotifier {
  final FavouriteServices _favService = FavouriteServices();
  final CartServices _cartService = CartServices();

  // 🔥 REMOVE SINGLE ITEM
  Future<void> removeFavourite(String id) async {
    await _favService.removeFavourite(id);
  }

  // 🔥 ADD ALL (KEEP IN FAVOURITES)
  Future<void> addAllToCart(List<FavouriteModel> favourites) async {
    if (favourites.isEmpty) return;

    await Future.wait(
      favourites.map((item) {
        return _cartService.addToCartProduct(
          CartModel(
            productId: item.productId,
            title: item.title,
            subtitle: item.subtitle,
            image: item.image,
            price: item.price,
            quantity: 1,
          ),
        );
      }),
    );
  }

  // 🔥 MOVE SINGLE ITEM (ADD + REMOVE)
  Future<void> moveToCart(FavouriteModel item) async {
    await _cartService.addToCartProduct(
      CartModel(
        productId: item.productId,
        title: item.title,
        subtitle: item.subtitle,
        image: item.image,
        price: item.price,
        quantity: 1,
      ),
    );

    await _favService.removeFavourite(item.id!);
  }

  // 🔥 MOVE ALL (ADD + REMOVE)
  Future<void> moveAllToCart(List<FavouriteModel> favourites) async {
    if (favourites.isEmpty) return;

    await Future.wait(
      favourites.map((item) {
        return Future.wait([
          _cartService.addToCartProduct(
            CartModel(
              productId: item.productId,
              title: item.title,
              subtitle: item.subtitle,
              image: item.image,
              price: item.price,
              quantity: 1,
            ),
          ),
          _favService.removeFavourite(item.id!),
        ]);
      }),
    );
  }
}