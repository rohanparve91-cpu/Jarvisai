import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const JarvisApp());
}

class JarvisApp extends StatelessWidget {
  const JarvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jarvis AI',
      theme: ThemeData.dark(),
      home: const JarvisHomePage(),
    );
  }
}

class JarvisHomePage extends StatefulWidget {
  const JarvisHomePage({super.key});

  @override
  State<JarvisHomePage> createState() => _JarvisHomePageState();
}

class _JarvisHomePageState extends State<JarvisHomePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Say "Hello Jarvis"...';
  FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _processCommand(_text);
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _processCommand(String command) async {
    String lower = command.toLowerCase();

    if (lower.contains('weather')) {
      var data = await _getWeather();
      _speak('The current temperature is ${data['temp']} degrees Celsius in ${data['city']}.');
    } else if (lower.contains('time')) {
      String time = TimeOfDay.now().format(context);
      _speak('The time is $time');
    } else {
      _speak('Sorry, I did not understand the command.');
    }
  }

  Future<Map<String, dynamic>> _getWeather() async {
    var url = Uri.parse("https://api.open-meteo.com/v1/forecast?latitude=28.61&longitude=77.20&current_weather=true");
    var res = await http.get(url);
    var data = jsonDecode(res.body);
    return {
      "temp": data["current_weather"]["temperature"],
      "city": "Delhi"
    };
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage("en-IN");
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jarvis AI')),
      body: Center(
        child: Text(
          _text,
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
    );
  }
}
