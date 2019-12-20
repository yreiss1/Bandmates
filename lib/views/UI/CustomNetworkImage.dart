import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jammerz/views/UI/Progress.dart';

Widget customNetworkImage(String mediaUrl) {
  return CachedNetworkImage(
    fadeInCurve: Curves.easeIn,
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) => Padding(
      child: circularProgress(context),
      padding: EdgeInsets.all(20),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}
