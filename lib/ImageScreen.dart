import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:palette_generator/palette_generator.dart';



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
    setState(() {
      dominantColor = generator.dominantColor?.color ?? Colors.tealAccent[400];
    });
  }

  Future<void> setWallpaper() async {
    try {
      int location = WallpaperManager.HOME_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
      bool result = await WallpaperManager.setWallpaperFromFile(
          file.path, location);
    } on PlatformException{}
  }

  Future<void> setLockScreen() async {
    try {
      int location = WallpaperManager.LOCK_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
      bool result = await WallpaperManager.setWallpaperFromFile(
          file.path, location);
    } on PlatformException{}
  }

  Future<void> setBoth() async {
    try {
      int location = WallpaperManager.BOTH_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
      bool result = await WallpaperManager.setWallpaperFromFile(
          file.path, location);
    } on Exception{}
  }

  Future<void> saveToGallery() async {
    try {
      var file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
      await ImageGallerySaver.saveFile(file.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.teal,
          content: Text('Saved to Gallery',
            style: GoogleFonts.aclonica(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: Text('Failed to save: $e',
            style: GoogleFonts.aclonica(
              fontSize: 10,
              color: Colors.black,
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
    final fontSize = width * 0.05;

    Color textColor = (dominantColor != null && dominantColor!.computeLuminance() < 0.5)
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
            color: textColor,
            size: 27,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: padding * 0.25,),
            child: PopupMenuButton(
              iconColor: textColor,
              iconSize: 30,
              color: textColor,
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
          Container(
            height: height * 0.1,
            width: double.infinity,
            decoration: BoxDecoration(
              color: dominantColor,
            ),
            child: Center(
              child: TextButton(
                onPressed: (){
                  setWallpaper();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(textColor,),
                ),
                child: Text('Set Wallpaper',
                  style: GoogleFonts.aclonica(
                    color: dominantColor,
                    fontSize: fontSize * 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
