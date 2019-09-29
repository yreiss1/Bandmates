import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  static const routeName = '/chat-screen';
  final List<Contact> _contacts = [
    Contact(email: "omeryampel.gmail", fullName: "Omer Yampel"),
    Contact(email: "omeryampel.gmail", fullName: "Omer Yampel"),
    Contact(email: "omeryampel.gmail", fullName: "Omer Yampel"),
    Contact(email: "omeryampel.gmail", fullName: "Omer Yampel"),
    Contact(email: "omeryampel.gmail", fullName: "Omer Yampel"),
    Contact(email: "omeryampel.gmail", fullName: "Omer Yampel")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              _ContactListItem(_contacts[index]),
              Divider(),
            ],
          );
        },
        itemCount: _contacts.length,
      ),
    );
  }
}

class _ContactListItem extends ListTile {
  _ContactListItem(Contact contact)
      : super(
            title: new Text(contact.fullName),
            subtitle: new Text(contact.email),
            leading: new CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                    "https://thumbnailer.mixcloud.com/unsafe/1200x628/tmp/7/4/2/8/fac1-7b75-4a97-a54c-02d8d853fa48")));
}

class Contact {
  final String fullName;
  final String email;

  const Contact({this.fullName, this.email});
}
