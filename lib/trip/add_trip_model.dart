import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_money_local/domain/db_table/trip.dart';
import 'package:uuid/uuid.dart';

class AddUpdateTripModel extends ChangeNotifier {
  String name = '';
  String memo = '';
  List<Trip> trips;

  Future addTrip(Trip trip) async {
    trip.id = Uuid().v1();
    trip.createdAt = DateTime.now().toString();
    trip.updatedAt = DateTime.now().toString();

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
}
