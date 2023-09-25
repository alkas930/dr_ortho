import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/imageconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:drortho/routes.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/sizeconstants.dart';

class SearchComponent extends StatelessWidget {
  final bool isBackEnabled;
  final bool isComponent;
  final VoidCallback? onBackPress;

  final Function(String)? onTextChange;
  final TextEditingController? searchInputController;

  const SearchComponent(
      {super.key,
      this.isBackEnabled = false,
      this.onBackPress,
      this.isComponent = true,
      this.onTextChange,
      this.searchInputController});

  

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: themeRed),
      child: SafeArea(
        child: Row(
          children: [
            isBackEnabled
                ? GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      if (onBackPress != null) {
                        onBackPress!();
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: bottomBarColor,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: searchBorderColor)),
                child: GestureDetector(
                  onTap: isComponent
                      ? () {
                          Navigator.pushNamed(context, searchScreen);
                        }
                      : null,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: bottomBarColor,
                      ),
                      Expanded(
                        child: isComponent
                            ? const Text(
                                searchHint,
                                style: TextStyle(
                                    fontSize: 2 + 12, color: hintTextColor),
                              )
                            : TextField(
                                autofocus: true,
                                onChanged: (String query) {
                                  onTextChange?.call(query);
                                },
                                maxLines: 1,
                                controller: searchInputController,
                                decoration: const InputDecoration(
                                  hintText: searchHint,
                                  hintStyle: TextStyle(color: hintTextColor),
                                  focusedBorder: InputBorder.none,
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 8),
                                  isDense: true, // Added this
                                ),
                                style: const TextStyle(fontSize: 2 + 12),
                                textInputAction: TextInputAction.search,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _openScanner(context);
              },
              child: SizedBox(
                  width: searchComponentIcons,
                  height: searchComponentIcons,
                  child: Image.asset(scannerImage)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  _sendEmail();
                },
                child: SizedBox(
                    width: searchComponentIcons,
                    height: searchComponentIcons,
                    child: Image.asset(chatImage)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _openScanner(BuildContext context) {
    Navigator.pushNamed(context, qrScannerRoute);
  }

  _sendEmail() {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'info@orthooil.com',
      queryParameters: {'subject': '', 'body': ''},
    );
    launchUrl(emailLaunchUri);
  }
}
