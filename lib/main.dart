import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: NotificationPage());
  }
}

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  FirebaseMessaging fm = FirebaseMessaging();
  @override
  void initState() {
    super.initState();
    fm.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    print("Hallo");
    fm.getToken().then((value) => print("token : $value"));
    fm.configure(
      onMessage: (message) async {
        fm.requestNotificationPermissions(const IosNotificationSettings(
            sound: true, badge: true, alert: true));

        print(message);
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    content: ListTile(
                  title: Text(message['notification']['title']),
                  subtitle: Text(message['notification']['body']),
                )));
      },
      onLaunch: (message) async {
        print(message);
      },
      onResume: (message) async {
        print(message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification Test"),
      ),
      // body: 
      // Center(
      //   child: RaisedButton(onPressed: () async {
      //     await sendAndRetrieveMessage();
      //     // Navigator.pushReplacement(
      //     //     context, MaterialPageRoute(builder: (context) => ForeignPage()));
      //   }
      //   ),
      // ),
    );
  }

  Future<Map<String, dynamic>> sendAndRetrieveMessage() async {
    String serverToken =
        'AAAAiP6ZkzA:APA91bGQcnDddU9Trp1r5D5g6H5jeAjZN-UmU9RH6mXZ5kXob1FrJO8uIQkDcwIntNh7Mx2clxWxZl1sRtPu0Pz-rSkVbF8z41o2F4pQiTBJs-BQbiFJmPvDDyaTdTycg59qWvOkxVEG';
    FirebaseMessaging firebaseMessaging = FirebaseMessaging();

    await firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: false));
    await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'this is a body',
            'title': 'this is a title'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': await firebaseMessaging.getToken(),
        }));
      final Completer<Map<String, dynamic>> completer= Completer<Map<String,dynamic>>();

      // firebaseMessaging.configure(
      //   onMessage: (message) async {
      //     completer.complete(message);
      //     print(message);
      //   },
      // );
      // var android = AndroidNotificationDetails('channel_id', 'CHANNLE NAME', 'channelDescription');
      // var iOS = IOSNotificationDetails();
      // var platform = NotificationDetails(android, iOS);
      // await FlutterLocalNotificationsPlugin.private(
      //   0, "Hallo", "Hai", platform
      // );
      return completer.future;
  }

}
