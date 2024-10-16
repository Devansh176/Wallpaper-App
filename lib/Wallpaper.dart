import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:wallviz/ImageScreen.dart';


class Wallpaper extends StatefulWidget {
  const Wallpaper({super.key});

  @override
  State<Wallpaper> createState() => _WallpaperState();
}

class _WallpaperState extends State<Wallpaper> {
  List images = [];
  int page = 1;
  final TextEditingController _searchController = TextEditingController();
  String currentQuery = '';

  @override
  void initState() {
    super.initState();

    fetchApi();
  }

  fetchApi() async {
    page = Random().nextInt(100);
    String pexelsUrl = 'https://api.pexels.com/v1/curated?per_page=80&page=$page';
    String unSplashUrl = 'https://api.unsplash.com/photos?per_page=80&page=$page';

    try {
      final pexelsResponse = await http.get(
          Uri.parse(pexelsUrl),
          headers: {
            'Authorization': '4qZ2txUCt5XrsjKk7YrkDanR5BvZwuyt5xR4zPW5kWL6LfkjxZapfsQM'
          }
      );

      final unsplashResponse = await http.get(
          Uri.parse(unSplashUrl),
          headers: {
            'Authorization' : 'Client-ID StGi4MHWQApE24YNTplYIq1mBRl-jhbFyoRSqvYEyso'
          }
      );

      print('Pexels Response Status Code: ${pexelsResponse.statusCode}');
      print('Unsplash Response Status Code: ${unsplashResponse.statusCode}');

      if(pexelsResponse.statusCode == 200 && unsplashResponse.statusCode == 200){
        Map pexelsResult = jsonDecode(pexelsResponse.body);
        List unsplashResult = jsonDecode(unsplashResponse.body);

        if (pexelsResult['photos'].isNotEmpty && unsplashResult.isNotEmpty) {
          setState(() {
            images.addAll(pexelsResult['photos']);
            images.addAll(unsplashResult.map((img) => {
              'src' : {
                'tiny' : img['urls']['small'],
                'large2x' : img['urls']['regular'],
              }
            }).toList());
            print(unsplashResult);
          });
        } else {
          print('No images found in response: ${pexelsResponse.statusCode} or ${unsplashResponse.statusCode}');
        }
      } else {
        print('Failed to load images: ${pexelsResponse.statusCode} or ${unsplashResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  loadMore() async {
    setState(() {
      page++;
    });

    String pexelsUrl;
    String unsplashUrl;

    if (currentQuery.isNotEmpty) {
      pexelsUrl = 'https://api.pexels.com/v1/search?query=$currentQuery&per_page=50&page=$page';
      unsplashUrl = 'https://api.unsplash.com/search/photos?query=$currentQuery&per_page=50&page=$page';
    } else {
      pexelsUrl = 'https://api.pexels.com/v1/curated?per_page=50&page=$page';
      unsplashUrl = 'https://api.unsplash.com/photos?per_page=50&page=$page';
    }

    try {
      final pexelsResponse = await http.get(
          Uri.parse(pexelsUrl),
          headers: {'Authorization': '4qZ2txUCt5XrsjKk7YrkDanR5BvZwuyt5xR4zPW5kWL6LfkjxZapfsQM'}
      );

      final unsplashResponse = await http.get(
          Uri.parse(unsplashUrl),
          headers: {'Authorization': 'Client-ID StGi4MHWQApE24YNTplYIq1mBRl-jhbFyoRSqvYEyso'}
      );

      if (pexelsResponse.statusCode == 200 && unsplashResponse.statusCode == 200) {
        Map pexelsResult = jsonDecode(pexelsResponse.body);
        List unsplashResult = jsonDecode(unsplashResponse.body);

        setState(() {
          images.addAll(pexelsResult['photos']);
          images.addAll(unsplashResult.map((img) => {
            'src': {
              'tiny': img['urls']['small'],
              'large2x': img['urls']['regular'],
            }
          }).toList());
        });
      } else {
        print('Failed to load more images: ${pexelsResponse.statusCode} or ${unsplashResponse.statusCode}');
      }
    } catch (e) {
      print('Error loading more images: $e');
    }
  }


  void _search(BuildContext context) async {
    String query = _searchController.text.trim();

    if(query.isNotEmpty) {
      setState(() {
        currentQuery = query;
        page = 1;
        images.clear();
      });

      final result = await _fetchSearchResults(query);
      setState(() {
        images = result;
      });
    }
  }

  Future<List> _fetchSearchResults(String query) async {
    String pexelsUrl = 'https://api.pexels.com/v1/search?query=$query&per_page=100';
    final unsplashUrl = "https://api.unsplash.com/search/photos?query=$query&per_page=100";

    final pexelsResponse = await http.get(Uri.parse(pexelsUrl),
      headers: {'Authorization': '4qZ2txUCt5XrsjKk7YrkDanR5BvZwuyt5xR4zPW5kWL6LfkjxZapfsQM'}
    );

    final unsplashResponse = await http.get(Uri.parse(unsplashUrl),
      headers: {'Authorization': 'Client-ID StGi4MHWQApE24YNTplYIq1mBRl-jhbFyoRSqvYEyso'}
    );

    if (pexelsResponse.statusCode == 200 && unsplashResponse.statusCode == 200) {
      Map<String, dynamic> pexelsResult = jsonDecode(pexelsResponse.body);
      Map<String, dynamic> unsplashResult = jsonDecode(unsplashResponse.body);

      List pexelsPhotos = pexelsResult['photos'];
      List unsplashPhotos = unsplashResult['results'];

      List combinedPhotos = [...pexelsPhotos, ...unsplashPhotos];

      return combinedPhotos;
    } else {
      throw Exception('Failed to load search results');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;
    final padding = width * 0.05;
    final fontSize = width * 0.05;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('The Wallviz',
          style: GoogleFonts.aclonica(
            color: Colors.teal,
            fontSize: fontSize * 1.7,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          _searchController.clear();
          FocusScope.of(context).unfocus();
          fetchApi();
        },
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    itemCount: images.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 3,
                      childAspectRatio: 2/3,
                      mainAxisSpacing: 3,
                    ),
                    itemBuilder: (context, index){
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageScreen(
                                imageUrl: images[index]['src']['large2x'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          color: Colors.black,
                          child: Image.network(
                            images[index]['src']['tiny'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              left: padding * 0.05,
              top: padding * 1.2,
              right: padding * 0.05,
              child: Padding(
                padding: EdgeInsets.all(padding,),

                child: TextField(
                  cursorColor: Colors.teal[300],
                  style: GoogleFonts.farro(
                    color: Colors.teal[300],
                  ),
                  onSubmitted: (query) => _search(context),
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Wallpapers...',
                    hintStyle: GoogleFonts.farro(
                      color: Colors.teal[300],
                    ),
                    prefixIcon: Icon(Icons.search,
                      color: Colors.teal[300],
                    ),

                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent,),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40,),
                      borderSide: BorderSide(color: Colors.transparent,),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40,),
                      borderSide: BorderSide(color: Colors.transparent,),
                    ),
                    filled: true,
                    fillColor: Colors.transparent.withOpacity(0.6,),

                    suffixIcon: IconButton(
                      color: Colors.teal[300],
                      onPressed: () {
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icon(Icons.clear,),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: padding,
              left: width/2 - (height * 0.039),
              child: Container(
                height: height * 0.17,
                width: width * 0.17,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent.withOpacity(0.8,),
                ),
                child: InkWell(
                  child: Icon(
                    Icons.add,
                    color: Colors.teal[300],
                    size: 35,
                  ),
                  onTap: () async {
                    loadMore();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
