import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class FeedItem extends StatelessWidget {
  const FeedItem({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
      height: height / 2.1,
      child: Card(
        elevation: 5.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Image.network(
                  "https://www.chicagotribune.com/resizer/Ynyah1DRcQ1DLzBswWXYS1KYyVw=/800x449/top/www.trbimg.com/img-5cb8b2c1/turbine/ct-1555608253-jl3p8ucnxq-snap-image",
                  height: height / 3,
                ),
                Container(
                  margin: EdgeInsets.only(top: height / 3.4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      RawMaterialButton(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                          shape: CircleBorder(),
                          elevation: 2.0,
                          fillColor: Colors.purple,
                          onPressed: () {}),
                      RawMaterialButton(
                          child: Icon(
                            FontAwesome.getIconData("heart"),
                            color: Colors.white,
                          ),
                          shape: CircleBorder(),
                          elevation: 2.0,
                          fillColor: Theme.of(context).primaryColor,
                          onPressed: () {}),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Rock Band Gig",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        "1234 Abcd Street",
                        style: TextStyle(
                            color: Colors.black45, fontFamily: 'OpenSans'),
                      ),
                    ],
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 12),
                      child: Text("148 Going",
                          style: TextStyle(
                              color: Colors.black45, fontFamily: 'OpenSans'))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
