// ignore_for_file: file_names, prefer_final_fields

import 'package:apptv02/gql/graphql.dart';
import 'package:apptv02/gql/user.dart';
import 'package:apptv02/models/user.dart';
import 'package:apptv02/utility/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

class UserProvider extends ChangeNotifier {
  GraphQLClient client = cli();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  bool _loading = false;
  String _deviceID = '';
  User _user = User(
    id: '',
    username: '',
    jwt: '',
    days: 0,
    begin: '',
    total: 0,
    listDevices: [],
  );
  User get user => _user;
  bool get loading => _loading;
  String get deviceID => _deviceID;

  Future<String> initPlatformState() async {
    try {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } catch (e) {
      return 'Unknown';
    }
  }

  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void setUser(User u) {
    _user = u;
    notifyListeners();
  }

  Future<void> fetchLogin() async {
    _loading = true;
    String tel = await UserPreferences().getUsername();
    String deviceId = await initPlatformState();
    _deviceID = deviceId;
    notifyListeners();
    client.resetStore();
    try {
      if (deviceId == 'Unknown' || tel == '') {
        _loading = false;
        notifyListeners();
        return;
      }
      QueryResult res = await client.mutate(MutationOptions(
        document: LOGIN,
        variables: {
          "input": {
            "identifier": tel.trim(),
            "password": tel.trim(),
          }
        },
      ));

      if (res.data == null) {
        _loading = false;
        notifyListeners();
        return;
      }
      QueryResult resUser = await client.query(QueryOptions(
          document: USER, variables: {"id": res.data!["login"]["user"]["id"]}));
      if (resUser.data == null) {
        _loading = false;
        notifyListeners();
        return;
      }

      final user0 = resUser.data!["usersPermissionsUser"]["data"]["attributes"];

      User user = User(
        id: res.data!["login"]["user"]["id"],
        username: user0["username"],
        jwt: res.data!["login"]["jwt"],
        days: int.parse('${user0["expire"]["days"]}'),
        begin: user0["expire"]["begin"],
        total: int.parse('${user0["devices"]["total"]}'),
        listDevices: user0["devices"]["listDevices"] != null
            ? [...user0["devices"]["listDevices"]]
            : [],
      );

      List<String> list = [];

      if (user.listDevices == []) {
        list = [deviceId];
      } else if (user.listDevices!.length < user.total &&
          !user.listDevices!.contains(deviceId)) {
        list = [...?user.listDevices, deviceId];
      } else {
        list = [...?user.listDevices];
      }

      QueryResult resUpdate = await client.mutate(MutationOptions(
        document: UPDATE_USER,
        variables: {
          "id": res.data!["login"]["user"]["id"],
          "data": {
            "devices": {
              "total": int.parse('${user0["devices"]["total"]}'),
              "listDevices": list,
            },
          }
        },
      ));
      if (resUpdate.data == null) {
        _loading = false;
        notifyListeners();
        return;
      }
      user.listDevices = list;

      if (!user.listDevices!.contains(deviceId)) {
        _loading = false;
        notifyListeners();
        return;
      }

      await UserPreferences().saveUsername(user.username);
      _user = user;
      _loading = false;
      Future.delayed(const Duration(seconds: 2), () {
        notifyListeners();
      });
    } catch (e) {
      _loading = false;
      notifyListeners();
      return;
    }
  }
}
