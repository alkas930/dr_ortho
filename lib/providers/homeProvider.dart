// ignore_for_file: file_names, unnecessary_brace_in_string_interps

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:drortho/constants/apiconstants.dart';
import 'package:drortho/utilities/apiClient.dart';

import '../models/userModel.dart';
import '../utilities/databaseProvider.dart';

class HomeProvider extends ChangeNotifier {
  final _provider = ApiClient();
  bool isLoading = false;
  final List products = [];
  final List featuredProducts = [];
  final List categories = [];
  final List carousel = [];
  final List banner = [];
  final List gridItems = [];
  final List blogs = [];
  final List review = [];
  // final List paymentGateways = [];

  final List categoryItems = [];
  final Map productDetails = {};
  final Map productVariation = {};
  final List reviews = [];
  final List videos = [];
  final List orders = [];
  final UserModel user = UserModel();

  HomeProvider() {
    getProducts();
    getFeaturedProducts();
    getCategories();
    getBanners();
    getGridItems();
    getHomeData();
    getBlogs();
    getUserData();
  }

  notifyListenersFromWidget() {
    notifyListeners();
  }

  showLoader() {
    isLoading = true;
    notifyListeners();
  }

  hideLoader() {
    isLoading = false;
    notifyListeners();
  }

  getProducts() async {
    try {
      final List response = await _provider.callGetAPI(productsEndpoint);
      if (response.isNotEmpty) {
        if (products.isNotEmpty) products.clear();
        products.addAll(response);

        notifyListeners();
      }
    } catch (e) {
      if (products.isNotEmpty) {
        products.clear();
        notifyListeners();
      }
      log('\x1B[31mERROR: ${e}\x1B[0m');
    }
  }

  getFeaturedProducts() async {
    try {
      final List response =
          await _provider.callGetAPI(featuredProductsEndpoint);
      if (response.isNotEmpty) {
        if (featuredProducts.isNotEmpty) featuredProducts.clear();
        featuredProducts.addAll(response);
        notifyListeners();
      }
    } catch (e) {
      if (featuredProducts.isNotEmpty) {
        featuredProducts.clear();
        notifyListeners();
      }
      log('\x1B[31mERROR: ${e}\x1B[0m');
    }
  }

  getReview(id) async {
    print('------------------');
    try {
      final response = await ApiClient().callGetAPI(
        getproductReview,
      );
      if (response.isNotEmpty) {
        review.addAll(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  getCategories() async {
    try {
      final List response = await _provider.callGetAPI(categoriesEndpoint);
      if (response.isNotEmpty) {
        if (categories.isNotEmpty) categories.clear();
        categories.addAll(response);
        notifyListeners();
      }
    } catch (e) {
      if (categories.isNotEmpty) {
        categories.clear();
        notifyListeners();
      }
      log('\x1B[31mERROR: ${e}\x1B[0m');
    }
  }

  getBanners() async {
    try {
      final Map response = await _provider.callGetAPI(bannersEndpoint);
      final Map? data = response['data'];
      if (data != null) {
        if (data.containsKey('carousel') &&
            (data['carousel'] as List).isNotEmpty) {
          if (carousel.isNotEmpty) carousel.clear();
          carousel.addAll(data['carousel']);
          notifyListeners();
        }
        if (data.containsKey('banner') && (data['banner'] as List).isNotEmpty) {
          if (banner.isNotEmpty) banner.clear();
          banner.addAll(data['banner']);
          notifyListeners();
        }
      }
    } catch (e) {
      if (carousel.isNotEmpty) {
        carousel.clear();
        notifyListeners();
      }
      log('\x1B[31mERROR: ${e}\x1B[0m');
    }
  }

  getGridItems() async {
    try {
      final List response = await _provider.callGetAPI(gridProductsEndpoint);
      if (response.isNotEmpty) {
        if (gridItems.isNotEmpty) gridItems.clear();
        gridItems.addAll(response);
        notifyListeners();
      }
    } catch (e) {
      if (gridItems.isNotEmpty) {
        gridItems.clear();
        notifyListeners();
      }
      log('\x1B[31mERROR: ${e}\x1B[0m');
    }
  }

  getBlogs() async {
    try {
      final List response = await _provider.callGetAPI(blogEndpoint);
      if (response.isNotEmpty) {
        if (blogs.isNotEmpty) blogs.clear();
        blogs.addAll(response);
        notifyListeners();
      }
    } catch (e) {
      if (blogs.isNotEmpty) {
        blogs.clear();
        notifyListeners();
      }
      log('\x1B[31mERROR: ${e}\x1B[0m');
    }
  }

  getCategoryItems(int id) async {
    isLoading = true;
    notifyListeners();
    if (categoryItems.isNotEmpty) categoryItems.clear();
    try {
      final List response =
          await _provider.callGetAPI("$categoryItemsEndpoint$id");
      if (response.isNotEmpty) {
        categoryItems.addAll(response);
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (categoryItems.isNotEmpty) {
        categoryItems.clear();
      }
      isLoading = false;
      notifyListeners();
      log('\x1B[31mERROR: ${e}\x1B[0m');
    }
  }

  getProductDetails(
    int id,
  ) async {
    isLoading = true;
    notifyListeners();
    if (productDetails.isNotEmpty) productDetails.clear();
    try {
      final Map response =
          await _provider.callGetAPI("$productDetailsEndpoint$id");
      if (response.isNotEmpty) {
        getReview(id);
        productDetails.addAll(response);
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (productDetails.isNotEmpty) {
        productDetails.clear();
      }
      isLoading = false;
      notifyListeners();
      log('\x1B[31mERROR: ${e}\x1B[0m');
    }
  }

  getProductDetailsFromSlug(String slug) async {
    isLoading = true;
    notifyListeners();
    if (productDetails.isNotEmpty) productDetails.clear();
    try {
      final List response =
          await _provider.callGetAPI("$getProductFromSlug$slug");
      if (response.isNotEmpty) {
        productDetails.addAll(response[0]);
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (productDetails.isNotEmpty) {
        productDetails.clear();
      }
      isLoading = false;
      notifyListeners();
      log('\x1B[31mERROR: ${e}\x1B[0m');
    }
  }

  getCouponFromCode(String code) async {
    isLoading = true;
    notifyListeners();
    try {
      final List response = await _provider.callGetAPI("$getCoupon$code");
      if (response.isNotEmpty) {
        log("DATA: $response");
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      // if (productDetails.isNotEmpty) {
      //   productDetails.clear();
      // }
      // isLoading = false;
      notifyListeners();
      log('\x1B[31mERROR: ${e}\x1B[0m');
    }
  }

  getHomeData() async {
    isLoading = true;
    notifyListeners();
    try {
      final Map response = await _provider.callGetAPI(homeEndpoint);
      if (response.containsKey('data')) {
        final Map data = response['data'];
        if (data.containsKey('reviews')) reviews.addAll(data['reviews']);
        if (data.containsKey('videos')) videos.addAll(data['videos']);
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (reviews.isNotEmpty) {
        reviews.clear();
        isLoading = false;
        notifyListeners();
      }
      if (videos.isNotEmpty) {
        videos.clear();
        isLoading = false;
        notifyListeners();
      }
      log('\x1B[31mERROR: ${e}\x1B[0m');
    }
  }

  getUserOrders() async {
    isLoading = true;
    notifyListeners();
    try {
      UserModel user = await DatabaseProvider().retrieveUserFromTable();
      final List response =
          await _provider.callGetAPI("$getUserOrdersEndpoint${user.id}");
      if (response.isNotEmpty) {
        if (orders.isNotEmpty) orders.clear();
        orders.addAll(response);
        notifyListeners();
      }
      isLoading = false;
    } catch (e) {
      if (orders.isNotEmpty) {
        orders.clear();
      }
      isLoading = false;
      notifyListeners();
      log('\x1B[31mERROR: ${e}\x1B[0m');
    }
  }

  getUserData() async {
    try {
      UserModel user = await DatabaseProvider().retrieveUserFromTable();
      if (user.id != null) {
        final Map response =
            await _provider.callGetAPI("$getUserDataEndpoint${user.id}");
        Map address = {};
        address["billing"] = response["billing"];
        address["shipping"] = response["shipping"];
        user.address = jsonEncode(address);
        await DatabaseProvider().updateUserData(user, user.id);
      }
    } catch (e) {
      log('\x1B[31mERROR: ${e}\x1B[0m');
    }
  }

  getUser() async {
    UserModel user = await DatabaseProvider().retrieveUserFromTable();
    if (user.id != null) {
      this.user.address = user.address;
      this.user.id = user.id;
      this.user.displayName = user.displayName;
      this.user.email = user.email;
      this.user.name = user.name;
      this.user.token = user.token;
    }
  }
}
