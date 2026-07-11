import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/theme_service.dart';
import 'services/alarm_clock_service.dart';
import 'services/firebase_service.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/verify_email_screen.dart';

import 'screens/userdashboard/home_screen.dart';
import 'screens/userdashboard/profile_screen.dart';
import 'screens/userdashboard/settings_screen.dart';

// ── Correct file names from your actual folder structure ──────────────────
import 'screens/Motherhealthtracker/mother_health_screen.dart';
import 'screens/Babyhealthtracker/baby_health_screen.dart';
import 'screens/RecordsAndGraphs/records_and_graphs_screen.dart';
import 'screens/reminders/reminders_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase — must be first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. FirestoreService — enables offline persistence explicitly and
  //    starts the connectivity listener that drives the OfflineBanner.
  //    Must come after Firebase.initializeApp(), before runApp().
  await FirestoreService.init();

  // 3. AlarmClockService — initializes the alarm engine
  await AlarmClockService().init();

  // 4. Portrait lock
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 5. Status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MotherAndBabySmartCare(),
    ),
  );
}

class MotherAndBabySmartCare extends StatelessWidget {
  const MotherAndBabySmartCare({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    final lightTheme = ThemeData.light(useMaterial3: true).copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(
        themeNotifier.themeData.textTheme,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE91E63),
        brightness: Brightness.light,
      ),
    );

    final darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mother And Baby SmartCare',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/verify_email': (context) => const VerifyEmailScreen(),
        '/dashboard': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),

        // Use the exact class names exported by each file
        '/mother_tracker': (context) => const MotherHealthScreen(),
        '/baby_tracker': (context) => const BabyHealthScreen(),
        '/records': (context) => const RecordsGraphsScreen(),
        '/reminders': (context) => const RemindersScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Admin Dashboard',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
