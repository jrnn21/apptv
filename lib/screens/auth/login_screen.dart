// ignore_for_file: deprecated_member_use, constant_identifier_names, empty_catches, use_build_context_synchronously, avoid_print

import 'package:apptv02/gql/graphql.dart';
import 'package:apptv02/models/user.dart';
import 'package:apptv02/providers/userProvider.dart';
import 'package:apptv02/utility/shared_preferences.dart';
import 'package:apptv02/widgets/keyboard.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql/client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../gql/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GraphQLClient client = cli();
  FocusNode node = FocusNode();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final focusNode = FocusScopeNode();
  String _password = '';
  String _platformID = 'Unknown';
  String error = '';
  String success = '';
  int select = 12;

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
    node.requestFocus();
    _allowStorage();
    initPlatformState();
    super.initState();
  }

  @override
  void dispose() {
    node.dispose();
    super.dispose();
  }

  void _allowStorage() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      print('Allowed Storage!');
    }
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
          error = 'លេខទូរស័ព្ទរបស់អ្នកមិនទាន់បានចុះឈ្មោះ!';
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

      if (user.listDevices == [] || user.listDevices == null) {
        list = [_platformID];
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
            error = "Can not Register this device!";
          });
          return;
        }
        user.listDevices = list;
      } else if (user.listDevices!.length < user.total &&
          !user.listDevices!.contains(_platformID)) {
        list = [...?user.listDevices, _platformID];
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
            error = "Can not Register this device!";
          });
          return;
        }
        user.listDevices = list;
      }

      if (!user.listDevices!.contains(_platformID)) {
        setState(() {
          error = 'គណនីនេះមិនអាចប្រើប្រាស់ជាមួយឧបករណ៏2បានទេ!';
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
        error = "មិនទាន់ភ្ជាប់ WiFi(Restart App)";
      });
    }
  }

  void onKey(RawKeyEvent event) async {
    int i = 1;
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          i = (select - 1).clamp(1, 12);
          setState(() {
            select = i;
          });
          break;
        case LogicalKeyboardKey.arrowRight:
          i = (select + 1).clamp(1, 12);
          setState(() {
            select = i;
          });
          break;
        case LogicalKeyboardKey.arrowDown:
          i = (select + 3).clamp(1, 12);
          setState(() {
            select = i;
          });
          break;
        case LogicalKeyboardKey.arrowUp:
          i = (select - 3).clamp(1, 12);
          setState(() {
            select = i;
          });
          break;
        case LogicalKeyboardKey.enter ||
              LogicalKeyboardKey.select ||
              LogicalKeyboardKey.numpadEnter:
          if (select == 10) {
            if (_password.isEmpty) break;
            _password = _password.substring(0, _password.length - 1);
            setState(() {});
            break;
          }
          if (select == 11) {
            _password = '${_password}0';
            setState(() {});
            break;
          }
          if (select == 12) {
            _fetch();
            break;
          }
          _password = '$_password$select';
          setState(() {});
          break;
        case LogicalKeyboardKey.digit0 || LogicalKeyboardKey.numpad0:
          setState(() {
            _password = '${_password}0';
          });
          break;
        case LogicalKeyboardKey.digit1 || LogicalKeyboardKey.numpad1:
          setState(() {
            _password = '${_password}1';
          });
          break;
        case LogicalKeyboardKey.digit2 || LogicalKeyboardKey.numpad2:
          setState(() {
            _password = '${_password}2';
          });
          break;
        case LogicalKeyboardKey.digit3 || LogicalKeyboardKey.numpad3:
          setState(() {
            _password = '${_password}3';
          });
          break;
        case LogicalKeyboardKey.digit4 || LogicalKeyboardKey.numpad4:
          setState(() {
            _password = '${_password}4';
          });
          break;
        case LogicalKeyboardKey.digit5 || LogicalKeyboardKey.numpad5:
          setState(() {
            _password = '${_password}5';
          });
          break;
        case LogicalKeyboardKey.digit6 || LogicalKeyboardKey.numpad6:
          setState(() {
            _password = '${_password}6';
          });
          break;
        case LogicalKeyboardKey.digit7 || LogicalKeyboardKey.numpad7:
          setState(() {
            _password = '${_password}7';
          });
          break;
        case LogicalKeyboardKey.digit8 || LogicalKeyboardKey.numpad8:
          setState(() {
            _password = '${_password}8';
          });
          break;
        case LogicalKeyboardKey.digit9 || LogicalKeyboardKey.numpad9:
          setState(() {
            _password = '${_password}9';
          });
          break;
        case LogicalKeyboardKey.delete || LogicalKeyboardKey.backspace:
          if (_password.isEmpty) break;
          _password = _password.substring(0, _password.length - 1);
          setState(() {});
          break;
        default:
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String deviceId = context.watch<UserProvider>().deviceID;
    return RawKeyboardListener(
      focusNode: node,
      autofocus: true,
      onKey: onKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background_image.jpg'),
              fit: BoxFit.fill,
            ),
          ),
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 280,
                  height: 390,
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  child: Column(
                    children: [
                      const Text(
                        'បញ្ចូលលេខទូរស័ព្ទរបស់អ្នក',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'koulen',
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 8.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 200,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(197, 56, 48, 48),
                          borderRadius: BorderRadius.circular(6),
                          border:
                              Border.all(color: Colors.blueAccent, width: 2),
                        ),
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
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 200,
                        child: CustomKeyboard(
                          select: select,
                          onKeyPressed: (String key) {
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
                          },
                        ),
                      ),
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color.fromRGBO(255, 53, 53, 1),
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 8.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
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
