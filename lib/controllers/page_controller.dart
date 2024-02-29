import 'package:video_news/consts/navigation_list_config.dart';
import 'package:video_news/models/navigation_item.dart';
import 'package:video_news/controllers/version_controller.dart';
  
class PageControllerClass{
  int pageIndex = 0;
  final _versionController = VersionController();
  List<NavigationItem> homeMenuList = NavigationListConfig.homeMenuList;
  List<NavigationItem> fakeHomeMenuList = NavigationListConfig.fakeHomeMenuList;
  List<NavigationItem> favoriteMenuList = NavigationListConfig.favoriteMenuList;
  List<NavigationItem> historyMenuList = NavigationListConfig.historyMenuList;
  List<NavigationItem> pageList = NavigationListConfig.pageList;

  getCurrentList(){
    _versionController.initialize();
    switch(pageList[pageIndex].name) {
      case 'favorite':
        return favoriteMenuList;
      case 'history':
        return historyMenuList;
      default:
        return homeMenuList;
      }
  }

  getCurrentPageName(){
    return pageList[pageIndex].name;
  }

  getNameFromIndex(int index){
    return getCurrentList()[index].name;
  }

  updatePage(int index){
    pageIndex = index;
  }
  
  isHomePage(){
    return pageList[pageIndex].name == 'home';
  }
  
  isHistoryPage(){
    return pageList[pageIndex].name == 'history';
  }

  isFavoritePage(){
    return pageList[pageIndex].name == 'favorite';
  }
  isDownloaderPage(){
    return pageList[pageIndex].name == 'downloader';
  }
}