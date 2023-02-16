import 'package:flutter/material.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateException,
  authenticateCanceled,
}

class UserLoginStatusProvider with ChangeNotifier {
  Status _status = Status.uninitialized;

  set status(Status value) {
    _status = value;
    notifyListeners();
  }

  Status get status => _status;
}
