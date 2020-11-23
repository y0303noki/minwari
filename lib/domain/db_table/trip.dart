import 'dart:convert';

class Trip {
  String id;
  final String name;
  final String memo;
  String createdAt;
  String updatedAt;

  Trip({this.id, this.name, this.memo, this.createdAt, this.updatedAt});

  factory Trip.fromJson(Map<String, dynamic> jsonData) {
    return Trip(
      id: jsonData['id'],
      name: jsonData['name'],
      memo: jsonData['memo'],
      createdAt: jsonData['createdAt'],
      updatedAt: jsonData['updatedAt'],
    );
  }

  static Map<String, dynamic> toMap(Trip trip) => {
        'id': trip.id,
        'name': trip.name,
        'memo': trip.memo,
        'createdAt': trip.createdAt,
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
