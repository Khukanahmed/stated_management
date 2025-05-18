class Alert {
  final int? id;
  final String name;
  final String startTime;
  final String endTime;

  Alert({
    this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'startTime': startTime, 'endTime': endTime};
  }

  factory Alert.fromMap(Map<String, dynamic> map) {
    return Alert(
      id: map['id'] as int?,
      name: map['name'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
    );
  }
}
