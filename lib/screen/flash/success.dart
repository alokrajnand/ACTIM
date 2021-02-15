import 'package:actim/screen/main/home.dart';
import 'package:flutter/material.dart';

class SuccessScreen extends StatefulWidget {
  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}


class _SuccessScreenState extends State<SuccessScreen> {


    ///navigation to home
  void _navigateToHome() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check_circle,
                size: 200,
                color: Colors.lightGreen,
              ),
              Text('Incident Created')
            ],
          ),
          ),
      ),
    );
  }
}