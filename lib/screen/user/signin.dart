import 'package:actim/environment/theam.dart';
import 'package:actim/screen/main/home.dart';
import 'package:actim/screen/user/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class SigninScreen extends StatefulWidget {
  @override
  _SigninScreenState createState() => _SigninScreenState();
}
class _SigninScreenState extends State<SigninScreen> {
  /// Variable 
  String _errorMsg = '';
  String _emailaddress;
  String _password;
  String _role ;
  String _deviceToken;
  bool _loading = false;

///Initialization Part
FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
final storage = new FlutterSecureStorage();


///Create a global key for the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); 


    ////
  @override
  void initState() {
    super.initState(); 
    _getToken();
  }
  

  _getToken(){
_firebaseMessaging.getToken().then(( devicetoken) {
    setState(() {
       _deviceToken = devicetoken;            
     });
});
}
  ///navigation to home
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }


  ///navigation to home
  void _navigateToSignUp() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => SignupScreen()));
  }

/// Future for sign In 

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

Future loginuser( String _emailaddress , String _password) async{
    //print(_emailaddress);
    //print(_password);
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: _emailaddress, password: _password);
      //final UserCredential user = result.user.emailVerified;      
      if(result.user.emailVerified == false){
        try {
                await result.user.sendEmailVerification();
        } catch (e) {
                var  message = 'An error occured while trying to send email verification';
                setState(() {
                   _loading = false;
                  _errorMsg = message;
                });
        }
        var  message = 'Email is not varified an email has been sent please verify !!';
          setState(() {
              _loading = false;
              _errorMsg = message;
          });

      } else {    
        print(_emailaddress); 
                   
          firestore.collection('incrole').where('email', isEqualTo: _emailaddress).get().then((data) {
                _role = data.docs[0]['role'];               
                  if (_role == 'User' ){
                        var  message = 'Your access previllages is not define. Please contact admin';
                        setState(() {
                          _loading = false;
                          _errorMsg = message;
                        });
                  }else {
                    /// update the device token
                    // Get the uid from the email 
                    var doc_id;
                    firestore.collection('incrole').where('email', isEqualTo: _emailaddress).get().then(
                      (data) {
                          doc_id = data.docs[0].id;
                          firestore.collection('incrole').doc(doc_id).update({"device_token" : _deviceToken,}).then((value){                     
                            // store the required value to the local storage // navigate to home
                              storage.write(key: '_emailaddress', value: _emailaddress);
                              storage.write(key: '_password', value: _password);
                              _navigateToHome();
                          }).catchError((onError){
                            print(onError);
                          });

                      }).catchError((onError){
                        print(onError);
                      });
                  }
         
          }).catchError((onError){
            print(onError);
          });
      }

    } catch (e) {
        print(e.message);
        setState(() {
         _loading = false;
        _errorMsg = e.message;
        print('ok');
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



  /// Main Widget
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
          child: Scaffold(
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
                    'Login To',
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
                  //submit button
                  SizedBox(height: 30),

                  _loading == false ? RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, bottom: 15.0, left: 50.0, right: 50.0),
                      child: Text(
                        'Submit',
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
                      print(_loading);
                      FocusScope.of(context).requestFocus(FocusNode());
                              setState(() {_errorMsg = '';});
                              setState(() {_loading = true;});
                              loginuser(_emailaddress, _password);
                      
                    },
                  )
                  : RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, bottom: 15.0, left: 50.0, right: 50.0),
                      child: SpinKitThreeBounce(color: AppColors.PRIMARY_COLOR_DARK, size: 20.0,)
                    ),
                    onPressed: (){},
                  )
                  ,
                  SizedBox(height: 30),
                  FlatButton(
                    child: Text(
                      'Forget Password ?',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.PRIMARY_COLOR_LIGHT,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () {},
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      onPressed: () {
                        _navigateToSignUp();
                       
                      },
                      child: Text(
                        'Register if you don\'t have account',
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
      ),
    );
  }
}

