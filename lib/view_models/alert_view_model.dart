import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_news/provider/alert.dart';
import 'package:video_news/models/common_status.dart';

import 'package:video_news/view_models/shared_view_model.dart';
class AlertViewModel{
  late WidgetRef _ref;
  String? _alert;

  void setRef(WidgetRef ref){
    this._ref = ref;
  }

  get alert => _ref.watch(alertProvider);

  display(String text) async {
    displayAlert(text, _ref, alert, alertProvider);
    //_alert = await text;
    //_ref.watch(alertProvider.notifier).state = _alert;
    //Future.delayed(const Duration(seconds: 2), () {
    //  _alert = null;
    //  _ref.watch(alertProvider.notifier).state = null;
    //});
  }

  displayFromStatus(CreateStatus status){
    switch(status) {
    case  CreateStatus.existing:
      display("すでに追加されています");
      break;
    case CreateStatus.failure:
      display("追加に失敗しました");
      break;
    case CreateStatus.success:
      display("追加しました");
      break;
    default:
      break;
                                    }
  }
}