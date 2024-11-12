import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';  
import 'package:flutter_svg/flutter_svg.dart'; 

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<dynamic> searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> searchShows(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = []; // Clear results if query is empty
      });
      return;
    }
    
    final response = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=$query'));
    if (response.statusCode == 200) {
      setState(() {
        searchResults = jsonDecode(response.body);
      });
    } else {
      // Handle error if needed
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.grey), // Set the back button color to grey
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            searchShows(value); // Trigger search as you type
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
      body: searchResults.isEmpty
          ? Center(
              child: SvgPicture.asset(
                'assets/search.svg',  // Path to the SVG file in your assets
                height: 150,  // Adjust size as needed
                width: 150,
                fit: BoxFit.contain,
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(8.0),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,  // Adjust if needed to increase image size
                    mainAxisSpacing: 1.0,
                    crossAxisSpacing: 12.0,
                    childAspectRatio: 0.55,  // Adjust aspect ratio to increase container size
                    children: List.generate(
                      searchResults.length,
                      (index) {
                        final show = searchResults[index]['show'];
                        return Center( // Center-aligns each grid item
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/details', arguments: show);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,  // Align text to the left
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(7.0),
                                  child: show['image'] != null
                                      ? Image.network(
                                          show['image']['medium'],
                                          fit: BoxFit.cover,
                                          height: 220, // Increase height for larger images
                                          width: double.infinity,
                                        )
                                      : Container(
                                          color: Colors.grey[800],
                                          height: 220, // Match the fixed height
                                          width: double.infinity,
                                        ),
                                ),
                                SizedBox(height: 8.0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                                  child: Text(
                                    show['name'],
                                    style: GoogleFonts.inter(  // Use Google Inter font
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,  // Align the text to the left
                                  ),
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
            ),
    );
  }
}
