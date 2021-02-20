import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_money_local/Item/add_item_model.dart';
import 'package:trip_money_local/domain/db_table/item.dart';
import 'package:trip_money_local/domain/db_table/member.dart';
import 'package:trip_money_local/domain/db_table/trip.dart';
import 'package:trip_money_local/member/add_member_model.dart';
import 'package:uuid/uuid.dart';

class AddUpdateTripModel extends ChangeNotifier {
  String name = '';
  String memo = '';
  List<Trip> trips;
  Trip selectedTripFromTrip;

  Future createSampleTrip() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final DateTime nowDate = DateTime.now();
    final String now = '${nowDate.year}-12-31';
    Trip sampleTrip = Trip(
        id: Uuid().v1(),
        name: 'サンプル旅',
        memo: null,
        isSelected: true,
        createdAt: now,
        eventAt: now,
        eventEndAt: now,
        updatedAt: now);
    List<Trip> trips = [];
    trips.add(sampleTrip);
    final tripsEncoded = Trip.encodeTrips(trips);
    final key = 'trips';
    prefs.setString(key, tripsEncoded);

    // 現在のtripに設定
    final selectedTripId = 'selectedTripId';
    prefs.setString(selectedTripId, sampleTrip.id);

    final Member sampleMember = Member(
        id: Uuid().v1(),
        tripId: sampleTrip.id,
        name: 'サンプルメンバー',
        memo: null,
        color: null,
        updatedAt: now,
        createdAt: now);
    await AddUpdateMemberModel().addMember(sampleMember);

    final Item sampleItem = Item(
      id: Uuid().v1(),
      tripId: sampleTrip.id,
      title: 'サンプルタスク',
      money: 1000,
      memberId: sampleMember.id,
      memo: null,
      isPaid: false,
      createdAt: now,
      updatedAt: now,
    );
    await AddUpdateItemModel().addItem(sampleItem);

    notifyListeners();
  }

  Future addTrip(Trip trip) async {
    if (trip.name == null || trip.name.length <= 0) {
      throw ('タイトルを入力してください。');
    }
    if (trip.eventAt == null || trip.eventAt == '') {
      throw ('出発日を選択してください。');
    }
    if (trip.eventEndAt == null || trip.eventEndAt == '') {
      throw ('帰宅日を選択してください。');
    }
    if (trip.name.length > 10) {
      throw ('タイトルは10文字未満にしてください。');
    }
    DateTime startTime = DateTime.parse(trip.eventAt);
    DateTime endTime = DateTime.parse(trip.eventEndAt);
    if (startTime.isAfter(endTime)) {
      throw ('帰宅日は出発日と同じ日付か、それ以降の日付にしてください。');
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = 'trips';
    var tripsData = prefs.getString(key);
    // 保存データがない時　通常はサンプルデータを保存するのでありえない
    if (tripsData == null) {
      Trip tesTrip = trip;
      List<Trip> tesTrips = [tesTrip];
      tripsData = Trip.encodeTrips(tesTrips);
    }
    // stringからList<Trip>にデコード
    List<Trip> tripsDecoded = Trip.decodeTrips(tripsData);
    tripsDecoded.add(trip);

    // ローカルストレージに保存するためにエンコード
    final tripsEncoded = Trip.encodeTrips(tripsDecoded);
    prefs.setString(key, tripsEncoded);
    notifyListeners();
  }

  Future updateTrip(Trip updatedTrip) async {
    if (updatedTrip.name == null || updatedTrip.name.length <= 0) {
      throw ('タイトルを入力してください。');
    }
    if (updatedTrip.eventAt == null || updatedTrip.eventAt == '') {
      throw ('出発日を選択してください。');
    }
    if (updatedTrip.eventEndAt == null || updatedTrip.eventEndAt == '') {
      throw ('帰宅日を選択してください。');
    }
    if (updatedTrip.name.length > 10) {
      throw ('タイトルは10文字未満にしてください。');
    }
    DateTime startTime = DateTime.parse(updatedTrip.eventAt);
    DateTime endTime = DateTime.parse(updatedTrip.eventEndAt);
    if (startTime.isAfter(endTime)) {
      throw ('帰宅日は出発日と同じ日付か、それ以降の日付にしてください。');
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = 'trips';
    var tripsData = prefs.getString(key);
    // stringからList<Trip>にデコード
    List<Trip> tripsDecoded = Trip.decodeTrips(tripsData);
    tripsDecoded.removeWhere((trip) => trip.id == updatedTrip.id);
    tripsDecoded.add(updatedTrip);

    // ローカルストレージに保存するためにエンコード
    final tripsEncoded = Trip.encodeTrips(tripsDecoded);
    prefs.setString(key, tripsEncoded);
    notifyListeners();
  }

  Future getTrips() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = 'trips';
    final tripsData = prefs.getString(key);
    if (tripsData == null) {
      return null;
    }

    // stringからList<Trip>にデコード
    List<Trip> tripsDecoded = Trip.decodeTrips(tripsData);
    this.trips = tripsDecoded;

    String tripId = await AddUpdateTripModel().getSelectedTripId();
    if (this.trips == null || this.trips.isEmpty) {}

    this.selectedTripFromTrip =
        this.trips.firstWhere((trip) => trip.id == tripId, orElse: () => null);

    notifyListeners();
    return tripsDecoded;
  }

  Future deleteAllTrip() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = 'trips';
    prefs.remove(key);
    notifyListeners();
  }

  Future getSelectedTripId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final selectedTripId = 'selectedTripId';
    return prefs.getString(selectedTripId);
  }

  Future selectedTrip(Trip selectedTrip) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = 'trips';
    final tripsData = prefs.getString(key);
    if (tripsData == null) {
      return null;
    }

    List<Trip> tripsDecoded = Trip.decodeTrips(tripsData);
    this.trips = tripsDecoded;

    String selectedId = '';

    this.trips.forEach((trip) {
      if (trip.id == selectedTrip.id) {
        trip.isSelected = true;
        selectedId = trip.id;
        print(trip.name);
      } else {
        trip.isSelected = false;
      }
    });

    final tripsEncoded = Trip.encodeTrips(this.trips);
    prefs.setString(key, tripsEncoded);

    // selectedTripをストレージに保管する方法
    final selectedTripId = 'selectedTripId';
    prefs.setString(selectedTripId, selectedId);
    notifyListeners();
  }

  Future deleteTrip(Trip deleteTrip) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = 'trips';

    final tripsData = prefs.getString(key);
    if (tripsData == null) {
      return null;
    }

    // stringからList<Trip>にデコード
    List<Trip> tripsDecoded = Trip.decodeTrips(tripsData);
    tripsDecoded.removeWhere((trip) => trip.id == deleteTrip.id);

    final tripsEncoded = Trip.encodeTrips(tripsDecoded);
    prefs.setString(key, tripsEncoded);
    // itemsを最新にしないと怒られる
    await getTrips();
  }

  // イベント日付選択
  String eventDate;
  setEventDate(String pickDate) {
    eventDate = pickDate;
    notifyListeners();
  }

  // イベント終了日付
  String eventEndDate;
  setEventEndDate(String pickDate) {
    eventEndDate = pickDate;
    notifyListeners();
  }
}
