class Category{
  String name;
  String japaneseName;
  String emoji = '';
  bool isDeleting = false;
  bool isAdded = false;
  bool isDefault;

  Category({
    required this.name,
    required this.japaneseName,
    required this.isDefault
  });

  Category.fromMap(Map<String, dynamic> map)
    : name = map['name'],
      japaneseName = map['japanese_name'],
      isDefault = map['is_default'],
      emoji = map['emoji'];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'japanese_name': japaneseName,
      'emoji': emoji,
      'is_default': isDefault,
    };
  }
}