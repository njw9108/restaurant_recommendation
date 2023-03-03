import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:recommend_restaurant/common/const/firestore_constants.dart';
import 'package:recommend_restaurant/user/model/my_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum LoginStatus {
  notInit,
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateException,
  authenticateCanceled,
}

enum SignInType {
  google,
  apple,
  kakao,
}

class AuthProvider with ChangeNotifier {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn;
  final SharedPreferences prefs;

  LoginStatus _status = LoginStatus.notInit;

  LoginStatus get status => _status;

  MyUserModel? _userModel;

  MyUserModel? get userModel => _userModel;

  AuthProvider({
    required this.googleSignIn,
    required this.prefs,
  });

  final _authStreamController = StreamController<LoginStatus>.broadcast();

  Stream<LoginStatus> get authStream =>
      _authStreamController.stream.asBroadcastStream();

  String? getUserFirebaseId() {
    return prefs.getString(FirestoreUserConstants.uid);
  }

  Future<void> checkLogin() async {
    _status = LoginStatus.uninitialized;

    final String? accessToken =
        prefs.getString(FirestoreUserConstants.accessToken);
    final String? idToken = prefs.getString(FirestoreUserConstants.idToken);
    final int? loginType = prefs.getInt(FirestoreUserConstants.loginType);

    if (accessToken == null || idToken == null || loginType == null) {
      notifyListeners();
      return;
    }

    try {
      final firebaseUser = await _getFirebaseUser(
        accessToken: accessToken,
        idToken: idToken,
        type: SignInType.values[loginType],
      );

      // if (isLoggedIn && firebaseUser != null) {
      if (firebaseUser != null) {
        final getUserModel =
            await _getMyUserModelFromFirebaseStore(firebaseUser);
        if (getUserModel) {
          _status = LoginStatus.authenticated;
          _authStreamController.sink.add(_status);
        }
      }
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _status = LoginStatus.authenticating;
    notifyListeners();

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final firebaseUser = await _getFirebaseUser(
        accessToken: googleAuth.accessToken ?? '',
        idToken: googleAuth.idToken ?? '',
        type: SignInType.google,
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

  Future<void> signInWithApple() async {
    _status = LoginStatus.authenticating;
    notifyListeners();

    try {
      final String? idToken = prefs.getString(FirestoreUserConstants.idToken);

      //
      // AppleAuthProvider appleAuthProvider = AppleAuthProvider();
      // appleAuthProvider.addScope('name');
      // appleAuthProvider.addScope('email');
      //
      //
      // UserCredential credential = await FirebaseAuth.instance.signInWithProvider(appleAuthProvider);
      // User? user = credential.user;
      // print(credential.credential?.token);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final firebaseUser = await _getFirebaseUser(
        accessToken: credential.authorizationCode,
        idToken: credential.identityToken ?? '',
        type: SignInType.apple,
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
    } catch (e) {
      _status = LoginStatus.authenticateCanceled;
      notifyListeners();
    }
  }

  Future<User?> _getFirebaseUser({
    required String accessToken,
    required String idToken,
    required SignInType type,
  }) async {
    try {
      AuthCredential credential;
      switch (type) {
        case SignInType.google:
          credential = GoogleAuthProvider.credential(
            accessToken: accessToken,
            idToken: idToken,
          );
          break;
        case SignInType.apple:
          credential = OAuthProvider("apple.com").credential(
            accessToken: accessToken,
            idToken: idToken,
          );
          break;
        case SignInType.kakao:
          credential = GoogleAuthProvider.credential(
            accessToken: accessToken,
            idToken: idToken,
          );
          break;
        default:
          credential = GoogleAuthProvider.credential(
            accessToken: accessToken,
            idToken: idToken,
          );
          break;
      }

      User? firebaseUser =
          (await FirebaseAuth.instance.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        await prefs.setString(FirestoreUserConstants.accessToken, accessToken);
        await prefs.setString(FirestoreUserConstants.idToken, idToken ?? '');
        await prefs.setInt(FirestoreUserConstants.loginType, type.index);
      }

      return firebaseUser;
    } catch (e) {
      print(e);
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        return firebaseUser;
      } else {
        return null;
      }
    }
  }

  Future<void> _saveUserToFirebaseStore(MyUserModel userModel) async {
    try {
      await firebaseFirestore
          .collection(FirestoreUserConstants.pathUserCollection)
          .doc(userModel.id)
          .set(
        {
          FirestoreUserConstants.uid: userModel.id,
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
      await prefs.setString(FirestoreUserConstants.uid, userModel.id);
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
          userData[FirestoreUserConstants.uid] == null ||
          userData[FirestoreUserConstants.uid] != firebaseUser.uid) {
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

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    notifyListeners();
  }
}
