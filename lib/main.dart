import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:partypeopleindividual/individualDashboard/bindings/individual_dashboard_binding.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:partypeopleindividual/individualDashboard/views/individual_dashboard_view.dart';
import 'package:partypeopleindividual/splash_screen/view/splash_screen.dart';
import 'package:sizer/sizer.dart';

import 'individual_profile/views/individual_profile.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  return;
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin pluginInstance =
  FlutterLocalNotificationsPlugin();
  var init = const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'));
  pluginInstance.initialize(init);

  NotificationSettings settings = await messaging.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else {
    print('User declined permission');
  }
  messaging.getToken().then((value) {
    print('Firebase Messaging Token : ${value}');
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print(message.messageType);
    print(message.data);
    AndroidNotificationDetails androidSpec = const AndroidNotificationDetails(
      'ch_id',
      'ch_name',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    NotificationDetails platformSpec =
    NotificationDetails(android: androidSpec);

    await pluginInstance.show(
        0, message.data['title'], message.data['body'], platformSpec);
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return GetMaterialApp(
        initialBinding: IndividualDashboardBinding(),
        debugShowCheckedModeBanner: false,
        title: 'Party People',
        theme: ThemeData.light(useMaterial3: false).copyWith(
          scaffoldBackgroundColor: Colors.red.shade900,
          primaryColor: Colors.red.shade900,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.red.shade900,
            titleTextStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(
              fontFamily: 'Poppins',
            ),
            // Add more text styles as needed
          ),
        ),
        home:SplashScreen(),
        //IndividualDashboardView(),
      );
    });
  }
}
