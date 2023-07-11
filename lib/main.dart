import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyDId0NVMhFFrP9HLELwfDFmgPxnpI7e2-M",
        authDomain: "speechapp-a378f.firebaseapp.com",
        projectId: "speechapp-a378f",
        storageBucket: "speechapp-a378f.appspot.com",
        messagingSenderId: "637028296510",
        appId: "1:637028296510:web:1cf398df9503e86497ae6f",
        measurementId: "G-79NTES2Y46"
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text to Speech Demo',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text to Speech Demo'),
      ),
      body: ReadingTile(),
    );
  }
}

class ReadingTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShortStoryOptionsPage(),
          ),
        );
      },
      child: Container(
        color: Color.fromRGBO(181, 101, 29, 0.5),
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Reading',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class ShortStoryOptionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Short Story Options'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchShortStories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching short stories'),
            );
          }
          final List<Map<String, dynamic>> shortStories = snapshot.data ?? [];
          return ListView.builder(
            itemCount: shortStories.length,
            itemBuilder: (context, index) {
              final shortStory = shortStories[index];
              return ListTile(
                title: Text(shortStory['Title'] ?? ''),
                subtitle: Text(shortStory['author'] ?? ''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticlePage(shortStory: shortStory),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchShortStories() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('short story')
        .get();

    final List<QueryDocumentSnapshot> documents = snapshot.docs;
    final List<Map<String, dynamic>> shortStories = [];
    for (final doc in documents) {
      shortStories.add(doc.data() as Map<String, dynamic>);
    }

    return shortStories;
  }
}

class ArticlePage extends StatefulWidget {
  final Map<String, dynamic>? shortStory;

  ArticlePage({required this.shortStory});

  @override
  ArticlePageState createState() => ArticlePageState();
}

class ArticlePageState extends State<ArticlePage> {
  FlutterTts flutterTts = FlutterTts();
  String? articleText;
  bool isPlaying = false;
  double selectedSpeechRate = 1.0;
  String selectedVoiceGender = "male";
  List<double> speedOptions = [0.5, 1.0, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    articleText = widget.shortStory?['Description'];
    initTts();
  }

  // Future<void> updateTtsSettings() async {
  //   await flutterTts.setSpeechRate(selectedSpeed);
  //   await flutterTts.setVoice({
  //     'name': selectedVoiceGender == "male"
  //         ? "en-IN-x-ism#male_2-local"
  //         : "en-IN-x-ism#female_1-local",
  //   });
  // }

  // Future<void> initTts() async {
  //   //await (flutterTts.getDefaultVoice);
  //   await flutterTts.setLanguage("en-US");
  //   await updateTtsSettings();
  //   await flutterTts.setSpeechRate(selectedSpeed);
  //   await flutterTts.setVoice({
  //     'name': selectedVoiceGender == "male"
  //         ? "en-IN-x-ism#male_2-local"
  //         : "en-IN-x-ism#female_1-local",
  //   });
  //   flutterTts.setStartHandler(() {
  //     setState(() {
  //       isPlaying = true;
  //     });
  //   });
  //   flutterTts.setCompletionHandler(() {
  //     setState(() {
  //       isPlaying = false;
  //     });
  //   });
  // }
  Future<void> initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setVoice({
      'name': selectedVoiceGender == "male"
          ? "en-IN-x-ism#male_2-local"
          : "en-IN-x-ism#female_1-local",
    });
    flutterTts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });
    await flutterTts.setSpeechRate(selectedSpeechRate);
  }

  // Future<void> speakArticle() async {
  //   if (articleText != null && articleText!.isNotEmpty) {
  //     if (!isPlaying) {
  //       await flutterTts.stop(); // Stop any ongoing reading
  //       await flutterTts.speak(articleText!);
  //       setState(() {
  //         isPlaying = true;
  //       });
  //     } else {
  //       await flutterTts.stop();
  //       setState(() {
  //         isPlaying = false;
  //       });
  //     }
  //   }
  // }
  Future<void> speakArticle() async {
    if (articleText != null && articleText!.isNotEmpty) {
      if (!isPlaying) {
        await flutterTts.stop(); // Stop any ongoing reading
        await flutterTts.setSpeechRate(selectedSpeechRate);
        await flutterTts.setVoice({
          'name': selectedVoiceGender == "male"
              ? "en-IN-x-ism#male_2-local"
              : "en-IN-x-ism#female_1-local",
        });
        await flutterTts.speak(articleText!);
        setState(() {
          isPlaying = true;
        });
      } else {
        await flutterTts.stop();
        setState(() {
          isPlaying = false;
        });
      }
    }
  }

  void toggleReading() {
    speakArticle();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.shortStory?['Title'] ?? '';
    final String author = widget.shortStory?['author'] ?? '';
    final String description = widget.shortStory?['Description'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Article'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Author: ${author ?? ''}',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              'Title: ${title ?? ''}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  description ?? '',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: toggleReading,
                child: Text(isPlaying ? 'Stop' : 'Read Aloud'),
              ),
            ),
            SizedBox(height: 16.0),
            Text('Speed:'),
            // DropdownButton<double>(
            //   value: selectedSpeed,
            //   onChanged: (newValue) {
            //     setState(() {
            //       selectedSpeed = newValue!;
            //       //updateTtsSettings();
            //       flutterTts.setSpeechRate(selectedSpeed);
            //     });
            //   },
            //   items: speedOptions.map((speed) {
            //     return DropdownMenuItem<double>(
            //       value: speed,
            //       child: Text(speed.toStringAsFixed(1) + 'x'),
            //     );
            //   }).toList(),
            // ),
            Slider(
              value: selectedSpeechRate,
              min: 0.5,
              max: 2.0,
              onChanged: (newValue) {
                setState(() {
                  selectedSpeechRate = newValue;
                  flutterTts.setSpeechRate(selectedSpeechRate);
                });
              },
            ),
            Text('Voice Gender:'),
            DropdownButton<String>(
              value: selectedVoiceGender,
              onChanged: (newValue) {
                setState(() {
                  selectedVoiceGender = newValue!;
                  //updateTtsSettings();
                  initTts();
                });
              },
              items: [
                DropdownMenuItem<String>(
                  value: "male",
                  child: Text('Male'),
                ),
                DropdownMenuItem<String>(
                  value: "female",
                  child: Text('Female'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// apiKey: "AIzaSyDId0NVMhFFrP9HLELwfDFmgPxnpI7e2-M",
// authDomain: "speechapp-a378f.firebaseapp.com",
// projectId: "speechapp-a378f",
// storageBucket: "speechapp-a378f.appspot.com",
// messagingSenderId: "637028296510",
// appId: "1:637028296510:web:1cf398df9503e86497ae6f",
// measurementId: "G-79NTES2Y46"