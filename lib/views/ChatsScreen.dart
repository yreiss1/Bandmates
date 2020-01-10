import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bandmates/views/ChatRoomScreen.dart';
import 'package:bandmates/views/UI/Progress.dart';
//import 'package:line_icons/line_icons.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import '../models/Chat.dart';
import '../models/User.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("[ChatScreen] Rebuilding the widget");

    return ListView(
      children: <Widget>[
        buildSearchHeader(),
        buildChatList(context),
      ],
    );
  }

  buildSearchHeader() {
    return Container(
      padding: EdgeInsets.only(left: 12, top: 32, right: 12),
      height: 100,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Chats",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {},
              )
            ],
          )

          // Expanded(
          //   child: SearchBar<Chat>(
          //     searchBarStyle: SearchBarStyle(
          //         backgroundColor: Colors.white,
          //         borderRadius: BorderRadius.all(Radius.circular(10.0))),
          //     onSearch: (String text) => _searchChats(),
          //     cancellationText: Text(
          //       "Cancel",
          //       style: TextStyle(color: Colors.white),
          //     ),
          //     onItemFound: (Chat chat, int index) {},
          //     minimumChars: 3,
          //     loader: Text("Loading"),
          //   ),
          // ),
        ],
      ),
    );
  }
}

buildChatList(context) {
  String uid = Provider.of<UserProvider>(context).currentUser.uid;

  return Container(
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30))),
    height: MediaQuery.of(context).size.height,
    width: double.infinity,
    child: Column(children: [
      Expanded(
        child: StreamBuilder(
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
                    if (snapshot.data.documents[index].data['users'][0] ==
                        uid) {
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
                                        futureSnapshot.data.photoUrl != null
                                            ? CircleAvatar(
                                                radius: 26,
                                                backgroundImage:
                                                    CachedNetworkImageProvider(
                                                        futureSnapshot
                                                            .data.photoUrl),
                                              )
                                            : CircleAvatar(
                                                radius: 26,
                                                backgroundImage: AssetImage(
                                                    "assets/images/user-placeholder.png"),
                                              ),
                                        /*
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
                                            width: 45.0,
                                            height: 45.0,
                                            padding: EdgeInsets.all(10.0),
                                          ),
                                          imageUrl: futureSnapshot
                                                      .data.photoUrl ==
                                                  null
                                              ? "https://llhh.org/pps-medias/14714.jpg"
                                              : futureSnapshot.data.photoUrl,
                                          width: 45.0,
                                          height: 45.0,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                      */
                                        SizedBox(
                                          width: 15.0,
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      futureSnapshot.data.name,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                  Text(
                                                      timeago.format(snapshot
                                                          .data
                                                          .documents[index]
                                                          .data['time']
                                                          .toDate()),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontStyle:
                                                              FontStyle.italic))
                                                ],
                                              ),
                                              if (snapshot.data.documents[index]
                                                      .data['lastMsg'] !=
                                                  null)
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: Text(
                                                    snapshot
                                                        .data
                                                        .documents[index]
                                                        .data['lastMsg'],
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
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
      ),
    ]),
  );
}
