import 'package:bandmates/models/Comment.dart';
import 'package:bandmates/views/HomeScreen.dart';
import 'package:bandmates/views/UI/CustomNetworkImage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bandmates/models/User.dart';
import 'package:bandmates/views/UI/Header.dart';
import 'package:bandmates/views/UI/PostItem.dart';
import 'package:bandmates/views/UI/Progress.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../Utils.dart';
import '../models/Post.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';

class PostScreen extends StatefulWidget {
  final Post post;

  PostScreen({@required this.post});

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  AudioPlayer _audioPlayer;
  bool _isAudioPlaying = true;

  VideoPlayerController _videoPlayerController;
  bool _isVideoPlaying = true;

  TextEditingController _textEditingController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    switch (widget.post.type) {
      case 0:
        break;
      case 1:
        _audioPlayer = AudioPlayer();
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => _audioPlayer.play(widget.post.mediaUrl));
        break;
      case 2:
        _videoPlayerController =
            VideoPlayerController.network(widget.post.mediaUrl)..initialize();
        _videoPlayerController.setLooping(true);
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _videoPlayerController.play());
        break;
      default:
        Utils.buildErrorDialog(
            context, "Could not build load post, please try again later");
    }
  }

  @override
  void dispose() {
    if (_audioPlayer != null) {
      _audioPlayer.stop();
    }

    if (_videoPlayerController != null) {
      _videoPlayerController.dispose();
    }

    _textEditingController.dispose();
    super.dispose();
  }

  _toggleAudio() {
    if (_isAudioPlaying) {
      setState(() {
        _audioPlayer.pause();
        _isAudioPlaying = false;
      });
    } else {
      setState(() {
        _audioPlayer.resume();
        _isAudioPlaying = true;
      });
    }
  }

  _toggleVideo() {
    if (_isVideoPlaying) {
      setState(() {
        _videoPlayerController.pause();
        _isVideoPlaying = false;
      });
    } else {
      setState(() {
        _videoPlayerController.play();
        _isVideoPlaying = true;
      });
    }
  }

  addComment() {
    if (_textEditingController.text.isNotEmpty) {
      Firestore.instance
          .collection("comments")
          .document(widget.post.postId)
          .collection("comments")
          .add({
        "user": currentUser.name,
        "text": _textEditingController.text,
        "time": DateTime.now(),
        "avatar": currentUser.photoUrl,
        "uid": currentUser.uid
      });

      if (currentUser.uid != widget.post.ownerId) {
        Firestore.instance
            .collection("feed")
            .document(widget.post.ownerId)
            .collection("feedItems")
            .add({
          "type": 1,
          "postType": widget.post.type,
          "text": _textEditingController.text,
          "user": currentUser.name,
          "userId": currentUser.uid,
          "avatar": currentUser.photoUrl,
          "postId": widget.post.postId,
          "mediaUrl": widget.post.mediaUrl,
          "time": DateTime.now()
        });
      }

      FocusScope.of(context).unfocus();
      _textEditingController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        top: false,
        child: Stack(
          children: <Widget>[
            _buildHeader(),
            CustomScrollView(
              slivers: <Widget>[
                widget.post.ownerId == currentUser.uid
                    ? SliverAppBar(
                        title: Text(
                          widget.post.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        expandedHeight: 50,
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(
                              LineIcons.ellipsis_h,
                              size: 32,
                              color: Colors.white,
                            ),
                            onPressed: () => print("Edit post"),
                          ),
                        ],
                      )
                    : SliverAppBar(
                        expandedHeight: 50,
                        title: Text(widget.post.title),
                      ),
                SliverList(
                  delegate: SliverChildListDelegate(
                      [_buildPostArea(context), _buildCommentArea()]),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(60),
                )
              ],
            ),
            Positioned(child: _buildTextField(), bottom: 0)
          ],
        ),
      ),
    );
  }

  _buildHeader() {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25))),
      padding: EdgeInsets.only(left: 12, top: 32),
      height: 250,
      width: double.infinity,
      child: Container(),
    );
  }

  _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 1, color: Colors.black)),
        color: Colors.white,
      ),
      height: 60,
      width: MediaQuery.of(context).size.width,
      child: ListTile(
        title: TextFormField(
          maxLines: null,
          controller: _textEditingController,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            focusColor: Theme.of(context).primaryColor,
            hintText: "Write a comment",
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.send),
          color: Theme.of(context).primaryColor,
          onPressed: () => addComment(),
        ),
      ),
    );
  }

  _buildPostArea(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (widget.post.type == 0)
                _imageWidget(context)
              else if (widget.post.type == 1)
                _audioWidget(context)
              else if (widget.post.type == 2)
                _videoWidget(context),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    widget.post.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ChangeNotifierProvider<Post>(
                    create: (_) {
                      return widget.post;
                    },
                    child: Consumer<Post>(
                      builder: (ctx, post, child) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(post.likes[currentUser.uid] == null ||
                                    post.likes[currentUser.uid] == false
                                ? Icons.favorite_border
                                : Icons.favorite),
                            onPressed: () {
                              post.toggleLikePost(context);
                            },
                            color: Colors.red,
                          ),
                          Text(
                            post.likes.values.length.toString(),
                            style: TextStyle(color: Colors.red),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                widget.post.text,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  DateFormat.yMMMEd().format(widget.post.time),
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _audioWidget(context) {
    return GestureDetector(
      onTap: () => _toggleAudio(),
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: Container(
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: new DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/images/audio-placeholder.png'),
            ),
          ),
        ),
      ),
    );
  }

  _videoWidget(context) {
    return GestureDetector(
      onTap: () => _toggleVideo(),
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: VideoPlayer(_videoPlayerController),
        ),
      ),
    );
  }

  _imageWidget(context) {
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: customNetworkImage(widget.post.mediaUrl),
      ),
    );
  }

  _buildCommentArea() {
    return Container(
      constraints: BoxConstraints(minHeight: 100),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(15),
          child: StreamBuilder(
              stream: Firestore.instance
                  .collection("comments")
                  .document(widget.post.postId)
                  .collection("comments")
                  .orderBy("time", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress(context);
                }

                if (snapshot.data.documents.isEmpty) {
                  return Center(
                    child: Text("No Comments"),
                  );
                }

                List<Comment> comments = [];

                snapshot.data.documents.forEach((doc) {
                  comments.add(Comment.fromDocument(doc));
                });

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: comments,
                );
              }),
        ),
      ),
    );
  }
}
