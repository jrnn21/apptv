import 'package:apptv02/models/app_version.dart';
import 'package:apptv02/providers/app_provider.dart';
import 'package:apptv02/providers/expire_provider.dart';
import 'package:apptv02/screens/auth/login_screen.dart';
import 'package:apptv02/models/user.dart';
import 'package:apptv02/providers/userProvider.dart';
import 'package:apptv02/screens/download_screen.dart';
import 'package:apptv02/screens/expire_screen.dart';
import 'package:apptv02/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  User user = User(
    id: '',
    username: '',
    begin: '0',
    jwt: '',
    days: 0,
    total: 0,
    listDevices: [],
  );
  bool inInitTime = false;

  @override
  void initState() {
    _fetch();
    super.initState();
  }

  _fetch() async {
    context.read<AppProvider>().init();
    context.read<UserProvider>().fetchLogin();
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<UserProvider>().user;
    TimeExpire timeExpire = context.watch<ExpireProvider>().timer;
    AppVersion? app = context.watch<AppProvider>().app;
    String? appCurrentVersion = context.watch<AppProvider>().appCurrentVersion;
    if (user.id.isNotEmpty && !inInitTime) {
      context
          .read<ExpireProvider>()
          .initExpireTime(time: user.begin, totalDay: user.days);
      setState(() {
        inInitTime = true;
      });
    }
    bool loading = context.watch<UserProvider>().loading;
    return MaterialApp(
      title: 'PLC TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false),
      home: loading
          ? const LoadingPage()
          : app != null &&
                  appCurrentVersion != null &&
                  appCurrentVersion != app.version
              ? const DownloadScreen()
              : user.id == ''
                  ? const LoginScreen()
                  : timeExpire.expireTime == timeExpire.correntTime
                      ? const LoadingPage()
                      : timeExpire.expireTime < timeExpire.correntTime
                          ? const ExpireScreen()
                          : const HomeScreen(),
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SpinKitWaveSpinner(
          color: Colors.white,
          trackColor: Colors.blueAccent,
          waveColor: Colors.blueAccent,
          size: 80.0,
        ),
      ),
    );
  }
}
