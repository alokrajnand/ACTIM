import 'package:flutter/material.dart';



class ContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contact Us'),),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 150,
          width: 400,
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('Address'),
                Text('Actoss Technology Private Limited'),
                Text('PNB Building - Doctors Colony'),
                Text('Kankarbagh'),
                Text('Patna'),
                Text('Bihar , India'),
                Text('phone no.: +91 8790423334')
              ],
          ),)
        ),
      )
      
    );
  }
}