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

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return LoadingWrapper(
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SearchComponent(
              isBackEnabled: true,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                yourOrders,
                style: TextStyle(
                    color: bottomBarColor,
                    fontSize: 2 + 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Consumer<HomeProvider>(builder: (_, homeProvider, __) {
              return Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.vertical,
                  itemCount: homeProvider.orders.length,
                  itemBuilder: (ctx, index) {
                    final orderItem = homeProvider.orders[index];
                    final dateFormatter = DateFormat('d MMMM yyyy');
                    final List itemsList = orderItem["line_items"];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, orderDetailRoute,
                            arguments: homeProvider.orders[index]);
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              getImages(itemsList, width),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: SizedBox(
                                    height: ((width - 32) * 0.25) * .75,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          itemsList[0]["name"],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 2 + 10),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "Purchased on ${dateFormatter.format(DateFormat("yyyy-MM-ddTHH:mm:ssZ").parseUTC(orderItem["date_created"]).toLocal())}",
                                          style: const TextStyle(
                                              color: strikethroughColor,
                                              fontSize: 2 + 10),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 8,
                                child: Image.asset(
                                  rightArrowImage,
                                  fit: BoxFit.contain,
                                ),
                              )
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            })
          ],
        ),
      ),
    );
  }

  Widget getImages(List itemsList, double width) {
    Widget images = const SizedBox.shrink();
    if (itemsList.isNotEmpty) {
      if (itemsList.length == 1) {
        final widthCalc = ((width - 32) * 0.25);
        final heightCalc = (((width - 32) * 0.25) * .75);
        images = Image.network(
          itemsList[0]["image"]["src"],
          fit: BoxFit.cover,
          width: widthCalc,
          height: heightCalc,
        );
      } else if (itemsList.length == 2) {
        final widthCalc = ((width - 32) * 0.25) / 2;
        final heightCalc = (((width - 32) * 0.25) * .75);
        images = Row(
          children: [
            Image.network(
              itemsList[0]["image"]["src"],
              fit: BoxFit.cover,
              width: widthCalc,
              height: heightCalc,
            ),
            Image.network(
              itemsList[1]["image"]["src"],
              fit: BoxFit.cover,
              width: widthCalc,
              height: heightCalc,
            )
          ],
        );
      } else if (itemsList.length == 3) {
        final widthCalc = ((width - 32) * 0.25) / 2;
        final heightCalc = (((width - 32) * 0.25) * .75) / 2;
        images = Column(
          children: [
            Row(
              children: [
                Image.network(
                  itemsList[0]["image"]["src"],
                  fit: BoxFit.cover,
                  width: widthCalc,
                  height: heightCalc,
                ),
                Image.network(
                  itemsList[1]["image"]["src"],
                  fit: BoxFit.cover,
                  width: widthCalc,
                  height: heightCalc,
                )
              ],
            ),
            Row(
              children: [
                Image.network(
                  itemsList[2]["image"]["src"],
                  fit: BoxFit.cover,
                  width: widthCalc,
                  height: heightCalc,
                ),
              ],
            ),
          ],
        );
      } else {
        final widthCalc = ((width - 32) * 0.25) / 2;
        final heightCalc = (((width - 32) * 0.25) * .75) / 2;
        images = Column(
          children: [
            Row(
              children: [
                Image.network(
                  itemsList[0]["image"]["src"],
                  fit: BoxFit.cover,
                  width: widthCalc,
                  height: heightCalc,
                ),
                Image.network(
                  itemsList[1]["image"]["src"],
                  fit: BoxFit.cover,
                  width: widthCalc,
                  height: heightCalc,
                )
              ],
            ),
            Row(
              children: [
                Image.network(
                  itemsList[2]["image"]["src"],
                  fit: BoxFit.cover,
                  width: widthCalc,
                  height: heightCalc,
                ),
                SizedBox(
                  width: widthCalc,
                  height: heightCalc,
                  child: Center(
                      child: Text(
                    "+${itemsList.length - 3}",
                    style: const TextStyle(fontSize: 14, color: bottomBarColor),
                  )),
                )
              ],
            ),
          ],
        );
      }
    }

    return images;
  }
}
