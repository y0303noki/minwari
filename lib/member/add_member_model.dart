import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_money_local/domain/db_table/member.dart';

class AddUpdateMemberModel extends ChangeNotifier {
  Future addMember(member) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = 'members_${member.tripId}';
    var membersData = prefs.getString(key);
    // 保存データがない時　通常はサンプルデータを保存するのでありえない
    if (membersData == null) {
      Member tesMember = member;
      List<Member> tesMembers = [tesMember];
      membersData = Member.encodeMembers(tesMembers);
    }
    // stringからList<Member>にデコード
    List<Member> membersDecoded = Member.decodeMembers(membersData);
    membersDecoded.add(member);

    // ローカルストレージに保存するためにエンコード
    final membersEncoded = Member.encodeMembers(membersDecoded);
    prefs.setString(key, membersEncoded);
    notifyListeners();
  }

  Future getMembers(tripId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = 'members_$tripId';
    final membersData = prefs.getString(key);
    if (membersData == null) {
      return null;
    }

    // stringからList<Member>にデコード
    List<Member> membersDecoded = Member.decodeMembers(membersData);

    notifyListeners();
    return membersDecoded;
  }
}
