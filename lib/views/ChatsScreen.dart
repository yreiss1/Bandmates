import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:jammerz/views/ChatRoomScreen.dart';
import 'package:jammerz/views/UI/Progress.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import '../models/Chat.dart';
import 'package:intl/intl.dart';
import '../models/User.dart';
import 'package:provider/provider.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).currentUser.uid;

    return Scaffold(
      body: StreamBuilder(
        stream: Provider.of<ChatProvider>(context).getChats(uid),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.documents.length == 0) {
              return Center(
                  child: Container(
                width: MediaQuery.of(context).size.width * .8,
                child: Text(
                  "You have no chats currently, start chatting to get the party going!",
                  textAlign: TextAlign.center,
                ),
              ));
            } else {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, index) {
                  String other;
                  if (snapshot.data.documents[index].data['users'][0] == uid) {
                    other = snapshot.data.documents[index].data['users'][1];
                  } else {
                    other = snapshot.data.documents[index].data['users'][0];
                  }

                  return FutureBuilder(
                    future: Provider.of<UserProvider>(context).getUser(other),
                    builder: (BuildContext futureContext, futureSnapshot) {
                      if (futureSnapshot.connectionState ==
                          ConnectionState.done) {
                        if (snapshot.hasData) {
                          return Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return ChatRoomScreen(
                                      otherUser: futureSnapshot.data,
                                    );
                                  }),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    children: <Widget>[
                                      Material(
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              Container(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.0,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Theme.of(context)
                                                          .primaryColor),
                                            ),
                                            width: 35.0,
                                            height: 35.0,
                                            padding: EdgeInsets.all(10.0),
                                          ),
                                          imageUrl: futureSnapshot
                                                      .data.photoUrl ==
                                                  null
                                              ? "https://llhh.org/pps-medias/14714.jpg"
                                              : futureSnapshot.data.photoUrl,
                                          width: 35.0,
                                          height: 35.0,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(18.0),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    futureSnapshot.data.name,
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                ),
                                                Text(
                                                  DateFormat('dd MMM kk:mm')
                                                      .format(snapshot
                                                          .data
                                                          .documents[index]
                                                          .data['time']
                                                          .toDate()),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption,
                                                )
                                              ],
                                            ),
                                            if (snapshot.data.documents[index]
                                                    .data['lastMsg'] !=
                                                null)
                                              SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  snapshot.data.documents[index]
                                                      .data['lastMsg'],
                                                  style: TextStyle(
                                                      fontSize:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .caption
                                                              .fontSize,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .caption
                                                          .color,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                ),
                                              ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),
                            ],
                          );
                        }
                      } else {
                        return Container(
                          width: double.infinity,
                          height: 50,
                          child: PKCardListSkeleton(
                            isBottomLinesActive: false,
                            isCircularImage: true,
                            length: 1,
                          ),
                        );
                      }
                    },
                  );
                },
              );
            }
          } else {
            return circularProgress(context);
          }
        },
      ),

      /*
      ListView.builder(
        itemCount: 5,
        itemBuilder: (BuildContext context, index) {
          return Column(
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) {
                    return ChatRoomScreen();
                  }),
                ),
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 25.0,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Contact $index',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                Text(
                                  "Last seen 24hrs ago",
                                  style: Theme.of(context).textTheme.caption,
                                )
                              ],
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                "The last thing I wrote",
                                style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .fontSize,
                                  color:
                                      Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Divider(),
            ],
          );
        },
      ),
      */
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
            radius: 25.0,
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
