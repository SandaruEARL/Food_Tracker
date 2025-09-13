// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(

        // Light Theme
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,

        ),

        // Dark Theme
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: Colors.black,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),

        // Automatically adapts to system theme
        themeMode: ThemeMode.system,

        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
