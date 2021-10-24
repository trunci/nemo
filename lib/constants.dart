import 'package:flutter/material.dart';

class Constants {
  static Color MAIN_COLOR = Colors.deepOrange;
  static Color SECONDARY_COLOR = Colors.white;

  static String FISH_IMAGE =
      'https://i.pinimg.com/originals/99/e8/72/99e87216f00689ee8058f11caaaa96f0.jpg';

  static Widget appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 1000),
      child: Container(
        color: Constants.MAIN_COLOR,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Text('NEMO', style: TextStyle(color: Colors.black, fontSize: 30)),
              Expanded(
                  child: Row(
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width / 20),
                  InkWell(
                    onTap: () {
                      var html;
                      html.window.open(
                          'https://www.linkedin.com/in/etrunci', "_blank");
                    },
                    child: Text(
                      'Made with ☕☕ by Eduardo Trunci',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
