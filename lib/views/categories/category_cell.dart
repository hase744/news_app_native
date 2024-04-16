import 'package:flutter/material.dart';
import 'package:video_news/consts/colors.dart';
import 'package:video_news/models/category.dart';
import 'package:video_news/models/channel_mode.dart';

class CategoryCell extends StatelessWidget {
  Category category;
  bool isOriginal;
  double width;
  Function() onAdded;
  Function() onDeleted;
  
  CategoryCell({
    super.key,
    required this.category,
    required this.width,
    required this.onAdded,
    required this.onDeleted,
    required this.isOriginal,
  });
  @override
  Widget build(BuildContext context){
    return Container(
      width: width - 2,
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          bottom: 
          BorderSide(
            color: ColorConfig.settingBorder,
            width: 0.5,
          ),
        ),
        color: Colors.white,
      ),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(![null, ''].contains(category.imageUrl))
          Container(
            width: width/20,
            margin: EdgeInsets.symmetric(horizontal: width/80),
            child: 
            Center(
              child: 
              ClipRRect(
                borderRadius: BorderRadius.circular(width),
                child:
                Image.network(category.imageUrl!)
              )
            )
          ),
          if([null, ''].contains(category.imageUrl))
          Container(
            width: width/20,
            margin: EdgeInsets.symmetric(horizontal: width/80),
            child: 
            Center(
              child: 
              Text(
                category.emoji,
                style: TextStyle(
                  fontSize: width/20,
                ),
              )
            )
          ),
          Text(
            category.japaneseName,
            style: TextStyle(
              fontSize: width/20,
            ),
          ),
          const Spacer(),
          if(isOriginal)
          Container(
            child: 
            InkWell(
              onTap: (){
                onAdded();
              },
              child: 
              Container(
                margin: EdgeInsets.only(right: 0),
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: width/320),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white
                ),
                child: 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.edit, 
                      color: Colors.grey,
                      size: width/20,
                    ),
                    Text(
                      "編集",
                      style: TextStyle(
                        fontSize: width/30,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(width: width/80),
                  ]
                ),
              ),
            )
          ),
          if(isOriginal)
          Container(
            child: 
            InkWell(
              onTap: (){
                onDeleted();
              },
              child: 
              Container(
                margin: EdgeInsets.only(right: width/80),
                padding: EdgeInsets.symmetric(horizontal: width/80, vertical: width/320),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white
                ),
                child: 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.delete, 
                      color: Colors.red,
                      size: width/20,
                    ),
                    Text(
                      "削除",
                      style: TextStyle(
                        fontSize: width/30,
                        color: Colors.red,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(width: width/80),
                  ]
                ),
              ),
            )
          ),
          if(!isOriginal)
          Container(
            child: category.isAdded! ?
            Container(
              margin: EdgeInsets.only(right: width/80),
              child:
              const Icon(
                Icons.check_circle, 
                color: Colors.green
              )
            ):
            InkWell(
              onTap: (){
                onAdded();
              },
              child: 
              Container(
                margin: EdgeInsets.only(right: width/80),
                padding: EdgeInsets.symmetric(horizontal: width/80, vertical: width/320),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue
                ),
                child: 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.add_circle, color: Colors.blue[200]),
                    SizedBox(width: width/80),
                    Text(
                      "追加",
                      style: TextStyle(
                        fontSize: width/30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ]
                ),
              ),
            )
          ),
        ]
      ),
    );
  }
}