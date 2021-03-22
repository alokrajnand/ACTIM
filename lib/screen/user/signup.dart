import 'package:actim/environment/theam.dart';
import 'package:actim/screen/main/home.dart';
import 'package:actim/screen/user/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {



  /// Variable 
  String _errorMsg = '';
  String _successMsg = '';
  String _emailaddress;
  String _password;
  String _passwordConfirmed;
  String _role = '';
  String _deviceToken;
   bool _loading = false;
///
FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

///Create a global key for the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); 


  ////
  @override
  void initState() {
    super.initState(); 
    _getToken();
  }

//// Get device toke when User Register

_getToken(){
_firebaseMessaging.getToken().then((devicetoken) {
  //print(devicetoken);
    setState(() {
       _deviceToken = devicetoken;            
     });
});
}

/// FCM CALL BACKS

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
*/
  
  ///navigation to home
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }

///navigation to Sign In 
  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => SigninScreen()));
  }




////// Signup Future 

Future  signUpUser( String _emailaddress , String _password) async{
    //print(_emailaddress);
    //print(_password);
    try {
      UserCredential result  = await _auth.createUserWithEmailAndPassword(email: _emailaddress, password: _password);
      final UserCredential user = result;      
      print(result.user.email);
        try {
           await result.user.sendEmailVerification();
           print('send mail');
            ///create an entry in the incrole 
                try {
                  firestore.collection('incrole').doc().set({
                            "email" : _emailaddress,
                            "role" : 'User',
                            "device_token" : _deviceToken,
                            "team" : null
                  });
                  /// success message and redirect to login
                setState(() {
                      _successMsg = 'Registration success - please validate your email and login';
                    });
                    Future.delayed(Duration(seconds: 5), () {
                      print('Success User Created');
                            _navigateToSignIn();
                      });   
                }catch (e) {
                    setState(() {
                      _loading = false;
                      _errorMsg = e.message;
                    });
            }

        } catch (e) {
            //print("An error occured while trying to send email verification");
            //print(e.message);
                    setState(() {
                      _loading = false;
                      _errorMsg = e.message;
                    });
        }
    } catch (e) {
        print(e.message);
        setState(() {
          _loading = false;
        _errorMsg = e.message;
      });
    }
}




  /// Email Field Widget 
  Widget _buildEmailField() {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return TextFormField(
      decoration: InputDecoration(labelText: 'Email Address'),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Email Address is required';
        } else if (!regex.hasMatch(value)) {
          return 'Email Is not Valid';
        }
      },
      onSaved: (String value) {
        _emailaddress = value;
      },
    );
  }
  

//// Build password field widget

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Password'),
      keyboardType: TextInputType.text,
      obscureText: true,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Password is required';
        }
      },
      onChanged: (String value) {
        _password = value;
      },
    );
  }


  Widget _buildConfirmPasswordField() {
    return TextFormField(
      decoration: InputDecoration(labelText: ' Retype Password'),
      keyboardType: TextInputType.text,
      obscureText: true,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Retype Password is required';
        }
      },
      onChanged: (String value) {
        _passwordConfirmed = value;
      },
    );
  }

  /// Main Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('ACTOSS')),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(left: 25.0, right: 25.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                SizedBox(height: 50),
                Text(
                  'Welcome To',
                  style: TextStyle(
                      fontSize: 25.0,
                      color: AppColors.PRIMARY_COLOR_DARK,
                      fontWeight: FontWeight.w900),
                ),
                Text(
                  'Actoss Private Lmt.',
                  style: TextStyle(
                      fontSize: 25.0,
                      color: AppColors.PRIMARY_COLOR_DARK,
                      fontWeight: FontWeight.w900),
                ),
                Text(
                  'Incident Management',
                  style: TextStyle(
                      fontSize: 25.0,
                      color: AppColors.PRIMARY_COLOR_DARK,
                      fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 20),
                _buildEmailField(),
                _buildPasswordField(),
               /// _buildConfirmPasswordField(),
                SizedBox(height: 20),
                //_buildEnableAuthField(),
                // to display server massage
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _errorMsg,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    )),
                
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _successMsg,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    )),                
                
                //submit button
                SizedBox(height: 30),                
                _loading == false ? RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 15.0, bottom: 15.0, left: 50.0, right: 50.0),
                    child: Text(
                      'Register',
                      style: TextStyle(
                          fontSize: 15.0,
                          color: AppColors.PRIMARY_COLOR_DARK,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState.validate()) {
                      return;
                    }
                    _formKey.currentState.save();
                    setState(() {_errorMsg = '';});
                    setState(() {_loading = true;});
                    signUpUser(_emailaddress, _password);
                  },
                ): RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, bottom: 15.0, left: 50.0, right: 50.0),
                      child: SpinKitThreeBounce(color: AppColors.PRIMARY_COLOR_DARK, size: 20.0,)
                    ),
                    onPressed: (){},
                  ),
                SizedBox(height: 30),
                Divider(
                  thickness: 2,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    onPressed: () {
                      _navigateToSignIn() ;                     
                    },
                    child: Text(
                      'Login if you have account with us',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.PRIMARY_COLOR_LIGHT,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

