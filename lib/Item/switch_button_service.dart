class SwitchButtonService {
  static SwitchButtonService _instance = SwitchButtonService._internal();

  String _switchType;

  SwitchButtonService._internal();

  factory SwitchButtonService() {
    if (_instance == null) {
      _instance = SwitchButtonService._internal();
    }
    return _instance;
  }

  String getSwitchType() {
    return this._switchType;
  }

  void setSwitchType(String switchType) {
    this._switchType = switchType;
  }
}
