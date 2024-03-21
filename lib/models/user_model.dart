import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String email;
  String fullName;
  String profilePic;
  Timestamp joinedAt;

  UserModel(
      {required this.uid,
      required this.email,
      required this.fullName,
      required this.profilePic,
      required this.joinedAt});

  factory UserModel.fromJSON(DocumentSnapshot userSnapshot) {
    return UserModel(
        uid: userSnapshot['uid'],
        email: userSnapshot['email'],
        fullName: userSnapshot['fullName'],
        profilePic: userSnapshot['profulePic'],
        joinedAt: userSnapshot['joinedAt']);
  }
}
