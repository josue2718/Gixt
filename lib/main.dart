import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gixt/Auth/Login.dart';
import 'package:gixt/Componets/colors.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gixt',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', ''),
      theme: ThemeData(useMaterial3: true),
      home: const SplashScreen(),
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
    await Future.delayed(const Duration(seconds: 2));
    _checkUser();
  }

  Future<void> _checkUser() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorfondo,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 3),
          opacity: _opacity,
          child: SvgPicture.asset(
            'assets/logo.svg',
            width: 1200,
            height: 1200,
            color:  const Color.fromARGB(255, 255, 255, 255),
          )
        ),
      ),
    );
  }
}
