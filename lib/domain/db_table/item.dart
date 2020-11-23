import 'dart:convert';

class Item {
  final int id;
  final int tripId;
  final String title;
  final int money;
  final String createdAt;
  final String updatedAt;

  Item(
      {this.id,
      this.tripId,
      this.title,
      this.money,
      this.createdAt,
      this.updatedAt});

  factory Item.fromJson(Map<String, dynamic> jsonData) {
    return Item(
      id: jsonData['id'],
      tripId: jsonData['tripId'],
      title: jsonData['title'],
      money: jsonData['money'],
      createdAt: jsonData['createdAt'],
      updatedAt: jsonData['updatedAt'],
    );
  }

  static Map<String, dynamic> toMap(Item item) => {
        'id': item.id,
        'tripId': item.tripId,
        'title': item.title,
        'money': item.money,
        'createdAt': item.createdAt,
        'updatedAt': item.updatedAt,
      };

  static String encodeItems(List<Item> items) => json.encode(
        items.map<Map<String, dynamic>>((item) => Item.toMap(item)).toList(),
      );

  static List<Item> decodeItems(String items) =>
      (json.decode(items) as List<dynamic>)
          .map<Item>((item) => Item.fromJson(item))
          .toList();
}
