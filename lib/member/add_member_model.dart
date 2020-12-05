import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
import 'package:trip_money_local/trip/add_trip_model.dart';

class AddUpdateMemberModel extends ChangeNotifier {
  String name = '';
  String memo = '';
  List<Member> members;

  Future addMember(Member member) async {
    String tripId = await AddUpdateTripModel().getSelectedTripId();
    member.tripId = tripId;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = 'members_$tripId';
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

  Future getMembers() async {
    String tripId = await AddUpdateTripModel().getSelectedTripId();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = 'members_$tripId';
    final membersData = prefs.getString(key);
    if (membersData == null) {
      return null;
    }

    // stringからList<Member>にデコード
    List<Member> membersDecoded = Member.decodeMembers(membersData);
    this.members = membersDecoded;
    notifyListeners();
    return membersDecoded;
  }

  Future deleteAllMember(tripId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = 'members_$tripId';
    prefs.remove(key);
    notifyListeners();
  }

  Future deleteMember(Member deleteMember) async {
    String selectedTripId = await AddUpdateTripModel().getSelectedTripId();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = 'members_$selectedTripId';

    final membersData = prefs.getString(key);
    if (membersData == null) {
      return null;
    }

    // stringからList<Member>にデコード
    List<Member> membersDecoded = Member.decodeMembers(membersData);
    membersDecoded.removeWhere((member) => member.id == deleteMember.id);

    final membersEncoded = Member.encodeMembers(membersDecoded);
    prefs.setString(key, membersEncoded);
    // itemsを最新にしないと怒られる
    await getMembers();
  }
}
