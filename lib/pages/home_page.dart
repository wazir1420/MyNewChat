import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/pages/search_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyHomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        centerTitle: true,
        title: Text(
          'Chat App',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchPage(
                      userModel: widget.userModel,
                      firebaseUser: widget.firebaseUser)));
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
    );
  }
}
