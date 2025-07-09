import 'package:flutter/material.dart';

class AppConstants {
  // Platform Colors
  static const Color amazonColor = Color(0xff232B38);
  static const Color flipkartColor = Color(0xff3D71E5);
  static const Color snapdealColor = Color(0xffe40046);
  
  // App Colors
  static const Color primaryColor = Colors.deepPurple;
  static const Color backgroundColor = Color(0xfff8f9fa);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xff2d3748);
  static const Color textSecondary = Color(0xff718096);
  
  // URLs
  static const String amazonBaseUrl = "https://www.amazon.in";
  static const String flipkartBaseUrl = "https://www.flipkart.com/";
  static const String snapdealBaseUrl = "https://www.snapdeal.com/";
  
  // Image Upload
  static const String imgbbApiKey = "f92be3361dc31f06fa36beb908248f6c";
  static const int imageExpiration = 600;
  
  // Affiliate Tag
  static const String amazonAffiliateTag = "prathameshbhu-21";
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

class PlatformInfo {
  final String name;
  final Color color;
  final Color textColor;
  final IconData icon;
  final String baseUrl;

  const PlatformInfo({
    required this.name,
    required this.color,
    required this.textColor,
    required this.icon,
    required this.baseUrl,
  });

  static const List<PlatformInfo> platforms = [
    PlatformInfo(
      name: 'Flipkart',
      color: AppConstants.flipkartColor,
      textColor: Colors.white,
      icon: Icons.shopping_cart,
      baseUrl: AppConstants.flipkartBaseUrl,
    ),
    PlatformInfo(
      name: 'Amazon',
      color: AppConstants.amazonColor,
      textColor: Colors.white,
      icon: Icons.shopping_bag,
      baseUrl: AppConstants.amazonBaseUrl,
    ),
    PlatformInfo(
      name: 'Snapdeal',
      color: AppConstants.snapdealColor,
      textColor: Colors.white,
      icon: Icons.local_offer,
      baseUrl: AppConstants.snapdealBaseUrl,
    ),
  ];
}