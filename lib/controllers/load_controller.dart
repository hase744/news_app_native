class LoadController{
  int loadCount = 1;
  int maxLoadCount = 20;
  bool loadCounting = false;
  bool isLoading = false;
  bool canLoad = false;

  getLoadText(){
    if(loadCount >= maxLoadCount){
      return " ↑ はなして更新";
    }else if(isLoading){
      return "更新中";
    }else{
      return " ↓ 引き下げて更新 ";
    }
  }
}