class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String country;
  final String city;
  final String address;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.country,
    required this.city,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'country': country,
      'city': city,
      'address': address,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      country: json['country'],
      city: json['city'],
      address: json['address'],
    );
  }
}
