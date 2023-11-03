class Category{
  String name;
  String japaneseName;
  String emoji = '';
  bool isDeleting = false;
  bool isAdded = false;

  Category({
    required this.name,
    required this.japaneseName,
  });

  Category.fromMap(Map<String, dynamic> map)
    : name = map['name'],
      japaneseName = map['japanese_name'],
      emoji = map['emoji'];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'japanese_name': japaneseName,
      'emoji': emoji,
    };
  }
}