import 'package:drortho/components/starRating.dart';
import 'package:flutter/material.dart';
import '../constants/colorconstants.dart';
import '../constants/sizeconstants.dart';
import '../constants/stringconstants.dart';

class TestimonialsCarousel extends StatefulWidget {
  final double width;
  final List itemList;

  const TestimonialsCarousel({
    super.key,
    required this.width,
    required this.itemList,
  });

  @override
  State<TestimonialsCarousel> createState() => _TestimonialsCarouselState();
}

class _TestimonialsCarouselState extends State<TestimonialsCarousel> {
  int _pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: testimonialsCardHeight,
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        gradient: LinearGradient(
          colors: [testimonialsColor, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              testimonialsText,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: bottomBarColor,
                  fontSize: 12),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.itemList.length,
                  onPageChanged: (value) => setState(() {
                    _pageIndex = value;
                  }),
                  itemBuilder: (context, index) {
                    final carouselItem = widget.itemList[index];
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              child: SizedBox(
                                width: testimonialsCardHeight * 0.25,
                                height: testimonialsCardHeight * 0.25,
                                child: ClipOval(
                                  child: Image.network(
                                    carouselItem['image'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SmoothStarRating(
                              color: startColor,
                              borderColor: startColor,
                              rating: carouselItem['rating'] ?? 0,
                              size: 12,
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              carouselItem['message'],
                              textAlign: TextAlign.center,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(
                      bottom: testimonialsCardHeight * 0.50 * 0.25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...Iterable<int>.generate(widget.itemList.length)
                          .toList()
                          .map((idx) => Transform.scale(
                                scale: idx == _pageIndex ? 2 : 1,
                                child: AnimatedContainer(
                                  curve: Curves.bounceIn,
                                  duration: const Duration(milliseconds: 100),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                      color: idx == _pageIndex
                                          ? bottomBarColor
                                          : Colors.grey.shade300,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(50))),
                                  width: homeBannerDotSize,
                                  height: homeBannerDotSize,
                                ),
                              ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
