// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:drortho/routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/iclauncher.png');

    var initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
      handleMessage(context, message);
    });
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      initLocalNotification(context, message);
      showNotification(message);
    });
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
    } else {
      AppSettings.openAppSettings();
    }
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    // print('Device Token');
    // print(token);
    return token!;
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'High Importtance Notifications',
        importance: Importance.max);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: 'Your Description',
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker');

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    } else {
      FirebaseMessaging.onMessageOpenedApp.listen((event) {
        handleMessage(context, event);
      });
    }
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'message') {
      Navigator.pushNamed(context, productDetailsRoute);
    }
  }
}
