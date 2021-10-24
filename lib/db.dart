import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:nemo/meeting.dart';
import 'package:nemo/user.dart';

class DatabaseServices {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static bool loggedIn = false;

  static String ENDPOINT =
      'https://us-central1-nemo-meetings.cloudfunctions.net/';

  static void init() async {
    if (FirebaseAuth.instance.currentUser != null) {
      DatabaseServices.loggedIn = true;

      NemoUser.loggedIn = NemoUser(
          FirebaseAuth.instance.currentUser.email,
          FirebaseAuth.instance.currentUser.displayName,
          FirebaseAuth.instance.currentUser.photoURL);
      await createUser(NemoUser.loggedIn.email, NemoUser.loggedIn.name,
          NemoUser.loggedIn.photoURL);

      print('User is signed in!');

      // Initialize meetings
      await Meeting.init();
    } else {
      print('User is currently signed out!');
      DatabaseServices.loggedIn = false;
      NemoUser.loggedIn = new NemoUser('', '', '');
    }
  }

  // TODO implement this
  static Future<bool> checkUser(email) async {
    return false;
  }

  static Future<bool> createUser(email, displayName, photoURL) async {
    bool registered = await checkUser(email);
    if (registered) {
      return true;
    } else {
      var url = ENDPOINT +
          'create_user?first_name=' +
          displayName +
          '&email=' +
          email +
          '&photo_url=' +
          photoURL;
      var response = await http.post(Uri.parse(url));
      return true;
    }
  }

  static Future<http.Response> getAllUsers() async {
    var url = ENDPOINT + 'get_all_users';
    Uri final_url = Uri.parse(url);
    var response = await http.post(final_url);
    return response;
  }

  static Future<http.Response> getMeetings() async {
    Uri final_url =
        Uri.parse(ENDPOINT + 'get_meetings?email=' + NemoUser.loggedIn.email);
    var response = await http.post(final_url);
    return response;
  }

  static dynamic signInWithGoogle() async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('https://www.googleapis.com/auth/userinfo.profile');

    // Once signed in, return the UserCredential
    UserCredential credential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);

    await DatabaseServices.init();
    return true;
  }

  static Future<http.Response> updateAgendaItem(Map dict) async {
    var url = ENDPOINT +
        'add_agenda_item?details=' +
        dict['details'] +
        '&stakeholders_emails=' +
        dict['emails'].toString() +
        '&time=' +
        dict['time'].toString() +
        '&topic=' +
        dict['topic'] +
        '&meeting_id=' +
        dict['meeting_id'];
    var response = await http.post(Uri.parse(url));
    return response;
  }
}
