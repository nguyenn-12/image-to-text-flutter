import 'dart:io';

import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String result = '';
  File? image;
  ImagePicker? imagePicker;

  pickImageFromGallery() async {
    XFile? pickedFile = await imagePicker!.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
        performImageLabeling();
      });
    }
  }

  pickImageFromCamera() async {
    XFile? pickedFile = await imagePicker!.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
        performImageLabeling();
      });
    }
  }

  performImageLabeling() async {
    if (image == null) return;

    // Chuyển đổi hình ảnh sang InputImage
    final InputImage inputImage = InputImage.fromFile(image!);

    // Khởi tạo bộ nhận diện văn bản từ Google ML Kit
    final TextRecognizer textRecognizer = GoogleMlKit.vision.textRecognizer();

    // Xử lý ảnh để nhận diện văn bản
    RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    // Đóng textRecognizer để tránh rò rỉ bộ nhớ
    await textRecognizer.close();

    result = '';
    setState(() {
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          result += "${line.text}\n";
        }
        result += "\n";
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/back.jpg'), fit: BoxFit.cover
          ),
        ),
        child: Column(
          children: [
            SizedBox(width: 100),
            Container(
              height: 280,
              width: 250,
              margin: const EdgeInsets.only(top:70),
              padding: const EdgeInsets.only(left: 28, bottom: 5, right: 18),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    result,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/note.jpg'),
                fit: BoxFit.cover
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top:20, right:140),
              child: Stack(
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/pin.png',
                          height: 240,
                          width: 240,
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: TextButton(
                        onPressed: () {
                          pickImageFromGallery();
                        },
                        onLongPress: () {
                          pickImageFromCamera();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top:25),
                          child: image!=null
                            ? Image.file(image!, width: 140, height: 192, fit: BoxFit.fill)
                              : Container(
                            width: 240,
                            height: 200,
                            child: const Icon(Icons.camera_enhance_sharp, size: 100, color: Colors.grey,),
                          )
                        )
                    )
                  )
                ],
              ),
            )
          ],
        )
      )
    );
  }
}
