import 'package:actim/screen/flash/flash.dart';
import 'package:actim/screen/user/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'environment/theam.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Actoss Incident Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.PRIMARY_COLOR,
        brightness: Brightness.light,
        accentColor: Colors.cyan[600],
        //fontFamily: 'Qanelas',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FlashScreen(),
    );
  }
}
