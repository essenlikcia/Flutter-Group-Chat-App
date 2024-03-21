//1-google sign in
//2-sign out
//get user data
//Login Page=> Home Page

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  //handle goole sign in
  Future<bool> signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      try {
        //oauth2 // id token and access token
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        //credential(email, password etc.)
        final OAuthCredential credential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

        // sign in to firebase
        final UserCredential userData =
            await firebaseAuth.signInWithCredential(credential);

        //insert user data into our database if its in their first time
        DatabaseService(userId: userData.user?.uid).insertUserData(
            userData.user?.displayName,
            userData.user?.email,
            userData.user?.photoURL);

        return true;
      } on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.message.toString()),
          backgroundColor: Colors.red,
        ));
        return false;
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ));
        return false;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Sign in process was cancelled"),
        backgroundColor: Colors.red,
      ));
      return false;
    }
  }

  // sign out from google and firebase
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

// determine if user is authenticated or not
  Widget handleAuthState() {
    return StreamBuilder(
      stream: firebaseAuth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomePage(
            userId: firebaseAuth.currentUser!.uid,
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
