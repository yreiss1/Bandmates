import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Chat {
  final String id;
  final List<String> users;

  Chat({this.id, this.users});

  factory Chat.fromDocument(DocumentSnapshot doc) {}
}

class ChatProvider with ChangeNotifier {
  List<Chat> _chats = [];

  List<Chat> get chats {
    return [..._chats];
  }

  CollectionReference chatsRef = Firestore.instance.collection("chats");
  CollectionReference userRef = Firestore.instance.collection("users");

  Future<DocumentSnapshot> getChat(String fromID, String toID) async {
    QuerySnapshot query =
        await chatsRef.where("users", arrayContains: fromID).getDocuments();

    DocumentSnapshot chatRoom = query.documents.firstWhere((chatRoom) {
      return chatRoom.data["users"].contains(toID);
    }, orElse: () => null);

    if (chatRoom != null) {
      return chatRoom;
    } else {
      Map<String, dynamic> chatMap = {
        "users": [fromID, toID],
        "time": DateTime.now(),
        "lastMsg": null
      };

      DocumentReference ref = await chatsRef.add(chatMap);
      userRef
          .document(fromID)
          .collection("chats")
          .document(ref.documentID)
          .setData({"active": true});
      userRef
          .document(toID)
          .collection("chats")
          .document(ref.documentID)
          .setData({"active": true});
      DocumentSnapshot chat = await ref.get();
      return chat;
    }
  }

  Stream<QuerySnapshot> getChats(String uid) {
    return Firestore.instance
        .collection("chats")
        .where("users", arrayContains: uid)
        .orderBy("time", descending: true)
        .snapshots();

    //print("[Chat]: " + chatRefs.documents.toString());
  }
}
