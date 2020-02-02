import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final Map<dynamic, dynamic> users;
  final String name;
  final String photoUrl;
  final String lastMessage;

  Chat({this.id, this.users, this.name, this.photoUrl, this.lastMessage});

  factory Chat.fromDocument(DocumentSnapshot doc) {
    return Chat(
        id: doc.documentID,
        users: doc['users'],
        name: doc['name'],
        photoUrl: doc['avatar'],
        lastMessage: doc['lastMsg']);
  }
}

class ChatProvider with ChangeNotifier {
  List<Chat> _chats = [];

  List<Chat> get chats {
    return [..._chats];
  }

  CollectionReference chatsRef = Firestore.instance.collection("chats");
  CollectionReference messagesRef = Firestore.instance.collection("messages");
  CollectionReference userRef = Firestore.instance.collection("users");

  Future<DocumentSnapshot> createChat(
      Map<String, Map<String, dynamic>> users) async {
    DocumentReference chat = await chatsRef.add({
      'time': DateTime.now(),
      'users': users,
      'lastMsg': null,
      'idList': users.keys.toList(),
    });

    return await chat.get();
  }

  Future<void> sendMessage(
      {String text, int type, String chatID, String userID}) async {
    WriteBatch batch = Firestore.instance.batch();
    batch.setData(
        Firestore.instance
            .collection("chats")
            .document(chatID)
            .collection('msgs')
            .document(),
        {
          "user": userID,
          "content": text,
          "time": DateTime.now(),
          "type": type
        });

    batch.updateData(Firestore.instance.collection("chats").document(chatID),
        {'lastMsg': text, 'time': DateTime.now()});

    batch.commit().catchError((error) => print(error.toString()));
  }

  Stream<QuerySnapshot> getChats(String uid) {
    return chatsRef
        .where('idList', arrayContains: uid)
        .orderBy('time', descending: true)
        .limit(20)
        .snapshots();
  }

  Stream<QuerySnapshot> getMessages(String chatID) {
    return chatsRef
        .document(chatID)
        .collection("msgs")
        .orderBy('time', descending: true)
        .limit(20)
        .snapshots();
  }

  Future<DocumentSnapshot> getIndividualChat(
      String fromID,
      String fromName,
      String fromAvatar,
      String fromToken,
      String toID,
      String toName,
      String toAvatar,
      String toToken) async {
    QuerySnapshot query =
        await chatsRef.where('idList', arrayContains: fromID).getDocuments();

    DocumentSnapshot chatRoom = query.documents.firstWhere((chatRoom) {
      return chatRoom.data["idList"].contains(toID) &&
          chatRoom.data['users'].length == 2;
    }, orElse: () => null);

    if (chatRoom != null) {
      return chatRoom;
    } else {
      return createChat({
        fromID: {'name': fromName, 'avatar': fromAvatar, 'token': fromToken},
        toID: {'name': toName, 'avatar': toAvatar, 'token': toToken}
      });
    }
  }
}
