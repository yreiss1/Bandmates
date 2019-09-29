import 'package:flutter/material.dart';

class EditProfile extends StatelessWidget {
  static const routeName = '/edit-profile';

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: Container(child: Form(child: new ListView(children: getForm()))),
    );
  }

  List<Widget> getForm() {
    List<Widget> formWidget = new List();

    formWidget.add(new TextFormField(
      decoration: InputDecoration(labelText: 'Enter Name', hintText: 'Name'),
    ));

    return formWidget;
  }
}
