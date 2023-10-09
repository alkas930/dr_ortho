import 'dart:io';
import 'dart:math';

import 'package:drortho/components/searchcomponent.dart';
import 'package:drortho/components/starRating.dart';
import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/imageconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:drortho/utilities/loadingWrapper.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:image_picker/image_picker.dart';

class ReviewScreen extends StatefulWidget {
  final slug;
  final List images;
  const ReviewScreen({
    super.key,
    this.slug,
    required this.images,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState(slug: slug);
}

class _ReviewScreenState extends State<ReviewScreen> {
  final slug;
  List? images;
  _ReviewScreenState({this.slug, this.images});
  final titleController = TextEditingController();
  final writeController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  List<XFile>? imageFileList = [];
  double values = 0.0;

  void selectImages() async {
    final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages!.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
    }
    setState(() {});
  }
  // File? _image;

  // Future<void> _getImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(
  //     source: ImageSource.camera,
  //   );

  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //   }
  // }

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
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 5),
                              child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Image(image: NetworkImage('$images'))),
                            ),
                            const Text(
                              rateText,
                              style: TextStyle(
                                  color: bottomBarColor,
                                  fontSize: 2 + 12,
                                  fontWeight: FontWeight.w400),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  RatingStars(
                                    starColor: startColor,
                                    starSize: 29,
                                    value: values,
                                    onValueChanged: (v) {
                                      setState(() {
                                        values = v;
                                      });
                                    },
                                  )
                                  // SmoothStarRating(
                                  //   color: startColor,
                                  //   borderColor: startColor,
                                  //   // rating: double.tryParse(
                                  //   //         product[
                                  //   //             'average_rating']
                                  //   //             ) ??
                                  //   //     0,
                                  //   size: 29,
                                  // ),
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
                            TextFormField(
                              controller: titleController,
                              decoration: const InputDecoration(
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
                            TextFormField(
                              controller: writeController,
                              maxLines: 4,
                              decoration: const InputDecoration(
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
                            InkWell(
                              onTap: () => selectImages(),
                              child: DottedBorder(
                                color: const Color.fromARGB(255, 187, 182, 182),
                                dashPattern: const [6, 4],
                                child: InkWell(
                                  // onTap: () => selectImages(),
                                  child: Container(
                                    height: max(size.height / 6,
                                        ((20.0) * imageFileList!.length)),
                                    width: size.width,
                                    color: cardBackgroundColor,

                                    child: imageFileList == null
                                        ? const Column(
                                            children: [
                                              Icon(
                                                Icons.add_a_photo,
                                                color: Colors.grey,
                                              ),
                                              Text(
                                                  'Please add photo more the one')
                                            ],
                                          )
                                        : imageFileList!.length > 1 ||
                                                imageFileList == null
                                            ? GridView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    imageFileList!.length,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 3),
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.file(
                                                        File(imageFileList![
                                                                index]
                                                            .path),
                                                        fit: BoxFit.cover),
                                                  );
                                                })
                                            : null,

                                    // child: Center(
                                    //     child: _image == null
                                    //         ? Icon(
                                    //             Icons.add_a_photo_outlined,
                                    //             color: Colors.grey,
                                    //           )
                                    //         : Image.file(
                                    //             _image!,
                                    //             fit: BoxFit.fitWidth,
                                    //           )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            margin: const EdgeInsets.only(
                                top: 8, right: 16, left: 16),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(
                                color: bottomBarColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: const Text(
                              proceedToBuyText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
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

void saveImage() async {}
