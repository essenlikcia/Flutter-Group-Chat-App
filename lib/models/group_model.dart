import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  String groupId;
  String groupName;
  String groupIcon;
  String admin;
  List members;
  String recentMessage;
  String recentMessagesender;
  bool public;

  GroupModel({
    required this.groupId,
    required this.groupName,
    required this.groupIcon,
    required this.admin,
    required this.members,
    required this.recentMessage,
    required this.recentMessagesender,
    required this.public,
  });

  factory GroupModel.fromJSON(DocumentSnapshot snapshot) {
    return GroupModel(
      groupId: snapshot['groupId'],
      groupName: snapshot['groupName'],
      groupIcon: snapshot['groupIcon'],
      admin: snapshot['admin'],
      members: snapshot['members'],
      recentMessage: snapshot['recentMessage'],
      recentMessagesender: snapshot['recentMessagesender'],
      public: snapshot['public'],
    );
  }
}
