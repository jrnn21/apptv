import 'package:apptv02/app.dart';
import 'package:apptv02/providers/app_provider.dart';
import 'package:apptv02/providers/expire_provider.dart';
import 'package:apptv02/providers/movies_provider.dart';
import 'package:apptv02/providers/series_provider.dart';
import 'package:apptv02/providers/tv_provider.dart';
import 'package:apptv02/providers/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.bottom]);
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  // HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SeriesProvider()),
        ChangeNotifierProvider(create: (_) => MoviesProvider()),
        ChangeNotifierProvider(create: (_) => TvProvider()),
        ChangeNotifierProvider(create: (_) => ExpireProvider()),
      ],
      child: const App(),
    );
  }
}
