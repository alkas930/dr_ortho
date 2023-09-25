import 'dart:async';

import 'package:drortho/constants/colorconstants.dart';
import 'package:drortho/constants/sizeconstants.dart';
import 'package:flutter/material.dart';

class Carousel extends StatefulWidget {
  final double width;
  final List itemList;
  final Function(int) onClick;
  const Carousel(
      {super.key,
      required this.width,
      required this.itemList,
      required this.onClick});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  int _pageIndex = 0;
  final PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageIndex < widget.itemList.length - 1) {
        setState(() {
          _pageIndex = _pageIndex + 1;
        });
        pageController.animateToPage(
          _pageIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      } else {
        setState(() {
          _pageIndex = 0;
        });
        pageController.animateToPage(
          _pageIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: homeBannerHeight,
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          PageView.builder(
            controller: pageController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.itemList.length,
            onPageChanged: (value) => setState(() {
              _pageIndex = value;
            }),
            itemBuilder: (context, index) {
              final carouselItem = widget.itemList[index];
              return Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.onClick(int.parse(carouselItem['id']));
                    },
                    child: Image.network(
                      carouselItem['banner'],
                      fit: BoxFit.cover,
                      height: homeBannerHeight,
                      width: widget.width,
                    ),
                  ),
                  Container(
                    height: homeBannerHeight * 0.25,
                    width: widget.width,
                    // Below is the code for Linear Gradient.
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  )
                ],
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(bottom: homeBannerHeight * 0.25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...Iterable<int>.generate(widget.itemList.length).toList().map(
                      (idx) => Transform.scale(
                        scale: idx == _pageIndex ? 2 : 1,
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
                          ),
                          width: homeBannerDotSize,
                          height: homeBannerDotSize,
                        ),
                      ),
                    )
              ],
            ),
          )
        ],
      ),
    );
  }
}
