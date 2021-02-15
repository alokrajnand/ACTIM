
//import 'package:actim/model/link.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class RoleService {

static getdata(_emailaddress)  {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection('incrole').where('email', isEqualTo: _emailaddress).snapshots().listen((event) {
      return "test";
    });
    
  }


}