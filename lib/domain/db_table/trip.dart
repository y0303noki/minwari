import 'dart:convert';

class Trip {
  String id;
  String name;
  String memo;
  bool isSelected = false;
  final String createdAt;
  String eventAt;
  String eventEndAt;
  String updatedAt;

  Trip(
      {this.id,
      this.name,
      this.memo,
      this.isSelected,
      this.createdAt,
      this.eventAt,
      this.eventEndAt,
      this.updatedAt});

  factory Trip.fromJson(Map<String, dynamic> jsonData) {
    return Trip(
      id: jsonData['id'],
      name: jsonData['name'],
      memo: jsonData['memo'],
      isSelected: jsonData['isSelected'],
      createdAt: jsonData['createdAt'],
      eventAt: jsonData['eventAt'],
      eventEndAt: jsonData['eventEndAt'],
      updatedAt: jsonData['updatedAt'],
    );
  }

  static Map<String, dynamic> toMap(Trip trip) => {
        'id': trip.id,
        'name': trip.name,
        'memo': trip.memo,
        'isSelected': trip.isSelected,
        'createdAt': trip.createdAt,
        'eventAt': trip.eventAt,
        'eventEndAt': trip.eventEndAt,
        'updatedAt': trip.updatedAt,
      };

  static String encodeTrips(List<Trip> trips) => json.encode(
        trips.map<Map<String, dynamic>>((trip) => Trip.toMap(trip)).toList(),
      );

  static List<Trip> decodeTrips(String trips) =>
      (json.decode(trips) as List<dynamic>)
          .map<Trip>((trip) => Trip.fromJson(trip))
          .toList();
}
