// ignore_for_file: file_names

import 'package:drortho/components/itemsGrid.dart';
import 'package:drortho/components/starRating.dart';
import 'package:drortho/routes.dart';
import 'package:drortho/utilities/loadingWrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/searchcomponent.dart';
import '../constants/colorconstants.dart';
import '../constants/imageconstants.dart';
import '../constants/stringconstants.dart';
import '../providers/homeProvider.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({
    super.key,
  });

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  @override
  Widget build(
    BuildContext context,
  ) {
    final double width = MediaQuery.of(context).size.width;
    final Map args = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map;

    openProductDetailScreen(int id, HomeProvider homeProvider) {
      homeProvider.getProductDetails(id);
      homeProvider.getUser();
      Navigator.pushNamed(context, productDetailsRoute);
    }

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
                  List products = homeProvider.products;
                  if (kDebugMode) {
                    print(products);
                  }
                  return homeProvider.products.isNotEmpty
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 20),
                              child: Row(
                                children: [
                                  Text(
                                    args['category'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: bottomBarColor,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: homeProvider.products.length,
                                  itemBuilder: (context, index) {
                                    final item = products[index];
                                    final List images = item['images'];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16, bottom: 10),
                                      child: GestureDetector(
                                        onTap: () {
                                          openProductDetailScreen(
                                              item['id'], homeProvider);
                                        },
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(0.0),
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0),
                                                        color:
                                                            cardBackgroundColor,
                                                      ),
                                                      width: 120,
                                                      height: 150,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Image.network(
                                                          images[0]['src'],
                                                          fit: BoxFit.contain,
                                                        ),
                                                      )),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          item['name'],
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        SmoothStarRating(
                                                          color: startColor,
                                                          borderColor:
                                                              startColor,
                                                          rating: double
                                                                  .tryParse(item[
                                                                      'average_rating']) ??
                                                              0,
                                                          size: 20,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4,
                                                                    vertical:
                                                                        2),
                                                                decoration: const BoxDecoration(
                                                                    color:
                                                                        bottomBarColor,
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(2))),
                                                                child:
                                                                    const Text(
                                                                  "Bestseller",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          2 + 10),
                                                                ),
                                                              ),
                                                              const Text(
                                                                "From Dr. Ortho Store",
                                                                style: TextStyle(
                                                                    color:
                                                                        bottomBarColor,
                                                                    fontSize:
                                                                        2 + 10),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Text(
                                                            "Rs. ${item['regular_price']} ",
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize:
                                                                    2 + 15))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        )

                      // ? SingleChildScrollView(
                      //     padding: const EdgeInsets.only(bottom: 16),
                      //     child: Column(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         Column(
                      //           children: [
                      //             ItemsGrid(
                      //               width: width,
                      //               gridItems: homeProvider.products,
                      //               title: args['category'] ?? "",
                      //               homeProvider: homeProvider,
                      //             ),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                args['category'] ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: bottomBarColor,
                                    fontSize: 12),
                              ),
                            ),
                            const Expanded(flex: 1, child: SizedBox.shrink()),
                            Image.asset(emptyImage),
                            const Center(
                              child: Text(
                                noDataFoundText,
                                style: TextStyle(color: hintTextColor),
                              ),
                            ),
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: const BoxDecoration(
                                    color: bottomBarColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Back to home",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Expanded(flex: 3, child: SizedBox.shrink()),
                          ],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
