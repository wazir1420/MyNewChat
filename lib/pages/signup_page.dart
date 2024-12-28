import 'package:chatapp/models/ui_helper.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/pages/completeprofile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailContoller = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController cPassController = TextEditingController();
  void check() {
    var email = emailContoller.text.trim();
    var pass = passController.text.trim();
    var cPass = cPassController.text.trim();

    if (email == '' || pass == '' || cPass == '') {
      UIHelper.showAlertDialog(
          context, 'Incomplete data', 'Please fill all the fields');
    } else if (pass != cPass) {
      UIHelper.showAlertDialog(context, 'Password Mismatch',
          'The password you entered do not match');
    } else {
      signUp(email, pass);
    }
  }

  void signUp(String email, String pass) async {
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, 'Creating new Account...');
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(
          context, 'An error occured', ex.message.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, email: email, fullname: '', profilePic: '');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        Navigator.popUntil(context, (route) => route.isFirst);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => CompleteProfile(
                    userModel: newUser, firebaseUser: credential!.user!)));
        print('New user created');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Chat App',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: emailContoller,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: cPassController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                ),
                SizedBox(
                  height: 20,
                ),
                CupertinoButton(
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () {
                      check();
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
          ),
        ),
      )),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account?",
            style: TextStyle(fontSize: 16),
          ),
          CupertinoButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Sign In',
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
