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
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  LoginStatus _status = LoginStatus.notInit;

  LoginStatus get status => _status;

  MyUserModel? _userModel;

  MyUserModel? get userModel => _userModel;

  AuthProvider({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.prefs,
    required this.firebaseFirestore,
  });

  String? getUserFirebaseId() {
    return prefs.getString(FirestoreConstants.id);
  }

  Future<void> checkLogin() async {
    _status = LoginStatus.uninitialized;

    bool isLoggedIn = await googleSignIn.isSignedIn();
    final accessToken = prefs.getString(FirestoreConstants.accessToken);
    final idToken = prefs.getString(FirestoreConstants.idToken);

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
      await prefs.setString(FirestoreConstants.accessToken, accessToken);
      await prefs.setString(FirestoreConstants.idToken, idToken);
    }

    return firebaseUser;
  }

  Future<void> _saveUserToFirebaseStore(MyUserModel userModel) async {
    try {
      firebaseFirestore
          .collection(FirestoreConstants.pathUserCollection)
          .doc(userModel.id)
          .set(
        {
          FirestoreConstants.id: userModel.id,
          FirestoreConstants.nickname: userModel.nickname,
          FirestoreConstants.email: userModel.email,
          FirestoreConstants.photoUrl: userModel.photoUrl,
          FirestoreConstants.createdAt:
              DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveUserToLocal(MyUserModel userModel) async {
    try {
      await prefs.setString(FirestoreConstants.id, userModel.id);
      await prefs.setString(FirestoreConstants.nickname, userModel.nickname);
      await prefs.setString(FirestoreConstants.email, userModel.email);
      await prefs.setString(FirestoreConstants.photoUrl, userModel.photoUrl);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _getMyUserModelFromFirebaseStore(User firebaseUser) async {
    try {
      final QuerySnapshot result = await firebaseFirestore
          .collection(FirestoreConstants.pathUserCollection)
          .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isEmpty) {
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
        DocumentSnapshot documentSnapshot = documents.first;
        final Map<String, dynamic> json =
            documentSnapshot.data() as Map<String, dynamic>;
        _userModel = MyUserModel.fromJson(json);

        await _saveUserToLocal(_userModel!);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    _status = LoginStatus.uninitialized;
    await prefs.remove(FirestoreConstants.accessToken);
    await prefs.remove(FirestoreConstants.idToken);

    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    notifyListeners();
  }
}
