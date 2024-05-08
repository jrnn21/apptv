import 'package:apptv02/models/app_version.dart';
import 'package:apptv02/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  TextStyle style = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18,
    fontFamilyFallback: ['koulen'],
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
  );
  @override
  Widget build(BuildContext context) {
    String? appCurrentVersion = context.watch<AppProvider>().appCurrentVersion;
    AppVersion? appVersion = context.watch<AppProvider>().app;
    double progressValue = context.watch<AppProvider>().progressValue;
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('images/Background.jpg'))),
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/apk.png',
                    width: 120,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Version: ${appVersion?.version}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Material(
                    color: const Color.fromARGB(226, 69, 56, 248),
                    elevation: 2,
                    borderRadius: BorderRadius.circular(5),
                    child: InkWell(
                      focusColor: Colors.white,
                      highlightColor: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        context
                            .read<AppProvider>()
                            .networkInstallApk(app: appVersion!);
                      },
                      child: const SizedBox(
                        width: 100,
                        height: 30,
                        child: Center(
                          child: Text(
                            'Update',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 20,
                    child: progressValue != 0
                        ? Text(
                            'Downloading...(${(progressValue * 100).toStringAsFixed(0)}%)',
                            style: const TextStyle(color: Colors.white),
                          )
                        : const SizedBox(),
                  ),
                  const SizedBox(height: 120)
                ],
              ),
            ),
            Positioned(
                bottom: 5,
                right: 10,
                child: Text(
                  'Current version: $appCurrentVersion',
                  style: const TextStyle(color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}
