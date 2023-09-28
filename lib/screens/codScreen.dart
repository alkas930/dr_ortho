import 'dart:math';

import 'package:drortho/components/searchcomponent.dart';
import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:drortho/providers/cartProvider.dart';
import 'package:drortho/providers/homeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CodScreen extends StatefulWidget {
  const CodScreen({super.key});

  @override
  State<CodScreen> createState() => _CodScreenState();
}

class _CodScreenState extends State<CodScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // loginUser(String email, String password) async {
    //   try {
    //     homeProvider.showLoader();
    //     final Map response = await _client.callPostAPI(
    //         se, {"username": email, "password": password});

    //     if (response.isNotEmpty) {
    //       if (response.containsKey('token')) {
    //         setSharedPref(false);

    //         await DatabaseProvider().insertUser(
    //           UserModel(
    //               id: int.parse(response["user_id"]),
    //               name: response["user_nicename"],
    //               token: response["token"],
    //               email: response["user_email"],
    //               displayName: response["user_display_name"],
    //               address: ""),
    //         );
    //         cartProvider.cleanCartItems();
    //         homeProvider.getUserData();
    //         Navigator.pushNamedAndRemoveUntil(
    //             context, tabsRoute, (Route<dynamic> route) => false);
    //       } else {
    //         const snackBar = SnackBar(
    //           content: Text('Incorrect username/password'),
    //           // action: SnackBarAction(
    //           //   label: 'Undo',
    //           //   onPressed: () {
    //           //     // Some code to undo the change.
    //           //   },
    //           // ),
    //         );
    //         ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //       }
    //     } else {
    //       const snackBar = SnackBar(
    //         content: Text('Incorrect username/password'),
    //         // action: SnackBarAction(
    //         //   label: 'Undo',
    //         //   onPressed: () {
    //         //     // Some code to undo the change.
    //         //   },
    //         // ),
    //       );
    //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //     }
    //     homeProvider.hideLoader();
    //   } catch (e) {
    //     const snackBar = SnackBar(
    //       content: Text('Incorrect username/password'),
    //       // action: SnackBarAction(
    //       //   label: 'Undo',
    //       //   onPressed: () {
    //       //     // Some code to undo the change.
    //       //   },
    //       // ),
    //     );
    //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //     homeProvider.hideLoader();
    //     log('\x1B[31mERROR: $e\x1B[0m' as num);
    //   }
    // }

    return Scaffold(
      body: Column(
        children: [
          const SearchComponent(
            isBackEnabled: true,
          ),
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 16),
                child: Row(
                  children: [
                    Text(
                      'Select a Delivery method',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ],
                ),
              ),
              // Divider();
              Padding(
                padding: const EdgeInsets.only(top: 30, right: 16, left: 16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: .5),
                            borderRadius: BorderRadius.circular(8)),
                        child: RadioListTile(
                          selectedTileColor: themeRed,
                          // tileColor: _type == 1 ? Colors.transparent : radioTileColor,
                          dense: true,
                          activeColor: radioButtonColor,
                          value: 1,
                          groupValue: '',
                          onChanged: (value) {
                            setState(() {});
                          },
                          title: RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Net Banking',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: .5),
                          borderRadius: BorderRadius.circular(8)),
                      child: RadioListTile(
                        selectedTileColor: themeRed,
                        // tileColor: _type == 1 ? Colors.transparent : radioTileColor,
                        dense: true,
                        activeColor: radioButtonColor,
                        value: 1,
                        groupValue: '',
                        onChanged: (value) {
                          setState(() {});
                        },
                        title: Column(
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Cash on Delivery/Pay on Delivery',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                RichText(
                                    text: const TextSpan(
                                  text: 'Cash, UPI and Card accepted',
                                  style: TextStyle(color: searchBorderColor),
                                )),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: size.height * .04),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                          color: bottomBarColor,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: const Text(
                        proceedToBuyText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
