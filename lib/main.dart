import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_google_maps/flutter_google_maps.dart';
import 'package:map_demo/src/home.dart';


void main() async {
  GoogleMap.init(FlutterConfig.get('GOOGLE_API'));
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Maps Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Color(0xff112b43),
        accentColor: Colors.amber[500]
      ),
      home: HomePage(),
    );
  }
}
