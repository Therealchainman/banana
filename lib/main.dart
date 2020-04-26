import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("assets/backgroundApp.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: MyHomePage(),
      ),
      debugShowCheckedModeBanner: false,
//      home: MyHomePage(),
    );
  }
}

enum TtsState { playing, stopped }

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
//  This part gets the image and loads it.
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
      final confidence = (label.confidence*100).toStringAsFixed(2);
      final name = label.text;
      if (tracker.length == 3) {
        break;
      }
      tracker.add(label.confidence);
      setState(() {
        text = "$text $name   $confidence% \n";

      });
    }
    audio(text);

    cloudLabeler.close();
  }
// This part is for the text to speech.
  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;

  String _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    _getLanguages();

    flutterTts.setStartHandler(() {
      setState(() {
        print("playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    if (languages != null) setState(() => languages);
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(_newVoiceText);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems() {
    var items = List<DropdownMenuItem<String>>();
    for (String type in languages) {
      items.add(DropdownMenuItem(value: type, child: Text(type)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language);
    });
  }

  void audio(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: <Widget>[
          SizedBox(height: 100.0),
          imageLoaded
              ? Center(
              child: Container(
                decoration: BoxDecoration(
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
                text = '';
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
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.red)
                  ),
                  color: Colors.blueGrey[600],
                  child: Text(
                    text.trim(),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],),
                  ),
                  onPressed: () => _speak(),
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