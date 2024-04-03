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
              Flexible(
              child: 
              ListView.builder(
                itemCount: _categoryController.unusedCategories.length,
                itemBuilder: (context, index) {
                  final category = _categoryController.unusedCategories[index];
                  return 
                  Container(
                    width: _deviceWidth! - 2,
                    height: 50,
                    color: Colors.white,
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            " ${category.emoji} ${category.japaneseName}",
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            child: _categoryController.unusedCategories[index].isAdded ?
                              IconButton(
                                icon:  const Icon(Icons.check_circle, color: Colors.green) ,
                                onPressed: () {
                                  setState(() {
                                    //_categoryController.unusedCategories[index]['is_added'] = !_categoryController.unusedCategories[index]['is_added'];
                                  });
                                },
                              ):
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _categoryController.unusedCategories[index].isAdded = !_categoryController.unusedCategories[index].isAdded;
                                  //addCategory(category.name);
                                  _categoryController.add(_categoryController.unusedCategories[index]);
                                });
                              },
                              child: 
                                Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red),
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.red
                                  ),
                                  child: 
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                    Text(
                                      "追加",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Icon(Icons.add_circle, color: Colors.white),
                                  ]
                                ),
                                
                              )
                              
                            )
                          ),
                        ]
                      ),
                    );
                  },
                ),
              ),
          
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