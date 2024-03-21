import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/group_model.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/pages/chat_page.dart';
import 'package:flutter_application_1/pages/profile_page.dart';
import 'package:flutter_application_1/pages/search_page.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/database_service.dart';

class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController groupNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          "My Groups",
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchPage(
                        userId: widget.userId,
                      ),
                    ));
              },
              icon: const Icon(Icons.search))
        ],
      ),
      drawer: Drawer(
        child: FutureBuilder(
          future: DatabaseService(userId: widget.userId).getUserData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserModel userData = snapshot.data!;
              return ListView(
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(userData.fullName),
                    accountEmail: Text(userData.email),
                    decoration:
                        BoxDecoration(color: Theme.of(context).primaryColor),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(userData.profilePic),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(userData: userData),
                          ));
                    },
                    title: const Text("Profile"),
                    leading: const Icon(Icons.person, color: Colors.black),
                  ),
                  ListTile(
                    title: const Text("Log out"),
                    leading: const Icon(Icons.logout, color: Colors.black),
                    onTap: () async {
                      await AuthService().signOut();
                    },
                  ),
                ],
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      // sign out button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text(
                      "Create a group",
                      textAlign: TextAlign.center,
                    ),
                    content: TextField(
                      controller: groupNameController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter group name"),
                    ),
                    actions: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Cancel",
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (groupNameController.text.isNotEmpty) {
                              await DatabaseService(userId: widget.userId)
                                  .createGroup(groupNameController.text);
                              groupNameController.text = "";
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Group created")));
                              }
                            }
                          },
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Theme.of(context).primaryColor),
                          child: const Text("Create")),
                    ],
                  ));
        },
      ),

      body: StreamBuilder(
        stream: DatabaseService(userId: widget.userId).fetchJoinedGroups(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text("You haven't joined any group yet"),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data?.length,
              reverse: true,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                GroupModel groupData = snapshot.data![index];
                bool isAdmin = groupData.admin == widget.userId;

                return ListTile(
                  title: Text(groupData.groupName),
                  subtitle: groupData.recentMessage == ''
                      ? const Text('Start a conversation')
                      : Text(groupData.recentMessage),
                  trailing: isAdmin
                      ? const Icon(Icons.person)
                      : const Icon(Icons.chair),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child:
                        Text(groupData.groupName.substring(0, 1).toUpperCase()),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatPage(
                                  groupData: groupData,
                                  userId: widget.userId,
                                )));
                  },
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
