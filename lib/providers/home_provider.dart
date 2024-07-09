// ignore_for_file: file_names

import 'dart:convert';
import 'dart:math';

import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:drortho/constants/apiconstants.dart';
import 'package:drortho/utilities/api_client.dart';
import 'package:quickalert/quickalert.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/stringconstants.dart';
import '../models/userModel.dart';
import '../utilities/database_provider.dart';

class HomeProvider extends ChangeNotifier {
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailUpdateController = TextEditingController();
  final _provider = ApiClient();
  bool isLoading = false;
  bool isSubmit = false;
  int type = 1;

  final List products = [];
  final List featuredProducts = [];
  final List categories = [];
  final List carousel = [];
  final List banner = [];
  final List gridItems = [];
  final List blogs = [];
  final List review = [];

  final List categoryItems = [];
  final Map productDetails = {};
  final Map productGallery = {};
  final Map productVariation = {};
  final List reviews = [];
  final List videos = [];
  final List orders = [];
  final List taxes = [];

  // List<String> states = [];
  final UserModel user = UserModel();

  HomeProvider() {
    getProducts();
    getFeaturedProducts();
    getCategories();
    getBanners();
    getGridItems();
    getHomeData();
    getBlogs();
  }

  List statesDetails = [
    {"name": 'select state', "shortname": ""},
    {"name": 'Andhra Pradesh', "shortname": "AP"},
    {"name": 'Arunachal Pradesh', "shortname": "AR"},
    {"name": 'Assam', "shortname": "AS"},
    {"name": 'Bihar', "shortname": "BR"},
    {"name": 'Chhattisgarh', "shortname": "CG"},
    {"name": 'Gujarat', "shortname": "GJ"},
    {"name": 'Haryana', "shortname": "HR"},
    {"name": 'Himachal Pradesh', "shortname": "HP"},
    {"name": 'Jammu and Kashmir', "shortname": "JK"},
    {"name": 'Goa', "shortname": "GA"},
    {"name": 'Jharkhand', "shortname": "JH"},
    {"name": 'Karnataka', "shortname": "KA"},
    {"name": 'Kerala', "shortname": "KL"},
    {"name": 'Madhya Pradesh', "shortname": "MP"},
    {"name": 'Maharashtra', "shortname": "MH"},
    {"name": 'Manipur', "shortname": "MN"},
    {"name": 'Meghalaya', "shortname": "ML"},
    {"name": 'Mizoram', "shortname": "MZ"},
    {"name": 'Nagaland', "shortname": "NL"},
    {"name": 'Odisha', "shortname": "OR"},
    {"name": 'Punjab', "shortname": "PB"},
    {"name": 'Rajasthan', "shortname": "RJ"},
    {"name": 'Sikkim', "shortname": "SK"},
    {"name": 'Tamil Nadu', "shortname": "TN"},
    {"name": 'Telangana', "shortname": "TS"},
    {"name": 'Tripura', "shortname": "TR"},
    {"name": 'Uttarakhand', "shortname": "UK"},
    {"name": 'Uttar Pradesh', "shortname": "UP"},
    {"name": 'West Bengal', "shortname": "WB"},
    {"name": 'Andaman and Nicobar Islands', "shortname": "AN"},
    {"name": 'Chandigarh', "shortname": "CH"},
    {"name": 'Dadra and Nagar Haveli', "shortname": "DH"},
    {"name": 'Daman and Diu', "shortname": "DD"},
    {"name": 'Delhi', "shortname": "DL"},
    {"name": 'Lakshadweep', "shortname": "LD"},
    {"name": 'Puducherry', "shortname": "PY"},
  ];

  String selectedState = '';
  String? _selectedShortName;
  String? get selectedShortName => _selectedShortName;

  setSelectedState(String? newState) {
    selectedState = newState.toString();
    notifyListeners(); // Notify listeners of the change
  }

  selectedShortStateName(String? newShortName) {
    _selectedShortName = newShortName;
    notifyListeners(); // Notify listeners of the change
  }

  notifyListenersFromWidget() {
    notifyListeners();
  }

  isSubmited() {
    isSubmit = true;
    notifyListeners();
  }

  isnotSubmited() {
    isSubmit = false;
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

  getProductGallery(id) async {
    try {
      final response = await _provider.callPostAPI(descriptiongallery, {
        "product_id": id,
      });

      if (response['code'] == 200) {
        if (productGallery.isNotEmpty) productGallery.clear();
        productGallery.addAll(response['data']);
        notifyListeners();
      }
    } catch (e) {
      if (productGallery.isNotEmpty) {
        productGallery.clear();
        notifyListeners();
      }
    }
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
    }
  }

  getReview(id) async {
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

  getTaxes() async {
    try {
      final response = await ApiClient().callGetAPI(taxesEndpoint);
      if (response.isNotEmpty) {
        taxes.addAll(response);
        notifyListeners();
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
    }
  }

  getCouponFromCode(String code) async {
    isLoading = true;
    notifyListeners();
    try {
      final List response = await _provider.callGetAPI("$getCoupon$code");
      if (response.isNotEmpty) {
        log("DATA: $response" as num);
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (productDetails.isNotEmpty) {
        productDetails.clear();
      }
      isLoading = false;
      notifyListeners();
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
    }
  }

  Future<bool> getUserOrders() async {
    showLoader();
    try {
      UserModel user = await DatabaseProvider().retrieveUserFromTable();
      final List response =
          await _provider.callGetAPI("$getUserOrdersEndpoint${user.id}");
      if (response.isNotEmpty) {
        if (orders.isNotEmpty) orders.clear();
        orders.addAll(response);
        hideLoader();
        return true;
      } else {
        hideLoader();
        return false;
      }
    } catch (e) {
      if (orders.isNotEmpty) orders.clear();
      hideLoader();

      return false;
    }
  }

  Future getUserData(id, phone, token, context) async {
    try {
      if (id != null) {
        final response = await _provider.callGetAPI("$getUserDataEndpoint$id");
        await DatabaseProvider().cleanUserTable();
        UserModel user = UserModel.fromResponse(response);
        Map address = {};
        address["billing"] = response["billing"];
        address["shipping"] = response["shipping"];
        user.address = jsonEncode(address);
        user.phoneNumber = address['billing']['phone'] ??
            address['shipping']['phone'] ??
            phone;
        user.token = token;
        await DatabaseProvider().insertUser(user);

        Navigator.pushNamedAndRemoveUntil(
          context,
          tabsRoute,
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  bool isEmailValid(String email) {
    final RegExp emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
      multiLine: false,
    );

    return emailRegex.hasMatch(email);
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
    } else {
      this.user.id = null;
    }
  }

  Future<dynamic> loginUser(
      String email, String password, isGoogleAuth, context, number) async {
    // if (isGoogleAuth == true) {
    //   Navigator.pop(context);
    // }
    try {
      showLoader();
      final Map<String, dynamic> response = await ApiClient().callPostAPI(
          loginEndpoint, {"username": email, "password": password});
      if (kDebugMode) {
        print("response on login -------------- $response");
      }
      if (response.isNotEmpty && response.containsKey('token')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isGuest", false);
        await getUserData(
            response['user_id'], number, response['token'], context);
        hideLoader();
      } else if (response['code'].contains("incorrect_password") &&
          isGoogleAuth) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.custom,
          barrierDismissible: true,
          customAsset: 'assets/phone.gif',
          title: 'Please Enter your Password',
          text: email,
          widget: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextFormField(
              maxLines: 1,
              controller: passwordController,
              decoration: const InputDecoration(
                  hintText: passwordHintText,
                  hintStyle: TextStyle(color: hintTextColor),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: themeRed, width: 2),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                      gapPadding: 0),
                  isDense: true,
                  contentPadding: EdgeInsets.all(8)),
              style: const TextStyle(fontSize: 12),
              textInputAction: TextInputAction.done,
              validator: (authResult) =>
                  authResult!.length < 8 || authResult.length > 16
                      ? 'Password should be 8-16 characters.'
                      : null,
            ),
          ),
          animType: QuickAlertAnimType.slideInLeft,
          confirmBtnText: "Submit",
          showConfirmBtn: true,
          onConfirmBtnTap: () async {
            await loginUser(
                email, passwordController.text, false, context, number);
          },
          confirmBtnColor: bottomBarColor,
        );
      } else if (isGoogleAuth &&
          response.containsKey('code') &&
          response['code'].contains("invalid_email")) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext ctx) {
              Widget continueButton = TextButton(
                child: Container(
                  decoration: BoxDecoration(
                      color: bottomBarColor,
                      borderRadius: BorderRadius.circular(7)),
                  child: const Center(
                    child: Text(
                      "New User?",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
                onPressed: () async {
                  final value = await registerUser(
                      email, password, true, context, number);
                  if (value == 1) {
                    await loginUser(email, password, false, context, number);
                  }
                },
              );
              Widget cancleButton = TextButton(
                child: Container(
                  decoration: BoxDecoration(
                      color: bottomBarColor,
                      borderRadius: BorderRadius.circular(7)),
                  child: const Center(
                    child: Text(
                      "Existing User?",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);

                  QuickAlert.show(
                      context: context,
                      type: QuickAlertType.custom,
                      customAsset: 'assets/email.gif',
                      title: 'Please add existing email address',
                      widget: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: TextFormField(
                            maxLines: 1,
                            controller: emailUpdateController,
                            decoration: const InputDecoration(
                                hintText: emailHintText,
                                hintStyle: TextStyle(color: hintTextColor),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: themeRed, width: 2),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    gapPadding: 0),
                                isDense: true,
                                contentPadding: EdgeInsets.all(8)),
                            style: const TextStyle(fontSize: 12),
                            textInputAction: TextInputAction.done,
                            validator: (authResult) {
                              if (!isEmailValid(authResult.toString())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            }),
                      ),
                      animType: QuickAlertAnimType.slideInLeft,
                      confirmBtnText: "Submit",
                      showConfirmBtn: true,
                      onConfirmBtnTap: () async {
                        final value = await registerUser(
                            emailUpdateController.text,
                            password,
                            true,
                            context,
                            number);

                        if (value == 1) {
                          await loginUser(emailUpdateController.text, password,
                              true, context, number);
                        } else {
                          Navigator.pop(context);
                        }
                      });
                },
              );

              return AlertDialog(
                title: const Text("Select Account Type"),
                actions: [cancleButton, continueButton],
                actionsAlignment: MainAxisAlignment.center,
              );
            });
      } else {
        hideLoader();
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              Widget continueButton = TextButton(
                child: Container(
                  width: 70,
                  decoration: BoxDecoration(
                      color: bottomBarColor,
                      borderRadius: BorderRadius.circular(7)),
                  child: const Center(
                    child: Text(
                      "OK",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              );

              return AlertDialog(
                title: const Text("Invalid username or password"),
                actions: [continueButton],
                actionsAlignment: MainAxisAlignment.center,
              );
            });
      }
    } catch (e) {
      hideLoader();
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            Widget continueButton = TextButton(
              child: Container(
                width: 70,
                decoration: BoxDecoration(
                    color: bottomBarColor,
                    borderRadius: BorderRadius.circular(7)),
                child: const Center(
                  child: Text(
                    "OK",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
              },
            );

            return AlertDialog(
              title: const Text("Something Went Wrong, please try later "),
              actions: [continueButton],
              actionsAlignment: MainAxisAlignment.center,
            );
          });
    }
  }

  udpateType(a) {
    type = a;
    notifyListeners();
  }

  Future<dynamic> registerUser(
      String email, String password, isGoogleAuth, context, phone) async {
    try {
      showLoader();
      final Map response = await ApiClient().callPostAPI(registerEndpoint,
          {"email": email, "password": password, "phone": phone});
      print("response -----------------------  $response");
      if (response.isNotEmpty) {
        if (response['code'] == 200) {
          hideLoader();
          if (isGoogleAuth) {
            notifyListeners();
            return 1;
          }
          udpateType(1);
          hideLoader();
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                Widget continueButton = TextButton(
                  child: Container(
                    width: 70,
                    decoration: BoxDecoration(
                        color: bottomBarColor,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Center(
                      child: Text(
                        "OK",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                );
                notifyListeners();

                return AlertDialog(
                  title: const Text(
                      "Registration successfull, please continue login!"),
                  actions: [continueButton],
                  actionsAlignment: MainAxisAlignment.center,
                );
              });
        } else {
          hideLoader();
          if (isGoogleAuth) {
            notifyListeners();

            return 1;
          }

          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                Widget continueButton = TextButton(
                  child: Container(
                    width: 70,
                    decoration: BoxDecoration(
                        color: bottomBarColor,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Center(
                      child: Text(
                        "OK",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                );
                notifyListeners();

                return AlertDialog(
                  title: const Text("User already exists"),
                  actions: [continueButton],
                  actionsAlignment: MainAxisAlignment.center,
                );
              });
        }
      } else {
        hideLoader();

        if (isGoogleAuth) {
          notifyListeners();

          return 2;
        }

        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              Widget continueButton = TextButton(
                child: Container(
                  width: 70,
                  decoration: BoxDecoration(
                      color: bottomBarColor,
                      borderRadius: BorderRadius.circular(7)),
                  child: const Center(
                    child: Text(
                      "OK",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              );
              notifyListeners();

              return AlertDialog(
                title: const Text("Something went wrong, please try again"),
                actions: [continueButton],
                actionsAlignment: MainAxisAlignment.center,
              );
            });
      }
      hideLoader();
    } catch (e) {
      hideLoader();
      notifyListeners();
      if (isGoogleAuth) return 2;

      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            Widget continueButton = TextButton(
              child: Container(
                width: 70,
                decoration: BoxDecoration(
                    color: bottomBarColor,
                    borderRadius: BorderRadius.circular(7)),
                child: const Center(
                  child: Text(
                    "OK",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
              },
            );

            return AlertDialog(
              title: const Text("Internal Server Error"),
              actions: [continueButton],
              actionsAlignment: MainAxisAlignment.center,
            );
          });
    }
  }
}
