import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
import 'package:trip_money_local/domain/db_table/trip.dart';
import 'package:trip_money_local/member/add_member_model.dart';
import 'package:trip_money_local/trip/add_trip_model.dart';
import 'package:uuid/uuid.dart';

class AddUpdateItemModel extends ChangeNotifier {
  String title = '';
  int money = 0;
  String memberId;
  List<Item> items = [];
  List<Member> members;
  Trip selectedTrip;

  Future addItem(Item item) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final tripId = await AddUpdateTripModel().getSelectedTripId();
    item.tripId = tripId;
    final key = 'items_${item.tripId}';
    var itemsData = prefs.getString(key);
    // 保存データがない時　通常はサンプルデータを保存するのでありえない
    print('itemsData:$itemsData');
    if (itemsData == null) {
      final String now = DateTime.now().toString();
      final uuid = Uuid().v1();
      String testMemberId = Uuid().v1();
      print('uuid:$uuid');
      Item tesItem = Item(
          id: uuid,
          tripId: tripId,
          title: 'test',
          money: 0,
          memberId: testMemberId,
          createdAt: now,
          updatedAt: now);
      List<Item> testItems = [tesItem];
      itemsData = Item.encodeItems(testItems);
    }
    // stringからList<Item>にデコード
    List<Item> itemsDecoded = Item.decodeItems(itemsData);
    itemsDecoded.add(item);

    // ローカルストレージに保存するためにエンコード
    final itemsEncoded = Item.encodeItems(itemsDecoded);
    prefs.setString(key, itemsEncoded);
    notifyListeners();
  }

  Future getItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // ストレージからtripidを探す
    String selectedTripId = await AddUpdateTripModel().getSelectedTripId();
    final tripId = selectedTripId;

    List<Trip> trips = await AddUpdateTripModel().getTrips();
    this.selectedTrip = trips.firstWhere((trip) => trip.id == tripId);

    final key = 'items_$tripId';
    final itemsData = prefs.getString(key);
    if (itemsData == null) {
      this.items = null;
      notifyListeners();
      return null;
    }

    // stringからList<Item>にデコード
    List<Item> itemsDecoded = Item.decodeItems(itemsData);
    // 更新日が最新順にソート
//    itemsDecoded.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    this.items = itemsDecoded;

    this.members = await AddUpdateMemberModel().getMembersNoNotify();
    notifyListeners();
    return itemsDecoded;
  }

  Future getItems2(tripId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = 'items_$tripId';
    final itemsData = prefs.getString(key);
    if (itemsData == null) {
      return null;
    }

    // stringからList<Item>にデコード
    List<Item> itemsDecoded = Item.decodeItems(itemsData);
    return itemsDecoded;
  }

  // 開発用、ほぼ使わない
  Future deleteAllItem() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Trip> trips = await AddUpdateTripModel().getTrips();
    for (var value in trips) {
      print('tripId:${value.id}');
      final key = 'items_${value.id}';
      prefs.remove(key);
    }
    notifyListeners();
  }

  Future deleteItem(Item deleteItem) async {
    String selectedTripId = await AddUpdateTripModel().getSelectedTripId();
    final key = 'items_$selectedTripId';

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Item> items = await getItems2(selectedTripId);

    items.removeWhere((item) => item.id == deleteItem.id);
    final itemsEncoded = Item.encodeItems(items);
    prefs.setString(key, itemsEncoded);
    // itemsを最新にしないと怒られる
    await getItems();
  }
}
