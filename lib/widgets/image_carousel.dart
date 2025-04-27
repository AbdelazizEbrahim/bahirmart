import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageCarousel extends StatelessWidget {
  final List<String> images;

  ImageCarousel({required this.images});

  @override
  Widget build(BuildContext context) {
    return images.isEmpty
        ? Container(
            height: 200,
            color: Colors.grey.shade200,
            child: Center(child: Icon(Icons.image_not_supported, size: 50)),
          )
        : CarouselSlider(
            options: CarouselOptions(
              height: 200,
              autoPlay: images.length > 1,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              aspectRatio: 2.0,
            ),
            items: images.map((image) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) => Icon(Icons.error),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
  }
}