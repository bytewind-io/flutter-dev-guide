// ✅ Сериализация в JSON
class Task {
  final String title;
  final Status status;

  const Task({required this.title, required this.status});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] as String,
      status: Status.fromValue(json['status'] as int?) ?? Status.pending,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'status': status.value, // ✅ используем .value
      };
}
