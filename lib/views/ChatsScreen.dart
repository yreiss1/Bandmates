import 'package:flutter/material.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:jammerz/views/UI/Header.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header("Chats"),
      body: Center(
        child: Text("Chats"),
      ),
    );
  }
}

class _ContactListItem extends ListTile {
  _ContactListItem(Contact contact)
      : super(
          title: new Text(contact.fullName),
          subtitle: new Text(contact.email),
          leading: CircularProfileAvatar(
            "https://thumbnailer.mixcloud.com/unsafe/1200x628/tmp/7/4/2/8/fac1-7b75-4a97-a54c-02d8d853fa48",
            initialsText: Text(contact.fullName.substring(0, 2)),
            cacheImage: true,
            radius: 30,
            borderColor: Colors.black45,
            borderWidth: 2,
            onTap: () {
              print("Hello World!");
            },
          ),
        );
}

class Contact {
  final String fullName;
  final String email;

  const Contact({this.fullName, this.email});
}
