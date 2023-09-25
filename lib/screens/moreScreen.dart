import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/apiconstants.dart';
import '../constants/colorconstants.dart';
import '../providers/homeProvider.dart';
import '../routes.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List moreList = [
      {
        "text": "Contact us",
        "link": "$baseURL/app-contact-us/",
      },
      {
        "text": "Privacy Policy",
        "link": "$baseURL/privacy-policy/",
      },
      {
        "text": "Terms & Condition",
        "link": "$baseURL/terms-and-condition/",
      },
      {
        "text": "Shipping & Return Policy",
        "link": "$baseURL/refund_returns/",
      },
    ];
    return Expanded(
      child: Consumer<HomeProvider>(
        builder: (_, homeProvider, __) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "More Info",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: bottomBarColor,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: moreList.length,
                  itemBuilder: (BuildContext context, int idx) {
                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, webviewRoute,
                            arguments: {"url": moreList[idx]["link"]});
                      },
                      // leading: Icon(Icons.car_rental),
                      title: Text(
                        moreList[idx]["text"],
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: Colors.black,
                      ),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
