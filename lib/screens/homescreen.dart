// ignore_for_file: unused_local_variable

import 'package:drortho/components/carousel.dart';
import 'package:drortho/components/testimonialsCarousel.dart';
import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/imageconstants.dart';
import 'package:drortho/constants/sizeconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:drortho/routes.dart';
import 'package:drortho/utilities/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_iframe/flutter_html_iframe.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;

import 'package:provider/provider.dart';

import '../components/itemsGrid.dart';
import '../providers/homeProvider.dart';
import '../utilities/shimmerLoading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    notificationService.requestNotificationPermission();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    //notificationService.isTokenRefresh();
    notificationService.getDeviceToken().then((value) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    openProductDetailScreen(int id, HomeProvider homeProvider) {
      homeProvider.getProductDetails(id);
      homeProvider.getUser();
      Navigator.pushNamed(context, productDetailsRoute);
    }

    getYoutubeID(String url) {
      final regex = RegExp(
        r"https?:\/\/(?:[0-9A-Z-]+\.)?(?:youtu\.be\/|youtube(?:-nocookie)?\.com\S*?[^\w\s-])([\w-]{11})(?=[^\w-]|$)(?![?=&+%\w.-]*(?:[^<>]*>|<\/a>))[?=&+%\w.-]*",
        caseSensitive: false,
      );

      try {
        if (regex.hasMatch(url)) {
          // print('${url} and ${HomeProvider().videos} and ${regex}');
          return regex.firstMatch(url)!.group(1);
        }
      } catch (e) {
        return "";
      }
    }

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Consumer<HomeProvider>(
          builder: (_, homeProvider, __) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                topCategoriesBar(homeProvider.categories, homeProvider),
                Stack(
                  children: [
                    Carousel(
                      width: width,
                      itemList: homeProvider.carousel,
                      onClick: (id) {
                        openProductDetailScreen(id, homeProvider);
                      },
                    ),
                    cardListing(homeProvider.featuredProducts, homeProvider,
                        openProductDetailScreen),
                  ],
                ),
                youtubeListing(homeProvider, getYoutubeID),
                homeProvider.banner.isNotEmpty && homeProvider.banner[0] != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: () {
                            openProductDetailScreen(
                                int.parse(homeProvider.banner[0]['id']),
                                homeProvider);
                          },
                          child: Image.network(
                            homeProvider.banner[0]['banner'],
                            fit: BoxFit.cover,
                            height: homeAdHeight,
                            width: width,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                newArrivals(homeProvider.products, homeProvider,
                    openProductDetailScreen),
                ItemsGrid(
                  width: width,
                  gridItems: homeProvider.gridItems,
                  homeProvider: homeProvider,
                  isViewAllVisible: true,
                ),
                TestimonialsCarousel(
                  width: width,
                  itemList: homeProvider.reviews,
                ),
                homeProvider.banner.length >= 2 &&
                        homeProvider.banner[0] != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: () {
                            openProductDetailScreen(
                                int.parse(homeProvider.banner[1]['id']),
                                homeProvider);
                          },
                          child: Image.network(
                            homeProvider.banner[1]['banner'],
                            fit: BoxFit.cover,
                            height: homeAdHeight,
                            width: width,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                Container(
                  height: whychooseusCardHeight,
                  width: width,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(whyusbgImage),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Text(
                          whyDrOrtho,
                          style: TextStyle(
                              color: bottomBarColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          whychooseusItem(ayurvedaImage, ayurvedaText),
                          whychooseusItem(authenticImage, authenticityText),
                          whychooseusItem(
                              resultOrientedImage, resultOrientedText),
                          whychooseusItem(chemicalsImage, noChemicalsText),
                        ],
                      )
                    ],
                  ),
                ),
                homeProvider.blogs.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              blogText,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: bottomBarColor,
                                  fontSize: 12),
                            ),
                          ),
                          SizedBox(
                            height: blogHeight,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(right: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: homeProvider.blogs.length,
                              itemBuilder: (ctx, index) {
                                const wrapperWidth =
                                    (blogHeight * (4 / 3)) - 16;
                                final Map blogData = homeProvider.blogs[index];
                                final String htmlContent =
                                    blogData['content']['rendered'];
                                dom.Document document =
                                    htmlparser.parse(htmlContent);

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, webviewRoute,
                                        arguments: {"url": blogData["link"]});
                                  },
                                  child: Container(
                                    width: wrapperWidth,
                                    margin: const EdgeInsets.only(left: 16),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5)),
                                            child: Image.network(
                                              document
                                                  .getElementsByTagName("img")
                                                  .first
                                                  .attributes["src"]!,
                                              fit: BoxFit.cover,
                                              width: wrapperWidth,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: SizedBox(
                                            height: blogHeight * 0.25,
                                            child: Text(
                                              blogData['title']['rendered'] ??
                                                  "",
                                              style: const TextStyle(
                                                  color: bottomBarColor,
                                                  fontSize: 2 + 10),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink()
              ],
            );
          },
        ),
      ),
    );
  }

  Widget whychooseusItem(String image, String text) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: whychooseusCardHeight / 4,
            height: whychooseusCardHeight / 4,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                border: Border.all(
                    width: 1.2,
                    style: BorderStyle.solid,
                    color: bottomBarColor)),
            child: Image.asset(
              image,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
            child: Text(
              text,
              style: const TextStyle(color: bottomBarColor, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget youtubeListing(
      HomeProvider homeProvider, String? getYoutubeID(String url)) {
    return homeProvider.videos.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  youtubeVideosText,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: bottomBarColor,
                      fontSize: 12),
                ),
              ),
              SizedBox(
                height: youtubeCardHeight,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: homeProvider.videos.length,
                  itemBuilder: (ctx, index) {
                    String youtubeframe =
                        '<iframe width="${(youtubeCardHeight * (16 / 9)) + 16}" height="$youtubeCardHeight" src="https://www.youtube.com/embed/${getYoutubeID(homeProvider.videos[index])}" frameborder="0"></iframe>';

                    return Container(
                      clipBehavior: Clip.hardEdge,
                      width: (youtubeCardHeight * (16 / 9)) + 16,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(5)),
                      margin: const EdgeInsets.only(left: 16),
                      child: Html(
                        data: youtubeframe,
                        extensions: const [IframeHtmlExtension()],
                        style: {
                          '#': Style(
                            margin: Margins.zero,
                            fontSize: FontSize(8),
                            maxLines: 1,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
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
                      fontSize: 12),
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
                          left: index == 0 ? 16 : 4,
                          right: 4,
                        ),
                        width: homeNewArrialsHeight / 1.5,
                        height: homeNewArrialsHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: cardBackgroundColor,
                          ),
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
                                              padding: const EdgeInsets.all(8),
                                              child: Image.network(
                                                images[0]['src'],
                                                fit: BoxFit.fitWidth,
                                              ),
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
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
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

  Widget cardListing(List products, HomeProvider homeProvider,
      Function openProductDetailScreen) {
    return products.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(
                top: homeBannerHeight - (homeBannerHeight * 0.125)),
            child: SizedBox(
              height: homeCardHeight,
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
                      margin:
                          EdgeInsets.only(left: index == 0 ? 16 : 4, right: 4),
                      width: homeCardHeight,
                      height: homeCardHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: cardBackgroundColor,
                        ),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Expanded(
                                  child: Shimmer(
                                    child: ShimmerLoading(
                                        isLoading: images.isEmpty,
                                        child: images.isEmpty
                                            ? Container(
                                                decoration: const BoxDecoration(
                                                    color: cardBackgroundColor),
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Image.network(
                                                    images[0]['src']),
                                              )),
                                  ),
                                ),
                                Text(
                                  product['name'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            // Positioned(
                            //   top: 0,
                            //   left: 0,
                            //   child: Container(
                            //     width: 16,
                            //     height: 16,
                            //     padding: const EdgeInsets.all(4),
                            //     decoration: const BoxDecoration(
                            //         color: bottomBarColor,
                            //         borderRadius: BorderRadius.only(
                            //             bottomRight: Radius.circular(5))),
                            //     child: Image.asset(
                            //       favouriteImage,
                            //       fit: BoxFit.contain,
                            //     ),
                            //   ),
                            // ),
                            product['on_sale']
                                ? Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      height: 16,
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                          color: themeRed,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(5))),
                                      child: FittedBox(
                                        child: Text(
                                          "${(((int.parse(product['regular_price']) - int.parse(product['sale_price'])) / int.parse(product['regular_price'])) * 100).toStringAsFixed(0)}% off"
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget topCategoriesBar(List categories, HomeProvider homeProvider) {
    return categories.isNotEmpty
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: categoryItemHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final categoryItem = categories[index];
                return GestureDetector(
                  onTap: () {
                    homeProvider.getCategoryItems(categoryItem['id']);
                    Navigator.pushNamed(context, categoryItemRoute,
                        arguments: {"category": categoryItem['name'] ?? ""});
                  },
                  child: Container(
                    margin:
                        EdgeInsets.only(left: index == 0 ? 16 : 4, right: 4),
                    width: 70,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            categoryItem['image']['src'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          categoryItem['name'] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        : const SizedBox.shrink();
  }
}
