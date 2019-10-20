import 'package:flutter/material.dart';
import 'package:jammerz/views/UI/ChatMessage.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat-screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Chat Screen"),
        ),
        body: Column(
          children: <Widget>[
            new Flexible(
              //new
              child: new ListView.builder(
                //new
                padding: new EdgeInsets.all(8.0), //new
                reverse: true, //new
                itemBuilder: (_, int index) => _messages[index], //new
                itemCount: _messages.length, //new
              ), //new
            ), //new
            new Divider(height: 1.0), //new
            new Container(
              //new
              decoration:
                  new BoxDecoration(color: Theme.of(context).cardColor), //new
              child: _buildTextComposer(context), //modified
            ),
          ],
        ));
  }

  Widget _buildTextComposer(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: new TextField(
                controller: _textController,
                onChanged: (String str) {
                  setState(() {
                    _isComposing = str.length > 0;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration:
                    new InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            new Container(
              //new
              margin: new EdgeInsets.symmetric(horizontal: 4.0), //new
              child: new IconButton(
                  //new
                  icon: new Icon(Icons.send), //new
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null), //new
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    ChatMessage message = ChatMessage(
      text: text,
      name: "Omer",
      animationController: new AnimationController(
        duration: new Duration(milliseconds: 400),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0, message);
    });

    message.animationController.forward();
  }

  @override
  void dispose() {
    //new
    for (ChatMessage message in _messages) //new
      message.animationController.dispose(); //new
    super.dispose(); //new
  }
}
