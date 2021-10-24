import 'dart:html';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:firebase_core/firebase_core.dart';
import 'package:nemo/constants.dart';
import 'package:nemo/db.dart';
import 'package:nemo/user.dart';

import 'main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp() : super();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });

      // Add here all cache
      NemoUser.initialize();
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
        print('EROR');
        print(e);
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    // if (_error) {
    //   return SomethingWentWrong();
    // }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return LoadingScreen();
    }

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: _initialized
          ? MyHomePage(title: 'Flutter Demo Home Page')
          : LoadingScreen(),
    );
    ;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({this.title = 'Title'}) : super();

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _loggedIn = DatabaseServices.loggedIn;

  void updateLogin() {
    setState(() {
      _loggedIn = DatabaseServices.loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return _loggedIn ? MainApp() : LogInScreen(updateLogin);
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen() : super();

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
            child: Image.network(
                'https://c.tenor.com/6bT3Uj-98JAAAAAM/finding-nemo-confused.gif')));
  }
}

class LogInScreen extends StatefulWidget {
  final Function updateLogin;
  const LogInScreen(this.updateLogin) : super();

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constants.appBar(context),
      body: _loading
          ? Center(
              child: Image.network(
                  'https://c.tenor.com/6bT3Uj-98JAAAAAM/finding-nemo-confused.gif'))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width / 4,
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.grey[800],
                            padding: EdgeInsets.all(50)),
                        onPressed: () async {
                          setState(() {
                            _loading = true;
                          });
                          bool response =
                              await DatabaseServices.signInWithGoogle();
                          widget.updateLogin();
                          setState(() {
                            _loading = false;
                          });
                        },
                        icon: Icon(
                          Icons.door_front_door_rounded,
                          size: 40,
                        ),
                        label: Text('Start with your Google Account',
                            style: TextStyle(fontSize: 25))),
                  ),
                ],
              ),
            ),
    );
  }
}
