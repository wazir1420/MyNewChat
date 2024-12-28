import 'dart:io';

import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? imagefile;
  TextEditingController fullnameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedfile = await ImagePicker().pickImage(source: source);

    if (pickedfile != null) {
      cropImage(pickedfile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );

    if (croppedFile != null) {
      setState(() {
        imagefile = File(croppedFile.path);
      });
    }
  }

  void showPhotoOption() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Upload Profile Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
                leading: Icon(Icons.photo_album),
                title: Text('Select from Gallery'),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
              ),
            ],
          ),
        );
      },
    );
  }

  void checkValues() {
    String fullname = fullnameController.text.trim();
    if (fullname == '' || imagefile == null) {
      print('Please fill all fields');
      Navigator.popUntil(context, (route) => route.isFirst);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MyHomePage(
                  userModel: widget.userModel,
                  firebaseUser: widget.firebaseUser)));
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref('profilePictures')
        .child(widget.userModel.uid.toString())
        .putFile(imagefile!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullname = fullnameController.text.trim();
    widget.userModel.fullname = fullname;
    widget.userModel.profilePic = imageUrl;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      print('Data Uploaded');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyHomePage(
                  userModel: widget.userModel,
                  firebaseUser: widget.firebaseUser)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        centerTitle: true,
        title: Text(
          'Complete Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: ListView(
            children: [
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  showPhotoOption();
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      imagefile != null ? FileImage(imagefile!) : null,
                  child: imagefile == null
                      ? Icon(
                          Icons.person,
                          size: 60,
                        )
                      : null,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: fullnameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  checkValues();
                },
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
