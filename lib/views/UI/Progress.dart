import 'package:flutter/material.dart';

Container circularProgress(context) {
  return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 10.0),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).primaryColor,
      ));
}

Container linearProgress(context, {value = null}) {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
        value: value,
        valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
        backgroundColor: Colors.white),
  );
}
