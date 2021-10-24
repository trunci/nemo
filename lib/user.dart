import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nemo/constants.dart';
import 'package:nemo/db.dart';

class NemoUser {
  String name;
  String email;
  String photoURL;

  static List<NemoUser> users = List.empty(growable: true);
  static NemoUser loggedIn = NemoUser('', '', '');

  NemoUser(this.email, this.name, this.photoURL);

  static void initialize() async {
    Response response = await DatabaseServices.getAllUsers();
    String body = response.body;
    dynamic users_list = json.decode(body);
    users_list.forEach((element) {
      NemoUser.users.insert(
          0,
          NemoUser(
              element['email'], element['first_name'], element['photo_url']));
    });
    print('Initialized!');
    print(NemoUser.users.toString());
  }

  List<NemoUser> getUsersByEmails(List<String> emails) {
    return List.from(users.where((element) => emails.contains(element.email)));
  }

  Widget getImageAndName() {
    return Container(
      width: 150,
      height: 60,
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                  photoURL == '' ? Constants.FISH_IMAGE : photoURL)),
          Text(name),
        ],
      ),
    );
  }

  Widget getImageAndNameSmall() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 1)
          ]),
      height: 30,
      padding: EdgeInsets.all(2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
              radius: 10,
              backgroundImage: NetworkImage(
                  photoURL == '' ? Constants.FISH_IMAGE : photoURL)),
          Container(
            width: 10,
            height: 10,
          ),
          Text(name),
        ],
      ),
    );
  }
}
