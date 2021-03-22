import 'package:actim/environment/theam.dart';
import 'package:actim/screen/flash/success.dart';
import 'package:actim/screen/main/home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class CreateIncScreen extends StatefulWidget {
  @override
  _CreateIncScreenState createState() => _CreateIncScreenState();
}

class _CreateIncScreenState extends State<CreateIncScreen> {
  String _route_name;
  String _issue_desc;
  String _messageToUser = '';
  String _user_email;
  String _selectedLocation; // Option 2
  bool _autovalidate = false;
  List _routeLink = List();
  List _clientGroup = List();
  String newValue;
  QuerySnapshot _test;
  String _linksp;
  String _linkep;
  bool _loading = false;
  String errormsg = '';
  String _client_group;
 

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;


  @override
  void initState() {
    super.initState();
    getRoute();
    getClientGroup();
   someMethod();

  }

 someMethod() async {
      final _emailaddress =  _auth.currentUser.email;     
      setState(() {
      _user_email = _emailaddress;
    }); 
  } 

// Get all the Route for the drop down
  Future getRoute() async {
    QuerySnapshot qn = await firestore.collection('links').get();
    setState(() {
      _routeLink = qn.docs;
    });
  }

  // Get all the Route for the drop down
  Future getClientGroup() async {
    QuerySnapshot qn = await firestore.collection('client').get();
    setState(() {
      _clientGroup = qn.docs;
    });
  }

 Future getRouteDetail(link_id) async {
   FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.collection('links').where('link_id', isEqualTo: link_id).get().then((data) {
    print(data.docs[0]['link_start_point']);
    print(data.docs[0]['link_end_point']);
    setState(() {
      _linksp = data.docs[0]['link_start_point'];
      _linkep = data.docs[0]['link_end_point'];
    });
     setState(() {_loading = false;});
    _settingModalBottomSheet(context);
  });   
 }

void setloading(){
setState(() {_loading = true;});
}
  ///Create a global key for the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

 
  ///navigation to home
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }

  ///navigation to home
  void _navigateToSuccess() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => SuccessScreen()));
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState /*You can rename this!*/) {           
                    return Padding(
                        padding:
                            const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Column(children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      'Are you Sure !!',
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.PRIMARY_COLOR_DARK),
                                    ),
                                  ),
                                  Container(
                                      child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Divider(color: Colors.grey),
                                      Text(
                                        'Problem in the Link :',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.PRIMARY_COLOR_DARK),
                                      ),
                                      SizedBox(height: 8),
                                      Text(_route_name),
                                      Container(child: Row(
                                        children: [
                                          Text(_linksp),
                                          Text(' - To - '),
                                          Text(_linkep),
                                        ],
                                      )),
                                      
                                      
                                    ],
                                  )),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Divider(color: Colors.grey),
                                        Text(
                                          'Issue Description :',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.PRIMARY_COLOR_DARK),
                                        ),
                                        SizedBox(height: 8),
                                        Text(_issue_desc),
                                        SizedBox(height: 10),
                                        
                                        Divider(color: Colors.grey),
                                        Text(
                                          'Clent Group To Send Mail:',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.PRIMARY_COLOR_DARK),
                                        ),
                                        SizedBox(height: 8),
                                        Text(_client_group),                                        
                                        
                                        Divider(color: Colors.grey),
                                        
                                        Text(errormsg , style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.red),
                                        ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _messageToUser,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                        ),
                      ]),
                    ),                 
                    _loading == false ?  RaisedButton(
                      color: AppColors.PRIMARY_COLOR_DARK,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, bottom: 15.0, left: 50.0, right: 50.0),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {_loading = true;});
                        
                        DocumentSnapshot variable = await firestore.collection('incidentstats').doc('--stats--').get();
                        var auto_inc = variable['counter'] + 1;
                        var inc_id = 'INC' + auto_inc.toString() ;

                        /// Data load in batches
                        var batch = firestore.batch();
                        /// First batch to create an incident document
                        batch.set(
                        firestore.collection('incidents').doc(),
                        {
                          "incident_id" : inc_id,
                          "link_for_incident" : _route_name,
                          "inc_desc" : _issue_desc,
                          "inc_status" : 'Raised',
                          "inc_client_group" : _client_group,
                          "inc_created_by" : _user_email,
                          "inc_created_dt" : DateTime.now(),
                          "inc_closed_by" : null,
                          "inc_closed_dt" : null,  
                          "inc_close_comment" : null                    
                        }
                      );

                      //// Second batch to load increate the counter
                      batch.update(
                        firestore.collection('incidentstats').doc("--stats--"),
                        {"counter" : FieldValue.increment(1)}
                      );

                      /// Third Batch to create incident 

                      batch.set(
                        firestore.collection('incmessage').doc(),
                        {
                          "incident_id" : inc_id,
                          "inc_raised_by" : _user_email,
                          "inc_client_group" : _client_group,
                          "msg" : _issue_desc,
                          "msg_by" : _user_email,
                          "msg_dt" : DateTime.now(),                   
                        }
                      );

                      //// Send mail to the incident creater -- incident id  - link id  -- link name --  
                      batch.set(
                        firestore.collection('createincmsg').doc(),
                        {
                          "incident_id" : inc_id,
                          "link_id" : _route_name,
                          "inc_raised_by":_user_email,
                          "inc_client_group" : _client_group,
                          "msg" : _issue_desc,
                          "title" : 'Incident has been created',
               
                        }
                      );

                      /// incident support manager

                      ///////
                      batch.commit().then((value) {
                        _navigateToHome();
                      }).catchError((onError){                                          
                        setState(() { errormsg = 'Server Issue please contact admin';});                     
                        setState(() {_loading = false;});
                        print(onError);
                      });
                      }
                  
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
                  ],
                ),
              ),
          );
          });
          
        });
  }

 

  Widget _buildFormRouteDropDown() {
    return DropdownButtonFormField(
      isDense: false,
      isExpanded: true,
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: _route_name,        
          ),
      
      hint: Text('Please Select Route Link ', textAlign: TextAlign.left,), // Not necessary for Option 1
      value: _route_name,
      
      
      validator: (value) => value == null ? 'Please Select Route Link' : null,
      onChanged: (newValue) {
        setState(() {
          _route_name = newValue;   
          //print(newValue);
        });
      },
      items: _routeLink.map((list) {       
        return DropdownMenuItem(                   
            child: Column(
              children: [
                ListTile( 
                  contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0 , bottom: 0.0),
                  title : Text(list['link_id'] + '\n' + list['link_start_point'] + '-' + list['link_end_point']),
                  ),
                Divider(height: 0.5)
              ],
            ),                      
            value: list['link_id'] 
            
            
        );
      }).toList(),
    );
  }


  Widget _buildFormmaillistDropDown() {
    return DropdownButtonFormField(
      isDense: false,
      //isExpanded: true,
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: _client_group,        
          ),
      
      hint: Text('Please Select client Group ', textAlign: TextAlign.left,), // Not necessary for Option 1
      value: _client_group,     
      validator: (value) => value == null ? 'Please Select client Group' : null,
      onChanged: (newValue) {
        setState(() {
          _client_group = newValue;   
          //print(newValue);
        });
      },
      items: _clientGroup.map((list) {       
        return DropdownMenuItem(                   
            child: Text(list['client_group']),                      
            value: list['client_group']             
        );
      }).toList(),
    );
  }


  Widget _buildFormIssueDesc() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Describe your Issue',
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
        _issue_desc = value;
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Incident'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          autovalidate: _autovalidate,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(),
              Container(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 15),
                    _buildFormRouteDropDown(),
                    SizedBox(height: 15),
                    _buildFormIssueDesc(),
                    SizedBox(height: 15),
                    _buildFormmaillistDropDown()
                    // to display server massage
                    //submit button
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FloatingActionButton.extended(
                heroTag: "btn2",
                backgroundColor: Colors.grey,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                label: Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                  child: Text('Cancle'),
                ),
                onPressed: () {
                  _navigateToHome();
                },
              ),
                           
              _loading == false ? FloatingActionButton.extended(
                heroTag: "btn3",
                backgroundColor: Colors.green,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                label: Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                  child: Text('Submit'),
                ),
                onPressed: () async {
                  if (!_formKey.currentState.validate()) {
                    return;
                  }
                  _formKey.currentState.save();
                  setState(() {_loading = true;});
                  getRouteDetail(_route_name);
                  
                },
              ): FloatingActionButton.extended(
                heroTag: "btn3",
                backgroundColor: Colors.green,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                label: Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                  child: SpinKitThreeBounce(color: AppColors.PRIMARY_COLOR_DARK, size: 20.0,),
                ),
                onPressed: () {},
              )
            
            ],
          ),
        ),
      ),
    );
  }
}
