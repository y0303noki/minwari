import 'package:flutter/material.dart';

class FooterNavigationService {
  static FooterNavigationService _instance =
      FooterNavigationService._internal();

  String _footerType;
  int _currentIndex = 0;

  FooterNavigationService._internal();

  factory FooterNavigationService() {
    if (_instance == null) {
      _instance = FooterNavigationService._internal();
    }
    return _instance;
  }

  String getFooterType() {
    return this._footerType;
  }

  void setFooterType(String footerType) {
    this._footerType = footerType;
    this._currentIndex = 1;
  }
}
