// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/imageconstants.dart';
import 'package:drortho/models/userModel.dart';
import 'package:drortho/providers/homeProvider.dart';
import 'package:drortho/routes.dart';
import 'package:drortho/utilities/databaseProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    getSharedPref() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool("isGuest");
    }

    navigateNext() async {
      final UserModel user = await DatabaseProvider().retrieveUserFromTable();
      final bool isGuest = await getSharedPref() ?? false;
      if (user.id != null || isGuest == true)
        Navigator.pushNamedAndRemoveUntil(
            context, tabsRoute, (Route<dynamic> route) => false);
      else
        Navigator.pushNamedAndRemoveUntil(
            context, authentication, (Route<dynamic> route) => false);
    }

    homeProviderListener() {
      if (homeProvider.products.isNotEmpty ||
          homeProvider.categories.isNotEmpty) {
        homeProvider.removeListener(homeProviderListener);
        navigateNext();
      }
    }

    homeProvider.addListener(homeProviderListener);

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: width * 0.25),
      decoration: const BoxDecoration(color: splashBG),
      child: Center(
          child: Image.asset(
        logoImage,
        fit: BoxFit.contain,
      )),
    );
  }
}
