import 'dart:convert';
import 'dart:developer';

import 'package:drortho/constants/apiconstants.dart';
import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:drortho/providers/cartProvider.dart';
import 'package:drortho/providers/homeProvider.dart';
import 'package:drortho/routes.dart';
import 'package:drortho/screens/tabBarScreen.dart';
import 'package:drortho/utilities/apiClient.dart';
import 'package:drortho/utilities/loadingWrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class PaymentOptions extends StatefulWidget {
  Function? dismiss;
  PaymentOptions({super.key, this.dismiss});

  @override
  State<PaymentOptions> createState() => PaymentOptionsState(dismiss: dismiss);
}

class PaymentOptionsState extends State<PaymentOptions>
    with SingleTickerProviderStateMixin {
  final Function? dismiss;
  PaymentOptionsState({this.dismiss});
  late AnimationController _controller;

  final _razorpay = Razorpay();
  bool loader = false;

  List paymentGateway = [];
  bool isLoading = true;
  String selectedMethod = '';
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
              tileColor: selectedMethod == data[i]['id']
                  ? radioTileColor
                  : Colors.transparent,
              dense: true,
              activeColor: radioButtonColor,
              value: data[i]['id'],
              groupValue: selectedMethod,
              onChanged: (value) {
                setState(() {
                  selectedMethod = value;
                });
              },
              title: Text(
                data[i]['title'],
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      );
      i = i + 1;
    }
    return container;
  }

  updateOrder(String status, int id, HomeProvider homeProvider,
      CartProvider cartProvider) async {
    final data = {"status": status};
    try {
      homeProvider.showLoader();

      await ApiClient().callPutAPI("$createOrderEndpoint/$id", data);
      showPaymentSuccessSnackbar();
      homeProvider.getUserOrders();
      Navigator.pushNamed(context, ordersRoute);
      homeProvider.hideLoader();
      cartProvider.cleanCartItems();
    } catch (e) {
      homeProvider.hideLoader();
      log('\x1B[31mERROR: $e\x1B[0m');
    }
  }

  createOrder(HomeProvider homeProvider, List cartList,
      CartProvider cartProvider) async {
    homeProvider.showLoader();
    try {
      final data = {
        "customer_id": homeProvider.user.id,
        "payment_method": selectedMethod,
        "payment_method_title": paymentGateway
            .firstWhere((element) => element['id'] == selectedMethod)['title'],
        "set_paid": true,
        "line_items": [],
        "shipping_lines": [
          {
            "method_id": "flat_rate",
            "method_title": "Flat Rate",
            "total": "0.00"
          }
        ]
      };
      Map addressFromDB = jsonDecode(homeProvider.user.address!);
      data["billing"] = addressFromDB["billing"];
      data["shipping"] = addressFromDB["shipping"];
      for (final cartItem in cartList) {
        (data["line_items"] as List<dynamic>)
            .add({"product_id": cartItem.id, "quantity": cartItem.quantity});
      }
      (data["billing"] as Map)["email"] = homeProvider.user.email;
      final Map response =
          await ApiClient().callPostAPI(createOrderEndpoint, data);
      if (response.containsKey("id") &&
          response.containsKey("order_key") &&
          response.containsKey("total")) {
        if (selectedMethod.contains('cod')) {
          updateOrder('completed', response['id'], homeProvider, cartProvider);
        } else {
          double totalPrice = double.parse(response["total"]) * 100;
          final Map razorpayResponse = await ApiClient().createRazorPayOrder(
              totalPrice, response["order_key"], response["id"].toString());
          if (razorpayResponse.containsKey("id")) {
            homeProvider.hideLoader();
            openRazorPay(homeProvider, razorpayResponse["id"], totalPrice,
                response["id"], cartProvider);
          } else {
            homeProvider.hideLoader();
            showSnackbar();
          }
        }
      } else {
        homeProvider.hideLoader();
        showSnackbar();
      }
    } catch (e) {
      homeProvider.hideLoader();
      log('\x1B[31mERROR: $e\x1B[0m');
    }
  }

  showSnackbar() {
    const snackBar = SnackBar(
      content: Text('Something went wrong, please try again'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  showPaymentSuccessSnackbar() {
    const snackBar = SnackBar(
      content: Text('Order created successfully'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  isAddressAvailable(HomeProvider homeProvider) {
    try {
      String address = jsonDecode(homeProvider.user.address!)["billing"]
              ["address_1"]
          .toString();
      if (address.trim().isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  //RAZORPAY
  openRazorPay(HomeProvider homeProvider, String rpOrderId, double total,
      int wcOrderId, CartProvider cartProvider) {
    final options = {
      'key': rzrPayKey,
      'amount': total, //in the smallest currency sub-unit.
      'name': 'Dr Ortho',
      'order_id': rpOrderId, // Generate order_id using Orders API
      'description': homeProvider.productDetails['name'],
      'timeout': 120, // in seconds
      'send_sms_hash': true,
      'external': {
        'wallets': ['paytm']
      },
      'theme': {'color': '#D60007'}
    };
    handlePaymentSuccess(
      PaymentSuccessResponse response,
    ) {
      // Do something when payment succeeds

      updateOrder("completed", wcOrderId, homeProvider, cartProvider);
    }

    handlePaymentError(PaymentFailureResponse response) {
      // Do something when payment fails

      updateOrder("failed", wcOrderId, homeProvider, cartProvider);
    }

    handleExternalWallet(ExternalWalletResponse response) {
      // Do something when an external wallet is selected
    }

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
    _razorpay.open(options);
  }

  @override
  void initState() {
    super.initState();
    getCodPayment();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final homeProvider = Provider.of<HomeProvider>(
      context,
      listen: false,
    );
    Size size = MediaQuery.of(context).size;

    return LoadingWrapper(
      child: Consumer<CartProvider>(builder: (_, cartProvider, __) {
        return SafeArea(
          child: Stack(clipBehavior: Clip.none, children: [
            // Positioned(
            //   top: -60,
            //   right: 12,
            //   child: FloatingActionButton.small(
            //       backgroundColor: Colors.white,
            //       clipBehavior: Clip.antiAlias,
            //       onPressed: () {
            //         // dismiss!();
            //         Navigator.of(context).pop();
            //       },
            //       child: const Icon(
            //         Icons.close,
            //         color: Colors.black,
            //       )),
            // ),
            Container(
              height: size.height * 0.55,
              // height: (paymentGateway.length ?? 2.0) * 100,
              decoration: const BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(left: 16, right: 16, top: 16),
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
                        ],
                      ),
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    isLoading
                        ? const Center(
                            heightFactor: 10,
                            child: CircularProgressIndicator(
                              color: themeRed,
                            ))
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(width: .4),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 16),
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
                                        createOrder(
                                            homeProvider,
                                            cartProvider.cartItems,
                                            cartProvider);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          top: 20,
                                        ),
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: const BoxDecoration(
                                            color: bottomBarColor,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
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
              ),
            ),
          ]),
        );
      }),
    );
  }
}
