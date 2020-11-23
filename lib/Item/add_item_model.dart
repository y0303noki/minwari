import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/trip/add_trip_model.dart';

class AddUpdateItemModel extends ChangeNotifier {
  String title = '';
  int money = 0;
  List<Item> items;

  Future addItem(item) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final tripId = await AddUpdateTripModel().getSelectedTripId();
    item.tripId = tripId;
    final key = 'items_${item.tripId}';
    print(item.tripId);
    var itemsData = prefs.getString(key);
    // 保存データがない時　通常はサンプルデータを保存するのでありえない
    if (itemsData == null) {
      final String now = DateTime.now().toString();
      Item tesItem = Item(
          id: -1,
          tripId: tripId,
          title: 'test',
          money: 0,
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

  Future getItems(tripId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // ストレージからtripidを探す
    String selectedTripId = await AddUpdateTripModel().getSelectedTripId();
    tripId = selectedTripId;

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

    this.items = itemsDecoded;
    return itemsDecoded;
  }

  Future deleteAllItem(tripId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = 'items_$tripId';
    prefs.remove(key);
    notifyListeners();
  }
}
