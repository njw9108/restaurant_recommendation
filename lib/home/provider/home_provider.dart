import 'package:flutter/material.dart';

class HomeProvider with ChangeNotifier {
  List<String> _selectedTagList = [];

  List<String> get selectedTagList => _selectedTagList;

  set selectedTagList(List<String> value) {
    _selectedTagList = value;
    notifyListeners();
  }
}
