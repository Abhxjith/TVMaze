import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';  
import 'package:flutter_spinkit/flutter_spinkit.dart';  
import 'details_screen.dart';
import 'search_screen.dart';  

class NetflixHomeScreen extends StatefulWidget {
  @override
  _NetflixHomeScreenState createState() => _NetflixHomeScreenState();
}

class _NetflixHomeScreenState extends State<NetflixHomeScreen> {
  List<dynamic> shows = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  int _selectedIndex = 0;  // To track the selected screen

  @override
  void initState() {
    super.initState();
    fetchShows();
  }

  Future<void> fetchShows() async {
    try {
      final response = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=all'));
      if (response.statusCode == 200) {
        setState(() {
          shows = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
    }
  }

  Future<void> searchShows(String searchTerm) async {
    if (searchTerm.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=$searchTerm'));
      if (response.statusCode == 200) {
        setState(() {
          searchResults = jsonDecode(response.body);
        });
      } else {
        
      }
    } catch (e) {
      
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0  
          ? AppBar(
              backgroundColor: Colors.black,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    searchShows(value);
                  },
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                  ),
                ),
              ),
              actions: [
                Icon(Icons.notifications, color: Colors.white),
                SizedBox(width: 16),
              ],
            )
          : null,  
      backgroundColor: Colors.black,
      body: _selectedIndex == 0
          ? isLoading
              ? Center(
                  child: SpinKitFadingCircle(
                    color: Colors.red,  
                    size: 50.0,  
                  ),
                )  
              : searchResults.isNotEmpty || searchController.text.isNotEmpty
                  ? _buildSearchResultsGrid()
                  : ListView(
                      children: [
                        SizedBox(height: 16),
                        _buildCarouselHero(),
                        SizedBox(height: 16),
                        _buildRowHeader('Trending Now'),
                        SizedBox(height: 8),
                        _buildHorizontalList(shows.isEmpty ? [] : shows.sublist(3, 9)),
                        SizedBox(height: 16),
                        _buildRowHeader('Popular on TV Maze'),
                        SizedBox(height: 8),
                        _buildHorizontalList(shows.isEmpty ? [] : shows.sublist(0, shows.length < 15 ? shows.length : 15)),
                      ],
                    )
          : SearchScreen(), 
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselHero() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 270.0,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
      items: shows.isNotEmpty
          ? shows.sublist(0, 3).map((item) {
              final show = item['show'];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(show: show),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: show['image'] != null
                      ? Image.network(show['image']['original'], fit: BoxFit.cover)
                      : Container(color: Colors.grey[800]),
                ),
              );
            }).toList()
          : [],
    );
  }

  Widget _buildRowHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<dynamic> shows) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: shows.length,
        itemBuilder: (context, index) {
          final show = shows[index]['show'];
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 16 : 8, right: index == shows.length - 1 ? 16 : 8),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(show: show),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: show['image'] != null
                        ? Image.network(show['image']['medium'], fit: BoxFit.cover, height: 150, width: 100)
                        : Container(color: Colors.grey[800], height: 150, width: 100),
                  ),
                  SizedBox(height: 8),
                  Text(
                    show['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  
  Widget _buildSearchResultsGrid() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(8.0),
          sliver: SliverGrid.count(
            crossAxisCount: 2,  
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 12.0,
            childAspectRatio: 0.55,  
            children: List.generate(
              searchResults.length,
              (index) {
                final show = searchResults[index]['show'];
                return Center( 
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(show: show),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,  
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(7.0),
                          child: show['image'] != null
                              ? Image.network(
                                  show['image']['medium'],
                                  fit: BoxFit.cover,
                                  height: 220, 
                                  width: double.infinity,
                                )
                              : Container(
                                  color: Colors.grey[800],
                                  height: 220,
                                  width: double.infinity,
                                ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          show['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
