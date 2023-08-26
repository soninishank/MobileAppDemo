import 'package:flutter/material.dart';
import 'package:flutter_app/views/home/notification_page.dart';
import 'package:flutter_app/views/home/user_info_page.dart';
import 'package:flutter_app/views/auth/logout_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _notifications.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Set Notification'),
              Tab(text: 'User Details'),
              Tab(text: 'Logout'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SetNotificationScreen(_notifications),
            UserInfoPage(),
            LogoutScreen(),
          ],
        ),
      ),
    );
  }
}
