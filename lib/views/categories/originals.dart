import 'package:flutter/material.dart';
import 'package:video_news/controllers/version_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class OriginalCategory extends ConsumerStatefulWidget {
  @override
  ConsumerState<OriginalCategory> createState() => _OriginalCategoryState();
}

class _OriginalCategoryState extends ConsumerState<OriginalCategory> {
  VersionController _versionController = VersionController();
  @override
  void initState() {
    super.initState();
    _versionController.initialize();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromRGBO(255,251,255, 1),
        title: const Text('オリジナル',style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
              const Text("プラスからカテゴリーを追加"),
          
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        child: new Icon(Icons.add),
      ),
    );
  }
}