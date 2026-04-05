import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/location_provider.dart';
import 'providers/user_provider.dart';
import 'screens/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AccidentAlertApp());
}

class AccidentAlertApp extends StatelessWidget {
  const AccidentAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'SOS Emergency Hub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A), // Midnight Blue-Slate
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0F172A),
            brightness: Brightness.dark,
            primary: const Color(0xFF00E5FF), // Electric Cyan
            secondary: const Color(0xFFFF1744), // Neon Crimson
            surface: const Color(0xFF1E293B),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Color(0xFF0F172A),
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            bodyLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            bodyMedium: TextStyle(fontWeight: FontWeight.w600, color: Colors.white70),
          ),
        ),
        home: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (userProvider.userProfile == null) {
              return const ProfileScreen();
            }
            return const HomeScreen();
          },
        ),
      ),
    );
  }
}
