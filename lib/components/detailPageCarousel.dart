import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/imageconstants.dart';
import 'package:flutter/material.dart';

import '../constants/sizeconstants.dart';

class DetailsCarousel extends StatefulWidget {
  final double width;
  final List images;
  const DetailsCarousel({super.key, required this.width, required this.images});

  @override
  State<DetailsCarousel> createState() => _DetailsCarouselState();
}

class _DetailsCarouselState extends State<DetailsCarousel> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: widget.width,
          height: detailsCarouselHeight,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.images.length,
            onPageChanged: (value) => setState(() {
              _pageIndex = value;
            }),
            itemBuilder: (context, index) {
              final carouselItem = widget.images[index];
              return Image.network(
                carouselItem['src'],
                fit: BoxFit.contain,
                height: detailsCarouselHeight,
                width: widget.width,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    ...Iterable<int>.generate(widget.images.length)
                        .toList()
                        .map(
                          (idx) => Transform.scale(
                            scale: idx == _pageIndex ? 1.5 : 1.5,
                            child: AnimatedContainer(
                              curve: Curves.bounceIn,
                              duration: const Duration(milliseconds: 100),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                  color: idx == _pageIndex
                                      ? bottomBarColor
                                      : Colors.white,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                  border: Border.all(
                                      color: bottomBarColor, width: 1)),
                              width: homeBannerDotSize,
                              height: homeBannerDotSize,
                            ),
                          ),
                        ),
                  ],
                ),
              ),
              // SizedBox(
              //   width: iconSize,
              //   height: iconSize,
              //   child: Image.asset(
              //     favouriteOutlinedImage,
              //   ),
              // ),
              // const SizedBox(
              //   width: iconSize / 2,
              // ),
              InkWell(
                onTap: () {},
                child: SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: Image.asset(
                    shareImage,
                    fit: BoxFit.contain,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
