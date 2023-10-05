// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:dynamic_grid_view/dynamic_grid_view.dart';
import '../constants/colorconstants.dart';
import '../constants/stringconstants.dart';
import '../providers/homeProvider.dart';
import '../routes.dart';
import '../utilities/shimmerLoading.dart';

class ItemsGrid extends StatelessWidget {
  final double width;
  final List gridItems;
  final String title;
  final HomeProvider homeProvider;
  final bool isViewAllVisible;
  const ItemsGrid(
      {super.key,
      required this.width,
      required this.gridItems,
      this.title = "",
      required this.homeProvider,
      this.isViewAllVisible = false});

  @override
  Widget build(BuildContext context) {
    openProductDetailScreen(int id) {
      homeProvider.getProductDetails(
        id,
      );
      homeProvider.getUser();
      Navigator.pushNamed(context, productDetailsRoute);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.isEmpty ? orthoticRangeText : title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: bottomBarColor,
                    fontSize: 12),
              ),
              isViewAllVisible
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, allProductsRoute,
                            arguments: {"category": orthoticRangeText});
                      },
                      child: const Text(
                        viewAllText,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: bottomBarColor,
                            fontSize: 12),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        DynamicGridView(
          width: width,
          horizontalPadding: 16,
          dataSet: gridItems,
          child: (context, index) {
            final item = gridItems[index];
            final List images = item['images'];
            return GestureDetector(
              onTap: () {
                openProductDetailScreen(item['id']);
              },
              child: SizedBox(
                child: Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: cardBackgroundColor,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    children: [
                      Expanded(
                        child: Shimmer(
                          child: ShimmerLoading(
                              isLoading: images.isEmpty,
                              child: images.isEmpty
                                  ? Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.white),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Image.network(images[0]['src']),
                                    )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        child: Text(
                          item['name'],
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
