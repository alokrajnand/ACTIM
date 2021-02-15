
//import 'package:actinc/model/link.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class IncService {


// FOR THE ADMIN VIEW ///

/// Get all the incident   
     static Future getAllInc() async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot qn = await firestore.collection('incidents').orderBy('inc_created_dt', descending: true).get();
      return qn.docs;
    }

  /// get all the Raised incident

    static Future  getAllRaisedInc() async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot qn = await firestore.collection('incidents')
      .where('inc_status', isEqualTo: 'Raised').
      orderBy('inc_created_dt', descending: true)
      .get();
      return qn.docs;
    }

  /// get all the Closed incident

  static Future getAllClosedInc() async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot qn = await firestore.collection('incidents')
      .where('inc_status', isEqualTo: 'Closed')
      .get();
      return qn.docs;
    }
  /// get all the Open incident

  static Future getAllOpenInc() async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot qn = await firestore.collection('incidents')
      .where('inc_status', isEqualTo: 'Open')
      .get();
      return qn.docs;
    }

  /// get all the invalid incident

  static Future getAllInvalidInc() async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot qn = await firestore.collection('incidents')
      .where('inc_status', isEqualTo: 'Invalid')
      .get();
      return qn.docs;
    }


///// Service for the client view ///

  // Get all the incident filter by user
static Future getAllIncbyUser(email) async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot qn = await firestore.collection('incidents')
      .where('inc_created_by', isEqualTo: email)
      .orderBy('inc_created_dt', descending: true)
      .get();
      return qn.docs;
    }
  // get all the open incident filter by user 

  // Get all the incident filter by user
static Future getOpenIncbyUser(email) async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot qn = await firestore.collection('incidents')
      .where('inc_created_by', isEqualTo: email)
      .where('inc_status', isEqualTo: 'Open')
      .get();
      return qn.docs;
    }

  // get all the riased incident filter by user
  static Future getRaisedIncbyUser(email) async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot qn = await firestore.collection('incidents')
      .where('inc_created_by', isEqualTo: email)
      .where('inc_status', isEqualTo: 'Raised')
      .orderBy('inc_created_dt', descending: true)
      .get();
      return qn.docs;
    }
  // get all the closed incident filter by 
  static Future getClosedIncbyUser(email) async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot qn = await firestore.collection('incidents')
      .where('inc_created_by', isEqualTo: email)
      .where('inc_status', isEqualTo: 'Closed')
      .get();
      return qn.docs;
    }

// Get all invalid incident for user
  // get all the closed incident filter by 
  static Future getInvalidIncbyUser(email) async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot qn = await firestore.collection('incidents')
      .where('inc_created_by', isEqualTo: email)
      .where('inc_status', isEqualTo: 'Invalid')
      .get();
      return qn.docs;
    }

}
