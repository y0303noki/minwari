import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_money_local/domain/db_table/switchType.dart';

class SwitchButtonService {
//  Future<String> getSwitchType() async {
//    final SharedPreferences prefs = await SharedPreferences.getInstance();
//    String result = prefs.getString(key);
//    return result;
//  }

//  Future setSwitchType(String switchType) async {
//    final SharedPreferences prefs = await SharedPreferences.getInstance();
//    prefs.setString(key, switchType);
//  }

  static SwitchButtonService _instance = SwitchButtonService._internal();

//  final key = 'switchType';

  //お財布の中のお金
  String _switchType;

  SwitchButtonService._internal();

  factory SwitchButtonService() {
    if (_instance == null) {
      _instance = SwitchButtonService._internal();
    }
    return _instance;
  }

  String getSwitchType() {
    print('get:${this._switchType}');
    return this._switchType;
  }

//  void setSwitchType(String switchType) {
//    this.switchType = switchType;
//  }

  void setSwitchType(String switchType) {
    this._switchType = switchType;
  }
}
