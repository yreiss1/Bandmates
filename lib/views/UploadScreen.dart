import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:jammerz/views/UploadScreens/PostUploadScreen.dart';
import 'package:line_icons/line_icons.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'UploadScreens/EventUploadScreen.dart';
import 'dart:async';

import 'package:search_map_place/search_map_place.dart';
import 'dart:io';

class UploadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("[UploadScreen] Rebuilding the widget");

    return Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, PostUploadScreen.routeName),
              child: Container(
                height: 120,
                margin: EdgeInsets.only(bottom: 5),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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
                        borderRadius: BorderRadius.circular(10),
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
                height: 120,
                margin: EdgeInsets.only(bottom: 5),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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
                      borderRadius: BorderRadius.circular(10),
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
            Container(
              height: 120,
              margin: EdgeInsets.only(bottom: 5),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
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
                      borderRadius: BorderRadius.circular(10),
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
          ],
        ),
      ),
    );
  }
}

// AIzaSyBVY9wwL0hnzcoEN7HTKh41o92PzHZe0wI
// AIzaSyBVY9wwL0hnzcoEN7HTKh41o92PzHZe0wI
