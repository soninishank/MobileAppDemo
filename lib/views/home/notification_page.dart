import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/views/home/user_entry_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class SetNotificationScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin notifications;

  SetNotificationScreen(this.notifications);

  @override
  _SetNotificationScreenState createState() => _SetNotificationScreenState();
}

class _SetNotificationScreenState extends State<SetNotificationScreen> {
  int _selectedInterval = 1; // Default interval in minutes
  String? initialMessage;
  late SharedPreferences _prefs;
  static const String _intervalKey = 'notification_interval';
  bool _shouldChangeInterval = false;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Initialize the timezone package
    _initSharedPreferences();
    var androiInit =
        AndroidInitializationSettings('@mipmap/ic_launcher'); //for logo
    var iosInit = IOSInitializationSettings();
    var initSetting = InitializationSettings(android: androiInit, iOS: iosInit);

    var androidDetails = AndroidNotificationDetails('1', 'channelName');
    var iosDetails = IOSNotificationDetails();
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    flutterLocalNotificationsPlugin = widget.notifications;

    channel = AndroidNotificationChannel(
      'insights',
      'Notification Channel',
      importance: Importance.max,
      playSound: true,
    );

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.instance.getToken().then((token) {
      print("Device Token: $token");
    });
    FirebaseMessaging.instance.getInitialMessage().then(
          (value) => setState(
            () {
              initialMessage = value?.data.toString();
            },
          ),
        );
    flutterLocalNotificationsPlugin.initialize(initSetting,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String? payload) async {
    // Navigate to the desired page
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          TextEntryDialogScreen(), // Replace with the actual page you want to navigate to
    ));
  }

  Future<void> _scheduleNotifications() async {
    int intervalInMinutes = _selectedInterval;
    int intervalInSeconds = intervalInMinutes * 60;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      additionalFlags: Int32List.fromList(<int>[4]),
    );

    final IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails();

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    bool intervalChanged = false; // Track whether the interval was changed
    if (_selectedInterval != _prefs.getInt(_intervalKey)) {
      // Show a confirmation dialog before changing the interval
      bool? confirmChange = await _showIntervalChangeConfirmationDialog();
      if (confirmChange != null) {
        if (confirmChange) {
          _showConfirmationDialog(); // Show the confirmation dialog if interval changed
          await _saveInterval(
              _selectedInterval); // Save interval when scheduled and interval changed
        }
      }
    }
    await widget.notifications.zonedSchedule(
      0,
      'Time to enter data!',
      'Tap to enter data for this interval',
      _nextInstanceOfInterval(intervalInSeconds),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'my_payload',
    );
    if (intervalChanged) {
      await _saveInterval(
          _selectedInterval); // Save interval when scheduled and interval changed
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Notification Scheduled'),
          content: Text(
              'A notification has been scheduled for every $_selectedInterval minutes.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  tz.TZDateTime _nextInstanceOfInterval(int seconds) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = now.add(Duration(seconds: seconds));
    return scheduledDate;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_shouldChangeInterval) // Show the dropdown when _shouldChangeInterval is true
            DropdownButton<int>(
              value: _selectedInterval,
              onChanged: (value) {
                setState(() {
                  _selectedInterval = value!;
                });
              },
              items: [
                DropdownMenuItem<int>(
                  value: 1,
                  child: Text('1 minute'),
                ),
                DropdownMenuItem<int>(
                  value: 5,
                  child: Text('5 minutes'),
                ),
                DropdownMenuItem<int>(
                  value: 10,
                  child: Text('10 minutes'),
                ),
              ],
            ),
          SizedBox(height: 20),
          Text('Current Notification Interval: $_selectedInterval minute'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _shouldChangeInterval =
                    !_shouldChangeInterval; // Toggle _shouldChangeInterval
              });
              if (!_shouldChangeInterval) {
                await _scheduleNotifications();
                await _saveInterval(
                    _selectedInterval); // Save interval when scheduled
              }
            },
            child: Text(_shouldChangeInterval
                ? 'Cancel'
                : 'Change Interval'), // Change button text accordingly
          ),
        ],
      ),
    );
  }

  // Initialize SharedPreferences
  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save interval to SharedPreferences
  Future<void> _saveInterval(int interval) async {
    await _prefs.setInt(_intervalKey, interval);
  }

  Future<bool?> _showIntervalChangeConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Interval Change'),
          content: Text('Do you want to change the notification interval?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Return false if user cancels
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Return true if user confirms
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
