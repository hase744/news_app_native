class HomeCondition {
  final String mode;
  final bool isSearchingByWord;
  final bool isSearchingByCategory;
  final String page;

  HomeCondition({
    required this.mode, 
    required this.page, 
    required this.isSearchingByWord,
    required this.isSearchingByCategory,
  });

  factory HomeCondition.fromJson(Map<String, dynamic> json) {
    return HomeCondition(
      mode: json['mode'], 
      page: json['page'],
      isSearchingByWord: json['isSearchingByWord'],
      isSearchingByCategory: json['isSearchingByCategory'],
      );
  }
}
