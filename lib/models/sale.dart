import 'package:flutter/material.dart';

class Sale {
  final String id;
  final String title;
  final String category;
  final String price;
  final String distance;
  final String date;
  final String? imageAsset;
  final String? imageUrl;
  final Color color;
  final IconData icon;
  final double lat;
  final double lng;
  final bool featured;
  final List<String> photoPaths;

  const Sale({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.distance,
    required this.date,
    this.imageAsset,
    this.imageUrl,
    required this.color,
    required this.icon,
    required this.lat,
    required this.lng,
    this.featured = false,
    this.photoPaths = const <String>[],
  });

  Sale copyWith({
    String? id,
    String? title,
    String? category,
    String? price,
    String? distance,
    String? date,
    String? imageAsset,
    String? imageUrl,
    Color? color,
    IconData? icon,
    double? lat,
    double? lng,
    bool? featured,
    List<String>? photoPaths,
  }) {
    return Sale(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      price: price ?? this.price,
      distance: distance ?? this.distance,
      date: date ?? this.date,
      imageAsset: imageAsset ?? this.imageAsset,
      imageUrl: imageUrl ?? this.imageUrl,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      featured: featured ?? this.featured,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }
}
