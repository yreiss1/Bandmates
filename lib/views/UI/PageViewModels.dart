import 'package:flutter/material.dart';

class PageViewModels {
  final String title;
  final Widget bodyWidget;
  final Widget footer;
  final bool scroll;

  PageViewModels({this.title, this.bodyWidget, this.footer, this.scroll});
}
