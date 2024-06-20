// ignore_for_file: avoid_print

import 'package:apptv02/gql/app.dart';
import 'package:apptv02/gql/graphql.dart';
import 'package:apptv02/models/app_version.dart';
import 'package:apptv02/models/link.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AppProvider extends ChangeNotifier {
  GraphQLClient client = cli();
  String? _appCurrentVersion;
  AppVersion? _app;
  double _progressValue = 0.0;
  LinkApp _linkApp = LinkApp(tv: '', movies: '', series: '');

  bool _downloaded = false;

  String? get appCurrentVersion => _appCurrentVersion;
  double get progressValue => _progressValue;
  AppVersion? get app => _app;
  LinkApp get linkApp => _linkApp;

  init() {
    getVersionNumber();
  }

  getLinkApp() async {
    QueryResult res = await client.query(QueryOptions(document: LINK_APP));
    if (res.data != null) {
      final l = res.data!["link"]["data"]["attributes"];
      _linkApp = LinkApp(tv: l["tv"], movies: l["movies"], series: l["series"]);
    }
    notifyListeners();
  }

  Future<void> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    _appCurrentVersion = version;
    QueryResult res = await client.query(QueryOptions(document: APP_VERSION));
    if (res.data != null) {
      final a = res.data!["app"]["data"]["attributes"];
      _app = AppVersion(version: a["version"], appUrl: a["appUrl"]);
    }
    notifyListeners();
  }

  // https://raw.githubusercontent.com/jrnn21/apptvApk/main/appv1.apk
  void networkInstallApk({required AppVersion app}) async {
    if (_progressValue != 0.0 && _progressValue < 1) {
      // print("Wait a moment, downloading");
      return;
    }
    _progressValue = 0.0;
    var appDocDir = await getTemporaryDirectory();
    String savePath = "${appDocDir.path}/appv${app.version}.apk";

    if (!_downloaded) {
      final appv = await Dio().download(app.appUrl, savePath,
          onReceiveProgress: (count, total) {
        final value = count / total;
        if (_progressValue != value) {
          if (_progressValue < 1.0) {
            _progressValue = count / total;
          } else {
            _progressValue = 0.0;
          }
          // print("${(_progressValue * 100).toStringAsFixed(0)}%");
          notifyListeners();
        }
      });
      if (appv.statusCode == 200) {
        _downloaded = true;
      }
    }

    var status = await Permission.requestInstallPackages.request();
    if (status.isGranted) {
      final res = await InstallPlugin.install(savePath);
      print(
          "install apk ${res['isSuccess'] == true ? 'success' : 'fail:${res['errorMessage'] ?? ''}'}");
    } else {
      final res = await InstallPlugin.install(savePath);
      print(
          "install apk ${res['isSuccess'] == true ? 'success' : 'fail:${res['errorMessage'] ?? ''}'}");
      _progressValue = 0.0;
      notifyListeners();
    }
  }
}
