import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ProfilePage extends StatelessWidget {
  final UserModel userData;
  const ProfilePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(userData.profilePic),
              radius: 60,
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              child: Material(
                child: Text(
                  'User Information',
                  style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
            ListTile(
                title: Text(
                  'Email: ${userData.email}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Make the text bold
                  ),
                ),
                leading: const Icon(Icons.email)),
            ListTile(
                title: Text(
                  'Username: ${userData.fullName}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Make the text bold
                  ),
                ),
                leading: const Icon(Icons.person)),
            ListTile(
                title: Text(
                  'Joined At: ${userData.joinedAt.toDate().toString()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Make the text bold
                  ),
                ),
                leading: const Icon(Icons.date_range)),
          ],
        ),
      ),
    );
  }
}
