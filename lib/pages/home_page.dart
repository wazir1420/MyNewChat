import 'package:chatapp/models/chatroom_model.dart';
import 'package:chatapp/models/firebase_helper.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/pages/chat_room_page.dart';
import 'package:chatapp/pages/login_page.dart';
import 'package:chatapp/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ))
        ],
      ),
      body: SafeArea(
          child: Container(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chatrooms')
                .where('participants.${widget.userModel.uid}', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot =
                      snapshot.data as QuerySnapshot;
                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatRoomSnapshot.docs[index].data()
                              as Map<String, dynamic>);
                      Map<String, dynamic> participants =
                          chatRoomModel.participants!;
                      List<String> participantsKey = participants.keys.toList();
                      participantsKey.remove(widget.userModel.uid);
                      return FutureBuilder(
                          future: FirebaseHelper.getUserModelById(
                              participantsKey[0]),
                          builder: (context, userData) {
                            if (userData.connectionState ==
                                ConnectionState.done) {
                              if (userData.data != null) {
                                UserModel targetUser =
                                    userData.data as UserModel;
                                return ListTile(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatRoomPage(
                                              targetUser: targetUser,
                                              chatroom: chatRoomModel,
                                              userModel: widget.userModel,
                                              firebaseUser:
                                                  widget.firebaseUser))),
                                  leading: CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(targetUser.email.toString()),
                                  subtitle: (chatRoomModel.lastMessage
                                              .toString() !=
                                          '')
                                      ? Text(
                                          chatRoomModel.lastMessage.toString())
                                      : Text(
                                          'Say hi to your new friend!',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ),
                                );
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          });
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Center(
                    child: Text('No Chats'),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      )),
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
