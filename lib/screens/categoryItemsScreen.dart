import 'package:drortho/components/itemsGrid.dart';
import 'package:drortho/utilities/loadingWrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/searchcomponent.dart';
import '../constants/colorconstants.dart';
import '../constants/imageconstants.dart';
import '../constants/stringconstants.dart';
import '../providers/homeProvider.dart';

class CategoryItemsScren extends StatelessWidget {
  const CategoryItemsScren({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final Map args = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map;

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
                  return homeProvider.categoryItems.isNotEmpty
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ItemsGrid(
                                width: width,
                                gridItems: homeProvider.categoryItems,
                                title: args['category'] ?? "",
                                homeProvider: homeProvider,
                              ),
                            ],
                          ),
                        )
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
