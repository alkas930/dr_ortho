import 'dart:developer';

import 'package:drortho/components/searchcomponent.dart';
import 'package:drortho/constants/apiconstants.dart';
import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:drortho/providers/homeProvider.dart';
import 'package:drortho/utilities/apiClient.dart';
import 'package:flutter/material.dart';

class CodScreen extends StatefulWidget {
  const CodScreen({super.key});

  @override
  State<CodScreen> createState() => _CodScreenState();
}

class _CodScreenState extends State<CodScreen> {
  List paymentGateway = [];
  bool isLoading = true;

  getCodPayment() async {
    try {
      final List response = await ApiClient().callGetAPI(codEndpoint);
      if (response.isNotEmpty) {
        setState(() {
          paymentGateway = response;
          isLoading = false;
        });
      }
    } catch (e) {
      if (paymentGateway.isNotEmpty) {
        paymentGateway.clear();
      }
      log('\x1B[31mERROR: $e\x1B[0m');
    }
  }

  List<Widget> getGateways(List data) {
    int i = 0;
    List<Widget> container = [];
    while (i < data.length) {
      if (data[i]['enabled'] == false) {
        i = i + 1;

        continue;
      }
      container.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(width: .4),
                borderRadius: BorderRadius.circular(8)),
            child: RadioListTile(
              tileColor: Colors.white,
              // tileColor:
              //     _type == 1 ? Colors.transparent : radioTileColor,
              // dense: true,
              activeColor: radioButtonColor,
              value: 1,
              groupValue: '',
              onChanged: (value) {
                setState(() {});
              },
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: data[i]['title'],
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      i = i + 1;
    }
    return container;
  }

  @override
  void initState() {
    getCodPayment();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SearchComponent(),
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Row(
              children: [
                Text(
                  'Select a payment method',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
              ],
            ),
          ),
          isLoading
              ? const Center(
                  heightFactor: 15,
                  child: CircularProgressIndicator(
                    color: themeRed,
                  ))
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: .4),
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 16),
                      child: Column(
                        children: [
                          Column(
                            children: getGateways(paymentGateway),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              // if (homeProvider.user.id != null) {
                              //   if (isAddressAvailable(homeProvider)) {
                              //     createOrder(homeProvider, cartProvider.cartItems,
                              //         cartProvider);
                              //   } else {
                              //     final snackBar = SnackBar(
                              //       content:
                              //           const Text('Please update address to continue'),
                              //       action: SnackBarAction(
                              //         label: 'Click here',
                              //         onPressed: () {
                              //           Navigator.push(
                              //               context,
                              //               MaterialPageRoute(
                              //                   builder: (context) =>
                              //                       const TabBarScreen(
                              //                         param: 1,
                              //                       )));
                              //         },
                              //       ),
                              //     );
                              //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              //   }
                              // } else {
                              //   final snackBar = SnackBar(
                              //     content: const Text('Please continue login to buy'),
                              //     action: SnackBarAction(
                              //       label: 'Click here',
                              //       onPressed: () {
                              //         Navigator.pushNamed(context, authentication);
                              //       },
                              //     ),
                              //   );
                              //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              // }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                top: 20,
                              ),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: const BoxDecoration(
                                  color: bottomBarColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: const Text(
                                continueText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 13, horizontal: 32),
                            child: Text(
                              termsText,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
