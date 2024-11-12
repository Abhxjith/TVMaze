import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'pages/home_screen.dart';
import 'pages/search_screen.dart';
import 'pages/details_screen.dart';

void main() {
  runApp(TVMazeApp());
}

class TVMazeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TVMaze',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      debugShowCheckedModeBanner: false, 
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => NetflixHomeScreen(),
        '/search': (context) => SearchScreen(),
        '/details': (context) => DetailsScreen(
              show: ModalRoute.of(context)?.settings.arguments as dynamic,
            ),
      },
    );
  }
}
