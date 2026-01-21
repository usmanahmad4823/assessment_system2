import 'package:assessment_system2/screens/assessment_list.dart';
import 'package:assessment_system2/screens/login_screen.dart';
import 'package:assessment_system2/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  // Check for persistent login
  final prefs = await SharedPreferences.getInstance();
  final int? userId = prefs.getInt('id');
  final bool isLoggedIn = userId != null && userId != 0;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Assessment App',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000), // Pure black for OLED depth
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF), // Apple Blue
          brightness: Brightness.dark,
          surface: const Color(0xFF121212),
          primary: const Color(0xFF007AFF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1C1C1E), // Apple Dark Gray
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -1.0, fontSize: 20),
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: -0.5, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.white60, fontSize: 11, letterSpacing: 0.1),
          bodyLarge: TextStyle(color: Colors.white, fontSize: 13, letterSpacing: -0.2),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: const Color(0xFF007AFF).withOpacity(0.5), width: 1),
          ),
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 11),
          prefixIconColor: Colors.white38,
          suffixIconColor: Colors.white38,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: -0.1),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: Color(0xFF007AFF)),
      ),
      home: isLoggedIn ? const AssessmentList() : const LoginScreen(),
    );
  }
}
