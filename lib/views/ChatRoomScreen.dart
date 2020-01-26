import 'package:bandmates/Utils.dart';
import 'package:bandmates/views/HomeScreen.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:bandmates/views/UI/ChatMessage.dart';
import 'package:line_icons/line_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/User.dart';
import '../models/Chat.dart';
import './UI/Progress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import 'package:timeago/timeago.dart' as timeago;

import 'package:provider/provider.dart';

class ChatRoomScreen extends StatefulWidget {
  static const routeName = '/chat-screen';

  final Chat chat;

  ChatRoomScreen({this.chat});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState(chat: chat);
}

class _ChatRoomScreenState extends State<ChatRoomScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<ChatMessage> _messages = <ChatMessage>[];
  FocusNode _focusNode = FocusNode();
  File _imageFile;
  bool _isLoading;
  User _currentUser;

  Chat chat;

  _ChatRoomScreenState({this.chat});

  bool _isComposing = false;

  String _chatName;
  String _chatPhoto;

  @override
  void initState() {
    super.initState();

    _currentUser = currentUser;
    _chatName = _buildChatName();
    _chatPhoto = _buildChatPhoto();
  }

  String _buildChatName() {
    if (chat.name != null) {
      return chat.name;
    }
    String chatName;
    chat.users.forEach((key, value) {
      if (key != _currentUser.uid) {
        chatName = value['name'];
      }
    });

    return chatName;
  }

  _buildChatPhoto() {
    if (chat.photoUrl != null) {
      return chat.photoUrl;
    }
    String chatPhoto;
    chat.users.forEach((key, value) {
      if (key != _currentUser.uid) {
        chatPhoto = value['avatar'];
      }
    });

    return chatPhoto;
  }

  @override
  Widget build(BuildContext context) {
    print("[ChatRoomScreen] currentUser: " + _currentUser.name);
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            builderHeader(),
            Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream: Provider.of<ChatProvider>(context)
                    .getMessages(widget.chat.id),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.data == null) {
                    return Center(child: Text("No Messages yet"));
                  }

                  if (snapshot.hasError) {
                    Utils.buildErrorDialog(context, snapshot.error);
                  }

                  if (snapshot.data.documents.length == 0) {
                    return Center(child: Text("No Messages yet"));
                  }

                  if (snapshot.hasData) {
                    return new ListView.builder(
                      padding: new EdgeInsets.all(8.0),
                      reverse: true,
                      itemBuilder: (_, int index) => buildItem(
                          index,
                          snapshot.data.documents[index],
                          snapshot.data.documents),
                      /*Text(
                                                (snapshot.data.documents[index]
                                                                ['user'] ==
                                                            _currentUser.uid
                                                        ? _currentUser.name
                                                        : widget.otherUser.name) +
                                                    " - " +
                                                    snapshot.data.documents[index]
                                                        ['text']),*/
                      itemCount: snapshot.data.documents.length, //new
                    );
                  } else {
                    return circularProgress(context);
                  }
                },
              ),
            ),
            _buildTextComposer(context),
          ],
        ),
      ),
    );
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
                key: _formKey,
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

      Provider.of<ChatProvider>(context).sendMessage(
          text: text, chatID: chat.id, userID: _currentUser.uid, type: type);

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
                          imageUrl: widget.chat.users[document['user']]
                                      ['avatar'] ==
                                  null
                              ? "https://llhh.org/pps-medias/14714.jpg"
                              : widget.chat.users[document['user']]['avatar'],
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
                      timeago.format(document['time'].toDate()),
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

  builderHeader() {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25))),
        padding: EdgeInsets.only(left: 12, top: 32),
        height: 100,
        width: double.infinity,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    LineIcons.arrow_left,
                    size: 32,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                if (_chatPhoto != null)
                  CircularProfileAvatar(
                    _chatPhoto,
                    radius: 25,
                    borderColor: Colors.white,
                    borderWidth: 1,
                  ),
                SizedBox(
                  width: 12,
                ),
                Text(
                  _chatName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18),
                ),
                // Align(
                //   alignment: Alignment.topLeft,
                //   child: IconButton(
                //     icon: Icon(
                //       LineIcons.ellipsis_v,
                //       size: 32,
                //       color: Colors.white,
                //     ),
                //     onPressed: () => print("Menu clicked"),
                //   ),
                // ),
              ],
            ),
          ],
        ));
  }
}
