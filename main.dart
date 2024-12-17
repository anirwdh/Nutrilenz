import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'screens/home_screen.dart';
import 'providers/food_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final speechToText = stt.SpeechToText();
  bool initialized = await speechToText.initialize();
  
  if (!initialized) {
    debugPrint('Failed to initialize speech to text');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FoodProvider()),
        Provider.value(value: speechToText),
      ],
      child: const NutriLenzApp(),
    ),
  );
}

class NutriLenzApp extends StatelessWidget {
  const NutriLenzApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriLenz',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
          accentColor: Colors.orangeAccent,
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

