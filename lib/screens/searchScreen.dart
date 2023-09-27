// ignore_for_file: file_names, unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:developer';

import 'package:drortho/constants/apiconstants.dart';
import 'package:drortho/main.dart';
import 'package:drortho/utilities/apiClient.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import '../components/searchcomponent.dart';
import '../constants/colorconstants.dart';
import '../constants/imageconstants.dart';
import '../constants/sizeconstants.dart';
import '../constants/stringconstants.dart';
import '../providers/homeProvider.dart';
import '../routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isLoading = false;
  final List searchItemsList = [];
  Timer? _debounce;
  final inputController = TextEditingController();

  searchItems(String query) async {
    setState(() {
      isLoading = true;
    });
    if (searchItemsList.isNotEmpty) searchItemsList.clear();
    try {
      final List response =
          await ApiClient().callGetAPI("${searchEndpoint}${query}");

      if (response.isNotEmpty) {
        setState(() {
          searchItemsList.addAll(response);
        });
      }
      isLoading = false;
    } catch (e) {
      if (searchItemsList.isNotEmpty) {
        searchItemsList.clear();
      }
      log('\x1B[31mERROR: ${e}\x1B[0m');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body?.text).documentElement!.text;
    return parsedString;
  }

  openProductDetailScreen(int id, HomeProvider homeProvider) {
    homeProvider.getProductDetails(id);
    homeProvider.getUser();
    Navigator.pushNamed(context, productDetailsRoute);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final double width = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final double height = MediaQuery.of(context).size.height;
    final Map args = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map;
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SearchComponent(
            isBackEnabled: true,
            isComponent: false,
            searchInputController: inputController,
            onTextChange: (String query) {
              searchItemsList.toList();
              final String findProd = query.trim().replaceAll(' ', '');

              if (query.length >= 3) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  searchItems(findProd);
                });
              }
            },
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: themeRed))
                : searchItemsList.isEmpty
                    ? Column(
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
                                  fontSize: 2 + 12),
                            ),
                          ),
                          const Expanded(flex: 1, child: SizedBox.shrink()),
                          Image.asset(nosearchresultImage),
                          const Center(
                            child: Text(
                              noDataFoundText,
                              style: TextStyle(color: hintTextColor),
                            ),
                          ),
                          const Expanded(flex: 3, child: SizedBox.shrink()),
                        ],
                      )
                    : ListView.builder(
                        itemCount: searchItemsList.length,
                        itemBuilder: (BuildContext ctx, int idx) {
                          final item = searchItemsList[idx];
                          return GestureDetector(
                            onTap: () {
                              openProductDetailScreen(
                                  item["id"]!, homeProvider);
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
                                        Image.network(
                                          item["images"][0]["src"],
                                          width: cartItemHeight,
                                          height: cartItemHeight,
                                          fit: BoxFit.contain,
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
                                                        item["name"],
                                                        style: const TextStyle(
                                                            color:
                                                                bottomBarColor,
                                                            fontSize: 2 + 10),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    // SmoothStarRating(
                                                    //   color: startColor,
                                                    //   borderColor: startColor,
                                                    //   rating: double.tryParse(
                                                    //           cartItem
                                                    //               .rating!) ??
                                                    //       0,
                                                    //   size: 12,
                                                    // ),
                                                    // Text(
                                                    //   " ${cartItem.reviewcount} Reviews",
                                                    //   style: const TextStyle(
                                                    //       color:
                                                    //           bottomBarColor,
                                                    //       fontSize:2+ 10),
                                                    // ),
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
                                                              "Rs. ${item["on_sale"] == true ? item["sale_price"] : item["regular_price"]}",
                                                          style: const TextStyle(
                                                              color:
                                                                  bottomBarColor,
                                                              fontSize: 2 + 12),
                                                        ),
                                                        if (item["on_sale"] ==
                                                            true) ...[
                                                          TextSpan(
                                                              text:
                                                                  " Rs. ${item["regular_price"]} ",
                                                              style: const TextStyle(
                                                                  color:
                                                                      strikethroughColor,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough,
                                                                  fontSize:
                                                                      2 + 8))
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
                                                      item["description"]),
                                                  style: const TextStyle(
                                                    color: bottomBarColor,
                                                    fontSize: 2 + 10,
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
                                                              fontSize: 2 + 10),
                                                        ),
                                                      ),
                                                      const Text(
                                                        "From Dr. Ortho Store",
                                                        style: TextStyle(
                                                            color:
                                                                bottomBarColor,
                                                            fontSize: 2 + 10),
                                                      ),
                                                    ],
                                                  ),
                                                ),
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
          ),
        ],
      ),
    );
  }
}
