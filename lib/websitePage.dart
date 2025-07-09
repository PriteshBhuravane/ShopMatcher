import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'widgets/custom_app_bar.dart';
import 'widgets/platform_button.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/loading_overlay.dart';
import 'utils/constants.dart';
import 'services/image_search_service.dart';

class MyWebsite extends StatefulWidget {
  const MyWebsite({Key? key}) : super(key: key);

  @override
  State<MyWebsite> createState() => _MyWebsiteState();
}

class _MyWebsiteState extends State<MyWebsite> with TickerProviderStateMixin {
  bool _isLoading = false;
  String _loadingText = 'Loading...';
  double _progress = 0;
  int _selectedPlatform = 0;
  
  late InAppWebViewController amazonWebViewController;
  late InAppWebViewController flipkartWebViewController;
  late InAppWebViewController snapdealWebViewController;
  late TextEditingController _textEditingController;
  late AnimationController _buttonAnimationController;

  File? capturedImage;
  String amazonUrl = AppConstants.amazonBaseUrl;
  String flipkartUrl = AppConstants.flipkartBaseUrl;
  String snapdealUrl = AppConstants.snapdealBaseUrl;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _buttonAnimationController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> _captureImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
        _loadingText = 'Capturing image...';
      });

      final imagePicker = ImagePicker();
      final imageFile = await imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (imageFile != null) {
        setState(() {
          capturedImage = File(imageFile.path);
          _loadingText = 'Uploading image...';
        });

        final imageUrl = await ImageSearchService.uploadImageToImgBB(capturedImage!);
        
        setState(() {
          _loadingText = 'Searching products...';
        });

        final productUrls = await ImageSearchService.searchImageOnGoogleLens(imageUrl);
        
        if (productUrls.isNotEmpty) {
          final productName = ImageSearchService.extractProductNameFromUrl(productUrls.first);
          if (productName != null) {
            _searchOnAllPlatforms(productName);
          }
        } else {
          _showSnackBar('No products found. Try a different image.', isError: true);
        }
      }
    } catch (e) {
      _showSnackBar('Failed to search image: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchOnAllPlatforms(String query) {
    if (query.trim().isEmpty) {
      _showSnackBar('Please enter a search term', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingText = 'Searching across platforms...';
    });

    final searchUrls = _buildSearchUrls(query);
    
    amazonWebViewController.loadUrl(urlRequest: URLRequest(url: searchUrls[1]));
    flipkartWebViewController.loadUrl(urlRequest: URLRequest(url: searchUrls[0]));
    snapdealWebViewController.loadUrl(urlRequest: URLRequest(url: searchUrls[2]));

    _textEditingController.clear();
    FocusScope.of(context).unfocus();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    _showSnackBar('Searching for "$query" across all platforms');
  }

  List<Uri> _buildSearchUrls(String query) {
    final encodedQuery = Uri.encodeComponent(query.replaceAll(" ", ""));
    
    return [
      Uri.parse("https://www.flipkart.com/search?q=$encodedQuery"),
      Uri.parse("https://www.amazon.in/s?k=$encodedQuery"),
      Uri.parse("https://www.snapdeal.com/search?keyword=$encodedQuery"),
    ];
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<String> _getUrlFromURL(String url) async {
    Uri uri = Uri.parse(url);
    String decodedUrl = Uri.decodeComponent(uri.queryParameters['url'] ?? '');
    return decodedUrl.isEmpty ? url : 'https://www.amazon.in$decodedUrl';
  }

  bool _isProductUrl(String url) {
    return url.contains('/dp/');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final controllers = [
          flipkartWebViewController,
          amazonWebViewController,
          snapdealWebViewController,
        ];

        for (var controller in controllers) {
          if (await controller.canGoBack()) {
            controller.goBack();
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: const CustomAppBar(title: 'ShopMatcher'),
        body: LoadingOverlay(
          isLoading: _isLoading,
          loadingText: _loadingText,
          child: Column(
            children: [
              // Platform Selection Buttons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      PlatformInfo.platforms.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: PlatformButton(
                          title: PlatformInfo.platforms[index].name,
                          primaryColor: PlatformInfo.platforms[index].color,
                          textColor: PlatformInfo.platforms[index].textColor,
                          isSelected: _selectedPlatform == index,
                          icon: PlatformInfo.platforms[index].icon,
                          onPressed: () {
                            setState(() {
                              _selectedPlatform = index;
                            });
                            _buttonAnimationController.forward().then((_) {
                              _buttonAnimationController.reverse();
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Search Bar
              SearchBarWidget(
                controller: _textEditingController,
                onSearch: () => _searchOnAllPlatforms(_textEditingController.text),
                onCameraPressed: () => _captureImage(ImageSource.camera),
                onGalleryPressed: () => _captureImage(ImageSource.gallery),
              ),

              // Progress Indicator
              if (_progress < 1.0 && _progress > 0)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      PlatformInfo.platforms[_selectedPlatform].color,
                    ),
                  ),
                ),

              // WebView Container
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: IndexedStack(
                    index: _selectedPlatform,
                    children: _buildWebViews(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildWebViews() {
    return [
      // Flipkart WebView
      InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(flipkartUrl)),
        onWebViewCreated: (controller) => flipkartWebViewController = controller,
        onProgressChanged: (controller, progress) {
          setState(() => _progress = progress / 100);
        },
        onLoadStop: (controller, url) {
          setState(() => _progress = 1.0);
        },
      ),
      
      // Amazon WebView
      InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(amazonUrl)),
        onWebViewCreated: (controller) => amazonWebViewController = controller,
        onLoadStart: (controller, url) async {
          if (url != null) {
            String currentUrl = url.toString();
            String actualUrl = await _getUrlFromURL(currentUrl);
            
            if (_isProductUrl(actualUrl)) {
              if (!actualUrl.contains("tag=${AppConstants.amazonAffiliateTag}")) {
                String modifiedUrl = '$actualUrl&tag=${AppConstants.amazonAffiliateTag}';
                controller.stopLoading();
                controller.loadUrl(urlRequest: URLRequest(url: Uri.parse(modifiedUrl)));
              }
            }
          }
        },
        onProgressChanged: (controller, progress) {
          setState(() => _progress = progress / 100);
        },
        onLoadStop: (controller, url) {
          setState(() => _progress = 1.0);
        },
      ),
      
      // Snapdeal WebView
      InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(snapdealUrl)),
        onWebViewCreated: (controller) => snapdealWebViewController = controller,
        onProgressChanged: (controller, progress) {
          setState(() => _progress = progress / 100);
        },
        onLoadStop: (controller, url) {
          setState(() => _progress = 1.0);
        },
      ),
    ];
  }
}