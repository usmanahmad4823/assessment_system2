import 'package:assessment_system2/screens/splash_screen.dart';
import 'package:assessment_system2/services/storage_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Assessment App',
      themeMode: ThemeMode.system, // Automatically follow device theme
      
      // Dark Theme - Professional with high contrast
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.dark,
          surface: const Color(0xFF1C1C1E),
          primary: const Color(0xFF007AFF),
          onPrimary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1C1C1E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.15), width: 1),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -1.0, fontSize: 20),
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: -0.5, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 0.1),
          bodyLarge: TextStyle(color: Colors.white, fontSize: 13, letterSpacing: -0.2),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          prefixIconColor: Colors.white54,
          suffixIconColor: Colors.white54,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: -0.1),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF007AFF),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
        dividerColor: Colors.white.withOpacity(0.1),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: Color(0xFF007AFF)),
      ),
      
      // Light Theme - Professional with high contrast
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.light,
          surface: const Color(0xFFFFFFFF),
          primary: const Color(0xFF007AFF),
          onPrimary: Colors.white,
          onSurface: Colors.black87,
          onBackground: Colors.black87,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          iconTheme: IconThemeData(color: Colors.black87),
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: Colors.black87,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.black.withOpacity(0.12), width: 1),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, letterSpacing: -1.0, fontSize: 20),
          headlineMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, letterSpacing: -0.5, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.black54, fontSize: 11, letterSpacing: 0.1),
          bodyLarge: TextStyle(color: Colors.black87, fontSize: 13, letterSpacing: -0.2),
          titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14),
          titleMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 14),
          labelStyle: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.2), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.2), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          prefixIconColor: Colors.black54,
          suffixIconColor: Colors.black54,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: -0.1),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF007AFF),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
        dividerColor: Colors.black.withOpacity(0.1),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: Color(0xFF007AFF)),
      ),
      
      home: const SplashScreen(),
    );
  }
}
