import 'package:cloud_firestore/cloud_firestore.dart';

class Record {
  String id;
  String uid;
  DateTime createdAt;
  int heartRate;
  double bodyTemperature;
  int spo2Level;
  String coughSoundResult;
  String vitalSignsResult;
  String overallHealth;

  Record({
    required this.id,
    required this.uid,
    required this.createdAt,
    required this.heartRate,
    required this.bodyTemperature,
    required this.spo2Level,
    required this.coughSoundResult,
    required this.vitalSignsResult,
    required this.overallHealth,
  });

  Future<void> addRecord(
      String uid,
      int heartRate,
      double bodyTemperature,
      int spo2Level,
      String coughSoundResult,
      String vitalSignsResult,
      String overallHealth) async {
    CollectionReference records =
        FirebaseFirestore.instance.collection('records');
    await records.add({
      'uid': uid,
      'created_at': DateTime.now(),
      'heart_rate': heartRate,
      'body_temperature': bodyTemperature,
      'spo2_level': spo2Level,
      'cough_sound_result': coughSoundResult,
      'vital_signs_result': vitalSignsResult,
      'overall_health': overallHealth,
    });
  }

  static Future<List<Record>> getRecordsByUser(String uid) async {
    CollectionReference records =
        FirebaseFirestore.instance.collection('records');
    QuerySnapshot snapshot = await records.where('uid', isEqualTo: uid).get();
    List<Record> recordList = [];
    snapshot.docs.forEach((doc) {
      Record record = Record(
        id: doc.id,
        uid: doc['uid'],
        createdAt: doc['created_at'].toDate(),
        heartRate: doc['heart_rate'],
        bodyTemperature: doc['body_temperature'],
        spo2Level: doc['spo2_level'],
        coughSoundResult: doc['cough_sound_result'],
        vitalSignsResult: doc['vital_signs_result'],
        overallHealth: doc['overall_health'],
      );
      recordList.add(record);
    });
    return recordList;
  }

  Future<void> deleteUserRecords(String userId) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('records')
          .where('uid', isEqualTo: userId)
          .get();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

// Future<void> updateRecord() async {
//   CollectionReference records =
//       FirebaseFirestore.instance.collection('records');
//   await records.doc(this.id).update({
//     'heart_rate': this.heartRate,
//     'body_temperature': this.bodyTemperature,
//     'spo2_level': this.spo2Level,
//     'cough_sound_result': this.coughSoundResult,
//     'vital_signs_result': this.vitalSignsResult,
//     'overall_health': this.overallHealth,
//   });
// }

// Future<void> deleteRecord() async {
//   CollectionReference records =
//       FirebaseFirestore.instance.collection('records');
//   await records.doc(this.id).delete();
// }
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class Record {
//   //final String id;
//   final String uid;
//   final DateTime createdAt;
//   final int heartRate;
//   final double bodyTemperature;
//   final int spo2;
//   final String coughSoundResult;
//   final String vitalSignsResult;
//   final String overallHealth;
//
//   Record({
//     //required this.id,
//     required this.uid,
//     required this.createdAt,
//     required this.heartRate,
//     required this.bodyTemperature,
//     required this.spo2,
//     required this.coughSoundResult,
//     required this.vitalSignsResult,
//     required this.overallHealth,
//   });
//
//   factory Record.fromFirestore(DocumentSnapshot doc) {
//     Map data = doc.data() as Map<String, dynamic>;
//     return Record(
//       //id: doc.id,
//       uid: data['uid'] ?? '',
//       createdAt: (data['created_at'] as Timestamp).toDate(),
//       heartRate: data['heart_rate'] ?? 0,
//       bodyTemperature: data['body_temperature'] ?? 0.0,
//       spo2: data['spo2_level'] ?? 0,
//       coughSoundResult: data['cough_sound_result'] ?? '',
//       vitalSignsResult: data['vital_signs_result'] ?? '',
//       overallHealth: data['overall_health'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'created_at': createdAt,
//       'heart_rate': heartRate,
//       'body_temperature': bodyTemperature,
//       'spo2_level': spo2,
//       'cough_sound_result': coughSoundResult,
//       'vital_signs_result': vitalSignsResult,
//       'overall_health': overallHealth,
//     };
//   }
// }
