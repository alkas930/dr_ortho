// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:io';
import 'dart:math';

import 'package:drortho/components/detailPageCarousel.dart';
import 'package:drortho/components/searchcomponent.dart';
import 'package:drortho/constants/apiconstants.dart';
import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/sizeconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:drortho/models/userModel.dart';
import 'package:drortho/providers/homeProvider.dart';
import 'package:drortho/routes.dart';
import 'package:drortho/screens/productDetails.dart';
import 'package:drortho/utilities/apiClient.dart';
import 'package:drortho/utilities/databaseProvider.dart';
import 'package:drortho/utilities/loadingWrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ReviewScreen extends StatefulWidget {
  final emailInputController;
  final images;
  // final double width;
  final slug;

  final carouselItem;
  const ReviewScreen({
    super.key,
    this.images,
    this.slug,
    this.emailInputController,
    this.carouselItem,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState(
        carouselItem: carouselItem,
        images: images,
        emailInputController: emailInputController,
      );
}

class _ReviewScreenState extends State<ReviewScreen> {
  UserModel user = UserModel();
  final carouselItem;
  final emailInputController;
  int _pageIndex = 0;
  List? images;
  _ReviewScreenState(
      {this.emailInputController, this.carouselItem, this.images});
  final nameController = TextEditingController();
  final writeController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  List<XFile>? imageFileList = [];
  List review = [];
  bool isLoading = true;
  double values = 0.0;
  double? _rating;
  IconData? _selectedIcon;
  getUser() async {
    UserModel user = await DatabaseProvider().retrieveUserFromTable();
    setState(() {
      this.user = user;
    });
  }

  postReview(id) async {
    print(
        '888888888888888888888888888888 ${id} ${writeController.text} ${user.name} ${user.email} ${_rating}');
    try {
      final response = await ApiClient().callPostAPI(
        productReview,
        {
          "product_id": id,
          "review": writeController.text,
          "reviewer": user.name,
          "reviewer_email": user.email,
          "rating": _rating?.toStringAsFixed(1),
        },
      );
      if (kDebugMode) {
        print(response);
      }
      if (response.isNotEmpty) {
        setState(() {});
        await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ProductDetails()),
            (route) => false);
      }

      // if (response.isNotEmpty) {
      //   setState(() {
      //     isLoading = false;
      //     review = response;
      //   });
      // }
    } catch (e) {
      if (review.isNotEmpty) {
        review.clear();
      }
      await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProductDetails()),
          (route) => false);
      print(e);
      rethrow;
    }
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  bool validateAndSave() {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      // Navigator.of(context).pop();
      return true;
    } else {
      return false;
    }
  }

  void selectImages() async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
    }
    setState(() {});
  }

  openProductDetailScreen(int id, HomeProvider homeProvider) {
    homeProvider.getProductDetails(id);
    homeProvider.getUser();
    Navigator.pushNamed(context, productDetailsRoute);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final Map args = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map;

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
              child: Consumer<HomeProvider>(builder: (_, homeProvider, __) {
                final Map products = homeProvider.productDetails;
                final Map product = products ?? {};
                final List images = homeProvider.productDetails['images'] ?? [];

                return SingleChildScrollView(
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
                              // DetailsCarousel(
                              //     slug: product['slug'],
                              //     width: size.width / 2,
                              //     images: images),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                ),
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: PageView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: images.length,
                                    onPageChanged: (value) => setState(() {
                                      _pageIndex = value;
                                    }),
                                    itemBuilder: (context, index) {
                                      final carouselItem = images[index];
                                      return Image.network(
                                        carouselItem['src'],
                                        fit: BoxFit.contain,
                                        // height: detailsCarouselHeight,
                                        // width: widget.width,
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const Text(
                                rateText,
                                style: TextStyle(
                                    color: bottomBarColor,
                                    fontSize: 2 + 12,
                                    fontWeight: FontWeight.w400),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(vertical: 5),
                              //   child: Row(
                              //     children: [
                              //       RatingStars(
                              //         starColor: startColor,
                              //         starSize: 29,
                              //         value: values,
                              //         onValueChanged: (v) {
                              //           setState(() {
                              //             values = v;
                              //           });
                              //         },
                              //       )
                              //       // SmoothStarRating(
                              //       //   color: startColor,
                              //       //   borderColor: startColor,
                              //       //   // rating: double.tryParse(
                              //       //   //         product[
                              //       //   //             'average_rating']
                              //       //   //             ) ??
                              //       //   //     0,
                              //       //   size: 29,
                              //       // ),
                              //     ],
                              //   ),
                              // ),
                              RatingBar.builder(
                                initialRating: _rating ?? 0.0,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                itemCount: 5,
                                itemSize: 22,
                                itemPadding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                itemBuilder: (context, _) => Icon(
                                  _selectedIcon ?? Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  _rating = rating;
                                },
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
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      validator: (value) => value!.isEmpty
                                          ? 'Please enter your name'
                                          : null,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                      controller: nameController,
                                      decoration: const InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                              borderSide:
                                                  BorderSide(color: themeRed)),
                                          hintText: hintTitleText,
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14),
                                          border: OutlineInputBorder(),
                                          contentPadding:
                                              EdgeInsets.only(left: 10)),
                                    ),
                                    const Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Text(
                                            writeReviewText,
                                            style: TextStyle(
                                                color: bottomBarColor,
                                                fontSize: 2 + 12,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      validator: (value) => value!.isEmpty
                                          ? 'Please enter your review'
                                          : null,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                      controller: writeController,
                                      maxLines: 4,
                                      decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: themeRed)),
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
                                  ],
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
                                  color:
                                      const Color.fromARGB(255, 187, 182, 182),
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
                          onTap: () => {
                            postReview(args['id'].toString()),
                            // if (validateAndSave()) {postReview(args['id'])}
                          },
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
                                'Submit Review',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        // RoundedLoadingButton(controller: nameController., onPressed: (){}, child: Text(
                        //         'Submit Review',
                        //         style: TextStyle(
                        //           color: Colors.white,
                        //           fontSize: 14,
                        //         ),
                        //         textAlign: TextAlign.center,
                        //       ), )
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
