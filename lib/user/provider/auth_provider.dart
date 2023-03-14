import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recommend_restaurant/common/const/firestore_constants.dart';
import 'package:recommend_restaurant/user/model/my_user_model.dart';
import 'package:recommend_restaurant/user/use_case/apple_login.dart';
import 'package:recommend_restaurant/user/use_case/google_login.dart';
import 'package:recommend_restaurant/user/use_case/social_login.dart';

import '../../common/repository/firebase_repository.dart';
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
  withdrawal,
}

enum SignInType {
  google,
  apple,
  kakao,
}

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage secureStorage;
  final FirebaseAuthRemoteRepository firebaseAuthRemoteRepository;
  final FirebaseRepository firebaseRepository;

  LoginStatus _status = LoginStatus.notInit;

  LoginStatus get status => _status;

  MyUserModel? _userModel;

  MyUserModel? get userModel => _userModel;

  late SocialLogin _googleLoginUseCase;
  late SocialLogin _appleLoginUseCase;
  late SocialLogin _kakaoLoginUseCase;

  AuthProvider({
    required this.secureStorage,
    required this.firebaseAuthRemoteRepository,
    required this.firebaseRepository,
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

  Future<void> checkLogin() async {
    _status = LoginStatus.uninitialized;

    final String? accessToken =
        await secureStorage.read(key: FirestoreUserConstants.accessToken);
    final String? idToken =
        await secureStorage.read(key: FirestoreUserConstants.idToken);
    final temp =
        await secureStorage.read(key: FirestoreUserConstants.loginType);
    final int? loginType = temp == null ? null : int.parse(temp);

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
        await secureStorage.write(
            key: FirestoreUserConstants.accessToken, value: accessToken);
        await secureStorage.write(
            key: FirestoreUserConstants.idToken, value: idToken);
        await secureStorage.write(
            key: FirestoreUserConstants.loginType,
            value: type.index.toString());
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
      await firebaseRepository.saveUserToFirebase(userModel: userModel);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserName(String userName) async {
    if (_userModel != null) {
      _userModel = _userModel!.copyWith(nickname: userName);
      firebaseRepository.updateUserToFirebase(userModel: userModel!);
      notifyListeners();
    }
  }

  Future<void> _saveUserToLocal(MyUserModel userModel) async {
    try {
      await secureStorage.write(
          key: FirestoreUserConstants.uid, value: userModel.id);
      await secureStorage.write(
          key: FirestoreUserConstants.nickname, value: userModel.nickname);
      await secureStorage.write(
          key: FirestoreUserConstants.email, value: userModel.email);
      await secureStorage.write(
          key: FirestoreUserConstants.photoUrl, value: userModel.photoUrl);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _getMyUserModelFromFirebaseStore(User firebaseUser) async {
    try {
      final userData = await firebaseRepository.getUserModelFromFirebase(
          uid: firebaseUser.uid);

      if (userData == null ||
          userData[FirestoreUserConstants.uid] == null ||
          userData[FirestoreUserConstants.uid] != firebaseUser.uid) {
        _userModel = MyUserModel(
          id: firebaseUser.uid,
          photoUrl: firebaseUser.photoURL ?? '',
          nickname: firebaseUser.displayName ?? '익명 유저',
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
    await secureStorage.delete(key: FirestoreUserConstants.accessToken);
    await secureStorage.delete(key: FirestoreUserConstants.idToken);
    await secureStorage.delete(key: FirestoreUserConstants.loginType);

    await _appleLoginUseCase.logout();
    await _kakaoLoginUseCase.logout();
    await _googleLoginUseCase.logout();

    await FirebaseAuth.instance.signOut();

    notifyListeners();
  }

  void statusInit() {
    _status = LoginStatus.uninitialized;
    notifyListeners();
  }

  Future<void> withdrawal() async {
    _status = LoginStatus.withdrawal;

    firebaseRepository.deleteUserDB();

    await FirebaseAuth.instance.currentUser?.delete();

    final temp =
        await secureStorage.read(key: FirestoreUserConstants.loginType);
    final int? loginType = temp == null ? null : int.parse(temp);
    if (loginType != null) {
      switch (SignInType.values[loginType]) {
        case SignInType.google:
          _googleLoginUseCase.withdrawal();
          break;
        case SignInType.apple:
          _appleLoginUseCase.withdrawal();
          break;
        case SignInType.kakao:
          _kakaoLoginUseCase.withdrawal();
          break;
      }
    }

    await Future.wait([
      secureStorage.delete(key: FirestoreUserConstants.accessToken),
      secureStorage.delete(key: FirestoreUserConstants.idToken),
      secureStorage.delete(key: FirestoreUserConstants.loginType),
    ]);

    notifyListeners();
  }
}
