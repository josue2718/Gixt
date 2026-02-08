import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gixt/Auth/Login.dart';
import 'package:gixt/cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/theme_provider.dart'; // 👈 Nuevo import


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Establece la orientación del dispositivo a solo vertical
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: ".env");
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Gixt',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode, // 👈 Dinámico
          debugShowCheckedModeBanner: false,
          locale: const Locale('es', ''),
          home: const SplashScreen(),
        );
      },
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
  
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  final PreferencesService _preferencesService = PreferencesService();
  
  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _opacity = 1.0);
    }
    await Future.delayed(const Duration(seconds: 4));
    _checkUser();
  }

  Future<void> _checkUser() async {
    final prefs = await SharedPreferences.getInstance();

    String? inicio = prefs.getString('inicio');
    if (inicio == 'true') {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => RootPage()),
      // );
       Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 3),
          opacity: _opacity,
          child: SvgPicture.asset(
            'assets/logo.svg',
            width: 1200,
            height: 1200,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color.fromARGB(255, 255, 255, 255),
          )
        ),
      ),
    );
  }
}