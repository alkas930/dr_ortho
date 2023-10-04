import 'dart:convert';
import 'dart:developer';

import 'package:drortho/components/searchcomponent.dart';
import 'package:drortho/constants/apiconstants.dart';
import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:drortho/providers/cartProvider.dart';
import 'package:drortho/providers/homeProvider.dart';
import 'package:drortho/routes.dart';
import 'package:drortho/screens/tabBarScreen.dart';
import 'package:drortho/utilities/apiClient.dart';
import 'package:drortho/utilities/loadingWrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CodScreen extends StatefulWidget {
  final bool isScreen;
  const CodScreen({super.key, required this.isScreen});

  @override
  State<CodScreen> createState() => _CodScreenState();
}

class _CodScreenState extends State<CodScreen> {
  //RAZORPAY
  final _razorpay = Razorpay();

  List paymentGateway = [];
  bool isLoading = true;
  int? _type = null;

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
              tileColor: _type == i ? radioTileColor : Colors.transparent,
              dense: true,
              activeColor: radioButtonColor,
              value: i,
              groupValue: _type,
              onChanged: (value) {
                setState(() {
                  _type = int.parse('$value');
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
      Navigator.pushNamed(context as BuildContext, ordersRoute);
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
        "payment_method": "razorpay",
        "payment_method_title": "Credit Card/Debit Card/NetBanking",
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
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar);
  }

  showPaymentSuccessSnackbar() {
    const snackBar = SnackBar(
      content: Text('Order created successfully'),
    );
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar);
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
      // 'prefill': {
      //   'contact': '9123456789',
      //   'email': 'gaurav.kumar@example.com'
      // }
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
    getCodPayment();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    if (widget.isScreen) {
      return LoadingWrapper(
          child: Scaffold(
        body: Column(
          children: [
            OpenContentWithoutFrame(isLoading, homeProvider, isAddressAvailable,
                createOrder, context, getGateways, paymentGateway),
          ],
        ),
      ));
    } else {
      return OpenContentWithoutFrame(
          isLoading,
          homeProvider,
          isAddressAvailable,
          createOrder,
          context,
          getGateways,
          paymentGateway);
    }
  }
}

Widget OpenContentWithoutFrame(bool isLoading, HomeProvider homeProvider,
    isAddressAvailable, createOrder, context, getGateways, paymentGateway) {
  return Expanded(
    child:
        Scaffold(body: Consumer<CartProvider>(builder: (_, cartProvider, __) {
      return Column(
        children: [
          const SearchComponent(
            isBackEnabled: true,
          ),
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
                              if (homeProvider.user.id != null) {
                                if (isAddressAvailable(homeProvider)) {
                                  createOrder(homeProvider,
                                      cartProvider.cartItems, cartProvider);
                                } else {
                                  final snackBar = SnackBar(
                                    content: const Text(
                                        'Please update address to continue'),
                                    action: SnackBarAction(
                                      label: 'Click here',
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const TabBarScreen(
                                                      param: 1,
                                                    )));
                                      },
                                    ),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              } else {
                                final snackBar = SnackBar(
                                  content: const Text(
                                      'Please continue login to buy'),
                                  action: SnackBarAction(
                                    label: 'Click here',
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, authentication);
                                    },
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
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
      );
    })),
  );
}
