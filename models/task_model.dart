class Task {
  int? id;
  String title;
  bool isCompleted;
  int listId;

  Task({
    this.id,
    required this.title,
    required this.isCompleted,
    required this.listId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'listId': listId,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
      listId: map['listId'],
    );
  }
}
