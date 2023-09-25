// ignore_for_file: camel_case_types, file_names

import 'package:drortho/constants/colorconstants.dart';
import 'package:flutter/material.dart';

class loadingWrapperWithoutProvider extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  const loadingWrapperWithoutProvider({
    super.key,
    required this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        child,
        if (!isLoading) ...[
          const SizedBox.shrink(),
        ] else ...[
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(color: Colors.black45),
              child: Center(
                child: Container(
                  width: width * 0.25,
                  height: width * 0.25,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: const CircularProgressIndicator(color: themeRed),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
