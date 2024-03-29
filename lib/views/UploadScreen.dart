import 'package:bandmates/views/SearchScreens/EventsSearchScreen.dart';
import 'package:bandmates/views/SearchScreens/MusiciansSearchScreen.dart';
import 'package:bandmates/views/UploadScreens/ClassifiedUploadScreen.dart';
import 'package:flutter/material.dart';
import 'package:bandmates/views/UploadScreens/PostUploadScreen.dart';
import 'SearchScreens/ClassifiedSearchScreen.dart';
import 'UploadScreens/EventUploadScreen.dart';

class UploadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("[UploadScreen] Rebuilding the widget");

    return ListView(
      children: <Widget>[buildSearchHeader(context), buildMainArea(context)],
    );
  }
}

buildMainArea(context) {
  double _borderRadius = 20;

  double buttonSize = MediaQuery.of(context).size.height * 0.17;
  return Container(
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30))),
    height: MediaQuery.of(context).size.height,
    width: double.infinity,
    child: ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
        ),
        padding: EdgeInsets.only(left: 8, right: 8, top: 16),
        children: <Widget>[
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, PostUploadScreen.routeName),
            child: Container(
              height: buttonSize,
              margin: EdgeInsets.only(bottom: 5),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_borderRadius)),
                child: Container(
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: const Text(
                      "Upload a Post",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          colorFilter: new ColorFilter.mode(
                              Colors.black.withOpacity(.6),
                              BlendMode.hardLight),
                          image: const AssetImage(
                              'assets/images/silhouette.jpg'))),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, EventUploadScreen.routeName),
            child: Container(
              height: buttonSize,
              margin: EdgeInsets.only(bottom: 5),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_borderRadius)),
                child: Container(
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: const Text(
                      "Create an Event",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_borderRadius),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.6), BlendMode.hardLight),
                      image: const AssetImage('assets/images/concert.jpg'),
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              MusiciansSearchScreen.routeName,
            ),
            child: Container(
              height: buttonSize,
              margin: EdgeInsets.only(bottom: 5),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_borderRadius)),
                child: Container(
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: const Text(
                      "Discover Musicans",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          colorFilter: new ColorFilter.mode(
                              Colors.black.withOpacity(0.6),
                              BlendMode.hardLight),
                          image:
                              const AssetImage('assets/images/musicians.jpg'))),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              EventsSearchScreen.routeName,
            ),
            child: Container(
              height: buttonSize,
              margin: EdgeInsets.only(bottom: 5),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_borderRadius)),
                child: Container(
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: const Text(
                      "Discover Events",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          colorFilter: new ColorFilter.mode(
                              Colors.black.withOpacity(0.6),
                              BlendMode.hardLight),
                          image: const AssetImage('assets/images/singer.jpg'))),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              ClassifiedUploadScreen.routeName,
            ),
            child: Container(
              height: buttonSize,
              margin: EdgeInsets.only(bottom: 5),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_borderRadius)),
                child: Container(
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: const Text(
                      "Upload Classified",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          colorFilter: new ColorFilter.mode(
                              Colors.black.withOpacity(0.6),
                              BlendMode.hardLight),
                          image:
                              const AssetImage('assets/images/ad-wall.jpg'))),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              ClassifiedSearchScreen.routeName,
            ),
            child: Container(
              height: buttonSize,
              margin: EdgeInsets.only(bottom: 5),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_borderRadius)),
                child: Container(
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: const Text(
                      "Search Classified",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(_borderRadius),
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          colorFilter: new ColorFilter.mode(
                              Colors.black.withOpacity(0.6),
                              BlendMode.hardLight),
                          image: const AssetImage('assets/images/ads.jpg'))),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

buildSearchHeader(context) {
  return Container(
    // decoration: BoxDecoration(
    //   gradient: LinearGradient(
    //     // Where the linear gradient begins and ends
    //     begin: Alignment.centerLeft,
    //     end: Alignment.centerRight,
    //     // Add one stop for each color. Stops shozuld increase from 0 to 1
    //     stops: [0.45, 1],
    //     colors: [
    //       // Colors are easy thanks to Flutter's Colors class.
    //       Theme.of(context).primaryColor,

    //       Color(0xff962d54),
    //     ],
    //   ),
    // ),
    padding: EdgeInsets.only(left: 12, top: 32),
    height: 100,
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "BandMates",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
          ],
        ),
      ],
    ),
  );
}

// AIzaSyBVY9wwL0hnzcoEN7HTKh41o92PzHZe0wI
// AIzaSyBVY9wwL0hnzcoEN7HTKh41o92PzHZe0wI
