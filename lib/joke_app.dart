import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JokesApp extends StatefulWidget {
  const JokesApp({super.key});

  @override
  _JokesAppState createState() => _JokesAppState();
}

class _JokesAppState extends State<JokesApp> {
  List<String> jokes = [];

  Future<void> fetchData() async {
    try {
      final response = await http.get(
          Uri.parse('https://geek-jokes.sameerkumar.website/api?format=json'));

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedResponse = json.decode(response.body);
        String joke = decodedResponse['joke'];

        setState(() {
          jokes.insert(0, joke);
          if (jokes.length > 10) {
            jokes.removeLast();
          }
          _saveJokesToPreferences();
        });
      } else {
        print('API call failed');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _saveJokesToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('jokes_list', jokes);
  }

  Future<void> _loadJokesFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      jokes = prefs.getStringList('jokes_list') ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadJokesFromPreferences();
    fetchData();
    Timer.periodic(Duration(seconds: 10), (Timer timer) {
      fetchData();
    });
    Timer.periodic(Duration(minutes: 10), (Timer timer) {
      if (jokes.length > 0) {
        setState(() {
          jokes.removeLast();
        });
        _saveJokesToPreferences();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F2FD),
      appBar: AppBar(title: Text("Joke App")),
      body: SafeArea(child: ListView.builder(
        itemCount: jokes.length,
        itemBuilder: (context, index) {
          return ListTile(
              title: Card(
                  elevation: 1,
                  // Adjust the elevation to control the shadow depth
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text(jokes[index])]))));
        },
      ),),
    );
  }
}
