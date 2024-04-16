import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:video_news/models/common_status.dart';
displayAlert(
  String text, 
  WidgetRef ref, 
  String? alert,
  StateProvider<String?> alertProvider
  ) async {
  alert = await text;
  ref.watch(alertProvider.notifier).state = alert;
  Future.delayed(const Duration(seconds: 2), () {
    alert = null;
    ref.watch(alertProvider.notifier).state = null;
  });
}
displayMessage(BuildContext context, String text){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

  displayMessageFromStatus(BuildContext context, CreateStatus status){
    switch(status) {
    case  CreateStatus.existing:
      displayMessage(context, "すでに追加されています");
      break;
    case CreateStatus.failure:
      displayMessage(context, "追加に失敗しました");
      break;
    case CreateStatus.success:
      displayMessage(context, "追加しました");
      break;
    default:
      break;
                                    }
  }