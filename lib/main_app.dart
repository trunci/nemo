import 'package:flutter/material.dart';
import 'package:nemo/constants.dart';
import 'package:nemo/meeting_screen.dart';
import 'package:nemo/user.dart';

import 'meeting.dart';
import 'package:intl/intl.dart';

class MainApp extends StatefulWidget {
  const MainApp() : super();

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.appBar(context),
      body: Center(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.all(30)),
            Text(
                'You have ' +
                    Meeting.meetings.length.toString() +
                    ' meetings, ' +
                    NemoUser.loggedIn.name +
                    '!',
                style: TextStyle(fontSize: 25, color: Colors.black)),
            Padding(padding: EdgeInsets.all(30)),
            Divider(),
            MeetingList()
          ],
        ),
      ),
    );
  }
}

class MeetingList extends StatefulWidget {
  const MeetingList() : super();

  @override
  _MeetingListState createState() => _MeetingListState();
}

class _MeetingListState extends State<MeetingList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 5,
      width: MediaQuery.of(context).size.height / 1.5,
      child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return MeetingListItem(index);
          },
          padding: EdgeInsets.all(8),
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
          itemCount: Meeting.meetings.length),
    );
  }
}

class MeetingListItem extends StatelessWidget {
  final int index;
  MeetingListItem(this.index);

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat("MM-dd, HH:mm");
    return Container(
      height: MediaQuery.of(context).size.height / 6,
      decoration: BoxDecoration(
          border: Border.all(color: Constants.MAIN_COLOR, width: 3),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Meeting.meetings.elementAt(index).name,
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                Divider(),
                Text(Meeting.meetings.elementAt(index).description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                Text(dateFormat.format(Meeting.meetings.elementAt(index).date),
                    style: TextStyle(fontSize: 18, color: Colors.grey[500]))
              ],
            ),
            IconButton(
              constraints: BoxConstraints(maxHeight: 36),
              onPressed: () {
                goToMeeting(context, Meeting.meetings.elementAt(index).id);
              },
              icon: Icon(
                Icons.zoom_in,
                size: 30,
              ),
            ),
            IconButton(
              onPressed: () {
                removeMeeting(Meeting.meetings.elementAt(index).id);
              },
              icon: Icon(Icons.delete_forever, size: 30),
            )
          ],
        ),
      ),
    );
  }
}

void goToMeeting(BuildContext context, String id) {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => MeetingScreen(id)));
}

void removeMeeting(String id) {
  // TODO: Implement this
  return;
}
