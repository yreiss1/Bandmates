import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final usersRef = Firestore.instance.collection('users');

class TimelineScreen extends StatefulWidget {
  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  void initState() {
    super.initState();
  }

/*
  createUser() async {
    await usersRef.document("gsfgdfgs").setData({"Username": "Jeff"});
  }

  updateUser() async {
    final doc = await usersRef.document("gsfgdfgs").get();
    if (doc.exists) {
      doc.reference.updateData({"Username": "John"});
    }
  }

  deleteUser() async {
    final doc = await usersRef.document("gsfgdfgs").get();
    if (doc.exists) {
      await usersRef.document("gsfgdfgs").delete();
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(""),
      ),
    );
  }
}
