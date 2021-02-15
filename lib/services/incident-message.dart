
//import 'package:actinc/model/link.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class IncMsgService {

  /// get all the Raised incident

    static Future  getMsgByInc(inc_id) async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      return   firestore.collection('incmessage')
      .where('incident_id', isEqualTo: inc_id).
      snapshots();
    }




}