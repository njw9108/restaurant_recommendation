import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:recommend_restaurant/common/const/firestore_constants.dart';
import 'package:recommend_restaurant/user/model/my_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LoginStatus {
  notInit,
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateException,
  authenticateCanceled,
}

class AuthProvider with ChangeNotifier {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final SharedPreferences prefs;

  LoginStatus _status = LoginStatus.notInit;

  LoginStatus get status => _status;

  MyUserModel? _userModel;

  MyUserModel? get userModel => _userModel;

  AuthProvider({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.prefs,
  });

  final _authStreamController = StreamController<LoginStatus>.broadcast();

  Stream<LoginStatus> get authStream =>
      _authStreamController.stream.asBroadcastStream();

  String? getUserFirebaseId() {
    return prefs.getString(FirestoreUserConstants.id);
  }

  Future<void> checkLogin() async {
    _status = LoginStatus.uninitialized;

    bool isLoggedIn = await googleSignIn.isSignedIn();
    final accessToken = prefs.getString(FirestoreUserConstants.accessToken);
    final idToken = prefs.getString(FirestoreUserConstants.idToken);

    if (accessToken == null || idToken == null) {
      notifyListeners();
      return;
    }

    try {
      final firebaseUser = await _getFirebaseUser(
        accessToken: accessToken,
        idToken: idToken,
      );

      if (isLoggedIn && firebaseUser != null) {
        final getUserModel =
            await _getMyUserModelFromFirebaseStore(firebaseUser);
        if (getUserModel) {
          _status = LoginStatus.authenticated;
          _authStreamController.sink.add(_status);
        }
      }
    } catch (e) {}
    notifyListeners();
  }

  Future<void> signIn() async {
    _status = LoginStatus.authenticating;
    notifyListeners();

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final firebaseUser = await _getFirebaseUser(
        accessToken: googleAuth.accessToken ?? '',
        idToken: googleAuth.idToken ?? '',
      );

      if (firebaseUser != null) {
        final getUserModel =
            await _getMyUserModelFromFirebaseStore(firebaseUser);
        if (getUserModel) {
          _status = LoginStatus.authenticated;
          _authStreamController.sink.add(_status);
          notifyListeners();
        }
      } else {
        _status = LoginStatus.authenticateError;
        notifyListeners();
      }
    } else {
      _status = LoginStatus.authenticateCanceled;
      notifyListeners();
    }
  }

  Future<User?> _getFirebaseUser({
    required String accessToken,
    required String idToken,
  }) async {
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: idToken,
    );

    User? firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      await prefs.setString(FirestoreUserConstants.accessToken, accessToken);
      await prefs.setString(FirestoreUserConstants.idToken, idToken);
    }

    return firebaseUser;
  }

  Future<void> _saveUserToFirebaseStore(MyUserModel userModel) async {
    try {
      await firebaseFirestore
          .collection(FirestoreUserConstants.pathUserCollection)
          .doc(userModel.id)
          .set(
        {
          FirestoreUserConstants.id: userModel.id,
          FirestoreUserConstants.nickname: userModel.nickname,
          FirestoreUserConstants.email: userModel.email,
          FirestoreUserConstants.photoUrl: userModel.photoUrl,
          FirestoreUserConstants.createdAt:
              DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveUserToLocal(MyUserModel userModel) async {
    try {
      await prefs.setString(FirestoreUserConstants.id, userModel.id);
      await prefs.setString(
          FirestoreUserConstants.nickname, userModel.nickname);
      await prefs.setString(FirestoreUserConstants.email, userModel.email);
      await prefs.setString(
          FirestoreUserConstants.photoUrl, userModel.photoUrl);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _getMyUserModelFromFirebaseStore(User firebaseUser) async {
    try {
      final result = await firebaseFirestore
          .collection(FirestoreUserConstants.pathUserCollection)
          .doc(firebaseUser.uid)
          .get();

      final Map<String, dynamic>? userData = result.data();

      if (userData == null ||
          userData[FirestoreUserConstants.id] == null ||
          userData[FirestoreUserConstants.id] != firebaseUser.uid) {
        _userModel = MyUserModel(
          id: firebaseUser.uid,
          photoUrl: firebaseUser.photoURL ?? '',
          nickname: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
        );

        await Future.wait([
          _saveUserToFirebaseStore(_userModel!),
          _saveUserToLocal(_userModel!),
        ]);
      } else {
        _userModel = MyUserModel.fromJson(userData);

        await _saveUserToLocal(_userModel!);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    _status = LoginStatus.uninitialized;
    await prefs.remove(FirestoreUserConstants.accessToken);
    await prefs.remove(FirestoreUserConstants.idToken);

    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    notifyListeners();
  }
}
