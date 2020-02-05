import 'package:bandmates/models/Comment.dart';
import 'package:bandmates/views/HomeScreen.dart';
import 'package:bandmates/views/UI/CustomNetworkImage.dart';
import 'package:chewie_audio/chewie_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:bandmates/views/UI/Progress.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../Utils.dart';
import '../models/Post.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PostScreen extends StatefulWidget {
  final Post post;

  PostScreen({@required this.post});

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  AudioPlayer _audioPlayer;
  bool _hasMore = true;
  DocumentSnapshot _lastDocument;
  bool _isLoading = false;
  List<Comment> _commentsList = [];

  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  ChewieAudioController _chewieAudioController;
  ScrollController _scrollController;

  TextEditingController _textEditingController = new TextEditingController();

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.2;

      if (maxScroll - currentScroll <= delta) {
        _getComments();
      }
    });
    _getComments();
    super.initState();
    switch (widget.post.type) {
      case 0:
        break;
      case 1:
        _videoPlayerController =
            VideoPlayerController.network(widget.post.mediaUrl);

        _chewieAudioController = ChewieAudioController(
            videoPlayerController: _videoPlayerController,
            allowMuting: true,
            autoPlay: true,
            showControls: true,
            looping: true);

        break;
      case 2:
        _videoPlayerController =
            VideoPlayerController.network(widget.post.mediaUrl);

        _chewieController = ChewieController(
            aspectRatio: 3 / 2,
            videoPlayerController: _videoPlayerController,
            autoPlay: true,
            looping: true,
            errorBuilder: (context, error) {
              Utils.buildErrorDialog(context, error);
            },
            allowFullScreen: true,
            allowMuting: true,
            showControlsOnInitialize: true);

        break;
      default:
        Utils.buildErrorDialog(
            context, "Could not build load post, please try again later");
    }
  }

  _getComments() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    QuerySnapshot snapshot;
    if (_lastDocument == null) {
      snapshot = await Firestore.instance
          .collection("comments")
          .document(widget.post.postId)
          .collection("comments")
          .orderBy("time", descending: false)
          .limit(20)
          .getDocuments();
    } else {
      snapshot = await Firestore.instance
          .collection("comments")
          .document(widget.post.postId)
          .collection("comments")
          .startAfterDocument(_lastDocument)
          .orderBy("time", descending: false)
          .limit(20)
          .getDocuments();
    }

    if (!snapshot.documents.isEmpty) {
      _lastDocument = snapshot.documents[snapshot.documents.length - 1];
    }

    List<Comment> results = [];
    snapshot.documents.forEach((doc) => results.add(Comment.fromDocument(doc)));

    setState(() {
      _commentsList.addAll(results);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    if (_audioPlayer != null) {
      _audioPlayer.stop();
    }

    if (_videoPlayerController != null) {
      _videoPlayerController.dispose();
    }

    if (_chewieController != null) {
      _chewieController.dispose();
    }

    if (_chewieAudioController != null) {
      _chewieAudioController.dispose();
    }

    _textEditingController.dispose();
    super.dispose();
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
        top: false,
        child: Stack(
          children: <Widget>[
            _buildHeader(),
            RefreshIndicator(
              onRefresh: () => _getComments(),
              color: Theme.of(context).primaryColor,
              child: CustomScrollView(
                controller: _scrollController,
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
                  // SliverList(
                  //   delegate: SliverChildListDelegate(
                  //       [_buildPostArea(context), _buildCommentArea()]),
                  // ),
                  SliverToBoxAdapter(
                    child: _buildPostArea(context),
                  ),
                  SliverToBoxAdapter(
                    child: _buildCommentArea(),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(60),
                  )
                ],
              ),
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
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    widget.post.title,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
    return Column(
      children: <Widget>[
        AspectRatio(
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
        ChewieAudio(
          controller: _chewieAudioController,
        ),
      ],
    );
  }

  _videoWidget(context) {
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Chewie(
          controller: _chewieController,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Comments",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 8,
              ),
              _commentsList.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(15),
                      child: Center(
                        child: Text("Be the first to leave a comment"),
                      ),
                    )
                  : Flexible(
                      fit: FlexFit.loose,
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _commentsList.length,
                        itemBuilder: (context, index) {
                          return _commentsList[index];
                        },
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
