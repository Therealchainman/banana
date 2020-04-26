import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hover_effect/hover_effect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File pickedImage;
  var text = '';

  bool imageLoaded = false;

  Future pickImage() async {
    var awaitImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = awaitImage;
      imageLoaded = true;
    });

    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(pickedImage);

    final ImageLabeler cloudLabeler =
    FirebaseVision.instance.cloudImageLabeler();

    final List<ImageLabel> cloudLabels =
    await cloudLabeler.processImage(visionImage);
    final List<double> tracker = new List();

    for (ImageLabel label in cloudLabels) {
      final confidence = label.confidence.toStringAsFixed(2);
      final name = label.text;
      if (tracker.length == 3) {
        break;
      }
      tracker.add(label.confidence);
      setState(() {
        text = "$text $name   $confidence \n";

      });
    }

    cloudLabeler.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      body: Column(
        children: <Widget>[
          SizedBox(height: 100.0),
          imageLoaded
              ? Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(blurRadius: 20),
                  ],
                ),
                margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                height: 250,
                child: Image.file(
                  pickedImage,
                  fit: BoxFit.cover,
                ),
              ))
              : Container(),
          SizedBox(height: 10.0),
          Center(
            child: FlatButton.icon(
              icon: Icon(
                Icons.photo_camera,
                size: imageLoaded ? 100 : 350,
                color: Colors.orange,
              ),
              label: Text(''),
              textColor: Theme.of(context).hoverColor,
              onPressed: () async {
                pickImage();
              },
            ),
          ),
          SizedBox(height: 20.0),
          SizedBox(height: 20.0),
          text == ''
              ? Text('Choose an Image',
              style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],),)
              : Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],),
                ),
              ),
              )
            ),
          ),
        ],
      ),
    );
  }
}