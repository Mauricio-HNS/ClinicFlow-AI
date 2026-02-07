import 'package:flutter/material.dart';

class Sale {
  final String id;
  final String title;
  final String category;
  final String price;
  final String distance;
  final String date;
  final Color color;
  final IconData icon;
  final double lat;
  final double lng;
  final bool featured;

  const Sale({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.distance,
    required this.date,
    required this.color,
    required this.icon,
    required this.lat,
    required this.lng,
    this.featured = false,
  });
}
