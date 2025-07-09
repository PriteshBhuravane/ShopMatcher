import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ImageSearchService {
  static Future<String> uploadImageToImgBB(File imageFile) async {
    final apiUrl = Uri.parse(
        'https://api.imgbb.com/1/upload?expiration=${AppConstants.imageExpiration}&key=${AppConstants.imgbbApiKey}');

    final request = http.MultipartRequest('POST', apiUrl);
    final fileStream = http.ByteStream(imageFile.openRead());
    final fileLength = await imageFile.length();

    final fileField = http.MultipartFile(
      'image',
      fileStream,
      fileLength,
      filename: 'search_image.jpg',
    );

    request.files.add(fileField);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final data = json.decode(responseString);
      
      if (data is Map<String, dynamic> && data['data'] != null) {
        return data['data']['url'] as String;
      }
    }
    
    throw Exception('Failed to upload image');
  }

  static Future<List<String>> searchImageOnGoogleLens(String imageUrl) async {
    final encodedImageUrl = Uri.encodeFull(imageUrl);
    final lensUrl = "https://lens.google.com/uploadbyurl?url=$encodedImageUrl";

    final response = await http.get(
      Uri.parse(lensUrl),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36',
      },
    );

    if (response.statusCode == 200) {
      return _extractProductURLs(response.body);
    }
    
    throw Exception('Failed to search image');
  }

  static List<String> _extractProductURLs(String html) {
    List<String> productUrls = [];
    
    // Extract Amazon URLs
    RegExp amazonPattern = RegExp(r'https://www\.amazon[^"\s]*');
    amazonPattern.allMatches(html).forEach((match) {
      if (match.group(0) != null) {
        productUrls.add(match.group(0)!);
      }
    });

    // Extract Flipkart URLs
    RegExp flipkartPattern = RegExp(r'https://www\.flipkart[^"\s]*');
    flipkartPattern.allMatches(html).forEach((match) {
      if (match.group(0) != null) {
        productUrls.add(match.group(0)!);
      }
    });

    return productUrls;
  }

  static String? extractProductNameFromUrl(String url) {
    try {
      List<String> components = url.split('/');
      if (components.length > 3) {
        return components[3];
      }
    } catch (e) {
      print('Error extracting product name: $e');
    }
    return null;
  }
}