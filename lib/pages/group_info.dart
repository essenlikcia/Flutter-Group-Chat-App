import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/group_model.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/services/database_service.dart';

class GroupInfoPage extends StatefulWidget {
  final GroupModel groupData;
  final String userId;
  const GroupInfoPage(
      {super.key, required this.groupData, required this.userId});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Group Information',
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () async {
                // exit group
                await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          'Exit Group',
                          textAlign: TextAlign.center,
                        ),
                        content: const Text(
                          'Are you sure you want to exit the group?',
                        ),
                        actions: [
                          OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel')),
                          ElevatedButton(
                              onPressed: () async {
                                // remove user from group
                                await DatabaseService(userId: widget.userId)
                                    .exitGroup(widget.groupData.groupId);
                                if (mounted) {
                                  // pop to home page
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red),
                              child: const Text('Exit')),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.cancel))
        ],
      ),
      body: ListView.builder(
        itemCount: widget.groupData.members.length,
        itemBuilder: (context, index) {
          String userId = widget.groupData.members[index];
          return FutureBuilder(
              future: DatabaseService(userId: userId).getUserData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  UserModel userData = snapshot.data!;
                  bool isAdmin = userData.uid == widget.groupData.admin;
                  return ListTile(
                    title: Text(userData.fullName),
                    subtitle: isAdmin
                        ? Text(
                            'Admin of ${widget.groupData.groupName}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(userData.email),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage: NetworkImage(userData.profilePic),
                    ),
                  );
                }
                return const CircularProgressIndicator();
              });
        },
      ),
    );
  }
}
