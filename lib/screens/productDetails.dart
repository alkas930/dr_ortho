// ignore_for_file: no_logic_in_create_state, avoid_print, unnecessary_brace_in_string_interps, use_build_context_synchronously, unused_local_variable, unused_import

import 'dart:developer';

import 'package:drortho/components/detailPageCarousel.dart';
import 'package:drortho/constants/apiconstants.dart';
import 'package:drortho/constants/imageconstants.dart';
import 'package:drortho/models/cartModel.dart';
import 'package:drortho/models/userModel.dart';
import 'package:drortho/providers/cartProvider.dart';
import 'package:drortho/screens/tabBarScreen.dart';
import 'package:drortho/utilities/apiClient.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;

import 'package:drortho/utilities/loadingWrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

import '../components/searchcomponent.dart';
import '../constants/colorconstants.dart';
import '../constants/sizeconstants.dart';
import '../constants/stringconstants.dart';
import '../providers/homeProvider.dart';
import '../routes.dart';
import '../utilities/shimmerLoading.dart';
//RAZORPAY
import 'dart:convert';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body?.text).documentElement!.text;
    return parsedString;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final Map args = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map;

    //RAZORPAY
    final _razorpay = Razorpay();

    openProductDetailScreen(int id, HomeProvider homeProvider) {
      homeProvider.getProductDetails(id);
      homeProvider.getUser();
      Navigator.pushNamed(context, productDetailsRoute);
    }

    showSnackbar() {
      const snackBar = SnackBar(
        content: Text('Something went wrong, please try again'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    showAddedToCartSnackbar() {
      final snackBar = SnackBar(
        content: const Text('Item added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            Navigator.pushNamed(context, cartScreenRoute);
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    showBuyToUpdateAddressSnackbar() {
      final snackBar = SnackBar(
        content: const Text('Please update your address to buy'),
        action: SnackBarAction(
          label: 'click Cart',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TabBarScreen(param: 1)));
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    showPaymentSuccessSnackbar() {
      const snackBar = SnackBar(
        content: Text('Order created successfully'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    updateOrder(String status, int id, HomeProvider homeProvider) async {
      final data = {"status": status};
      try {
        homeProvider.showLoader();
        final Map response =
            await ApiClient().callPostAPI("${createOrderEndpoint}/${id}", data);
        showPaymentSuccessSnackbar();
        homeProvider.getUserOrders();
        Navigator.pushNamed(context, ordersRoute);
        homeProvider.hideLoader();
      } catch (e) {
        homeProvider.hideLoader();
        log('\x1B[31mERROR: ${e}\x1B[0m');
      }
    }

    //RAZORPAY
    openRazorPay(HomeProvider homeProvider, String rpOrderId, double total,
        int wcOrderId) {
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
      _handlePaymentSuccess(
        PaymentSuccessResponse response,
      ) {
        // Do something when payment succeeds

        updateOrder("completed", wcOrderId, homeProvider);
      }

      _handlePaymentError(PaymentFailureResponse response) {
        // Do something when payment fails
        updateOrder("failed", wcOrderId, homeProvider);
      }

      _handleExternalWallet(ExternalWalletResponse response) {
        // Do something when an external wallet is selected
      }

      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
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

    createOrder(HomeProvider homeProvider, int id) async {
      homeProvider.showLoader();
      try {
        final data = {
          "customer_id": homeProvider.user.id,
          "payment_method": "razorpay",
          "payment_method_title": "Credit Card/Debit Card/NetBanking",
          "set_paid": true,
          "line_items": [
            {"product_id": id, "quantity": 1}
          ],
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
                response["id"]);
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
        log('\x1B[31mERROR: ${e}\x1B[0m');
      }
    }

    String calcDiscountPercent(salePrice, regularPrice) {
      try {
        final double percent =
            (1 - (double.parse(salePrice) / double.parse(regularPrice))) * 100;
        return "-${percent.toInt().toString()}% ";
      } catch (e) {
        return "0%";
      }
    }

    final Map<String, dynamic> item = {
      "value": 'Not Available',
    };
    return LoadingWrapper(
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SearchComponent(
              isBackEnabled: true,
            ),
            Expanded(
              child: Consumer<HomeProvider>(
                builder: (_, homeProvider, __) {
                  final Map products = homeProvider.productDetails;
                  final Map product = products ?? {};
                  final List images =
                      homeProvider.productDetails['images'] ?? [];
                  return product.isNotEmpty
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            top: 16,
                            bottom: 16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //HEADING
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product['name'] ?? "",
                                        style: const TextStyle(
                                            color: bottomBarColor,
                                            fontSize: 2 + 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //SHORT DESCRIPTION
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, right: 16, left: 16),
                                child: Text(
                                  _parseHtmlString(
                                      product['short_description']),
                                  style: const TextStyle(
                                      color: bottomBarColor, fontSize: 2 + 10),
                                ),
                              ),

                              //BESTSELLER FLAG
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      decoration: const BoxDecoration(
                                          color: bottomBarColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(2))),
                                      child: const Text(
                                        "Bestseller",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 2 + 10),
                                      ),
                                    ),
                                    const Text(
                                      "From Dr. Ortho Store",
                                      style: TextStyle(
                                          color: bottomBarColor,
                                          fontSize: 2 + 10),
                                    ),
                                  ],
                                ),
                              ),
                              // CAROUSEL
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: DetailsCarousel(
                                    width: width - 32, images: images),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: Divider(),
                              ),

                              SelctedSize(
                                product: product,
                                createOrder: createOrder,
                                isAddressAvailable: isAddressAvailable,
                                showBuyToUpdateAddressSnackbar:
                                    showBuyToUpdateAddressSnackbar,
                                showAddedToCartSnackbar:
                                    showAddedToCartSnackbar,
                                calcDiscountPercent: calcDiscountPercent,
                                user: homeProvider.user,
                                homeProvider: homeProvider,
                              ),
                              //FEATURES
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: Divider(),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: featuresSize,
                                            height: featuresSize,
                                            child: Image.asset(
                                              deliveryImage,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              freeDeliveryText,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: bottomBarColor,
                                                  fontSize: 2 + 10),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: featuresSize,
                                            height: featuresSize,
                                            child: Image.asset(
                                              cashImage,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              codText,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: bottomBarColor,
                                                  fontSize: 2 + 10),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: featuresSize,
                                            height: featuresSize,
                                            child: Image.asset(
                                              returnImage,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              refundableText,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: bottomBarColor,
                                                  fontSize: 2 + 10),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: featuresSize,
                                            height: featuresSize,
                                            child: Image.asset(
                                              privacyImage,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              secureTransactionText,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: bottomBarColor,
                                                  fontSize: 2 + 10),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    top: 8.0, right: 16, left: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      productDetails,
                                      style: TextStyle(
                                          color: bottomBarColor,
                                          fontSize: 2 + 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 16),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        "Brand",
                                        style: TextStyle(
                                            color: bottomBarColor,
                                            fontSize: 2 + 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child:
                                          Text(product['meta_data']!.firstWhere(
                                        (product) => product['key'] == 'brand',
                                        orElse: () => item,
                                      )['value']!),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 16),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        "Item Form",
                                        style: TextStyle(
                                            color: bottomBarColor,
                                            fontSize: 2 + 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child:
                                          Text(product['meta_data']!.firstWhere(
                                        (product) =>
                                            product['key'] == 'item_form',
                                        orElse: () => item,
                                      )['value']!),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 16),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        "Material Feature",
                                        style: TextStyle(
                                            color: bottomBarColor,
                                            fontSize: 2 + 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child:
                                          Text(product['meta_data']!.firstWhere(
                                        (product) =>
                                            product['key'] ==
                                            'material_feature',
                                        orElse: () => item,
                                      )['value']!),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 16),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        "Net Quantity",
                                        style: TextStyle(
                                            color: bottomBarColor,
                                            fontSize: 2 + 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child:
                                          Text(product['meta_data']!.firstWhere(
                                        (product) =>
                                            product['key'] == 'net_quantity',
                                        orElse: () => item,
                                      )['value']!),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    right: 16, left: 16, bottom: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'About Details',
                                      style: TextStyle(
                                          color: bottomBarColor,
                                          fontSize: 2 + 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                ),
                                child: TextWrapper(
                                  text: "${product['meta_data']!.firstWhere(
                                        (product) =>
                                            product['key'] == 'about_product',
                                        orElse: () => item,
                                      )['value'].replaceAll('•', '●')}",
                                  style: const TextStyle(color: bottomBarColor),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(),
                              ),

                              newArrivals(homeProvider.products, homeProvider,
                                  openProductDetailScreen),
                            ],
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget newArrivals(List products, HomeProvider homeProvider,
      Function openProductDetailScreen) {
    return products.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  newArrivalsText,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: bottomBarColor,
                      fontSize: 2 + 12),
                ),
              ),
              SizedBox(
                height: homeNewArrialsHeight,
                child: ListView.builder(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final List images = product['images'];
                    return GestureDetector(
                      onTap: () {
                        openProductDetailScreen(product['id'], homeProvider);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            left: index == 0 ? 16 : 4, right: 4),
                        width: homeNewArrialsHeight / 1.5,
                        height: homeNewArrialsHeight,
                        child: Card(
                          color: cardBackgroundColor,
                          clipBehavior: Clip.hardEdge,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Shimmer(
                                  child: ShimmerLoading(
                                      isLoading: images.isEmpty,
                                      child: images.isEmpty
                                          ? Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.white),
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Image.network(
                                                  images[0]['src']),
                                            )),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: Text(
                                          product['name'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 2 + 10,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 4),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            if (product['on_sale']) ...[
                                              TextSpan(
                                                  text:
                                                      "Rs. ${product['regular_price']} ",
                                                  style: const TextStyle(
                                                      color: strikethroughColor,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      fontSize: 2 + 8))
                                            ],
                                            TextSpan(
                                                text:
                                                    "Rs. ${product['on_sale'] ? product['sale_price'] : product['regular_price']}",
                                                style: const TextStyle(
                                                    color: themeRed,
                                                    fontSize: 2 + 12)),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}

class TextWrapper extends StatefulWidget {
  const TextWrapper({Key? key, required this.text, required TextStyle style})
      : super(key: key);

  final String text;

  @override
  State<TextWrapper> createState() => _TextWrapperState();
}

class _TextWrapperState extends State<TextWrapper>
    with TickerProviderStateMixin {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: ConstrainedBox(
              constraints: isExpanded
                  ? const BoxConstraints()
                  : const BoxConstraints(maxHeight: 70),
              child: Text(
                widget.text,
                style: const TextStyle(fontSize: 16),
                softWrap: true,
                overflow: TextOverflow.fade,
              ))),
      isExpanded
          ? OutlinedButton.icon(
              icon: const Icon(Icons.arrow_upward, color: bottomBarColor),
              label: const Text(
                'Read less',
                style: TextStyle(color: bottomBarColor),
              ),
              onPressed: () => setState(() => isExpanded = false))
          : TextButton.icon(
              icon: const Icon(Icons.arrow_downward, color: themeRed),
              label: const Text(
                'Read more',
                style: TextStyle(color: themeRed),
              ),
              onPressed: () => setState(() => isExpanded = true))
    ]);
  }
}

Container quantityChangeWrapper(CartModel cartItem, CartProvider cartProvider) {
  return Container(
    margin: const EdgeInsets.only(right: 16),
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      border:
          Border.all(color: bottomBarColor, width: 1, style: BorderStyle.solid),
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

class SelctedSize extends StatefulWidget {
  final Map product;
  final Function showBuyToUpdateAddressSnackbar;
  final Function isAddressAvailable;
  final Function createOrder;
  final Function showAddedToCartSnackbar;
  final Function calcDiscountPercent;
  final UserModel user;
  final HomeProvider homeProvider;

  const SelctedSize(
      {super.key,
      required this.product,
      required this.showBuyToUpdateAddressSnackbar,
      required this.isAddressAvailable,
      required this.createOrder,
      required this.showAddedToCartSnackbar,
      required this.calcDiscountPercent,
      required this.user,
      required this.homeProvider});

  @override
  State<SelctedSize> createState() => _SelctedSizeState(
      product: product,
      showBuyToUpdateAddressSnackbar: showBuyToUpdateAddressSnackbar,
      isAddressAvailable: isAddressAvailable,
      createOrder: createOrder,
      showAddedToCartSnackbar: showAddedToCartSnackbar,
      calcDiscountPercent: calcDiscountPercent,
      user: user,
      homeProvider: homeProvider);
}

class _SelctedSizeState extends State<SelctedSize> {
  final Map product;
  final Function showBuyToUpdateAddressSnackbar;
  final Function isAddressAvailable;
  final Function createOrder;
  final Function showAddedToCartSnackbar;
  final Function calcDiscountPercent;
  final UserModel user;
  final HomeProvider homeProvider;
  _SelctedSizeState(
      {required this.product,
      required this.showBuyToUpdateAddressSnackbar,
      required this.isAddressAvailable,
      required this.createOrder,
      required this.showAddedToCartSnackbar,
      required this.calcDiscountPercent,
      required this.user,
      required this.homeProvider});

  printval() {
    if (kDebugMode) {}
  }

  var index = 0;
  List item = [1, 2, 3, 4, 5];
  final List<String> _item = ['1', '2', '3', '4', '5'];
  String? _selectedItem = '1';
  bool isLoading = false;
  updateProductVariation(int? id, int? vId) async {
    try {
      final response = await ApiClient()
          .callGetAPI('$productVariationEndPoint${id}/variations/$vId');
      if (response.runtimeType == Map || response.isNotEmpty) {
        Map data = response;
        product['sale_price'] = data['sale_price'];
        product['regular_price'] = data['regular_price'];
        product['stock_status'] = data['stock_status'];
        isLoading = false;
        setState(() {});
      } else {}
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    isLoading = true;
    product['type'] == 'variable'
        ? updateProductVariation(product['id'], product['variations'][0])
        : isLoading = false;
    index = product['variations'].length > 0 ? product['variations'][0] : 0;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    List attributes = product['attributes']!;
    return Column(children: [
      product['type'] == 'variable'
          ? Column(
              children: [
                Column(children: [
                  const Row(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Text(
                          'Select Size :',
                          style: TextStyle(
                              color: bottomBarColor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 11),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              attributes.length,
                              (index1) => Row(
                                children: List.generate(
                                  attributes[index1]['options'].length,
                                  (index2) => Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Material(
                                      borderRadius: BorderRadius.circular(3),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            isLoading = true;
                                            index =
                                                product['variations'][index2];
                                            updateProductVariation(
                                                product['id'],
                                                product['variations'][index2]);
                                          });
                                        },
                                        child: Ink(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            border: Border.all(
                                              color: bottomBarColor,
                                            ),
                                            color: index ==
                                                    product['variations']
                                                        [index2]
                                                ? bottomBarColor
                                                : Colors.transparent,
                                          ),
                                          child: Center(
                                            child: Text(
                                              attributes[index1]['options']
                                                      [index2]
                                                  .toString(),
                                              style: TextStyle(
                                                color: index ==
                                                        product['variations']
                                                            [index2]
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ]),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(),
                ),
              ],
            )
          : const Column(
              children: [],
            ),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: isLoading
            ? const CircularProgressIndicator(
                color: themeRed,
                strokeWidth: 4.0,
                strokeAlign: 0.1,
              )
            : Row(
                children: [
                  product['on_sale']
                      ? const Text(
                          "",
                          // calcDiscountPercent(
                          //     product['sale_price'], product['regular_price']!),
                          style: TextStyle(color: themeRed, fontSize: 2 + 24),
                        )
                      : const SizedBox.shrink(),
                  Text(
                    "Rs. ${product['on_sale'] ? product['sale_price'] : product['regular_price']}",
                    style: const TextStyle(
                        color: bottomBarColor, fontSize: 2 + 24),
                  ),
                ],
              ),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: bottomBarColor, fontSize: 2 + 10),
                children: [
                  const TextSpan(
                    text: "MRP ",
                  ),
                  if (product['on_sale']) ...[
                    TextSpan(
                        text: "Rs. ${product['regular_price']} ",
                        style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 2 + 10))
                  ],
                  const TextSpan(
                      text: "Inclusive Of All Taxes",
                      style:
                          TextStyle(color: bottomBarColor, fontSize: 2 + 10)),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Divider(),
      ),

      //BUTTONS
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              product['stock_status'] == "instock"
                  ? "In Stock"
                  : "Out Of Stock",
              style: TextStyle(
                  fontSize: 2 + 10,
                  color: product['stock_status'] == "instock"
                      ? textGreenColor
                      : themeRed),
            ),
          ),
          // quantityChangeWrapper(cartItem, cartProvider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Container(
              height: 40,
              // width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xffE4E4E4),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Text(
                          'Qty:',
                          style: TextStyle(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              color: bottomBarColor),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: DropdownButton<String>(
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedItem = newValue;
                            });
                          },
                          underline: Container(
                            height: 1,
                            color: const Color(0xffE4E4E4),
                          ),
                          value: _selectedItem,
                          alignment: Alignment.center,
                          borderRadius: BorderRadius.circular(10),
                          items: _item
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                                value: value,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          color: bottomBarColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ));
                          }).toList(),
                        ),
                      )
                    ]),
              ),
            ),
          ),
        ],
      ),
      GestureDetector(
        onTap: () async {
          if (user.id != null) {
            await cartProvider.insertCartItems(
              CartModel(
                  id: product["id"],
                  name: product["name"],
                  desc: product["short_description"],
                  image: product["images"][0]["src"],
                  quantity: int.parse('${_selectedItem}'),
                  regularprice: product["regular_price"],
                  saleprice: product["sale_price"],
                  onsale: product["on_sale"] == true ? 1 : 0,
                  rating: product["average_rating"],
                  reviewcount: product["rating_count"],
                  slug: product['slug']),
            );

            showAddedToCartSnackbar();
          } else {
            final snackBar = SnackBar(
              content: const Text('Please continue login to add to cart'),
              action: SnackBarAction(
                label: 'Click here',
                onPressed: () {
                  Navigator.pushNamed(context, authentication);
                },
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(top: 8, right: 16, left: 16),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
              color: themeRed,
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: const Text(
            addToCartText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 2 + 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      GestureDetector(
        onTap: () async {
          if (user.id != null) {
            if (isAddressAvailable(homeProvider)) {
              createOrder(homeProvider, product['id']);
            } else {
              showBuyToUpdateAddressSnackbar();
            }
          } else {
            final snackBar = SnackBar(
              content: const Text('Please continue login to buy'),
              action: SnackBarAction(
                label: 'Click here',
                onPressed: () {
                  Navigator.pushNamed(context, authentication);
                },
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(top: 8, right: 16, left: 16),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
              color: bottomBarColor,
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: const Text(
            buyNowText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 2 + 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ]);
  }
}
