import 'package:video_news/controllers/category_controller.dart';
class CategoryBarController{
  double width;
  CategoryController categoryController;
  CategoryBarController({
    required this.width,
    required this.categoryController
  });

  double categoryTextSize(int i) {
    return width/30;
  }

  int textCount(int i){
    return categoryController.categories[i].japaneseName.length;
  }

  double lablSize(i){
    return (categoryTextSize(textCount(i))*(textCount(i)+1)).clamp(width/5, width/3);
  }

  double labelSumSize(int i){
    double sum = 0.0;
    for(var j=0; j<i ;j++){
      sum += lablSize(j);
    }
    sum -= (width - lablSize(i))/2;
    return sum.clamp(0.0, double.infinity);
  }
}