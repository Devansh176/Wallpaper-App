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
  final FocusNode _searchFocusNode = FocusNode();
  bool showChoices = false;
  bool _isSearchedFocus = false;
  String? selectedValue;
  int tag = 1;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  void scrollToTop() {
    _scrollController.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.easeInOut,);
  }

  void setSelectedValue(String? value) {
    setState(() => selectedValue = value);
  }

  List<String> choices = [
    'Nature',
    'Abstract Art',
    'Minimalist Designs',
    'Space',
    'CityScape',
    'Animals',
    'Flowers',
    'Mountains',
    'Fantasy',
    'Ocean',
    'Vintage',
    'Cars',
    'Patterns',
    'Dark',
    'Artistic Illusions',
    'Quotes',
    '3D Rendered Art',
    'Tech',
    'Anime',
    'Neon Lights',
    'Aesthetics',
    'Landscapes',
    'Sports',
    'Rich Textures',
    'Geometric Patterns',
    'Sunset',
    'Forest',
    'Galaxy',
    'Flowing Water',
    'Street Art',
    'Monochrome',
    'Wildlife',
    'Typography',
    'Surrealism',
    'Graffiti',
    'Abstract Portraits',
    'Cyberpunk',
    'Sci-Fi',
    'Pop Art',
    'Photography',
    'Bohemian',
    'Meditative',
    'Retro Futurism',
    'Steampunk',
    'Bokeh',
    'Color Splash',
    'Rainy Days',
    'Vibrant Landscapes',
    'Pixel Art',
    'Doodles',
    'Tropical Paradise',
    'Grunge',
    'Baroque',
    'Vector Graphics',
    'Cubism',
    'Impressionism',
    'Digital Glitch',
    'Stealth Mode',
    'Underwater',
    'Desert Landscapes',
    'Whimsical',
    'Mythology',
    'Gothic',
    'Renaissance Art',
    'Zen Gardens',
    'Silhouettes',
    'Cultural Heritage',
    'Comic Book Style',
    'Calligraphy',
    'Sacred Geometry',
    'Art Deco',
    'Holographic',
    'Mediterranean',
    'Street Photography',
    'Traditional Painting',
    'Cosmos Exploration',
    'Northern Lights',
    'Fireworks',
    'Vintage Posters',
    'Rainforests',
    'Marble Patterns',
    'Street Photography',
    'Food Photography',
    'Architectural Wonders',
    'Color Gradients',
    'Ethnic Patterns',
    'Folk Art',
    'Psychedelic',
    'Retro Gaming',
    'Fantasy Landscapes',
    'Kaleidoscope',
    'Dreamy Clouds',
    'Mystical Forests',
    'Street Fashion',
    'Desert Oasis',
    'Polar Landscapes',
    'Carnival Vibes',
    'Minimal Line Art',
    'Retro Aesthetics',
    'Celestial Wonders',
    'Industrial Designs',
    'Motion Blur',
    'Surreal Dreams',
    'Zen Stones',
    'Urban Exploration',
    'Wild West',
    'Crystal Reflections',
    'Ink Sketches',
    'Fantasy Creatures',
    'Sun-Kissed Beaches',
    'Fire and Ice',
    'Autumn Leaves',
  ];

  @override
  void initState() {
    super.initState();

    fetchApi();

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchedFocus = _searchFocusNode.hasFocus;
        showChoices = _isSearchedFocus;
      });
    });
  }

  void fetchApi() async {
    int randomPageNo = Random().nextInt(100) + 1;
    String pexelsUrl = currentQuery.isNotEmpty
        ? 'https://api.pexels.com/v1/search?query=$currentQuery&per_page=50&page=$randomPageNo'
        : 'https://api.pexels.com/v1/curated?per_page=50&page=$randomPageNo';

    String unsplashUrl = currentQuery.isNotEmpty
        ? 'https://api.unsplash.com/search/photos?query=$currentQuery&per_page=50&page=$randomPageNo'
        : 'https://api.unsplash.com/photos?per_page=50&page=$randomPageNo';

    try {
      final pexelsResponse = await http.get(
        Uri.parse(pexelsUrl),
        headers: {'Authorization': '4qZ2txUCt5XrsjKk7YrkDanR5BvZwuyt5xR4zPW5kWL6LfkjxZapfsQM'},
      );

      final unsplashResponse = await http.get(
        Uri.parse(unsplashUrl),
        headers: {'Authorization': 'Client-ID StGi4MHWQApE24YNTplYIq1mBRl-jhbFyoRSqvYEyso'},
      );

      if (pexelsResponse.statusCode == 200 && unsplashResponse.statusCode == 200) {
        Map<String, dynamic> pexelsResult = jsonDecode(pexelsResponse.body);
        List<dynamic> pexelsPhotos = pexelsResult['photos'] ?? [];

        dynamic unsplashResult = jsonDecode(unsplashResponse.body);
        List<dynamic> unsplashPhotos = (unsplashResult is List
            ? unsplashResult
            : unsplashResult['results'] ?? []) as List;

        List filteredPexelsPhotos = pexelsPhotos
            .where((img) => img['src'] != null && img['src']['tiny'] != null && img['src']['large2x'] != null)
            .toList();
        List filteredUnsplashPhotos = unsplashPhotos
            .where((img) =>
        img['urls'] != null && img['urls']['small'] != null && img['urls']['regular'] != null)
            .map((img) => {
          'src': {
            'tiny': img['urls']['small'],
            'large2x': img['urls']['regular'],
          }
        })
            .toList();

        print("Fetched Pexels images count: ${filteredPexelsPhotos.length}");
        print("Fetched Unsplash images count: ${filteredUnsplashPhotos.length}");

        List combinedImages = filteredPexelsPhotos + filteredUnsplashPhotos;
        combinedImages.shuffle(Random());

        setState(() {
          images = combinedImages;
        });
      } else {
        print('Failed to fetch images from APIs');
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  Widget buildImageGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final imageUrl = images[index]['src']['large2x'] ?? 'https://via.placeholder.com/150';

        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.network(
              'https://via.placeholder.com/150',  // Placeholder URL
              fit: BoxFit.cover,
            );
          },
        );
      },
    );
  }

  loadMore() async {
    setState(() {
      _isLoadingMore = true;
      page++;
    });

    int randomPageNo = Random().nextInt(100) + 1;

    String pexelsUrl = currentQuery.isNotEmpty
        ? 'https://api.pexels.com/v1/search?query=$currentQuery&per_page=50&page=$randomPageNo'
        : 'https://api.pexels.com/v1/curated?per_page=50&page=$randomPageNo';

    String unsplashUrl = currentQuery.isNotEmpty
        ? 'https://api.unsplash.com/search/photos?query=$currentQuery&per_page=50&page=$randomPageNo'
        : 'https://api.unsplash.com/photos?per_page=50&page=$randomPageNo';

    try {
      final pexelsResponse = await http.get(
        Uri.parse(pexelsUrl),
        headers: {'Authorization': '4qZ2txUCt5XrsjKk7YrkDanR5BvZwuyt5xR4zPW5kWL6LfkjxZapfsQM'},
      );

      final unsplashResponse = await http.get(
        Uri.parse(unsplashUrl),
        headers: {'Authorization': 'Client-ID StGi4MHWQApE24YNTplYIq1mBRl-jhbFyoRSqvYEyso'},
      );

      if (pexelsResponse.statusCode == 200 && unsplashResponse.statusCode == 200) {
        Map<String, dynamic> pexelsResult = jsonDecode(pexelsResponse.body);
        List<dynamic> pexelsPhotos = pexelsResult['photos'] ?? [];

        List filteredPexelsPhotos = pexelsPhotos.where((img) => img['src'] != null && img['src']['tiny'] != null && img['src']['large2x'] != null).toList();

        dynamic unsplashResult = jsonDecode(unsplashResponse.body);
        List<dynamic> unsplashPhotos;

        if (unsplashResult is List) {
          unsplashPhotos = unsplashResult;
        } else if (unsplashResult is Map<String, dynamic>) {
          unsplashPhotos = unsplashResult['results'] ?? [];
        } else {
          unsplashPhotos = [];
        }

        List filteredUnsplashPhotos = unsplashPhotos.where((img) =>
        img['urls'] != null && img['urls']['small'] != null && img['urls']['regular'] != null
        ).map((img) => {
          'src': {
            'tiny': img['urls']['small'],
            'large2x': img['urls']['regular'],
          }
        }).toList();

        List combinedImages = filteredPexelsPhotos + filteredUnsplashPhotos;
        combinedImages.shuffle(Random());

        setState(() {
          images.addAll(combinedImages);
          _isLoadingMore = false;
        });
      } else {
        print('Failed to load more images: ${pexelsResponse.statusCode} or ${unsplashResponse.statusCode}');
      }
    } catch (e) {
      print('Error loading more images: $e');
    }
  }

  Future<void> _search(BuildContext context) async {
    String query = _searchController.text.trim();

    if (query.isNotEmpty) {
      setState(() {
        currentQuery = query;
        page = 1;
        images.clear();
        showChoices = false;
      });

      final result = await _fetchSearchResults(query);
      setState(() {
        images = result;
      });
    }
  }

  Future<List> _fetchSearchResults(String query) async {
    String pexelsUrl = 'https://api.pexels.com/v1/search?query=$query&per_page=150&page=1';
    final unsplashUrl = "https://api.unsplash.com/search/photos?query=$query&per_page=150&page=1";

    final pexelsResponse = await http.get(Uri.parse(pexelsUrl),
        headers: {
          'Authorization': '4qZ2txUCt5XrsjKk7YrkDanR5BvZwuyt5xR4zPW5kWL6LfkjxZapfsQM'
        }
    );

    final unsplashResponse = await http.get(Uri.parse(unsplashUrl),
        headers: {
          'Authorization': 'Client-ID StGi4MHWQApE24YNTplYIq1mBRl-jhbFyoRSqvYEyso'
        }
    );

    if (pexelsResponse.statusCode == 200 &&
        unsplashResponse.statusCode == 200) {
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
    final screenSize = MediaQuery
        .of(context)
        .size;
    final width = screenSize.width;
    final height = screenSize.height;
    final padding = width * 0.05;
    final fontSize = width * 0.05;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _searchController.clear();
          FocusScope.of(context).unfocus();
          fetchApi();
          setState(() {
            showChoices = false;
          });
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              expandedHeight: height * 0.3,
              flexibleSpace: FlexibleSpaceBar(
                title: GestureDetector(
                  onTap: scrollToTop,
                  child: _isSearchedFocus
                      ? null
                      : Text(
                    'The Wallviz',
                    style: GoogleFonts.aclonica(
                      color: Colors.teal,
                      fontSize: fontSize * 1.7,
                    ),
                  ),
                ),
                background: _buildChoicesList(width, height),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: TextField(
                  focusNode: _searchFocusNode,
                  cursorColor: Colors.teal[300],
                  style: GoogleFonts.farro(
                    color: Colors.teal[300],
                  ),
                  contextMenuBuilder: (context, editableTextState) {
                    return AdaptiveTextSelectionToolbar.editableText(
                      editableTextState: editableTextState,
                    );
                  },
                  onTap: () {
                    setState(() {
                      showChoices = true;
                    });
                  },
                  onSubmitted: (query) => _search(context),
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Wallpapers...',
                    hintStyle: GoogleFonts.farro(
                      color: Colors.teal[300],
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.teal[300],
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    filled: true,
                    fillColor: Colors.transparent.withOpacity(0.6),
                    suffixIcon: IconButton(
                      color: Colors.teal[300],
                      onPressed: () {
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                        fetchApi();
                        setState(() {
                          showChoices = false;
                        });
                      },
                      icon: Icon(Icons.clear),
                    ),
                  ),
                ),
              ),
            ),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 3,
                childAspectRatio: 2 / 3,
                mainAxisSpacing: 3,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final image = images[index];
                  final imageUrl =
                  image != null && image['src'] != null
                      ? image['src']['tiny']
                      : null;

                  if (imageUrl == null) {
                    return Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey[200],
                    );
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageScreen(
                            imageUrls: [images[index]['src']['large2x']],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.black,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 150,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 150,
                            color: Colors.grey[200],
                          );
                        },
                      ),
                    ),
                  );
                },
                childCount: images.length,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: height * 0.1,
        width: width * 0.2,
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0,),
          ),
          backgroundColor: Colors.transparent.withOpacity(0.8),
          onPressed: _isLoadingMore ? null : loadMore,
          child: _isLoadingMore ? SizedBox(
            height: height * 0.028,
            width: width * 0.047,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: Colors.teal,
            ),
          ) : Icon(
            Icons.add,
            color: Colors.teal[300],
            size: width * 0.111,
          ),
        ),
      ),
    );
  }

  Widget _buildChoicesList(double width, double height) {
    choices.shuffle();

    return Container(
      padding: EdgeInsets.only(top: height * 0.04),
      color: Colors.black,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(
                  min(choices.length, 37),
                      (index) => _buildChip(index),
                ),
              ),
              SizedBox(height: height * 0.01,),
              Row(
                children: List.generate(
                  min(choices.length - 37, 37),
                      (index) => _buildChip(index + 37),
                ),
              ),
              SizedBox(height: height * 0.01,),
              Row(
                children: List.generate(
                  min(choices.length - 37, 37),
                      (index) => _buildChip(index + 74),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChip(int index) {
    final screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
      ),
      child: ChoiceChip(
        label: Text(
          choices[index],
          style: TextStyle(color: Colors.teal),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0,),
          side: BorderSide(color: Colors.teal,),
        ),
        selected: tag == false,
        onSelected: (selected) {
          setState(() {
            tag = index;
            selectedValue = choices[index];
            _searchController.text = selectedValue!;
            _search(context);
          });
        },
      ),
    );
  }
}