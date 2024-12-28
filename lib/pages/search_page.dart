import 'dart:math';

import 'package:chatapp/main.dart';
import 'package:chatapp/models/chatroom_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/pages/chat_room_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('participants.${widget.userModel.uid}', isEqualTo: true)
        .where('participants.${targetUser.uid}', isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatRoom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatRoom;
    } else {
      ChatRoomModel newChatroom = ChatRoomModel(
          chatroomid: uuid.v1(),
          lastMessage: '',
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true
          });
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());
      chatRoom = newChatroom;
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            TextFormField(
              controller: searchController,
              decoration: InputDecoration(labelText: 'Email Address'),
            ),
            SizedBox(
              height: 20,
            ),
            CupertinoButton(
              onPressed: () {
                setState(() {});
              },
              color: Theme.of(context).colorScheme.secondary,
              child: Text(
                'Search',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: searchController.text)
                    .where('email', isNotEqualTo: widget.userModel.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;
                      if (dataSnapshot.docs.isNotEmpty) {
                        Map<String, dynamic> userMap =
                            dataSnapshot.docs[0].data() as Map<String, dynamic>;
                        UserModel searchUser = UserModel.fromMap(userMap);
                        return ListTile(
                          onTap: () async {
                            ChatRoomModel? chatRoomModel =
                                await getChatRoomModel(searchUser);
                            if (chatRoomModel != null) {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                            targetUser: searchUser,
                                            userModel: widget.userModel,
                                            firebaseUser: widget.firebaseUser,
                                            chatroom: chatRoomModel,
                                          )));
                            }
                          },
                          leading: CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(searchUser.email!),
                          trailing: Icon(Icons.keyboard_arrow_right),
                        );
                      } else {
                        return Text('No result found!');
                      }
                    } else if (snapshot.hasData) {
                      return Text('An error occured!');
                    } else {
                      return Text('No result found!');
                    }
                  } else {
                    return CircularProgressIndicator();
                  }
                })
          ],
        ),
      )),
    );
  }
}
