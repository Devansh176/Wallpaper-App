import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:share_plus/share_plus.dart';


class ImageScreen extends StatefulWidget {
  final String imageUrl;
  const ImageScreen({super.key, required this.imageUrl});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  Color? dominantColor;
  Color? undominantColor;

  @override
  void initState() {
    super.initState();
    _getDominantColor();
  }

  Future<void> _getDominantColor() async {
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      NetworkImage(widget.imageUrl),
    );
    if(mounted) {
      setState(() {
        dominantColor =
            generator.dominantColor?.color ?? Colors.tealAccent[400];
      });
    }
  }

  Future<void> setWallpaper() async {
    try {
      int location = WallpaperManager.HOME_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
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
    try {
      int location = WallpaperManager.LOCK_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
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
    try {
      int location = WallpaperManager.BOTH_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
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
    try {
      var file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
      await ImageGallerySaver.saveFile(file.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dominantColor,
          content: Text('Saved to Gallery',
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
          content: Text('Failed to save: $e',
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
    try {
      var file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
      final XFile xFile = XFile(file.path);
      Share.shareXFiles([xFile], text: 'Check out this amazing wallpaper from Wallviz !!');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share : $e',
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
                        color: dominantColor,                      ),
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
                        color: dominantColor,                      ),
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
            child: Image.network(widget.imageUrl),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.03,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: height * 0.16,
                  width: width * 0.16,
                  decoration: BoxDecoration(
                    color: toggleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: IconButton(
                      onPressed: saveToGallery,
                      icon: Icon(
                        Icons.download,
                        color: dominantColor,
                        size: width * 0.09,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.05,),
                Container(
                  height: height * 0.16,
                  width: width * 0.16,
                  decoration: BoxDecoration(
                    color: toggleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: IconButton(
                      onPressed: shareImage,
                      icon: Icon(
                        Icons.share,
                        color: dominantColor,
                        size: width * 0.09,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
