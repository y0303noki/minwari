import 'dart:convert';

class Member {
  final int id;
  final int tripId;
  final String name;
  final String memo;
  final String createdAt;
  final String updatedAt;

  Member(
      {this.id,
      this.tripId,
      this.name,
      this.memo,
      this.createdAt,
      this.updatedAt});

  factory Member.fromJson(Map<String, dynamic> jsonData) {
    return Member(
      id: jsonData['id'],
      tripId: jsonData['tripId'],
      name: jsonData['name'],
      memo: jsonData['memo'],
      createdAt: jsonData['createdAt'],
      updatedAt: jsonData['updatedAt'],
    );
  }

  static Map<String, dynamic> toMap(Member member) => {
        'id': member.id,
        'tripId': member.tripId,
        'name': member.name,
        'memo': member.memo,
        'createdAt': member.createdAt,
        'updatedAt': member.updatedAt,
      };

  static String encodeMembers(List<Member> members) => json.encode(
        members
            .map<Map<String, dynamic>>((member) => Member.toMap(member))
            .toList(),
      );

  static List<Member> decodeMembers(String members) =>
      (json.decode(members) as List<dynamic>)
          .map<Member>((member) => Member.fromJson(member))
          .toList();
}
