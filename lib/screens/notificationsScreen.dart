import 'package:drortho/constants/imageconstants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/searchcomponent.dart';
import '../constants/colorconstants.dart';
import '../constants/stringconstants.dart';
import '../providers/homeProvider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map args = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map;

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const SearchComponent(),
        Expanded(
          child: Consumer<HomeProvider>(
            builder: (_, homeProvider, __) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      args['category'] ?? "",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: bottomBarColor,
                          fontSize: 12),
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox.shrink()),
                  Image.asset(nonotificationsImage),
                  const Center(
                    child: Text(
                      noDataFoundText,
                      style: TextStyle(color: hintTextColor),
                    ),
                  ),
                  const Expanded(flex: 3, child: SizedBox.shrink()),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
