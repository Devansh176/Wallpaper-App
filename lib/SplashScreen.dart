import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallviz/Wallpaper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 2,), (){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Wallpaper(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final padding = width * 0.05;

    return Scaffold(
      backgroundColor: Color(0xFFE6C7CE),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ClipOval(
              child: Image(
                image: AssetImage("assets/logo-png.png"),
                fit: BoxFit.cover,
                width: 300,
                height: 300,
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.1,),
          Text('Wallviz',
            style: GoogleFonts.nunito(
              color: Color(0xFF43385D),
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
