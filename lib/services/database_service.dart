import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/group_model.dart';
import 'package:flutter_application_1/models/user_model.dart';

class DatabaseService {
  final String? userId;
  DatabaseService({this.userId});

  // collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  // insert new user data to firestore
  Future<void> insertUserData(
      String? fullName, String? email, String? profilePic) async {
    // check if user data already exists
    DocumentSnapshot userData = await userCollection.doc(userId).get();

    if (!userData.exists) {
      // insert only if its a new user
      await userCollection.doc(userId).set({
        'uid': userId,
        'fullName': fullName,
        'email': email,
        'profilePic': profilePic,
        'joinedAt': DateTime.now(),
      });
    }
  }

  Future<UserModel> getUserData({String? userDocId}) async {
    DocumentSnapshot result =
        await userCollection.doc(userDocId ?? userId).get();
    if (result.exists) {
      UserModel userModel = UserModel(
        uid: result['uid'],
        fullName: result['fullName'],
        email: result['email'],
        profilePic: result['profilePic'],
        joinedAt: result['joinedAt'],
      );
      return userModel;
    } else {
      throw Exception('User data not found');
    }
  }

  //create new group
  Future createGroup(String groupName) async {
    DocumentReference documentReference = await groupCollection.add({
      'groupId': '',
      'groupName': groupName,
      'groupIcon': '',
      'members': [userId],
      'admin': userId, // admin is the one who created the group
      'recentMessage': '',
      'recentMessagesender': '',
      'public': true,
      'searchKeywords': getSearchKeywords(groupName),
    });

    // update groupId with document id

    //await groupCollection.doc(documentReference.id)
    //.update({'groupId': documentReference.id});

    await documentReference.update({'groupId': documentReference.id});
  }

  // search groups letter by letter
  List<String> getSearchKeywords(String groupName) {
    List<String> SearchKeywordsList = [groupName.toLowerCase()];
    List<String> words = groupName.split(" ");

    String temp = "";
    for (var word in words) {
      for (int i = 0; i < word.length; i++) {
        temp += word[i];
        SearchKeywordsList.add(temp.toLowerCase());
        if (i == word.length - 1) {
          temp = "";
        }
      }
    }
    return SearchKeywordsList;
  }

  /*
  Firebase Community
  [Firebase, Community]
  Firebase =>
  F
  Fi
  Fir
  Fire
  Fireb
  Fireba
  Firebas
  Firebase
  */

  // fetch all groups Joined by user
  Stream<List<GroupModel>> fetchJoinedGroups() async* {
    yield* groupCollection
        .where('members', arrayContains: userId)
        .snapshots()
        .map((groups) =>
            groups.docs.map((group) => GroupModel.fromJSON(group)).toList());
  }

  // Join Group
  Future<void> joinGroup(String groupId) async {
    await groupCollection.doc(groupId).update({
      'members': FieldValue.arrayUnion([userId])
    });
  }

  // Exit Group
  Future<void> exitGroup(String groupId) async {
    await groupCollection.doc(groupId).update({
      'members': FieldValue.arrayRemove([userId])
    });
  }

  // Fetch Searched Groups
  Stream<List<GroupModel>> fetchSearchedGroups(String searchQuery) async* {
    yield* groupCollection
        .where('searchKeywords', arrayContains: searchQuery.toLowerCase())
        .snapshots()
        .map((groups) =>
            groups.docs.map((group) => GroupModel.fromJSON(group)).toList());
  }

  // Fetch all groups
  Stream<List<GroupModel>> fetchAllGroups() async* {
    yield* groupCollection.snapshots().map((groups) =>
        groups.docs.map((group) => GroupModel.fromJSON(group)).toList());
  }

  // Send message
  Future<void> sendMessage(
      String message, String groupId, String userId) async {
    UserModel userData = await getUserData(userDocId: userId);
    await groupCollection.doc(groupId).collection('messages').add(
      {
        'message': message,
        'senderId': userId,
        'senderName': userData.fullName,
        'sentAt': DateTime.now(),
      },
    );
    await groupCollection.doc(groupId).update({
      'recentMessage': message,
      'recentMessageSender': userData.fullName,
    });
  }

  Stream fetchMessages(String groupId) async* {
    yield* groupCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .snapshots();
  }

  // Fetch Messages
  /*Stream fetchMessages(String groupId) async* {
    yield* groupCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }*/
}
