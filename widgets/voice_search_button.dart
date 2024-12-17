// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/food_provider.dart';

class VoiceSearchButton extends StatefulWidget {
  final Function(String) onSearchComplete;

  const VoiceSearchButton({Key? key, required this.onSearchComplete}) : super(key: key);

  @override
  _VoiceSearchButtonState createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton> {
  bool _isListening = false;
  String _lastWords = '';

  void _listen() async {
    final speechToText = Provider.of<stt.SpeechToText>(context, listen: false);

    if (!_isListening) {
      bool available = await speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        speechToText.listen(
          onResult: (result) {
            setState(() {
              _lastWords = result.recognizedWords;
              if (result.finalResult) {
                _isListening = false;
                final formattedQuery = _formatRecognizedText(_lastWords);
                _searchFood(formattedQuery);
                widget.onSearchComplete(formattedQuery);
              }
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      speechToText.stop();
    }
  }

  String _formatRecognizedText(String text) {
    text = text.toLowerCase().trim();

    final Map<String, String> quantityWords = {
      'one': '1', 'two': '2', 'three': '3', 'four': '4', 'five': '5',
      'hundred': '100', 'thousand': '1000'
    };

    quantityWords.forEach((word, number) {
      text = text.replaceAll(word, number);
    });

    final RegExp regex = RegExp(
      r'(\d+(?:\.\d+)?)\s*(grams?|gram?|gm?|ml|milliliters?|pieces?|piece)\s+(?:of\s+)?(.+)',
      caseSensitive: false
    );

    final match = regex.firstMatch(text);
    
    if (match != null) {
      final quantity = match.group(1)!;
      var unit = match.group(2)!.toLowerCase();
      final foodName = match.group(3)!.trim();

      if (unit.contains('gram') || unit.contains('gm')) {
        unit = 'g';
      } else if (unit.contains('ml') || unit.contains('milliliter')) {
        unit = 'ml';
      } else if (unit.contains('piece')) {
        unit = 'piece';
      }

      return '$quantity $unit $foodName';
    }

    return text;
  }

  void _searchFood(String query) {
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    foodProvider.searchFood(query);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _listen,
      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
      label: Text(_isListening ? 'Listening...' : 'Voice Search'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isListening ? Colors.red : const Color(0xFFE94057),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}

