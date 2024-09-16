// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:skin_detection/presentation/screens/skin_disease_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skin Disease Detection',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
       home: SkinDiseaseScreen()
    );
  }
}

 
   

   

