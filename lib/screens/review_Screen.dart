import 'package:drortho/components/searchcomponent.dart';
import 'package:drortho/components/starRating.dart';
import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/stringconstants.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  final images;

  const ReviewScreen({super.key, this.images});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState(productImage: images);
}

class _ReviewScreenState extends State<ReviewScreen> {
  final productImage;
  _ReviewScreenState({this.productImage});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SearchComponent(
            isBackEnabled: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  rateText,
                  style: TextStyle(
                      color: bottomBarColor,
                      fontSize: 2 + 15,
                      fontWeight: FontWeight.w400),
                ),
                const Row(
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
                const Text(
                  sharePhotoText,
                  style: TextStyle(
                      color: bottomBarColor,
                      fontSize: 2 + 15,
                      fontWeight: FontWeight.w400),
                ),
                const Text(
                  titleReviewText,
                  style: TextStyle(
                      color: bottomBarColor,
                      fontSize: 2 + 15,
                      fontWeight: FontWeight.w400),
                ),
                const TextField(
                  decoration: InputDecoration(
                      hintText: hintTitleText,
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w300,
                      ),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(4)),
                ),
                const Text(
                  writeReviewText,
                  style: TextStyle(
                      color: bottomBarColor,
                      fontSize: 2 + 15,
                      fontWeight: FontWeight.w400),
                ),
                const TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: hintWriteText,
                    hintStyle: TextStyle(fontWeight: FontWeight.w300),
                    border: OutlineInputBorder(),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(width: .3)),
                      child: Text('Submit'),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
