import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as Quill;
import 'package:nemo/db.dart';
import 'package:nemo/meeting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'constants.dart';

class MeetingScreen extends StatefulWidget {
  String id;
  MeetingScreen(this.id) : super();

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  @override
  Widget build(BuildContext context) {
    Meeting currentMeeting =
        Meeting.meetings.firstWhere((element) => element.id == widget.id);
    DateFormat dateFormat = DateFormat("MM-dd, HH:mm");

    return Scaffold(
      appBar: Constants.appBar(context),
      body: Center(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.all(10)),
            Text(currentMeeting.name,
                style: TextStyle(fontSize: 30, color: Colors.black)),
            Padding(padding: EdgeInsets.all(20)),
            Text(currentMeeting.description,
                style: TextStyle(fontSize: 25, color: Colors.grey[800])),
            Text(dateFormat.format(currentMeeting.date),
                style: TextStyle(fontSize: 25, color: Colors.grey[800])),
            Divider(),
            AgendaWidget(currentMeeting.agenda),
            TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        AddAgendaItem(currentMeeting.id));
              },
              child: Text('Add a new Agenda Item',
                  style: TextStyle(fontSize: 18, color: Colors.grey[800])),
            ),
            Padding(padding: EdgeInsets.all(6)),
            Divider(),
            Padding(padding: EdgeInsets.all(6)),
            Text('Meeting Pre-read',
                style: TextStyle(fontSize: 20, color: Colors.grey[800])),
            Padding(padding: EdgeInsets.all(6)),
            RichEditor(currentMeeting),
          ],
        ),
      ),
    );
  }
}

class FirebaseServices {
  FirebaseFirestore _fireStoreDataBase = FirebaseFirestore.instance;

  //upload a data
  editPreread(String newString, String meeting_id) async {
    // String newString2 = newString.replaceAll("\n", r'\n');

    await _fireStoreDataBase
        .collection('meetings')
        .doc(meeting_id)
        .update({'pre-read': newString});
    await Meeting.init();
  }
}

class RichEditor extends StatefulWidget {
  Meeting currentMeeting;
  RichEditor(this.currentMeeting);

  @override
  _RichEditorState createState() => _RichEditorState();
}

class _RichEditorState extends State<RichEditor> {
  @override
  Widget build(BuildContext context) {
    final FirebaseServices firebaseServices = FirebaseServices();
    String a = widget.currentMeeting.preread;

    Quill.QuillController _controller = widget.currentMeeting.preread == ''
        ? Quill.QuillController.basic()
        : Quill.QuillController(
            document: Quill.Document.fromJson(
                jsonDecode(widget.currentMeeting.preread)),
            selection: TextSelection.collapsed(offset: 0));

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 2,
          height: 300,
          decoration:
              BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Quill.QuillToolbar.basic(controller: _controller),
                Expanded(
                  child: Container(
                    child: Quill.QuillEditor.basic(
                      controller: _controller,
                      readOnly: false, // true for view only mode
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () async {
            await FirebaseServices().editPreread(
                jsonEncode(_controller.document.toDelta().toJson()),
                widget.currentMeeting.id);
          },
        ),
        Padding(padding: EdgeInsets.all(6)),
        ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MeetingMode(widget.currentMeeting)));
            },
            label: Text('Enter Meeting Mode',
                style: TextStyle(fontSize: 18, color: Colors.grey[800])),
            icon: Icon(Icons.calendar_view_day))
      ],
    );
  }
}

class AgendaWidget extends StatefulWidget {
  List<AgendaItem> agenda;
  // ignore: use_key_in_widget_constructors
  AgendaWidget(this.agenda) : super();

  @override
  _AgendaWidgetState createState() => _AgendaWidgetState();
}

class _AgendaWidgetState extends State<AgendaWidget> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width / 4,
        maxWidth: MediaQuery.of(context).size.width / 3,
        maxHeight: MediaQuery.of(context).size.height / 4,
      ),
      child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return AgendaListItem(widget.agenda.elementAt(index));
          },
          padding: EdgeInsets.all(8),
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
          itemCount: widget.agenda.length),
    );
  }
}

class AgendaListItem extends StatelessWidget {
  AgendaItem item;
  AgendaListItem(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 4,
      height: MediaQuery.of(context).size.height / 8,
      decoration: BoxDecoration(
          border: Border.all(color: Constants.MAIN_COLOR, width: 1),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 3)
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(item.topic,
                      style: TextStyle(fontSize: 18, color: Colors.grey[800])),
                  Container(
                      width: MediaQuery.of(context).size.width / 5,
                      child: Text(item.details,
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey[600]))),
                ],
              ),
              Text(item.time.toString() + ' min',
                  style: TextStyle(fontSize: 25, color: Colors.grey[800]))
            ],
          ),
          Row(
              children: item.stakeholders.map((element) {
            return element.getImageAndNameSmall();
          }).toList())
        ],
      ),
    );
  }
}

class AddAgendaItem extends StatefulWidget {
  String meeting_id;
  AddAgendaItem(this.meeting_id);

  @override
  State<AddAgendaItem> createState() => _AddAgendaItemState();
}

class _AddAgendaItemState extends State<AddAgendaItem> {
  String topic;
  String details;
  String stakeholders;
  int time;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a new Agenda Item'),
      content: Form(
          child: Container(
        width: 700,
        child: Center(
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Topic",
                ),
                onChanged: (val) {
                  setState(() {
                    topic = val;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Details",
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onChanged: (val) {
                  setState(() {
                    details = val;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Stakeholders",
                ),
                onChanged: (val) {
                  setState(() {
                    stakeholders = val;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Duration (minutes)",
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() {
                    time = int.parse(val);
                  });
                },
              ),
            ],
          ),
        ),
      )),
      actions: [
        TextButton(
            onPressed: () {
              DatabaseServices.updateAgendaItem({
                'details': details,
                'emails': stakeholders,
                'time': time,
                'meeting_id': widget.meeting_id,
                'topic': topic
              });
            },
            // TODO: Update once you add
            child: Text('Add')),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class MeetingMode extends StatefulWidget {
  Meeting currentMeeting;
  MeetingMode(this.currentMeeting) : super();

  @override
  _MeetingModeState createState() => _MeetingModeState();
}

class _MeetingModeState extends State<MeetingMode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.appBar(context),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(
            children: [
              Text('Agenda'),
              Padding(
                padding: EdgeInsets.all(10),
              ),
              AgendaWidget(widget.currentMeeting.agenda),
              Padding(
                padding: EdgeInsets.all(10),
              ),
              Text('Time left for the meeting:',
                  style: TextStyle(fontSize: 18, color: Colors.grey[800])),
              Padding(
                padding: EdgeInsets.all(10),
              ),
              Clock(widget.currentMeeting)
            ],
          ),
          Padding(padding: EdgeInsets.all(10)),
          Column(
            children: [
              Text('Main Learnings and Takeaways',
                  style: TextStyle(fontSize: 18, color: Colors.grey[800])),
              Padding(padding: EdgeInsets.all(10)),
              MainTextEditor(widget.currentMeeting),
            ],
          ),
        ]),
      ),
    );
  }
}

class MainText {
  FirebaseFirestore _fireStoreDataBase = FirebaseFirestore.instance;

  //upload a data
  editPreread(String newString, String meeting_id) async {
    // String newString2 = newString.replaceAll("\n", r'\n');

    await _fireStoreDataBase
        .collection('meetings')
        .doc(meeting_id)
        .update({'takeaways': newString});
    await Meeting.init();
  }
}

class MainTextEditor extends StatefulWidget {
  Meeting currentMeeting;
  MainTextEditor(this.currentMeeting);

  @override
  _MainTextEditorState createState() => _MainTextEditorState();
}

class _MainTextEditorState extends State<MainTextEditor> {
  @override
  Widget build(BuildContext context) {
    final FirebaseServices firebaseServices = FirebaseServices();

    Quill.QuillController _controller =
        (!widget.currentMeeting.jsonString.containsKey('takeaways') ||
                widget.currentMeeting.jsonString['takeaways'] == '')
            ? Quill.QuillController.basic()
            : Quill.QuillController(
                document: Quill.Document.fromJson(
                    jsonDecode(widget.currentMeeting.jsonString['takeaways'])),
                selection: TextSelection.collapsed(offset: 0));

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 2,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration:
              BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Quill.QuillToolbar.basic(controller: _controller),
                Expanded(
                  child: Container(
                    child: Quill.QuillEditor.basic(
                      controller: _controller,
                      readOnly: false, // true for view only mode
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () async {
            await MainText().editPreread(
                jsonEncode(_controller.document.toDelta().toJson()),
                widget.currentMeeting.id);
          },
        ),
      ],
    );
  }
}

class Clock extends StatefulWidget {
  Meeting currentMeeting;
  Clock(this.currentMeeting);

  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  String _timeString;
  Color _color;

  void _getTime() {
    final int formattedDateTime =
        widget.currentMeeting.date.difference(DateTime.now()).inMinutes;
    setState(() {
      if (formattedDateTime > 0) {
        _timeString = widget.currentMeeting.duration.toString();
        _color = Colors.lightGreen;
      } else if (formattedDateTime < 0 &&
          -formattedDateTime > widget.currentMeeting.duration / 2) {
        _timeString =
            (widget.currentMeeting.duration + formattedDateTime).toString();
        _color = Colors.orange;
      } else {
        _timeString =
            (widget.currentMeeting.duration + formattedDateTime).toString();
        _color = Colors.red;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
          color: _color,
          border: Border.all(
            color: _color,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(10)),
      child: Center(
          child: Text(
        _timeString,
        style: TextStyle(color: Colors.white, fontSize: 18),
      )),
    );
  }
}
