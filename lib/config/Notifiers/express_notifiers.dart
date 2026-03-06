import 'package:flutter/material.dart';

class ExpressNotifier extends ChangeNotifier {
  String? _id;

  String? get id => _id;

  void refresh(String newId) {
    _id = newId;
    notifyListeners();
  }

  void clear() {
    _id = null;
  }
}

class ExpressStatusNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}

final expressNotifier = ExpressNotifier();
final expressStatusNotifier = ExpressStatusNotifier();