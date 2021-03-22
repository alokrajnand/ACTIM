import 'package:actim/environment/theam.dart';
import 'package:actim/screen/main/closetheinc.dart';
import 'package:actim/screen/main/home.dart';
import 'package:actim/services/incident-message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class IncDetailScreen extends StatefulWidget {
  final incident;
  IncDetailScreen({this.incident});

  @override
  _IncDetailScreenState createState() => _IncDetailScreenState();
}

class _IncDetailScreenState extends State<IncDetailScreen> {
  
  final storage = new FlutterSecureStorage();
  String prevUser;
  String role;
  String _user_email;
  String _messageToUser;
  String _textMessage;
  String user_name;

  static var _controller = TextEditingController();

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
ScrollController _scrollController = new ScrollController();


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

  @override
  void initState() {
    super.initState();
      getUser();
      
  }

   getUser() async {
      final _emailaddress =  _auth.currentUser.email;
      ///print(user.email);  
      setState(() {
      _user_email = _emailaddress;
    }); 
      } 

  ///navigation to home
  void _navigateToHome(context) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }



  Widget _chatBubble(message) {
    if (message['msg_by'] == _user_email) {
      return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topRight,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80,
              ),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message['msg'],
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Divider(color: Colors.grey),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        message['msg_by'],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(message['msg_dt'].toDate().toString().trim().substring(0,message['msg_dt'].toDate().toString().trim().length-7),
                         style: TextStyle(
                          color: Colors.white,
                        ),),
                    ],
                  ),
                ],
              ),
            ),
          ),

              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ],
                )

        ],
      );
    } else {
      return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80,
              ),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message['msg'],
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Divider(color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        message['msg_by'],
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '9:45',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

              Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                )
 
        ],
      );
    }
  }

  _sendMessageArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 70,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.insert_comment),
            iconSize: 25,
            color: Theme.of(context).primaryColor,
            onPressed: () {},
          ),
          Expanded(
            child: TextFormField(
                controller: _controller,
                keyboardType: TextInputType.text,
                decoration: InputDecoration.collapsed(
                  hintText: 'Send a message..',
                ),
                textCapitalization: TextCapitalization.sentences,                
                onChanged: (String value) {
                  setState(() {
                    _textMessage = value;
                  });
                },
                onTap: (){
               
            
                },
                ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              _scrollController.animateTo(                
                _scrollController.position.maxScrollExtent+500,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 1),
                );

              if (_textMessage != null){
                 _controller.clear(); 

              /// insert incident document in the database
              /// create a batch to load data -- message entry -- notification 
                
              var batch = firestore.batch();

              batch.set(
                firestore.collection('incmessage').doc(), 
                      {
                        "incident_id" : widget.incident['incident_id'],
                        "msg" : _textMessage,
                        "msg_by" : _user_email,
                        "msg_dt" : DateTime.now(),
                      });

                                                                          /// Send mail and push notifiction
                      batch.set(
                        firestore.collection('notificationmsg').doc(),
                          {
                            "incident_id" : widget.incident['incident_id'],
                            "link_id" : widget.incident['link_for_incident'],
                            "inc_raised_by":_user_email,
                            "msg" : _textMessage,
                            "title": 'has been Updated'
                                                      
                          }
                          );       

                          /// Commit the batch
                          batch.commit().then((value) {
                           setState(() { _textMessage = null;});
                                _scrollController.animateTo(                
                                _scrollController.position.maxScrollExtent+500,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 1),
                                );
                             }).catchError((onError){
                          print(onError);
                        });
              }             
            },

          ),

        ],
      ),
    );
  }

  ///////////
  ///

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.incident['incident_id'],
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            Text(
              widget.incident['link_for_incident'],
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(
              Icons.blur_circular,
              color: getColor(widget.incident['inc_status']),
            ),
          ),
          widget.incident['inc_status'] == "Open"
              ? IconButton(
                  icon: Icon(Icons.report_off),
                  color: Colors.redAccent,
                  onPressed: () {
                          Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CloseForIncScreen(incident: widget.incident['incident_id']),
                          ),
                        );
                  })
              : Container(),
        ],
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: firestore.collection('incmessage').where('incident_id', isEqualTo: widget.incident['incident_id']).orderBy('msg_dt', descending: false).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return Container(                    
                    child: ListView(
                      controller: _scrollController,
                      ///reverse: true,
                      //shrinkWrap: true,
                      children: snapshot.data.docs.map((document)=> _chatBubble(document)).toList()
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          widget.incident['inc_status'] == 'Open'
              ? _sendMessageArea()
              : Container(),
        ],
      ),
    );
  }
}
