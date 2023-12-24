class Goal {
  final String? title;
  final int? year;

  const Goal({
    this.title,
    this.year,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      title: json['title'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'year': year,
      };
}
