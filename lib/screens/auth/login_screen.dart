// ignore_for_file: deprecated_member_use, constant_identifier_names, empty_catches, use_build_context_synchronously

import 'package:apptv02/gql/graphql.dart';
import 'package:apptv02/models/user.dart';
import 'package:apptv02/providers/userProvider.dart';
import 'package:apptv02/utility/shared_preferences.dart';
import 'package:apptv02/widgets/keyboard.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:provider/provider.dart';

import '../../gql/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GraphQLClient client = cli();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final focusNode = FocusScopeNode();
  String _password = '';
  String _platformID = 'Unknown';
  bool selected = false;
  bool selected1 = false;
  String error = '';
  String success = '';

  TextStyle styleGT(Color color) {
    return TextStyle(
        color: color,
        fontFamilyFallback: const ['radley', 'koulen'],
        fontSize: 14,
        shadows: const [
          Shadow(offset: Offset(-1, -1), color: Colors.black),
          Shadow(offset: Offset(1, -1), color: Colors.black),
          Shadow(offset: Offset(1, 1), color: Colors.black),
          Shadow(offset: Offset(-1, 1), color: Colors.black),
        ]);
  }

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initPlatformState() async {
    try {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      setState(() {
        _platformID = androidInfo.id;
      });
    } catch (e) {}
  }

  Future<void> _fetch() async {
    client.resetStore();
    setState(() {
      error = '';
      success = '';
    });
    try {
      if (_platformID == 'Unknown') {
        setState(() {
          error = 'We can not get your device ID';
        });
        return;
      }
      QueryResult res = await client.mutate(MutationOptions(
        document: LOGIN,
        variables: {
          "input": {
            "identifier": _password.trim(),
            "password": _password.trim(),
          }
        },
      ));

      if (res.data == null) {
        setState(() {
          error = 'This account not register yet!';
        });
        return;
      }
      QueryResult resUser = await client.query(QueryOptions(
          document: USER, variables: {"id": res.data!["login"]["user"]["id"]}));
      if (resUser.data == null) {
        setState(() {
          error = "We cant find this User";
        });
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
        list = [_platformID];
      } else if (user.listDevices!.length < user.total &&
          !user.listDevices!.contains(_platformID)) {
        list = [...?user.listDevices, _platformID];
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
        setState(() {
          error = "Can not add this device";
        });
        return;
      }
      user.listDevices = list;

      if (!user.listDevices!.contains(_platformID)) {
        setState(() {
          error = 'This account can not log in with this device';
        });
        return;
      }
      await UserPreferences().saveUsername(user.username);
      context.read<UserProvider>().setUser(user);
      setState(() {
        success = "Login Success";
      });
    } catch (e) {
      setState(() {
        error = "error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String deviceId = context.watch<UserProvider>().deviceID;
    return WillPopScope(
      onWillPop: () async {
        if (selected) {
          setState(() {
            selected = false;
            selected1 = false;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/preview_main_ui_background_image.png'),
              fit: BoxFit.fill,
            ),
          ),
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 120),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.only(top: selected ? 0 : 50),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                            child: error.isNotEmpty
                                ? Text(
                                    error,
                                    style: styleGT(Colors.red),
                                  )
                                : success.isNotEmpty
                                    ? Text(success,
                                        style: styleGT(Colors.green))
                                    : const SizedBox(),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              autofocus: true,
                              focusColor: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                setState(() {
                                  selected = !selected;
                                });
                                Future.delayed(const Duration(milliseconds: 10),
                                    () {
                                  setState(() {
                                    selected1 = !selected1;
                                  });
                                });
                              },
                              child: Container(
                                width: 250,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                margin: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(197, 56, 48, 48),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.blueAccent, width: 3)),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Icons.phone_android,
                                      color: Colors.blueAccent,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                        child: Text(
                                      _password,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.w900),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Visibility(
                      visible: selected,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.translationValues(
                            0, selected1 ? 0 : 100, 0),
                        width: 250,
                        child: CustomKeyboard(onKeyPressed: (String key) {
                          // Handle key presses
                          if (key == 'backspace') {
                            if (_password.isEmpty) return;
                            _password =
                                _password.substring(0, _password.length - 1);
                            setState(() {});
                            return;
                          }
                          if (key == 'login') {
                            _fetch();
                            return;
                          }
                          _password = _password + key;
                          setState(() {});
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 5,
                right: 10,
                child: Text(
                  'Device ID: $deviceId',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    shadows: [
                      Shadow(offset: Offset(-1, -1), color: Colors.black),
                      Shadow(offset: Offset(1, -1), color: Colors.black),
                      Shadow(offset: Offset(1, 1), color: Colors.black),
                      Shadow(offset: Offset(-1, 1), color: Colors.black),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
