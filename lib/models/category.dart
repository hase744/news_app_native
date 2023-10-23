class Category{
  String name;
  String japaneseName;
  bool isDeleting = false;
  bool isAdded = false;

  Category({
    required this.name,
    required this.japaneseName
  });

  Category.fromMap(Map<String, dynamic> map)
    : name = map['name'],
      japaneseName = map['japanese_name'];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'japanese_name': japaneseName,
    };
  }
}