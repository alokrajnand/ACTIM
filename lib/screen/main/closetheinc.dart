import 'package:actim/environment/theam.dart';
import 'package:actim/screen/main/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CloseForIncScreen extends StatefulWidget {
  final  incident;
  CloseForIncScreen({this.incident});



  @override
  _CloseForIncScreenState createState() => _CloseForIncScreenState();
}

class _CloseForIncScreenState extends State<CloseForIncScreen> {

 String inc_close_comment;
 bool _success_ind = true;
 String _email;
 bool _autovalidate = false;
 DateTime currenttime = DateTime.now();
 bool _loading = false;
 String _errorMsg = '';

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
    ///Create a global key for the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getUserEmail();

  }


Future getUserEmail() async{
  final _emailaddress =  _auth.currentUser.email;
    setState(() {
      _email = _emailaddress;
    });
}


    ///navigation to home
  void _navigateToHome(context) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }


/////////
  Widget _buildCloseComment() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Closing Comment',
        fillColor: Colors.white,

        contentPadding:
            new EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
        border: new OutlineInputBorder(
          borderRadius: new BorderRadius.circular(5.0),
          borderSide: new BorderSide(),
        ),
        //fillColor: Colors.green
      ),
      keyboardType: TextInputType.text,
      validator: (String value) {
        if (value.isEmpty) {
          return 'This Field is required';
        }
      },
      onSaved: (String value) {
        inc_close_comment = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Close The Incident'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          child: Form(
          key: _formKey,
          //autovalidate: _autovalidate,
                  child: Column(
          children: <Widget>[
            SizedBox(height: 30),
            Text('Your are closing the incident - ' + widget.incident),
            SizedBox(height: 30),
            _buildCloseComment(),           
            Text(_errorMsg, style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),           
            SizedBox(height: 30), 
            _loading == false ?  RaisedButton(
                        color: AppColors.PRIMARY_COLOR_DARK,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, bottom: 15.0, left: 120.0, right: 120.0),
                          child:                       
                          Text(
                            'Submit',
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w900),
                          )                 
                        ),
                        onPressed: () async {
                          setState(() {_errorMsg = '';});
                            if (!_formKey.currentState.validate()) {
                                return;
                              }
                           setState(() {_loading = true;});
                          _formKey.currentState.save();
                                                      var doc_id;
                                                      var inc_id;
                                                      var _route_name;
                                                      var _user_email;
                                                      var _issue_desc;
                                                                                           
                                                    firestore.collection('incidents').where('incident_id', isEqualTo: widget.incident)
                                                      .get().then((data) { 
                                                        doc_id = data.docs[0].id;
                                                        inc_id = data.docs[0]['incident_id'];
                                                        _route_name = data.docs[0]['link_for_incident'];
                                                        _user_email = data.docs[0]['inc_created_by'];
                                                        _issue_desc = data.docs[0]['inc_desc'];


                                                          var batch = firestore.batch();
                                                          batch.update(firestore.collection('incidents').doc(doc_id),{ 
                                                            "inc_status": 'Closed',
                                                            "inc_close_comment": inc_close_comment,
                                                            "inc_closed_by": _email,
                                                            "inc_closed_dt": currenttime,
                                                 
                                                            });

                                                            /// Send mail and push notifiction
                                                                batch.set(
                                                                firestore.collection('notificationmsg').doc(),
                                                                {
                                                                  "incident_id" : inc_id,
                                                                  "link_id" : _route_name,
                                                                  "inc_raised_by":_user_email,
                                                                  "msg" : _issue_desc,
                                                                  "title": 'has been Moved to Closed'
                                                      
                                                                }
                                                              );       
                                                                batch.commit().then((value) {                                                                                                                
                                                                      _navigateToHome(context);
                                                                
                                                                }).catchError((onError){
                                                                  print(onError);
                                                                  setState(() {_errorMsg = 'Server Issue Contact Admin';});
                                                                  setState(() {_loading = false;});
                                                                });
 
                                                      }).catchError((error){
                                                        print(error);
                                                        setState(() {_errorMsg = 'Server Issue Contact Admin';});
                                                        setState(() {_loading = false;});
                                                      });                     


                        }): RaisedButton(
                        color: AppColors.PRIMARY_COLOR_DARK,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, bottom: 15.0, left: 50.0, right: 50.0),
                      child: SpinKitThreeBounce(color: Colors.white, size: 20.0,)
                    ),
                    onPressed: (){},
                  )

           ]
           ),
        ),    
        ),
      ),     
    );
  }
}