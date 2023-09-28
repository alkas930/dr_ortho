import 'dart:developer';

import 'package:drortho/routes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../components/searchcomponent.dart';
import '../constants/colorconstants.dart';
import '../constants/imageconstants.dart';
import '../constants/stringconstants.dart';
import '../providers/homeProvider.dart';
import '../utilities/loadingWrapper.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final Map args = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map;
    return LoadingWrapper(
      child: Scaffold(
        body: Consumer<HomeProvider>(
          builder: (_, homeProvider, __) {
            log("DATA: $args");
            final dateFormatter = DateFormat('d MMMM yyyy');
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SearchComponent(
                  isBackEnabled: true,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const Divider(),
                          actionItem(buyItAgain, () {
                            homeProvider.getProductDetails(
                                args["line_items"][0]["product_id"]);
                            homeProvider.getUser();
                            Navigator.pushNamed(context, productDetailsRoute);
                          }),
                          // const Divider(),
                          // const Padding(
                          //   padding: EdgeInsets.only(top: 8),
                          //   child: Text(
                          //     howsYourItem,
                          //     style: TextStyle(
                          //         color: bottomBarColor,
                          //         fontSize: 2 + 14,
                          //         fontWeight: FontWeight.bold),
                          //   ),
                          // ),
                          // actionItem(writeReview),
                          // const Divider(),
                          // actionItem(videoReview),
                          const Divider(),
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              orderDetails,
                              style: TextStyle(
                                  color: bottomBarColor,
                                  fontSize: 2 + 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Card(
                            elevation: 0,
                            color: orderDetailBackgroundColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Row(
                                        children: [
                                          CardTextItem(orderDate),
                                          CardTextItem(
                                            dateFormatter.format(DateFormat(
                                                    "yyyy-MM-ddTHH:mm:ssZ")
                                                .parseUTC(args["date_created"])
                                                .toLocal()),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Row(
                                        children: [
                                          CardTextItem(orderNumber),
                                          CardTextItem(args["product_id"]),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Row(
                                        children: [
                                          CardTextItem(orderTotal),
                                          CardTextItem(
                                            "\u{20B9} ${args["total"]}",
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // const Divider(),
                          // actionItem(downloadInvoice),
                          const Divider(),
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              paymentInformation,
                              style: TextStyle(
                                  color: bottomBarColor,
                                  fontSize: 2 + 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Card(
                            elevation: 0,
                            color: orderDetailBackgroundColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        paymentMethod,
                                        style: TextStyle(
                                            fontSize: 2 + 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Text(
                                          args["payment_method_title"],
                                          style:
                                              const TextStyle(fontSize: 2 + 10),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              args["status"],
                              style: const TextStyle(
                                color: bottomBarColor,
                                fontSize: 2 + 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Card(
                            elevation: 0,
                            color: orderDetailBackgroundColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [...getItems(args, width)]),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              orderSummary,
                              style: TextStyle(
                                color: bottomBarColor,
                                fontSize: 2 + 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Card(
                            elevation: 0,
                            color: orderDetailBackgroundColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Row(
                                          children: [
                                            CardTextItem(items),
                                            CardTextItem(
                                                "\u{20B9} ${args["total"]}"),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Row(
                                          children: [
                                            CardTextItem(totalBeforeTax),
                                            CardTextItem(
                                                "\u{20B9} ${args["total"]}"),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Row(
                                          children: [
                                            CardTextItem(total),
                                            CardTextItem(
                                                "\u{20B9} ${args["total"]}"),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Row(
                                          children: [
                                            CardTextItemBold(orderTotal),
                                            CardTextItemBold(
                                                "\u{20B9} ${args["total"]}"),
                                          ],
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget actionItem(String text, Function onClick) {
    return GestureDetector(
      onTap: () {
        onClick();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
                child: Text(
              text,
              style: const TextStyle(fontSize: 2 + 12),
            )),
            SizedBox(
              width: 8,
              child: Image.asset(
                rightArrowImage,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getItems(args, width) {
    final List<Widget> widgets = [];
    final List itemsList = args["line_items"];
    for (int i = 0; i < itemsList.length; i++) {
      final item = itemsList[i];
      widgets.add(
        Row(
          children: [
            Image.network(
              item["image"]["src"],
              fit: BoxFit.cover,
              width: (width - 32) * 0.25,
              height: ((width - 32) * 0.25) * .75,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  height: ((width - 32) * 0.25) * .75,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["name"],
                        style: const TextStyle(
                            color: bottomBarColor,
                            fontSize: 2 + 12,
                            fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Row(
                      //   children: [
                      //     SizedBox(
                      //       width: 8,
                      //       height: 8,
                      //       child: Image.asset(
                      //         shareImage,
                      //         fit: BoxFit.contain,
                      //       ),
                      //     ),
                      //     const Padding(
                      //       padding: EdgeInsets.only(left: 8),
                      //       child: Text(
                      //         shareThisItem,
                      //         style: TextStyle(
                      //             color: bottomBarColor,
                      //             fontSize: 2 + 10,
                      //             fontWeight: FontWeight.normal),
                      //       ),
                      //     ),
                      //   ],
                      // )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      if (i + 1 < itemsList.length) {
        widgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
        );
      }
    }

    return widgets;
  }
}

Widget CardTextItem(String text) {
  return Expanded(
      child: Text(
    text,
    style: const TextStyle(fontSize: 2 + 10),
  ));
}

Widget CardTextItemBold(String text) {
  return Expanded(
      child: Text(
    text,
    style: const TextStyle(fontSize: 2 + 12, fontWeight: FontWeight.bold),
  ));
}
