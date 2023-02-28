import 'package:flutter/material.dart';

class HomeProvider with ChangeNotifier {
  List<String> _selectedTagList = [];
  List<String> _selectedCategoryList = [];

  List<String> get selectedTagList => _selectedTagList;

  set selectedTagList(List<String> value) {
    _selectedTagList = value;
    notifyListeners();
  }

  List<String> get selectedCategoryList => _selectedCategoryList;

  set selectedCategoryList(List<String> value) {
    _selectedCategoryList = value;
    notifyListeners();
  }
}
