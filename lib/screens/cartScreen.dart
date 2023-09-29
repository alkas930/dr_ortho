// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:drortho/constants/imageconstants.dart';
import 'package:drortho/constants/sizeconstants.dart';
import 'package:drortho/screens/codScreen.dart';
import 'package:drortho/screens/tabBarScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../components/searchcomponent.dart';
import '../components/starRating.dart';
import '../constants/apiconstants.dart';
import '../constants/colorconstants.dart';
import '../constants/stringconstants.dart';
import '../models/cartModel.dart';
import '../providers/cartProvider.dart';
import '../providers/homeProvider.dart';
import '../routes.dart';
import '../utilities/apiClient.dart';
import 'package:html/parser.dart';

import '../utilities/loadingWrapper.dart';

class CartScreen extends StatefulWidget {
  final bool isScreen;
  final VoidCallback? onHomeNavigate;
  const CartScreen({super.key, required this.isScreen, this.onHomeNavigate});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
//RAZORPAY
  final _razorpay = Razorpay();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.getUser();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body?.text).documentElement!.text;
    return parsedString;
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

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    if (widget.isScreen) {
      return LoadingWrapper(
          child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SearchComponent(
              isBackEnabled: true,
            ),
            contentWithoutFrame(homeProvider, width),
          ],
        ),
      ));
    } else {
      return contentWithoutFrame(homeProvider, width);
    }
  }

  openProductDetailScreen(int id, HomeProvider homeProvider) {
    homeProvider.getProductDetails(id);
    homeProvider.getUser();
    Navigator.pushNamed(context, productDetailsRoute);
  }

  Widget contentWithoutFrame(HomeProvider homeProvider, double width) {
    Size size = MediaQuery.of(context).size;
    return Expanded(
      child: Consumer<CartProvider>(builder: (_, cartProvider, __) {
        return cartProvider.cartItems.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: Text(
                      "Subtotal ₹${getTotal(cartProvider.cartItems)}",
                      style: const TextStyle(
                          color: bottomBarColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pushNamed(context, codScreen);

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
                      margin:
                          const EdgeInsets.only(top: 8, right: 16, left: 16),
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
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: cartProvider.cartItems.length,
                        itemBuilder: (BuildContext ctx, int idx) {
                          final CartModel cartItem =
                              cartProvider.cartItems[idx];
                          return GestureDetector(
                            onTap: () {
                              openProductDetailScreen(
                                  cartItem.id!, homeProvider);
                            },
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: SizedBox(
                                    height: cartItemHeight,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: size.width / 4.5,
                                          decoration: BoxDecoration(),
                                          child: Image.network(
                                            cartItem.image!,
                                            height: cartItemHeight,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8, top: 8, bottom: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                //RATING AND NAME
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        cartItem.name!,
                                                        style: const TextStyle(
                                                            color:
                                                                bottomBarColor,
                                                            fontSize: 10),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    SmoothStarRating(
                                                      color: startColor,
                                                      borderColor: startColor,
                                                      rating: double.tryParse(
                                                              cartItem
                                                                  .rating!) ??
                                                          0,
                                                      size: 12,
                                                    ),
                                                    Text(
                                                      " ${cartItem.reviewcount} Reviews",
                                                      style: const TextStyle(
                                                          color: bottomBarColor,
                                                          fontSize: 10),
                                                    ),
                                                  ],
                                                ),
                                                //PRICE
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 4,
                                                  ),
                                                  child: RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              "Rs. ${cartItem.onsale == 1 ? cartItem.saleprice : cartItem.regularprice}",
                                                          style: const TextStyle(
                                                              color:
                                                                  bottomBarColor,
                                                              fontSize: 12),
                                                        ),
                                                        if (cartItem.onsale ==
                                                            1) ...[
                                                          TextSpan(
                                                              text:
                                                                  " Rs. ${cartItem.regularprice} ",
                                                              style: const TextStyle(
                                                                  color:
                                                                      strikethroughColor,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough,
                                                                  fontSize: 8))
                                                        ],
                                                      ],
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                                //DESCRIPTION
                                                Text(
                                                  _parseHtmlString(
                                                      cartItem.desc!),
                                                  style: const TextStyle(
                                                    color: bottomBarColor,
                                                    fontSize: 10,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                //BESTSELLER FLAG
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(right: 8),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 4,
                                                                vertical: 2),
                                                        decoration: const BoxDecoration(
                                                            color:
                                                                bottomBarColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            2))),
                                                        child: const Text(
                                                          "Bestseller",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10),
                                                        ),
                                                      ),
                                                      const Text(
                                                        "From Dr. Ortho Store",
                                                        style: TextStyle(
                                                            color:
                                                                bottomBarColor,
                                                            fontSize: 10),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    quantityChangeWrapper(
                                                        cartItem, cartProvider),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        cartProvider
                                                            .deleteCartItem(
                                                                cartItem.id!);
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black,
                                                              width: 1,
                                                              style: BorderStyle
                                                                  .solid),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            Radius.circular(50),
                                                          ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 2,
                                                                horizontal: 16),
                                                        child: const Text(
                                                          "Delete",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 10),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Divider(),
                                )
                              ],
                            ),
                          );
                        }),
                  )
                ],
              )
            : emptyCartView(width);
      }),
    );
  }

  Container quantityChangeWrapper(
      CartModel cartItem, CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        border: Border.all(
            color: bottomBarColor, width: 1, style: BorderStyle.solid),
        borderRadius: const BorderRadius.all(
          Radius.circular(50),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Map<String, dynamic> values = cartItem.toMap();
              if (cartItem.quantity! - 1 <= 0) {
                cartProvider.deleteCartItem(cartItem.id!);
              } else {
                values["quantity"] = cartItem.quantity! - 1;
                cartProvider.updateCartItems(
                    CartModel.fromMap(values), cartItem.id);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                color: lightBlueColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                ),
              ),
              child: const Text("-"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              cartItem.quantity.toString(),
            ),
          ),
          GestureDetector(
            onTap: () {
              Map<String, dynamic> values = cartItem.toMap();
              if (cartItem.quantity! + 1 < 6) {
                values["quantity"] = cartItem.quantity! + 1;
                cartProvider.updateCartItems(
                    CartModel.fromMap(values), cartItem.id);
                setState(() {});
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                color: lightBlueColor,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: const Text("+"),
            ),
          )
        ],
      ),
    );
  }

  //EmptyCartView
  Column emptyCartView(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(flex: 1, child: SizedBox.shrink()),
        SizedBox(
          width: width * 0.25,
          child: Image.asset(emptyCartImage),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            emptyCartText,
            style:
                TextStyle(color: bottomBarColor, fontWeight: FontWeight.bold),
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.onHomeNavigate!();
          },
          child: RichText(
            text: const TextSpan(children: [
              TextSpan(
                text: addItemsText,
                style: TextStyle(
                    color: bottomBarColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    fontSize: 10),
              ),
              TextSpan(
                text: toYourCartText,
                style: TextStyle(color: Colors.black, fontSize: 10),
              )
            ]),
          ),
        ),
        const Expanded(flex: 3, child: SizedBox.shrink()),
      ],
    );
  }

  double getTotal(List cartList) {
    double price = 0;

    for (final cartItem in cartList) {
      if (cartItem.onsale! == 1) {
        price += double.tryParse(cartItem.saleprice)!;
        price *= cartItem.quantity;
      } else {
        price += double.tryParse(cartItem.regularprice)!;
        price *= cartItem.quantity;
      }
    }
    return price;
  }
}
