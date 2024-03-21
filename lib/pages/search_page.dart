import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/group_model.dart';
import 'package:flutter_application_1/pages/chat_page.dart';
import 'package:flutter_application_1/services/database_service.dart';

class SearchPage extends StatefulWidget {
  final String userId;
  const SearchPage({super.key, required this.userId});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Search Group',
            style: TextStyle(
                fontSize: 27, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.all(10),
              child: TextField(
                decoration: const InputDecoration(
                  focusColor: Colors.black,
                  hintText: "Start typing to search...",
                  hintStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                ),
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: StreamBuilder<List<GroupModel>>(
              stream: searchQuery.isEmpty
                  ? DatabaseService().fetchAllGroups()
                  : DatabaseService().fetchSearchedGroups(searchQuery),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      GroupModel groupData = snapshot.data![index];
                      bool alreadyJoined =
                          groupData.members.contains(widget.userId);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          backgroundImage: NetworkImage(groupData.groupName
                              .substring(0, 1)
                              .toUpperCase()),
                        ),
                        title: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ChatPage(
                                groupData: groupData,
                                userId: widget.userId,
                              ),
                            ));
                          },
                          child: Text(groupData.groupName),
                        ),
                        trailing: alreadyJoined
                            ? ElevatedButton(
                                onPressed: () {
                                  /*Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                        groupData: groupData,
                                        userId: widget.userId),
                                  ));*/
                                },
                                child: const Text(
                                  'Joined',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  await DatabaseService(userId: widget.userId)
                                      .joinGroup(groupData.groupId);
                                },
                                child: const Text(
                                  'Join',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ))
          ],
        ));
  }
}
