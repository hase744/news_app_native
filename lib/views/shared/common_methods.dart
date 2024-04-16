import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
Future<void> showProgressDialog(context) async {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    transitionDuration: Duration.zero, // これを入れると遅延を入れなくて
    barrierColor: Colors.black.withOpacity(0.5),
    pageBuilder: (BuildContext context, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      );
    },
  );
}