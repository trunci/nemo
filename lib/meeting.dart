import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'package:nemo/user.dart';

import 'db.dart';

class Meeting {
  DateTime date;
  String description;
  int duration;
  String name;
  NemoUser owner;
  String id;
  String preread;
  List<NemoUser> participants;
  List<AgendaItem> agenda;
  Map jsonString;

  static List<Meeting> meetings = new List.empty(growable: true);

  Meeting(
      this.date,
      this.description,
      this.duration,
      this.id,
      this.name,
      this.owner,
      this.preread,
      this.participants,
      this.agenda,
      this.jsonString);

  static Future<void> init() async {
    Response response = await DatabaseServices.getMeetings();
    String body = response.body;
    dynamic meetingList = json.decode(body);
    meetingList.forEach((meeting_id, element) {
      print(element);
      List<AgendaItem> agenda = List.empty(growable: true);
      element['agenda'].forEach((item) {
        List<NemoUser> stakeholders = List.empty(growable: true);
        item['stakeholders'].forEach((sh) {
          stakeholders.add(NemoUser.users.firstWhere((i) => i.email == sh));
        });
        agenda.add(AgendaItem(
            item['details'], stakeholders, item['time'], item['topic']));
      });

      List<NemoUser> participants = List.empty(growable: true);
      element['participants'].forEach((part) {
        participants.add(NemoUser.users.firstWhere((i) => i.email == part));
      });
      Meeting.meetings.insert(
          0,
          Meeting(
              DateTime.fromMillisecondsSinceEpoch(
                  element['details']['date']['_seconds'] * 1000),
              element['details']['description'],
              element['details']['duration'],
              meeting_id,
              element['details']['name'],
              NemoUser.users
                  .firstWhere((el) => el.email == element['details']['owner']),
              element['pre-read'],
              participants,
              agenda,
              element));
    });
    print('Meetings loaded. Total meetings found: ' +
        Meeting.meetings.length.toString());
  }
}

class AgendaItem {
  String topic;
  String details;
  int time;
  List<NemoUser> stakeholders;

  AgendaItem(this.details, this.stakeholders, this.time, this.topic);
}
