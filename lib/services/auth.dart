import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/providers/note_provider.dart';
import 'package:notesapp/screens/home_screen.dart';
import 'package:notesapp/screens/login.dart';
import 'package:notesapp/utilities.dart';
import 'package:provider/provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getUid() {
    return _auth.currentUser!.uid;
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showAlertDialog(
            context: context,
            title: 'No user found for that email.',
            withButton: false);
      } else if (e.code == 'wrong-password') {
        showAlertDialog(
            context: context,
            title: 'Wrong password provided for that user.',
            withButton: false);
      }
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showAlertDialog(
            context: context,
            title: 'The password provided is too weak.',
            withButton: false);
      } else if (e.code == 'email-already-in-use') {
        showAlertDialog(
            context: context,
            title: 'The account already exists for that email.',
            withButton: false);
      }
    } catch (e) {
      showAlertDialog(context: context, title: e.toString(), withButton: false);
    }
  }

  // sign out
  Future signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Provider.of<NoteProvider>(context, listen: false).deleteState();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    } catch (error) {
      showAlertDialog(
          context: context, title: error.toString(), withButton: false);
    }
  }
}
