import 'package:flutter/material.dart';

class TutorialModel extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  int incrementAndGetCurrentIndex() {
    _currentIndex++;
    notifyListeners();
    return _currentIndex;
  }

  int decrementAndGetCurrentIndex() {
    _currentIndex--;
    notifyListeners();
    return _currentIndex;
  }

  reNotifyListeners() {
    notifyListeners();
  }
}
