import 'package:actim/environment/theam.dart';
import 'package:actim/screen/main/contact.dart';
import 'package:actim/screen/main/raisedInc.dart';
import 'package:actim/screen/user/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
 final storage = new FlutterSecureStorage();
  String _email;
  String name;
  String _role;
  ////////////////
  ///
FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getRole();
    getUserEmail();
  }



//// get usr email
Future getUserEmail() {
  final _emailaddress =  _auth.currentUser.email;
    setState(() {
      _email = _emailaddress;
    });
}

/// Check the role of the user

Future getRole() async{
  final _emailaddress =  _auth.currentUser.email;
  firestore.collection('incrole').where('email', isEqualTo: _emailaddress).snapshots().listen((data) => 
              setState(() {
                _role = data.docs[0]['role'];
                })
    );
}


  ///
  ///navigation to home
  void _navigateToRaisedIncident() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => RaisedInc()));
  }

    ///navigation to home
  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => SigninScreen()));
  }

    ///navigation to home
  void _navigateToContact() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => ContactScreen()));
  }
  

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white38,
            ),
            accountName: Text(_email.toString()),
            accountEmail: Text(_role.toString()),
          ),

            ListTile(
                  leading: Icon(
                    Icons.broken_image,
                    color: AppColors.PRIMARY_COLOR,
                    size: 25,
                  ),
                  title: Text(
                    'Raised Incident',
                    style: TextStyle(
                        color: AppColors.PRIMARY_COLOR,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward,
                    color: AppColors.PRIMARY_COLOR,
                    size: 25,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToRaisedIncident();
                  },
                ),
          Divider(thickness: 2),
          ListTile(
            leading: Icon(
              Icons.contacts,
              color: AppColors.PRIMARY_COLOR,
              size: 25,
            ),
            title: Text(
              'Contact Us',
              style: TextStyle(
                  color: AppColors.PRIMARY_COLOR,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            trailing: Icon(
              Icons.arrow_forward,
              color: AppColors.PRIMARY_COLOR,
              size: 25,
            ),
            onTap: () async {
              Navigator.of(context).pop();
             _navigateToContact();
            },
          ),

          Divider(thickness: 2),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: AppColors.PRIMARY_COLOR,
              size: 25,
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                  color: AppColors.PRIMARY_COLOR,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            trailing: Icon(
              Icons.arrow_forward,
              color: AppColors.PRIMARY_COLOR,
              size: 25,
            ),
            onTap: () async {
              Navigator.of(context).pop();
             await storage.deleteAll();
             _navigateToLogin();
            },
          ),
        ],
      ),
    );
  }
}
