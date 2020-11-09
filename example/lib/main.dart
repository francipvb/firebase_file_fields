import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_file_fields/firebase_file_fields.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PickedFile _file;
  Future _initialization;
  Reference _ref;

  @override
  void initState() {
    _initFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: FutureBuilder(
            future: _initialization,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              return FirebaseImageFormField(
                parentReference: _ref,
                enableCamera: true,
              );
            },
          ),
        ),
      ),
    );
  }

  void _initFirebase() {
    _initialization = Firebase.initializeApp()
        .then((value) => _ref = FirebaseStorage.instance.ref('images'))
        .then((value) async {
      if (FirebaseAuth.instance.currentUser == null)
        FirebaseAuth.instance.signInAnonymously();
    });
  }
}
