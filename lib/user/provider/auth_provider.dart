import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recommend_restaurant/common/const/firestore_constants.dart';
import 'package:recommend_restaurant/user/model/my_user_model.dart';
import 'package:recommend_restaurant/user/use_case/apple_login.dart';
import 'package:recommend_restaurant/user/use_case/google_login.dart';
import 'package:recommend_restaurant/user/use_case/social_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/login_result.dart';
import '../repository/firebase_auth_remote_repository.dart';
import '../use_case/kakao_login.dart';

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
  final SharedPreferences prefs;
  final FirebaseAuthRemoteRepository firebaseAuthRemoteRepository;

  LoginStatus _status = LoginStatus.notInit;

  LoginStatus get status => _status;

  MyUserModel? _userModel;

  MyUserModel? get userModel => _userModel;

  late SocialLogin _googleLoginUseCase;
  late SocialLogin _appleLoginUseCase;
  late SocialLogin _kakaoLoginUseCase;

  AuthProvider({
    required this.prefs,
    required this.firebaseAuthRemoteRepository,
  }) {
    _googleLoginUseCase = GoogleLogin();
    _appleLoginUseCase = AppleLogin();
    _kakaoLoginUseCase = KakaoLogin(
      repository: firebaseAuthRemoteRepository,
    );
  }

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

  Future<void> socialSignIn(SignInType type) async {
    _status = LoginStatus.authenticating;
    notifyListeners();

    SocialLogin useCase;
    switch (type) {
      case SignInType.google:
        useCase = _googleLoginUseCase;
        break;
      case SignInType.apple:
        useCase = _appleLoginUseCase;
        break;
      case SignInType.kakao:
        useCase = _kakaoLoginUseCase;
        break;
    }

    final result = await useCase.login();
    if (result is LoginResult) {
      //로그인 성공
      final firebaseUser = await _getFirebaseUser(
        accessToken: result.accessToken,
        idToken: result.idToken,
        type: type,
      );

      if (firebaseUser != null) {
        final getUserModel =
            await _getMyUserModelFromFirebaseStore(firebaseUser);
        if (getUserModel) {
          _status = LoginStatus.authenticated;
          //로그아웃 후 로그인이 될때마다 정보를 가져올수 있도록 stream 추가
          _authStreamController.sink.add(_status);
          notifyListeners();
        }
      } else {
        _status = LoginStatus.authenticateError;
        notifyListeners();
      }
    } else if (result is LoginError) {
      //로그인 실패, 에러
      _status = LoginStatus.authenticateError;
      notifyListeners();
    } else if (result is LoginCanceled) {
      //로그인 취소
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
      User? firebaseUser;
      switch (type) {
        case SignInType.google:
          credential = GoogleAuthProvider.credential(
            accessToken: accessToken,
            idToken: idToken,
          );
          firebaseUser =
              (await FirebaseAuth.instance.signInWithCredential(credential))
                  .user;
          break;
        case SignInType.apple:
          credential = OAuthProvider("apple.com").credential(
            accessToken: accessToken,
            idToken: idToken,
          );
          firebaseUser =
              (await FirebaseAuth.instance.signInWithCredential(credential))
                  .user;
          break;
        case SignInType.kakao:
          firebaseUser =
              (await FirebaseAuth.instance.signInWithCustomToken(idToken)).user;
          break;
      }

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
    await prefs.remove(FirestoreUserConstants.loginType);

    await _appleLoginUseCase.logout();
    await _kakaoLoginUseCase.logout();
    await _googleLoginUseCase.logout();

    await FirebaseAuth.instance.signOut();

    notifyListeners();
  }


  // void deleteUserFromFirebase() async {
  //   CollectionReference users = FirebaseFirestore.instance.collection(FirestoreUserConstants.pathUserCollection);
  //   users.doc(docId).delete();
  //   User user = FirebaseAuth.instance.currentUser;
  //   user.delete();
  //   await signOutGoogle(); // 위(2번 로그아웃 샘플코드)에서 정의한 함수입니다.
  // }
  //
  // Future<void> withdrawal() async {
  //   final int? loginType = prefs.getInt(FirestoreUserConstants.loginType);
  //   if (loginType != null) {
  //     switch (SignInType.values[loginType]) {
  //       case SignInType.google:
  //         _googleLoginUseCase.withdrawal();
  //         break;
  //       case SignInType.apple:
  //         _googleLoginUseCase.withdrawal();
  //         break;
  //       case SignInType.kakao:
  //         _googleLoginUseCase.withdrawal();
  //         break;
  //     }
  //   }
  //
  //   await signOut();
  // }
}
