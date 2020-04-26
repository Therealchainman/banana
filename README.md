# banana
Shopping app for visually impaired.  
## Some things I implemented
Flutter, Dart, Firebase ML Kit, flutter_tts package, Android phone

## How to run the program how I did. 
I used an emulator with hardware accelerator from Android studio, 
The emulator was for a Pixel 2 API R  with resolution 1080 x 1920: 420 dpi, playstore, CPU - x86.  

IDE: Intellij Community Edition  2019.2.2
OS: Windows 10 64 bit
GPU: Nvidia GeForce GTX 1050

I had to open android studio and go to Configure -> AVD Manager and click on the play symbol for the emulator. 
With the emulator running I click run on Intellij and the app works.  Then you can download some photos to your emulator from your drive and upload those images into the app for image labeling.  
Google drive works sporadically with this emulator.  

Once you upload images you can click on the results for it to convert text to speech.  


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

- Vision (https://cloud.google.com/vision/docs) - but for mobile apps use Firebase ML Kit (https://firebase.google.com/docs/ml-kit).
- Text-To-Speech (https://cloud.google.com/text-to-speech/docs)
Firebase (https://firebase.google.com/) - mobile / web development platform featuring the Firebase realtime database
