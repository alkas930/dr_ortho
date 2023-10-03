import 'package:drortho/screens/allProducts.dart';
import 'package:drortho/screens/authentication.dart';
import 'package:drortho/screens/cartScreen.dart';
import 'package:drortho/screens/categoryItemsScreen.dart';
import 'package:drortho/screens/codScreen.dart';
import 'package:drortho/screens/forgotPasswordScreen/forgotPassword.dart';
import 'package:drortho/screens/forgotPasswordScreen/sendCode.dart';
import 'package:drortho/screens/forgotPasswordScreen/verifyCode.dart';
import 'package:drortho/screens/orderDetailScreen.dart';
import 'package:drortho/screens/ordersScreen.dart';
import 'package:drortho/screens/productDetails.dart';
import 'package:drortho/screens/qrScanner.dart';
import 'package:drortho/screens/searchScreen.dart';
import 'package:drortho/screens/splashScreen.dart';
import 'package:drortho/screens/tabBarScreen.dart';
import 'package:drortho/screens/webview.dart';
import 'package:drortho/screens/profileScreen.dart';
import 'package:flutter/material.dart';

const initialRoute = "/";
const authentication = "/authentication";
const profileScreen = "/profileScreen";
const categoryItemRoute = "/categoryItem";
const allProductsRoute = "/allProducts";
const ordersRoute = "/orders";
const orderDetailRoute = "/orderDetail";
const productDetailsRoute = "/productDetails";
const cartScreenRoute = "/cartScreenRoute";
const tabsRoute = "/tabs";
const searchScreen = "/searchSceeen";
const webviewRoute = "/webview";
const qrScannerRoute = "/qrScanner";
const codScreen = "/codScreen";
const forgotPassword = "/forgotpassword";
const sendCode = "/sendCode";
const verifyCode = "/verifyCode";

final routes = {
  initialRoute: (context) => const SplashScreen(),
  authentication: (context) => const AuthenticationScreen(),
  profileScreen: (context) => const ProfileScreen(),
  categoryItemRoute: (context) => const CategoryItemsScren(),
  cartScreenRoute: (context) => CartScreen(
        isScreen: true,
        onHomeNavigate: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
  ordersRoute: (context) => const OrderScreen(),
  orderDetailRoute: (context) => const OrderDetailScreen(),
  productDetailsRoute: (context) => const ProductDetails(),
  tabsRoute: (context) => const TabBarScreen(),
  webviewRoute: (context) => const WebviewScreen(),
  codScreen: (context) => const CodScreen(
        isScreen: true,
      ),
  forgotPassword: (context) => const ForgotPassword(),
  sendCode: (context) => const SendCode(),
  verifyCode: (context) => const VerifyCode(),
  searchScreen: (context) => const SearchScreen(),
  allProductsRoute: (context) => const AllProductsScreen(),
  qrScannerRoute: (context) => const QrScanner(),
};
