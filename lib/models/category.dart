class Category{
  String name;
  String japaneseName;
  String emoji = '';
  bool isDeleting = false;
  bool isAdded = false;
  bool isDefault;
  bool isFormal;

  Category({
    required this.name,
    required this.japaneseName,
    required this.isDefault,
    required this.isFormal,
  });

  Category.fromMap(Map<String, dynamic> map)
    : name = map['name'],
      japaneseName = map['japanese_name'],
      isDefault = map['is_default'],
      isFormal = map['is_formal'],
      emoji = map['emoji'];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'japanese_name': japaneseName,
      'emoji': emoji,
      'is_default': isDefault,
      'is_formal': isFormal,
    };
  }
}