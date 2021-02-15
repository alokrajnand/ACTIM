import 'package:actim/environment/theam.dart';
import 'package:actim/screen/main/home.dart';
//mport 'package:actim/screen/main/home.dart';
import 'package:actim/screen/user/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class FlashScreen extends StatefulWidget {
  @override
  _FlashScreenState createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {

  String _deviceToken;

/// Initialization 
FirebaseAuth _auth = FirebaseAuth.instance;
final storage = new FlutterSecureStorage();
//FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  ///navigation to home
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }

  /// Navigation to login
  ////////////////
  Future _navigateToLogin(context) async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SigninScreen()));
  }

////
  @override
  void initState() {
    super.initState();
    _chekLocalStorageData();

  }


/// FCM CALL BACKS
/*
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    final dynamic data = message['data'];
  }
  if (message.containsKey('notification')) {
    final dynamic notification = message['notification'];
  }
  // Or do other work.
}

/*
_confFirebase(){
_firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
}
*/ */

//future to check the record in local storage and if true then paas true

  Future<bool> _chekLocalStorageData() async {
    await new Future.delayed(const Duration(seconds : 4));
    String _emailaddress = await storage.read(key: '_emailaddress');
    String _password = await storage.read(key: '_password');
    if (_password == null) {
      _navigateToLogin(context);
    } else {
      loginuser( _emailaddress , _password);
    }
  }

Future loginuser( String _emailaddress , String _password) async{
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: _emailaddress, password: _password);
      //final UserCredential user = result; 
      // store the required value to the local storage
      await storage.write(key: '_emailaddress', value: _emailaddress);
      await storage.write(key: '_password', value: _password);
      // navigate to home
      _navigateToHome();
    }catch (e){
      print(e);
      _navigateToLogin(context);
    }   

}

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BACKGROUND_COLOR,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/images/logo/Actoss-logo-600.png",
              height: 80,
            ),
            SizedBox(height: 10),
            Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: AppColors.FLASH_COLOR,
              child: Text(
                'ACTOSS',
                style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
