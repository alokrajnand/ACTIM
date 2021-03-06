
import 'package:actim/environment/theam.dart';
import 'package:actim/screen/main/incdetail.dart';
import 'package:actim/services/incident.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class IncOpenScreen extends StatefulWidget {
  @override
  _IncOpenScreenState createState() => _IncOpenScreenState();
}

class _IncOpenScreenState extends State<IncOpenScreen> {
 final storage = new FlutterSecureStorage();
  //String role;
  String _email;
  String _role;

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;


  @override
  void initState() {
    super.initState();
    getRole();
    getUserEmail();
  }

/// Check the role of the user
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
//// get usr email

  Color getColor(name) {
    if (name == 'Open') {
      return Colors.red;
    } else if (name == 'Closed') {
      return Colors.green;
    } else if (name == 'Invalid') {
      return Colors.yellow;
    } else if (name == 'Raised') {
      return Colors.grey;
    }
  }



Widget _incCard(incident) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Card(
            color: AppColors.CARD_BACKGROUND,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => IncDetailScreen(incident: incident),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          incident['incident_id'],
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.PRIMARY_COLOR_DARK),
                        ),
                        //                        //
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: getColor(incident['inc_status']),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 3.0, bottom: 3.0, left: 9.0, right: 9.0),
                              child: Text(incident['inc_status']),
                            )),
                          ],
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    Text('Route Name : ' + incident['link_for_incident']),
                    Text('Raised By : ' + incident['inc_created_by']),
                    Text('Priority : P1'),
                    Divider(
                      color: Colors.grey,
                    ),
                        incident['inc_status'] == 'Closed'
                        ? Text('Open At : ' +  incident['inc_created_dt'].toDate().toString() +  '\n' 'Closed At : ' + incident['inc_closed_dt'].toDate().toString())
                        : Text('Open At : ' + incident['inc_created_dt'].toDate().toString() ),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: AppColors.LIGHT_BACKGROUND,
        child:  FutureBuilder(
          future: _role == 'Client' ? IncService.getOpenIncbyUser(_email) : IncService.getAllOpenInc(),
          builder:(contaxt , snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(AppColors.PRIMARY_COLOR_DARK),
              ));
            }else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (contaxt , index){   
                var incidents =  snapshot.data[index];        
                return _incCard(incidents);         
                });
            }            
          }
        ),
      ),
    );
  }
}
