import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionProvider with ChangeNotifier {
  String _appVersion = '';
  String _buildNumber = '';

  String get appVersion => _appVersion;

  String get buildNumber => _buildNumber;

  Future<bool> checkAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;
    final config = await _getAppVersionFromFirebaseConfig();

    final value = jsonDecode(config);

    if (value['name'] == appVersion) {
      notifyListeners();
      return true;
    } else {
      if (kDebugMode) {
        notifyListeners();
        return true;
      }
      return false;
    }
  }

  Future<String> _getAppVersionFromFirebaseConfig() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 0),
    ));
    await remoteConfig.fetchAndActivate();
    return remoteConfig.getString('supportedBuild');
  }
}
