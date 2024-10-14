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
    String url = 'https://api.pexels.com/v1/curated?per_page=100&page=$page';

    try {
      final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': '4qZ2txUCt5XrsjKk7YrkDanR5BvZwuyt5xR4zPW5kWL6LfkjxZapfsQM'
          });
      if(response.statusCode == 200){
        Map result = jsonDecode(response.body);
        setState(() {
          images = result['photos'];
        });
      } else {
        print('Failed to load images: ${response.statusCode}');
      }
    }
    catch (e) {
      print('Error fetching images: $e');
    }
  }

  loadMore() async {
    setState(() {
      page++;
    });

    String url;
    if(currentQuery.isNotEmpty){
      url = 'https://api.pexels.com/v1/search?query=$currentQuery&per_page=100&page='+page.toString();
    } else {
      url = 'https://api.pexels.com/v1/curated?per_page=100&page='+page.toString();
    }

    try{
      final response = await http.get(
        Uri.parse(url),
        headers : {'Authorization' : '4qZ2txUCt5XrsjKk7YrkDanR5BvZwuyt5xR4zPW5kWL6LfkjxZapfsQM'}
      );
      if (response.statusCode == 200) {
        Map result = jsonDecode(response.body);
        setState(() {
          if (currentQuery.isNotEmpty) {
            images.addAll(result['photos']);
          } else {
            images.addAll(result['photos']);
          }
        });
      } else {
        print('Failed to load more images: ${response.statusCode}');
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
    String url = 'https://api.pexels.com/v1/search?query=$query&per_page=200';
    final response = await http.get(Uri.parse(url),
        headers: {'Authorization': '4qZ2txUCt5XrsjKk7YrkDanR5BvZwuyt5xR4zPW5kWL6LfkjxZapfsQM'});
    if (response.statusCode == 200) {
      Map result = jsonDecode(response.body);
      return result['photos'];
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
                  onTap: () => _search(context),
                  controller: _searchController,
                  onSubmitted: (query) => _search(context),
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

class ImageSearchDelegate extends SearchDelegate<List> {
  final _WallpaperState wallpaperState;
  ImageSearchDelegate(this.wallpaperState);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        toolbarTextStyle: GoogleFonts.farro(
          color: Colors.black,
        ),
        backgroundColor: Colors.transparent.withOpacity(0.2,),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        titleTextStyle: GoogleFonts.farro(
          color: Colors.black,
          fontSize: 22,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.farro(
          color: Colors.black,
        ),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Icon(Icons.arrow_back,),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
    );
  }


  @override
  Widget buildResults(BuildContext context) {
    return Container(
    );
  }

  Future<List> _fetchSearchResults(String query) async {
    String url = 'https://api.pexels.com/v1/search?query=$query&per_page=200';
    final response = await http.get(Uri.parse(url),
        headers: {'Authorization': '4qZ2txUCt5XrsjKk7YrkDanR5BvZwuyt5xR4zPW5kWL6LfkjxZapfsQM'});
    if (response.statusCode == 200) {
      Map result = jsonDecode(response.body);
      return result['photos'];
    } else {
      throw Exception('Failed to load search results');
    }
  }
}
