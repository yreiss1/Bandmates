import 'package:bandmates/views/HomeScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bandmates/views/ChatRoomScreen.dart';
import 'package:bandmates/views/UI/Progress.dart';
//import 'package:line_icons/line_icons.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import '../Utils.dart';
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
              //TODO: Add search functionality
              // IconButton(
              //   icon: Icon(
              //     Icons.search,
              //     color: Colors.white,
              //     size: 28,
              //   ),
              //   onPressed: () {},
              // )
            ],
          )
        ],
      ),
    );
  }
}

buildChatList(context) {
  String uid = currentUser.uid;

  return Container(
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30))),
    height: MediaQuery.of(context).size.height,
    width: double.infinity,
    child: Column(children: [
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
            stream: Provider.of<ChatProvider>(context).getChats(uid),
            builder: (BuildContext context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress(context);
              }

              if (snapshot.hasError) {
                Utils.buildErrorDialog(context,
                    "Could not retrieve your chats, please try again soon!");
              }

              if (snapshot.data.documents.length == 0) {
                return Center(
                    child: Container(
                  width: MediaQuery.of(context).size.width * .8,
                  child: Text(
                    "You have no chats currently, start chatting to get the party going!",
                    textAlign: TextAlign.center,
                  ),
                ));
              }
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, index) {
                  Chat chat = Chat.fromDocument(snapshot.data.documents[index]);
                  String avatar;
                  String name;
                  if (chat.users.keys.toList().length == 2) {
                    avatar = chat.users.keys.toList()[0] == uid
                        ? chat.users[chat.users.keys.toList()[1]]['avatar']
                        : chat.users[chat.users.keys.toList()[0]]['avatar'];
                    name = chat.users.keys.toList()[0] == uid
                        ? chat.users[chat.users.keys.toList()[1]]['name']
                        : chat.users[chat.users.keys.toList()[0]]['name'];
                  }

                  return Column(children: <Widget>[
                    GestureDetector(
                        onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return ChatRoomScreen(
                                  chat: chat,
                                );
                              }),
                            ),
                        child: ListTile(
                          title: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          leading: avatar != null
                              ? CircleAvatar(
                                  radius: 26,
                                  backgroundImage:
                                      CachedNetworkImageProvider(avatar),
                                )
                              : CircleAvatar(
                                  radius: 26,
                                  backgroundImage: AssetImage(
                                      "assets/images/user-placeholder.png"),
                                ),
                          subtitle: chat.lastMessage != null
                              ? Text(chat.lastMessage)
                              : null,
                          trailing: Text(
                            timeago.format(
                              snapshot.data.documents[index].data['time']
                                  .toDate(),
                            ),
                          ),
                        )

                        //  Container(
                        //   padding: EdgeInsets.all(10.0),
                        //   child: Row(
                        //     children: <Widget>[
                        //       avatar != null
                        //           ? CircleAvatar(
                        //               radius: 26,
                        //               backgroundImage:
                        //                   CachedNetworkImageProvider(avatar),
                        //             )
                        //           : CircleAvatar(
                        //               radius: 26,
                        //               backgroundImage: AssetImage(
                        //                   "assets/images/user-placeholder.png"),
                        //             ),
                        //       /*
                        //         Material(
                        //           child: CachedNetworkImage(
                        //             placeholder: (context, url) =>
                        //                 Container(
                        //               child: CircularProgressIndicator(
                        //                 strokeWidth: 1.0,
                        //                 valueColor:
                        //                     AlwaysStoppedAnimation<Color>(
                        //                         Theme.of(context)
                        //                             .primaryColor),
                        //               ),
                        //               width: 45.0,
                        //               height: 45.0,
                        //               padding: EdgeInsets.all(10.0),
                        //             ),
                        //             imageUrl: futureSnapshot
                        //                         .data.photoUrl ==
                        //                     null
                        //                 ? "https://llhh.org/pps-medias/14714.jpg"
                        //                 : futureSnapshot.data.photoUrl,
                        //             width: 45.0,
                        //             height: 45.0,
                        //             fit: BoxFit.cover,
                        //           ),
                        //           borderRadius: BorderRadius.all(
                        //             Radius.circular(20.0),
                        //           ),
                        //           clipBehavior: Clip.hardEdge,
                        //         ),
                        //         */
                        //       SizedBox(
                        //         width: 15.0,
                        //       ),
                        //       Expanded(
                        //         child: Column(
                        //           children: <Widget>[
                        //             Row(
                        //               children: <Widget>[
                        //                 Expanded(
                        //                   child: Text(
                        //                     name,
                        //                     overflow: TextOverflow.ellipsis,
                        //                     style: TextStyle(
                        //                         fontWeight: FontWeight.w600,
                        //                         fontSize: 18),
                        //                   ),
                        //                 ),
                        //                 Text(
                        //                     timeago.format(snapshot.data
                        //                         .documents[index].data['time']
                        //                         .toDate()),
                        //                     style: TextStyle(
                        //                         fontSize: 14,
                        //                         fontWeight: FontWeight.w300,
                        //                         fontStyle: FontStyle.italic))
                        //               ],
                        //             ),
                        //             if (snapshot.data.documents[index]
                        //                     .data['lastMsg'] !=
                        //                 null)
                        //               SizedBox(
                        //                 width: double.infinity,
                        //                 child: Text(
                        //                   snapshot.data.documents[index]
                        //                       .data['lastMsg'],
                        //                   style: TextStyle(
                        //                     fontSize: 16,
                        //                     fontWeight: FontWeight.w400,
                        //                   ),
                        //                 ),
                        //               ),
                        //           ],
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        // ),
                        ),
                    Divider(),
                  ]);
                },
              );

              // } else {
              //   return Container(
              //     width: double.infinity,
              //     height: 50,
              //     child: PKCardListSkeleton(
              //       isBottomLinesActive: false,
              //       isCircularImage: true,
              //       length: 1,
              //     ),
              //   );
            }),
      ),
    ]),
  );
}
