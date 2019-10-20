import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:line_icons/line_icons.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Widget _buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        decoration: InputDecoration(
          hintText: "Quick Search",
          filled: true,
          icon: Icon(
            LineIcons.rocket,
            size: 28.0,
          ),
          suffix: IconButton(
            icon: Icon(LineIcons.close),
            onPressed: () => print("Cleared"),
          ),
        ),
      ),
    );
  }

  Widget _buildNoContent() {
    return Container(
      child: Center(
        child: ListView(
          children: <Widget>[
            SvgPicture.asset('assets/images/search.svg', height: 300),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 60.0),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildSearchField(),
      body: _buildNoContent(),
    );
  }
}

class UserResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("User Result");
  }
}
