
//import 'package:actim/model/link.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class LinkService {
  static Future getAllLink() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot qn = await firestore.collection('links').get();
    return qn.docs;

  }
}