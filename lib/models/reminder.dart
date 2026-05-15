class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  bool isFavorite;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dateTime': dateTime.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        isFavorite: json['isFavorite'] as bool? ?? false,
      );

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isFavorite,
  }) =>
      Reminder(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        dateTime: dateTime ?? this.dateTime,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}
