import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import '../scoped_models/main.dart';

class CameraPage extends StatefulWidget {
  final MainModel model;

  CameraPage(this.model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CameraPageState();
  }
}

class _CameraPageState extends State<CameraPage> {
  File _image;

  notify(BuildContext context, String txt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('alert box'),
            content: Text(txt),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ]);
      },
    );
  }

  Future getImage({bool camera = true}) async {

      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      Map<String, bool> response = await widget.model.uploadImage(image, image.path);

    if (response['success'] == true) {
      notify(context, 'successully uploaded');
    }

//    List<int> imageBytes = await image.readAsBytes();
//    print('image bytes \n\n${imageBytes}');
//    String base64Image = base64Encode(imageBytes);
//    print('base64 \n\n${base64Image}');

    setState(() {
      _image = image;
      print('this is the image path ${_image.path}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Example'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Center(
              child: _image == null
                  ? Text('No image selected.')
                  : Image.file(_image),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}

//floatingActionButton: FloatingActionButton(
//onPressed: getImage,
//tooltip: 'Pick Image',
//child: Icon(Icons.add_a_photo),
//),
//Center(
//child: _image == null
//? Text('No image selected.')
//: Image.file(_image),
//),
//floatingActionButton: FloatingActionButton(
//onPressed: getImage,
//tooltip: 'Pick Image',
//child: Icon(Icons.add_a_photo),
//),
//)


//Stack(
//children: <Widget>[
//Align(
//alignment: Alignment.bottomLeft,
//child: FloatingActionButton(
//onPressed: () {
//getImage(true);
//},
//tooltip: 'click Image',
//child: Icon(Icons.add_a_photo),
//),
//),
//Align(
//alignment: Alignment.bottomRight,
//child: FloatingActionButton(
//onPressed: () {
//getImage(false);
//},
//tooltip: 'Pick Image',
//child: Icon(Icons.list),
//),
//),
//],
//)