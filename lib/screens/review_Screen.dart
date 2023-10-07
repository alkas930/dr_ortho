import 'dart:io';

import 'package:drortho/components/searchcomponent.dart';
import 'package:drortho/components/starRating.dart';
import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/imageconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:drortho/utilities/loadingWrapper.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    super.key,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  File? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return LoadingWrapper(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            const SearchComponent(
              isBackEnabled: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: size.height,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                                height: 50,
                                width: 50,
                                child: Image(
                                  image: AssetImage(
                                    logoImage,
                                  ),
                                )),
                            const Text(
                              rateText,
                              style: TextStyle(
                                  color: bottomBarColor,
                                  fontSize: 2 + 12,
                                  fontWeight: FontWeight.w400),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  SmoothStarRating(
                                    color: startColor,
                                    borderColor: startColor,
                                    // rating: double.tryParse(
                                    //         product[
                                    //             'average_rating']
                                    //             ) ??
                                    //     0,
                                    size: 25,
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                titleReviewText,
                                style: TextStyle(
                                    color: bottomBarColor,
                                    fontSize: 2 + 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            const TextField(
                              decoration: InputDecoration(
                                  hintText: hintTitleText,
                                  hintStyle: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.only(left: 10)),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                writeReviewText,
                                style: TextStyle(
                                    color: bottomBarColor,
                                    fontSize: 2 + 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            const TextField(
                              maxLines: 4,
                              decoration: InputDecoration(
                                // contentPadding:
                                //     EdgeInsets.symmetric(horizontal: 7),
                                hintText: hintWriteText,
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14,
                                ),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 10, top: 10),
                              child: Text(
                                sharePhotoText,
                                style: TextStyle(
                                    color: bottomBarColor,
                                    fontSize: 2 + 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            DottedBorder(
                              color: const Color.fromARGB(255, 187, 182, 182),
                              dashPattern: const [6, 4],
                              child: InkWell(
                                onTap: () => _getImage(),
                                child: Container(
                                  height: size.height / 8,
                                  width: size.width,
                                  color: cardBackgroundColor,
                                  child: Center(
                                      child: _image == null
                                          ? Icon(
                                              Icons.add_a_photo_outlined,
                                              color: Colors.grey,
                                            )
                                          : Image.file(_image!)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: .5,
                                  color: const Color.fromARGB(
                                      255, 187, 182, 182))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 38,
                                  width: size.width / 3,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border.all(
                                          width: .3,
                                          color: const Color.fromARGB(
                                              255, 187, 182, 182)),
                                      boxShadow: const <BoxShadow>[
                                        BoxShadow(
                                            blurStyle: BlurStyle.outer,
                                            blurRadius: 1,
                                            color: Color.fromARGB(
                                                255, 187, 182, 182))
                                      ],
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Center(
                                      child: Text(
                                    'Submit',
                                    style: TextStyle(
                                        color: bottomBarColor,
                                        fontSize: 2 + 15,
                                        fontWeight: FontWeight.w400),
                                  )),
                                ),
                                Container(
                                  height: 38,
                                  width: size.width / 3,
                                  decoration: BoxDecoration(
                                      color: startColor,
                                      // boxShadow: const <BoxShadow>[
                                      //   BoxShadow(
                                      //       blurStyle: BlurStyle.outer, blurRadius: 1)
                                      // ],
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Center(
                                      child: Text(
                                    'Next',
                                    style: TextStyle(
                                        color: bottomBarColor,
                                        fontSize: 2 + 15,
                                        fontWeight: FontWeight.w400),
                                  )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
