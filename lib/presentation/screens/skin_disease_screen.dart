// ignore_for_file: prefer_const_constructors, unused_field, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';

class SkinDiseaseScreen extends StatefulWidget {
  const SkinDiseaseScreen({super.key});

  @override
  State<SkinDiseaseScreen> createState() => _SkinDiseaseScreenState();
}

class _SkinDiseaseScreenState extends State<SkinDiseaseScreen> {
  File? _image;
  List? _output;
  final ImagePicker _picker = ImagePicker();

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
          model: "assets/model_unquanta.tflite", labels: "assets/labels.txt");
      print("Successfully load the model");
    } catch (e) {
      print("error loading model : $e");
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      setState(() {
        _image = imageFile;
      });

      await predictDisease(imageFile);
    }
  }

  Future<void> predictDisease(File imageFile) async {
    var recognitions = await Tflite.runModelOnImage(
        path: imageFile.path,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 5,
        threshold: 0.0);

    if (recognitions != null) {
      recognitions.sort((a, b) =>
          (b["confidence"] as double).compareTo(a['confidence'] as double));

      setState(() {
        _output = recognitions.take(3).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    loadModel();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 185, 206, 239),
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            "Skin Disease Detection",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
          ),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 20 , vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _image == null
                  ? Center(
                      child: Text(
                      "No image selected.",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.redAccent),
                    ))
                  : Image.file(_image!),
              _output == null
                  ? Text("")
                  : Expanded(
                      child: ListView.builder(
                          itemCount: _output!.length,
                          itemBuilder: (context, index) {
                            var prediction = _output![index];
                            return ListTile(
                              title: Text(
                                "Predicted: ${prediction['label']}",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                              ),
                              subtitle: Text(
                                "confidence: ${(prediction['confidence'] * 100).toStringAsFixed(2)}%",
                                style: TextStyle(
                                    color: Colors.redAccent, fontSize: 18),
                              ),
                            );
                          })),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(double.infinity, 50)),
                child: Text(
                  "Select image",
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
