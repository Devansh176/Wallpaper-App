import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;

class ImageScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageScreen({super.key, required this.imageUrls, this.initialIndex = 0});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  Color? dominantColor;
  int currentIndex = 0;
  List relatedImages = [];
  bool isLoadingImages = false;
  Map<String, List<dynamic>> cachedRelatedImages = {}; // Cache for related images

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _getDominantColor(widget.imageUrls[currentIndex]);
    if (relatedImages.isEmpty) {
      _fetchRelatedImages(widget.imageUrls[currentIndex]);
    }
  }

  Future<void> _getDominantColor(String imageUrl) async {
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      NetworkImage(imageUrl),
    );
    if(mounted) {
      setState(() {
        dominantColor =
            generator.dominantColor?.color ?? Colors.tealAccent[400];
      });
    }
  }

  List _filterUniqueImages(List images) {
    final seenUrls = <String>{};
    return images.where((img) {
      final largeUrl = img['src']['large2x'];
      if(seenUrls.contains(largeUrl)) {
        return false;
      } else {
        seenUrls.add(largeUrl);
        return true;
      }
    }).toList();
  }

  Future<void> _fetchRelatedImages(String query) async {
    setState(() {
      isLoadingImages = true;
    });

    // Check cache first
    if (cachedRelatedImages.containsKey(query)) {
      setState(() {
        relatedImages = cachedRelatedImages[query]!;
        isLoadingImages = false;
      });
      return;
    }

    String unsplashUrl = 'https://api.unsplash.com/search/photos?query=$query&per_page=15';
    String pexelsUrl = 'https://api.pexels.com/v1/search?query=$query&per_page=15';

    try {
      final unsplashResponse = await http.get(
        Uri.parse(unsplashUrl),
        headers: {
          'Authorization': 'Client-ID StGi4MHWQApE24YNTplYIq1mBRl-jhbFyoRSqvYEyso',
        },
      );

      final pexelsResponse = await http.get(
        Uri.parse(pexelsUrl),
        headers: {
          'Authorization': '4qZ2txUCt5XrsjKk7YrkDanR5BvZwuyt5xR4zPW5kWL6LfkjxZapfsQM',
        },
      );

      if (pexelsResponse.statusCode == 200 && unsplashResponse.statusCode == 200) {
        Map<String, dynamic> pexelsResult = jsonDecode(pexelsResponse.body);
        List<dynamic> pexelsPhotos = pexelsResult['photos'] ?? [];

        Map<String, dynamic> unsplashResult = jsonDecode(unsplashResponse.body);
        List<dynamic> unsplashPhotos = unsplashResult['results'] ?? [];

        List filteredPexelsPhotos = pexelsPhotos.where((img) =>
        img['src'] != null &&
            img['src']['tiny'] != null &&
            img['src']['large2x'] != null).toList();

        List filteredUnsplashPhotos = unsplashPhotos.where((img) =>
        img['urls'] != null &&
            img['urls']['small'] != null &&
            img['urls']['regular'] != null).map((img) => {
          'src': {
            'tiny': img['urls']['small'],
            'large2x': img['urls']['regular'],
          }
        }).toList();

        List combinedImages = _filterUniqueImages([...filteredPexelsPhotos, ...filteredUnsplashPhotos]);
        combinedImages.shuffle(Random());

        // Cache related images
        cachedRelatedImages[query] = combinedImages;

        if (mounted) {
          setState(() {
            relatedImages = combinedImages;
            isLoadingImages = false;
          });
        }
      } else {
        throw Exception("Failed to load related images");
      }
    } catch (e) {
      print("Error fetching images: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoadingImages = false;
        });
      }
    }
  }

  Future<void> setWallpaper() async {
    try {
      int location = WallpaperManager.HOME_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(widget.imageUrls[currentIndex]);
      bool result = await WallpaperManager.setWallpaperFromFile(
          file.path, location);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dominantColor,
          content: Text('HomeScreen set',
            style: GoogleFonts.farro(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dominantColor,
          content: Text('Failed to set',
            style: GoogleFonts.farro(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      );
    }
  }

  Future<void> setLockScreen() async {
    String? imageUrl;

    // Determine if the current image is from main images or related images
    if (currentIndex < widget.imageUrls.length) {
      imageUrl = widget.imageUrls[currentIndex];
    } else {
      int relatedIndex = currentIndex - widget.imageUrls.length;
      if (relatedIndex < relatedImages.length) {
        imageUrl = relatedImages[relatedIndex]['src']['large2x'];
      }
    }

    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image available'),
        ),
      );
      return;
    }

    try {
      int location = WallpaperManager.LOCK_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(widget.imageUrls[currentIndex]);
      bool result = await WallpaperManager.setWallpaperFromFile(
          file.path, location);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dominantColor,
          content: Text('LockScreen set',
            style: GoogleFonts.farro(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dominantColor,
          content: Text('Failed to set',
            style: GoogleFonts.farro(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      );
    }
  }

  Future<void> setBoth() async {
    String? imageUrl;

    // Determine if the current image is from main images or related images
    if (currentIndex < widget.imageUrls.length) {
      imageUrl = widget.imageUrls[currentIndex];
    } else {
      int relatedIndex = currentIndex - widget.imageUrls.length;
      if (relatedIndex < relatedImages.length) {
        imageUrl = relatedImages[relatedIndex]['src']['large2x'];
      }
    }

    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image available'),
        ),
      );
      return;
    }

    try {
      int location = WallpaperManager.BOTH_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(widget.imageUrls[currentIndex]);
      bool result = await WallpaperManager.setWallpaperFromFile(
          file.path, location);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dominantColor,
          content: Text('Both Screen set',
            style: GoogleFonts.farro(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to set',
            style: GoogleFonts.farro(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      );
    }
  }

  Future<void> saveToGallery() async {
    String? imageUrl;

    // Determine if the current image is from main images or related images
    if (currentIndex < widget.imageUrls.length) {
      imageUrl = widget.imageUrls[currentIndex];
    } else {
      int relatedIndex = currentIndex - widget.imageUrls.length;
      if (relatedIndex < relatedImages.length) {
        imageUrl = relatedImages[relatedIndex]['src']['large2x'];
      }
    }

    // If no image URL is found, show a message and exit
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image available to save'),
        ),
      );
      return;
    }

    try {
      var file = await DefaultCacheManager().getSingleFile(imageUrl);
      await ImageGallerySaver.saveFile(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dominantColor,
          content: Text(
            'Saved to Gallery',
            style: GoogleFonts.farro(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dominantColor,
          content: Text(
            'Failed to save: $e',
            style: GoogleFonts.aclonica(
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  Future<void> shareImage() async {
    String? imageUrl;

    // Determine if the current image is from main images or related images
    if (currentIndex < widget.imageUrls.length) {
      imageUrl = widget.imageUrls[currentIndex];
    } else {
      int relatedIndex = currentIndex - widget.imageUrls.length;
      if (relatedIndex < relatedImages.length) {
        imageUrl = relatedImages[relatedIndex]['src']['large2x'];
      }
    }

    // If no image URL is found, show a message and exit
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image available to share'),
        ),
      );
      return;
    }

    try {
      var file = await DefaultCacheManager().getSingleFile(imageUrl);
      final XFile xFile = XFile(file.path);
      Share.shareXFiles([xFile], text: 'Check out this amazing wallpaper from Wallviz !!');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to share: $e',
            style: GoogleFonts.aclonica(
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;
    final padding = width * 0.05;

    if(dominantColor == null){
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.teal,),
        ),
      );
    }

    Color toggleColor = (dominantColor != null && dominantColor!.computeLuminance() < 0.5)
        ? Colors.white
        : Colors.black;

    return Scaffold(
      backgroundColor: dominantColor,
      appBar: AppBar(
        backgroundColor: dominantColor,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_outlined,
            color: toggleColor,
            size: 27,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: padding * 0.25,),
            child: PopupMenuButton(
              iconColor: toggleColor,
              iconSize: 30,
              color: toggleColor,
              itemBuilder: (BuildContext context){
                return [
                  PopupMenuItem<String>(
                    value: '1',
                    child: Text('Set Wallpaper',
                      style: GoogleFonts.aclonica(
                        color: dominantColor,
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: '2',
                    child: Text('Set LockScreen',
                      style: GoogleFonts.aclonica(
                        color: dominantColor,
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: '3',
                    child: Text('Set Both',
                      style: GoogleFonts.aclonica(
                        color: dominantColor,
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: '4',
                    child: Text('Save to Gallery',
                      style: GoogleFonts.aclonica(
                        color: dominantColor,
                      ),
                    ),
                  ),
                ];
              },
              onSelected: (String item){
                switch(item){
                  case '1' : setWallpaper();
                  break;
                  case '2' : setLockScreen();
                  break;
                  case '3' : setBoth();
                  break;
                  case '4' : saveToGallery();
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider.builder(
              itemCount: widget.imageUrls.length + relatedImages.length,
              itemBuilder: (context, index, realIndex) {
                String imageUrl;
                if (index < widget.imageUrls.length) {
                  // Main image
                  imageUrl = widget.imageUrls[index];
                } else {
                  // Related image
                  int relatedIndex = index - widget.imageUrls.length;
                  if (relatedImages.isNotEmpty && relatedIndex < relatedImages.length) {
                    imageUrl = relatedImages[relatedIndex]['src']['large2x'];
                  } else {
                    // Fallback in case relatedImages is shorter than expected
                    imageUrl = widget.imageUrls[0]; // Or any default image
                  }
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = index;
                      _getDominantColor(imageUrl);
                    });
                  },
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if(loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text('Image not available'),
                      );
                    },
                  )
                );
              },
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.7,
                initialPage: 0,
                enableInfiniteScroll: true,
                enlargeCenterPage: true,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentIndex = index;

                    if (index < widget.imageUrls.length) {
                      // Main images
                      _getDominantColor(widget.imageUrls[index]);
                    } else if (index < widget.imageUrls.length + relatedImages.length) {
                      // Related images
                      int relatedIndex = index - widget.imageUrls.length;
                      _getDominantColor(relatedImages[relatedIndex]['src']['large2x']);
                    } else {
                      // Out of range - prevent further errors
                      print('Index out of range: $index');
                    }
                  });
                },

              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: screenSize.height * 0.03),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionIcon(Icons.download, toggleColor, saveToGallery),
                SizedBox(width: screenSize.width * 0.05),
                _actionIcon(Icons.share, toggleColor, shareImage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onPressed) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(height * 0.015),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
        ),
        child: Icon(icon, color: color, size: height * 0.035),
      ),
    );
  }

}
