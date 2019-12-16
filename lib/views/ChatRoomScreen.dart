import 'package:cloud_firestore/cloud_firestore.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:jammerz/views/HomeScreen.dart';
import 'package:jammerz/views/UI/ChatMessage.dart';
import 'package:line_icons/line_icons.dart';
import 'package:firestore_ui/firestore_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/User.dart';
import '../models/Chat.dart';
import './UI/Progress.dart';
import '../Utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class ChatRoomScreen extends StatefulWidget {
  static const routeName = '/chat-screen';

  final User otherUser;

  ChatRoomScreen({this.otherUser});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  FocusNode _focusNode = FocusNode();
  File _imageFile;
  bool _isLoading;
  User _currentUser;
  DocumentSnapshot _chatRef;

  bool _isComposing = false;

  Future<DocumentSnapshot> _getChats;
  @override
  void initState() {
    // TODO: implement initState
    //_getChats = _getChat(null, widget.otherUser.uid);
    super.initState();
    _currentUser = Provider.of<UserProvider>(context, listen: false).user;
    _getChats = getChatRef();
  }

  getChatRef() {
    return Provider.of<ChatProvider>(context, listen: false)
        .getChat(_currentUser.uid, widget.otherUser.uid);
  }

  @override
  Widget build(BuildContext context) {
    print("[ChatRoomScreen] currentUser: " + _currentUser.name);
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            widget.otherUser.name,
            style: TextStyle(color: Color(0xFF1d1e2c), fontSize: 16),
          ),
          leading: IconButton(
            icon: Icon(
              LineIcons.arrow_left,
              color: Color(0xFF1d1e2c),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  LineIcons.ellipsis_v,
                  color: Color(0xFF1d1e2c),
                  size: 30,
                ),
                onPressed: () {})
          ],
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Flexible(
              child: FutureBuilder<DocumentSnapshot>(
                future: _getChats,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      Utils.buildErrorDialog(
                          context, snapshot.error.toString());
                    } else {
                      if (snapshot.hasData) {
                        if (_chatRef == null) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => setState(() {
                                    _chatRef = snapshot.data;
                                  }));
                        }

                        print("[ChatRoomScreen] chatID: " +
                            snapshot.data.documentID);
                        return StreamBuilder(
                          stream: Firestore.instance
                              .collection('chats')
                              .document(snapshot.data.documentID)
                              .collection("msgs")
                              .orderBy('time', descending: true)
                              .limit(20)
                              .snapshots(),
                          builder:
                              (BuildContext streamContext, streamSnapshot) {
                            if (streamSnapshot.hasData) {
                              return new ListView.builder(
                                //new
                                padding: new EdgeInsets.all(8.0), //new
                                reverse: true, //new
                                itemBuilder: (_, int index) => buildItem(
                                    index,
                                    streamSnapshot.data.documents[index],
                                    streamSnapshot.data.documents),
                                /*Text(
                                    (streamSnapshot.data.documents[index]
                                                    ['user'] ==
                                                _currentUser.uid
                                            ? _currentUser.name
                                            : widget.otherUser.name) +
                                        " - " +
                                        streamSnapshot.data.documents[index]
                                            ['text']),*/
                                itemCount:
                                    streamSnapshot.data.documents.length, //new
                              );
                            } else {
                              return circularProgress(context);
                            }
                          },
                        );
                      }
                    }
                  } else {
                    return circularProgress(context);
                  }
                },
              ),
            ),
            _buildTextComposer(context),
          ],
        ));
  }

  Widget _buildTextComposer(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(LineIcons.image),
                onPressed: getImage,
                color: Theme.of(context).primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          /*
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.face),
                onPressed: getSticker,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          */

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 15.0),
                controller: _textController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                ),
                focusNode: _focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendMessage(_textController.text, 0),
                color: Theme.of(context).primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(top: new BorderSide(width: 0.5)),
          color: Colors.white),
    );
  }

  Future getImage() async {
    _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (_imageFile != null) {
      setState(() {
        _isLoading = true;
      });
      //uploadFile();
    }
  }

  @override
  void dispose() {
    //new
    for (ChatMessage message in _messages) //new
      message.animationController.dispose(); //new
    super.dispose(); //new
  }

  void onSendMessage(String text, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (text.trim() != '') {
      _textController.clear();
      Firestore.instance
          .collection("chats")
          .document(_chatRef.documentID)
          .collection('msgs')
          .add({
        "user": _currentUser.uid,
        "content": text,
        "time": DateTime.now(),
        "type": 0
      });

      Firestore.instance.runTransaction((transaction) async {
        transaction.update(
            Firestore.instance
                .collection("chats")
                .document(_chatRef.documentID),
            {'lastMsg': text});
        transaction.update(
            Firestore.instance
                .collection("chats")
                .document(_chatRef.documentID),
            {'time': DateTime.now()});
      });

      //listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      //Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildItem(int index, DocumentSnapshot document,
      List<DocumentSnapshot> listMessage) {
    if (document['user'] == _currentUser.uid) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document['type'] == 0
              // Text
              ? Container(
                  child: Text(
                    document['content'],
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom:
                          isLastMessageRight(index, listMessage) ? 20.0 : 10.0,
                      right: 10.0),
                )
              : document['type'] == 1
                  // Image
                  ? Container(
                      child: FlatButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: document['content'],
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {}));
                          //FullPhoto(url: document['content'])));
                        },
                        padding: EdgeInsets.all(0),
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index, listMessage)
                              ? 20.0
                              : 10.0,
                          right: 10.0),
                    )
                  // Sticker
                  : Container(
                      child: new Image.asset(
                        'images/${document['content']}.gif',
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index, listMessage)
                              ? 20.0
                              : 10.0,
                          right: 10.0),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index, listMessage)
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor),
                            ),
                            width: 35.0,
                            height: 35.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: widget.otherUser.photoUrl == null
                              ? "https://llhh.org/pps-medias/14714.jpg"
                              : widget.otherUser.photoUrl,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: 35.0),
                document['type'] == 0
                    ? Container(
                        child: Text(
                          document['content'],
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : document['type'] == 1
                        ? Container(
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).primaryColor),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      'images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document['content'],
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder:
                                            (context) {})); //FullPhoto(url: document['content'])));
                              },
                              padding: EdgeInsets.all(0),
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        : Container(
                            child: new Image.asset(
                              'images/${document['content']}.gif',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index, listMessage)
                                    ? 20.0
                                    : 10.0,
                                right: 10.0),
                          ),
              ],
            ),

            // Time
            isLastMessageLeft(index, listMessage)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm')
                          .format(document['time'].toDate()),
                      style: TextStyle(
                          fontSize: 12.0, fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index, List<DocumentSnapshot> listMessage) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['user'] == _currentUser.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index, List<DocumentSnapshot> listMessage) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['user'] != _currentUser.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }
}
