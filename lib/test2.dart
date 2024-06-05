import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

Future<String?> fcmSetting() async {
  // Firebase core initialization
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // foreground notification channel setup for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'somain_notification',
      'somain_notification',
      description: '소메인 알림입니다.',
      importance: Importance.max
  );

  // foreground notification setup using local notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  // foreground notification handling
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification?.title,
          notification?.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
            ),
          ));

      print('Message also contained a notification: ${message.notification}');
    }
  });

  // firebase token retrieval
  String? firebaseToken = await messaging.getToken();

  print("firebaseToken : ${firebaseToken}");

  return firebaseToken;
}