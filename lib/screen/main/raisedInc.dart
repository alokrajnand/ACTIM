import 'package:actim/environment/theam.dart';
import 'package:actim/screen/main/home.dart';
import 'package:actim/screen/main/incdetail.dart';
import 'package:actim/screen/main/invalidtheinc.dart';
import 'package:actim/services/incident.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'createInc.dart';

class RaisedInc extends StatefulWidget {
  @override
  _RaisedIncState createState() => _RaisedIncState();
}

class _RaisedIncState extends State<RaisedInc> {
  String _messageToUser;
  String _role;
  String _email;
  bool _autovalidate = false;
  bool _loading = false;

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
 
  @override
  void initState() {
    super.initState();
    getRole();
    getUserEmail();

  }
/////////
  Future _navigateToCreateInc(context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CreateIncScreen()));
  }

  ///navigation to home
  void _navigateToHome(context) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }

//// Get role 
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

 ///Create a global key for the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
Widget _validInvalid(incident_id){
  return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[     
                   RaisedButton(
                      color: Colors.greenAccent,
                      child: const Text(
                        'Valid',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: AppColors.PRIMARY_COLOR_DARK),
                      ),
                      onPressed: () {                   
                      var doc_id;
                      var inc_id;
                      var _route_name;
                      var _user_email;
                      var _issue_desc;
 
                        firestore.collection('incidents').where('incident_id', isEqualTo: incident_id).get()
                        .then((data) {
                            doc_id = data.docs[0].id;
                            inc_id = data.docs[0]['incident_id'];
                            _route_name = data.docs[0]['link_for_incident'];
                            _user_email = data.docs[0]['inc_created_by'];
                            _issue_desc = data.docs[0]['inc_desc'];

                        /// update incident 
                         var batch = firestore.batch();
                         batch.update(firestore.collection('incidents').doc(doc_id),{ 
                             "inc_status": 'Open',
                           });


                              /// Send mail and push notifiction
                           batch.set(
                            firestore.collection('notificationmsg').doc(),
                               {
                                  "incident_id" : inc_id,
                                  "link_id" : _route_name,
                                  "inc_raised_by":_user_email,
                                  "msg" : _issue_desc,
                                  "title": 'has been Moved to Open'
                                   }
                            );       
                             /// Commit the batch
                             batch.commit().then((value) {
                                     _navigateToHome(context);
                                 }).catchError((onError){
                                       print(onError);
                                   });
                        }).catchError((onError) {
                            print(onError);
                        });                             
                      }),          
                    SizedBox(width: 10),                   
       //// Invalidate the incident               
                    RaisedButton(
                      color: Colors.redAccent,
                      child: const Text(
                        'Invalid',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: AppColors.PRIMARY_COLOR_DARK),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => InvalidtheIncScreen(incident_id: incident_id),
                          ),
                        );
                      },
                    )


                  ],
                );
}


  @override
  Widget _incCard(incidents) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Card(
          color: AppColors.CARD_BACKGROUND,
          child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => IncDetailScreen(incident: incidents),
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
                        'INC' + incidents['incident_id'],
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppColors.PRIMARY_COLOR_DARK),
                      ),
                      //
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 3.0, bottom: 3.0, left: 9.0, right: 9.0),
                            child: Text(incidents['inc_status']),
                          )),
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  Text('Route ID : ' + incidents['link_for_incident']),
                  //Text('Route Name : ' + 'incident.incRouteName'),
                  Text('Raised By : ' + incidents['inc_created_by']),
                  //Text('Priority : P1'),
                  Text('Raised At : ' +  incidents['inc_created_dt'].toDate().toString()),
                  Divider(color: Colors.grey,),
                  Text(incidents['inc_desc']),
                  Divider(color: Colors.grey,),
                  _role == 'Client' ? Container() : _validInvalid(incidents['incident_id']),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Raised Incident'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                _navigateToHome(context);

              })
        ],
      ),
      body: Container(
        color: AppColors.LIGHT_BACKGROUND,
        //height: MediaQuery.of(context).size.height - 150,
        child: Container(
          child: FutureBuilder(
          future: _role == 'Client' ? IncService.getRaisedIncbyUser(_email) 
          : IncService.getAllRaisedInc(),
          builder:(contaxt , snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(AppColors.PRIMARY_COLOR_DARK),
              ));
            }else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: ( _ , index){   
                var incidents =  snapshot.data[index];        
                return _incCard(incidents);
                //print(incidents['incident_id'])  ; 
          
                });
            }            
    
          }
        ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "btn1",
        backgroundColor: AppColors.PRIMARY_COLOR_LIGHT,
        elevation: 3.0,
        icon: const Icon(Icons.add),
        label: const Text('Create An Incident'),
        onPressed: () {
          _navigateToCreateInc(context);
        },
      ),
    );
  }
}
