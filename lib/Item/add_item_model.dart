import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_money_local/Item/switch_button_service.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
import 'package:trip_money_local/domain/db_table/switchType.dart';
import 'package:trip_money_local/domain/db_table/trip.dart';
import 'package:trip_money_local/member/add_member_model.dart';
import 'package:trip_money_local/trip/add_trip_model.dart';
import 'package:uuid/uuid.dart';

class AddUpdateItemModel extends ChangeNotifier {
  String title = '';
  int money = 0;
  String memberId;
  String memo;
  List<Item> items = [];
  List<Member> members;
  Trip selectedTrip;
  SwitchButtonService switchButtonService = SwitchButtonService();

  Future addItem(Item item) async {
    if (item.title == null || item.title.length <= 0) {
      throw ('タイトルを入力してください。');
    }
    if (item.money == null || item.money < 0) {
      throw ('金額を入力してください。');
    }
    if (item.memberId == null) {
      throw ('メンバーを選択してください。');
    }
    List<String> checkList = [];
    checkList.add(item.memberId);
    item.checkMemberList = checkList;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // trip追加時はitem.tripIdを使う
    String tripId;
    if (item.tripId == null) {
      tripId = await AddUpdateTripModel().getSelectedTripId();
      item.tripId = tripId;
    } else {
      tripId = item.tripId;
    }
    final key = 'items_${item.tripId}';
    var itemsData = prefs.getString(key);
    // 保存データがない時　通常はサンプルデータを保存するのでありえない
    List<Item> itemsDecoded;
    if (itemsData == null) {
      itemsDecoded = [];
      itemsDecoded.add(item);
    } else {
      itemsDecoded = Item.decodeItems(itemsData);
      itemsDecoded.add(item);
    }

    // ローカルストレージに保存するためにエンコード
    final itemsEncoded = Item.encodeItems(itemsDecoded);
    prefs.setString(key, itemsEncoded);
    notifyListeners();
  }

  Future updateItem(Item updateItem) async {
    if (updateItem.title == null || updateItem.title.length <= 0) {
      throw ('タイトルを入力してください。');
    }
    if (updateItem.money == null || updateItem.money <= 0) {
      throw ('金額を入力してください。');
    }
    if (updateItem.memberId == null) {
      throw ('メンバーを選択してください。');
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final tripId = await AddUpdateTripModel().getSelectedTripId();
    updateItem.tripId = tripId;

    List<Item> items = await getItems2(tripId);

    items.removeWhere((item) => item.id == updateItem.id);
    items.add(updateItem);

    // ローカルストレージに保存するためにエンコード
    final itemsEncoded = Item.encodeItems(items);
    final key = 'items_$tripId';
    prefs.setString(key, itemsEncoded);
    notifyListeners();
  }

  Future getItems(String switchType) async {
    switchType = switchButtonService.getSwitchType();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // ストレージからtripidを探す
    String selectedTripId = await AddUpdateTripModel().getSelectedTripId();
    if (selectedTripId == null) {
      // 初めてのアプリ起動
      // サンプルのTrip、Member、Itemを作成する
      print('初めての起動');
      await AddUpdateTripModel().createSampleTrip();
      selectedTripId = await AddUpdateTripModel().getSelectedTripId();
    }
    String tripId = selectedTripId;

    List<Trip> trips = await AddUpdateTripModel().getTrips();
    this.selectedTrip =
        trips.firstWhere((trip) => trip.id == tripId, orElse: () => null);
    if (this.selectedTrip == null) {
      this.selectedTrip = trips.first;
      tripId = this.selectedTrip.id;
      await AddUpdateTripModel().selectedTrip(this.selectedTrip);
    }
    final key = 'items_$tripId';
    final itemsData = prefs.getString(key);
    if (itemsData == null) {
      this.items = null;
      notifyListeners();
      return null;
    }

    // stringからList<Item>にデコード
    List<Item> itemsDecoded = Item.decodeItems(itemsData);

    if (itemsDecoded.isEmpty || itemsDecoded == null) {
      notifyListeners();
      return null;
    }
    // 更新日が最新順にソート
//    itemsDecoded.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (switchType == SwitchType.ALL) {
    } else if (switchType == SwitchType.TODO) {
      itemsDecoded = itemsDecoded.where((item) => !item.isPaid).toList();
    } else if (switchType == SwitchType.DONE) {
      itemsDecoded = itemsDecoded.where((item) => item.isPaid).toList();
    } else {}

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
    String type = await SwitchButtonService().getSwitchType();

    // itemsを最新にしないと怒られる
    await getItems(type);
  }

  Future updateIsPayItem(Item paidItem) async {
    String selectedTripId = await AddUpdateTripModel().getSelectedTripId();
    final key = 'items_$selectedTripId';

    String type = await SwitchButtonService().getSwitchType();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Item> items = await getItems2(selectedTripId);

    items.removeWhere((item) => item.id == paidItem.id);
    if (type == SwitchType.TODO) {
      paidItem.isPaid = true;
    } else if (type == SwitchType.DONE) {
      paidItem.isPaid = false;
    }

    items.add(paidItem);
    final itemsEncoded = Item.encodeItems(items);
    prefs.setString(key, itemsEncoded);
    // itemsを最新にしないと怒られる
    await getItems(type);
  }

  // ドロップダウン
  List<String> _orderTypeJPList = ['新しい順', '古い順', '高い順', '安い順'];

  String _selectedOrderType;

  List<String> get orderTypeJPList => _orderTypeJPList;
  String get selectedOrderType => _selectedOrderType;

  // 並び替える種類をセット
  setOrderItem(String orderType) {
    _selectedOrderType = orderType;
    rearrangesItems(orderType);
    notifyListeners();
  }

  // タスクを並び替える
  rearrangesItems(String orderType) {
    if (this.items == null || this.items.isEmpty) {
      return;
    }

    if (orderType == '新しい順') {
      this.items.sort((a, b) => -a.updatedAt.compareTo(b.updatedAt));
    } else if (orderType == '古い順') {
      this.items.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    } else if (orderType == '高い順') {
      this.items.sort((a, b) => -a.money.compareTo(b.money));
    } else if (orderType == '安い順') {
      this.items.sort((a, b) => a.money.compareTo(b.money));
    }
  }

  changeCheckBox(String memberId, bool isCheck) {
    print(isCheck);
  }
}
