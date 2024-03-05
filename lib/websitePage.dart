

import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:webview_universal/webview_universal.dart';

class MyWebsite extends StatefulWidget {
  const MyWebsite({Key? key}) : super(key: key);

  @override
  State<MyWebsite> createState() => _MyWebsiteState();
}

class _MyWebsiteState extends State<MyWebsite> {
  bool _isLoading = false;
  double _progress = 0;
  late InAppWebViewController amazonWebViewController;
  late InAppWebViewController flipkartWebViewController;
  late InAppWebViewController snapdealWebViewController;
  TextEditingController _textEditingController = TextEditingController();

  @override
  double showAmazon = 0;
  File? capturedImage;// Variable to store the captured image
  String amazonUrl = "https://www.amazon.in";
  // "https://www.amazon.in/Monk-Sold-Ferrari-25th-Anniversary-ebook/dp/B09WDQSYHF/ref=pd_rhf_sc_s_dccs_mdi_sccl_2_1/258-0398248-5740447?pd_rd_w=gMgpn&content-id=amzn1.sym.e4459c11-0c52-4003-a7cd-bfaf053e0594&pf_rd_p=e4459c11-0c52-4003-a7cd-bfaf053e0594&pf_rd_r=YT6T0H2N55SMNNDSMBRK&pd_rd_wg=AZdzw&pd_rd_r=ec960060-c5ce-4c85-b296-d1b0eb4bf2b8&pd_rd_i=B09WDQSYHF&psc=1";//"https://www.amazon.com/"; //'https://www.amazon.in/Royal-Hub-Brainstorming-Ultimate-Multicolour/dp/B0BTP9XG2D'; //"https://www.amazon.com/";
  String flipkartUrl = "https://www.flipkart.com/";
  String snapdealUrl = "https://www.snapdeal.com/";

  List<Widget> orderedWidgetsOriginal() {

    return [
      InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(flipkartUrl),
        ),
        onWebViewCreated: (InAppWebViewController controller) {
          flipkartWebViewController = controller;
        },
        onProgressChanged: (InAppWebViewController controller, int progress) {
          setState(() {
            _progress = progress / 100;
          });
        },
      ),
      InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(amazonUrl),
        ),
        onWebViewCreated: (InAppWebViewController controller) {
          amazonWebViewController = controller;
          print("controller.getUrl()");

        },
        onLoadStart: (controller, url)  {
          if (url != null) {
            setState(() async{
              String currentAmazonUrl = url.toString();
              print('Amazon URL is about to load: $currentAmazonUrl');

              String afLink = await getUrlFromURL(currentAmazonUrl);
              //check is product url then add tag.
              if (_isProductUrl('$afLink')){
                //check is product url already contains tag.
                if (afLink.contains("tag=prathameshbhu-21")) {
                  print("URL contains tag=prathameshbhu-21");
                }
                else {
                  print("URL does not contain tag=prathameshbhu-21");
                  String modifiedUrl = '$afLink&tag=prathameshbhu-21';
                  controller.stopLoading();
                  controller.loadUrl(urlRequest: URLRequest(url: Uri.parse(modifiedUrl)));
                }
              }

            });
          }
        },
        onLoadStop: (controller, url) {
          if (url != null) {
            setState(() {
              // _isLoading = false;
              String currentAmazonUrl = url.toString();
              print('Amazon URL loaded: $currentAmazonUrl');
              _textEditingController.clear();
            });
          }
        },
        onLoadError: (controller, url, code, message) async {

        },
        onLoadHttpError: (controller, url, statusCode, reasonPhrase)async {

        },

        onProgressChanged: (InAppWebViewController controller, int progress) {
          setState(() {
            _progress = progress / 100;
          });
        },
        // pointerEvents: PointerEvents.none,
      ),
      InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(snapdealUrl),
        ),
        onWebViewCreated: (InAppWebViewController controller) {
          snapdealWebViewController = controller;
        },
      )
    ];
  }

  void initState() {
    super.initState();

    // Change the status bar color here
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.blue, // Change this color to the desired color
    ));

  }

//MARK:  select image either from gallery or capture from camera.

  Future<void> _captureImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final imageFile = await imagePicker.pickImage(source: source);



    setState(() {
      if (imageFile != null) {
        capturedImage = File(imageFile.path);
        String apiKey = "f92be3361dc31f06fa36beb908248f6c";
        int expiration = 600;
        uploadImageToImgBB(apiKey, capturedImage!, expiration);
      }
      else {
        _isLoading = false;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: ()async{
          var isLastPageFlipkart = await flipkartWebViewController.canGoBack();
          var isLastPageAmazon = await amazonWebViewController.canGoBack();
          var isLastPageSnap = await snapdealWebViewController.canGoBack();
          if(isLastPageFlipkart){
            flipkartWebViewController.goBack();
            return false;
          }
          if(isLastPageAmazon){
            amazonWebViewController.goBack();
            return false;
          }
          if(isLastPageSnap){
            snapdealWebViewController.goBack();
            return false;
          }
          return true;
        },
        child: SafeArea(
          child: Scaffold(
              body: GestureDetector(
                onTap: (){
                  FocusScope.of(context).unfocus();
                },
                child: ModalProgressHUD(
                  inAsyncCall: _isLoading,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      updateAmazonOrder();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: (showAmazon == 1)
                                          ? Color(0xff232B38)
                                          : Colors.white,
                                      foregroundColor: (showAmazon == 1)
                                          ? Colors.white
                                          : Color(0xff232B38),
                                    ),
                                    child: Text("Amazon"),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      updateFlipkartOrder();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: (showAmazon == 0)
                                          ? Color(0xff3D71E5)
                                          : Colors.white,
                                      foregroundColor: (showAmazon == 0)
                                          ? Colors.white
                                          : Color(0xff3D71E5),
                                    ),
                                    child: Text("Flipkart"),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      updateSnapDeal();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: (showAmazon == 2)
                                          ? Color(0xffe40046)
                                          : Colors.white,
                                      foregroundColor: (showAmazon == 2)
                                          ? Colors.white
                                          : Color(0xffe40046),
                                    ),
                                    child: Text("Snapdeal"),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      _captureImage(ImageSource.camera);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        // Adjust the radius as needed
                                      ),
                                      padding: EdgeInsets.all(0), // Remove padding
                                    ),
                                    child: Container(
                                      // padding: EdgeInsets.all(15),
                                      width: 20, // Set the width of the button
                                      height: 20, // Set the height of the button
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/photo-camera.png'), // Set the background image
                                          fit: BoxFit
                                              .scaleDown, // You can adjust the fit as needed
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 9),
                                  ElevatedButton(
                                    onPressed: () {
                                      _captureImage(ImageSource.gallery);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Adjust the radius as needed
                                      ),
                                      padding: EdgeInsets.all(0), // Remove padding
                                    ),
                                    child: Container(
                                      width: 20, // Set the width of the button
                                      height: 20, // Set the height of the button
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/image-gallery.png'), // Set the background image
                                          fit: BoxFit
                                              .cover, // You can adjust the fit as needed
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                              children: [
                                SizedBox(width: 15),
                                Expanded(
                                  // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  child: TextField(
                                    controller: _textEditingController,
                                    decoration: InputDecoration(
                                      // border: UnderlineInputBorder(),
                                      // disabledBorder: UnderlineInputBorder(,
                                      hintText: 'Search on all at one',

                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    // Handle button press

                                    setState(() {
                                      _isLoading = true;
                                      var text = _textEditingController.text;
                                      var uri = searchOnBothWebsites(text);
                                      amazonWebViewController.loadUrl(urlRequest: URLRequest(url: uri[0]));
                                      flipkartWebViewController.loadUrl(urlRequest: URLRequest(url: uri[1]));
                                      snapdealWebViewController.loadUrl(urlRequest: URLRequest(url: uri[2]));


                                      // searchOnBothWebsites(text);
                                      FocusScope.of(context).unfocus();
                                      print('Search button pressed: $text');
                                    }
                                    );

                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: Icon(
                                      Icons.search,
                                      color: Colors.black, // Change the color as needed
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15)


                              ]),
                          //Add Search
                          Expanded(
                            child: IndexedStack(

                              index: showAmazon.toInt(),
                              children:orderedWidgetsOriginal(),
                            ),
                          ),
                        ],
                      ),
                      // if (_isLoading)
                      //   Center(
                      //     child: CircularProgressIndicator(),
                      //   ),
                      if (capturedImage != null)
                      // Image.file(capturedImage!), // Display the captured image
                        if (_progress < 1.0)
                          LinearProgressIndicator(value: _progress),],
                  ),
                ),
              )

          ),
        )
    );
  }


//MARK:  Upload Image on website imgbb.com and pass the url of image to load on lense.

  Future<void> uploadImageToImgBB(String apiKey, File imageFile, int expiration) async {
    // Define the API endpoint URL
    setState(() {
      _isLoading = true;
    });
    print('here comes');
    final apiUrl = Uri.parse('https://api.imgbb.com/1/upload?expiration=$expiration&key=$apiKey');

    // Create a multipart request
    final request = http.MultipartRequest('POST', apiUrl);

    // Add the image file to the request
    final fileStream = http.ByteStream(imageFile.openRead());
    final fileLength = await imageFile.length();

    final fileField = http.MultipartFile(
      'image',
      fileStream,
      fileLength,
      filename: 'image.gif',
    );

    request.files.add(fileField);

    // Send the request
    final response = await request.send();

    if (response.statusCode == 200) {
      // Request was successful
      final responseString = await response.stream.bytesToString();
      print('Response: $responseString');

      // Parse the response to extract the image URL
      try {
        final data = json.decode(responseString);
        if (data is Map<String, dynamic>) {
          final imageUrl = data['data']['url'] as String;
          print('Image URL: $imageUrl');
          loadOnLens(imageUrl);
        }
      } catch (error) {
        print('Error parsing JSON: $error');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Request failed with status: ${response.statusCode}');
    }
  }


  // MARK: load image on google lens.
  Future<void> loadOnLens(String newImageUrl) async {
    final encodedImageUrl = Uri.encodeFull(newImageUrl);

    // Build the new URL
    final baseUrl = "https://lens.google.com/uploadbyurl?url=";
    final newUrl = baseUrl + encodedImageUrl;

    // Now, newUrl contains the updated URL with the new image URL
    print("newUrl: $newUrl");

    fetchResultFromURL(newUrl);
  }

  // MARK: Fetching the result of searching image on google lense.
  Future<void> fetchResultFromURL(String urlString) async {
    final response = await http.get(
      Uri.parse(urlString),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = response.body;
      print("Response: $responseBody");
      // Parse the response here to extract the result
      // You can call your extraction function here.
      extractAmazonURLsFromText(responseBody);
    } else {
      setState(() {
        _isLoading = false;
      });
      print("Failed to fetch data. Status code: ${response.statusCode}");
    }
  }

  // MARK: Extracts the Amazon or flipKart url from search result text.
  Future<void> extractAmazonURLsFromText(String text) async {
    List<String> amazonURLs = [];
    List<String> flipkartURLs = [];

    // Create a regular expression to match URLs
    RegExp urlPattern = RegExp(r'https?://[^\s/$.?#].[^\s]*');

    // Find all URLs in the text
    Iterable<Match> matches = urlPattern.allMatches(text);

    for (Match match in matches) {
      String? url = match.group(0);

      if (url != null) {
        if (url.startsWith('https://www.amazon')) {
          print('Amazon URL: $url');
          amazonURLs.add(url);
        } else if (url.startsWith('https://www.flipkart')) {
          print('Flipkart URL: $url');
          flipkartURLs.add(url);
        }
        else{
          setState(() {
            _isLoading = false;
          });
          print('URL++: $url');
        }
      }
    }
    var a = amazonURLs.first;
    // print('amazonURL.first = $a');
    //     if (amazonURLs != null) {
    //     loadNewUrl(extractUrlFromText(a)!,extractUrlFromText(a)!);
    //     }
    //     var b = extractUrlFromText(a);
    //     print('amazonURL.extractUrlFromText = $b');
    //     /*
    if (amazonURLs.isEmpty) {
      extractProductNamesFromURL(flipkartURLs.isNotEmpty ? flipkartURLs.first : null);
    } else if (flipkartURLs.isEmpty) {
      extractProductNamesFromURL(amazonURLs.first);
    } else {
      extractProductNamesFromURL(flipkartURLs.first);
    }
    // */
  }

  // MARK: Extract product Name from Url(getting from lens result  either of flipkart url or Amazon url.)
  String? extractProductNamesFromURL(String? url) {
    if (url != null) {
      List<String> components = url.split('/');
      if (components.length > 3) {
        String productName = components[3];
        print('Product Name: $productName');
        // You can call other functions or perform actions based on the product name here.
        searchOnBothWebsites(productName);
        return productName;
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Product name not found in the URL.');
        // Perform actions when the product name is not found.
        return null;
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      return null;
    }
  }

// MARK: Search on all websites with extracted productName
  List<Uri> searchOnBothWebsites(String query) {
    String inputString = query;
    String stringWithoutSpaces = inputString.replaceAll(" ", "");

    final amazonURL = Uri.parse("https://www.amazon.in/s?k=${Uri.encodeComponent(stringWithoutSpaces)}");
    final flipkartURL = Uri.parse("https://www.flipkart.com/search?q=${Uri.encodeComponent(stringWithoutSpaces)}");
    final snapdealURL = Uri.parse("https://www.snapdeal.com/search?keyword=${Uri.encodeComponent(stringWithoutSpaces)}");


    loadNewUrl("$amazonURL","$flipkartURL","$snapdealURL");

    print("Amazon URL: $amazonURL");
    // "/?tag=prathameshbhu-21");
    print("Flipkart URL: $flipkartURL");
    print("SnapDeal URL: $snapdealURL");
    return [amazonURL,flipkartURL,snapdealURL];
  }

  // MARK: Load the all websites url.
  void loadNewUrl(String? amazonurl, String? flipkarturl, String? snapdealurl) {
    setState(() {
      _isLoading = false;
      if (amazonurl != null) {
        amazonUrl = '$amazonurl';
        print('loadNewUrl $loadNewUrl');
      }
      else{

      }
      // '/?tag=prathameshbhu-21';
      if (flipkarturl != null) {
        flipkartUrl = '$flipkarturl';
        print('loadNewUrl $flipkartUrl');
      }
      if (snapdealurl != null) {
        snapdealUrl = '$snapdealurl';
        print('loadNewUrl $loadNewUrl');
      }
      // '/?tag=prathameshbhu-21';
    });
    print('amazonURL-loadNewUrl = $amazonUrl');
    // if (flipkartWebViewController != null) {
    //   flipkartWebViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse("www.google.com")));
    // }
    // if (amazonWebViewController != null) {
    //   amazonWebViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(currentamazonUrl)));
    // }
  }

  // MARK: update the Amazon button state when presses
  void updateAmazonOrder() {
    setState(() {
      // stackIndex = (stackIndex + 1) % 2;
      showAmazon = 1;
      print('order changed');
    });
  }

  // MARK: update the Flipkart button state when click
  void updateFlipkartOrder() {
    setState(() {
      showAmazon = 0;
      print('order changed 2');
    });
  }

  // MARK: update the SnapDeal button state when click
  void updateSnapDeal() {
    setState(() {
      showAmazon = 2;
      print('order changed 2');
    });
  }

  //MARK: extract the actual amazon Url from Url is about to load.Cause Url  about to load contains additional information attached to it.
  Future<String> getUrlFromURL(String URL) async {
    String firstLink = URL;

    // "https://www.amazon.in/sspa/click?ie=UTF8&spc=MTo1NDcwMTg1NjU2ODA5Njk0OjE3MDA5OTA5NjU6c3BfcGhvbmVfc2VhcmNoX2F0ZjozMDAwMTkxOTIwMDg4MzI6OjA6Og&url=%2FVaararo-Womens-Bodycon-Maroon-Casual%2Fdp%2FB09VD9NM91%2Fref%3Dmp_s_a_1_1_sspa%3Fcrid%3DDX98K5BP2LMY%26keywords%3Dparty%2Bwear%26qid%3D1700990965%26sprefix%3D%252Caps%252C163%26sr%3D8-1-spons%26sp_csd%3Dd2lkZ2V0TmFtZT1zcF9waG9uZV9zZWFyY2hfYXRm%26psc%3D1";

    // Extracting the "url" parameter from the first link
    Uri firstUri = Uri.parse(firstLink);
    String secondLink = Uri.decodeComponent(firstUri.queryParameters['url'] ?? '');

    print("Second Link: $secondLink");

    return secondLink == '' ? firstLink : 'https://www.amazon.in$secondLink';
    //
  }

// MARK: Check is Product url contains Product Name or not.
  bool _isProductUrl(String url) {
    // Add your logic to determine if the URL is a product URL
    // For example, check if it contains "/dp/" (product detail) in the path
    var a = url.contains('/dp/');
    print('is product URL: $a');
    return url.contains('/dp/');
  }

}






