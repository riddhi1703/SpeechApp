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

class ShortStoryOptionsPage extends StatefulWidget {
  @override
  _ShortStoryOptionsPageState createState() => _ShortStoryOptionsPageState();
}

class _ShortStoryOptionsPageState extends State<ShortStoryOptionsPage> {
  bool isPlaying = false;
  QueryDocumentSnapshot? selectedStory; // Store the selected story here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Short Story Options'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isPlaying = false;
                selectedStory = null; // Reset the selected story when refreshed
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: fetchShortStories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Text('Error fetching short stories'),
            );
          }
          final List<QueryDocumentSnapshot> shortStories =
              snapshot.data!.docs; // Access the documents list from QuerySnapshot
          return ListView.builder(
            itemCount: shortStories.length,
            itemBuilder: (context, index) {
              final shortStory = shortStories[index];
              final data = shortStory.data() as Map<String, dynamic>?; // Cast to the correct type
              final title = data?['Title'] ?? 'Unknown Title';
              final author = data?['author'] ?? 'Unknown Author';
              return ListTile(
                title: Text(title),
                subtitle: Text(author),
                onTap: () {
                  setState(() {
                    selectedStory = shortStory; // Update the selected story
                    isPlaying = false; // Stop any ongoing reading when a new story is selected
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticlePage(selectedStory: selectedStory!),
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

  Future<QuerySnapshot> fetchShortStories() async {
    return FirebaseFirestore.instance.collection('short story').get();
  }
}

class ArticlePage extends StatefulWidget {
  final QueryDocumentSnapshot selectedStory;

  ArticlePage({required this.selectedStory});

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  FlutterTts flutterTts = FlutterTts();
  String articleText = '';
  bool isPlayingState = false;

  @override
  void initState() {
    super.initState();
    _loadStory();
  }

  void _loadStory() {
    final data = widget.selectedStory.data() as Map<String, dynamic>;
    setState(() {
      articleText = data['Description'] ?? '';
    });
  }

  Future<void> _speak() async {
    await flutterTts.stop();
    await flutterTts.speak(articleText);
    setState(() {
      isPlayingState = true;
    });
  }

  Future<void> _stop() async {
    await flutterTts.stop();
    setState(() {
      isPlayingState = false;
    });
  }

  void _toggleReading() {
    if (isPlayingState) {
      _stop();
    } else {
      _speak();
    }
  }

  @override
  void didUpdateWidget(ArticlePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedStory != oldWidget.selectedStory) {
      _stop();
      setState(() {
        isPlayingState = false;
      });
      _loadStory();
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.selectedStory['Title'] ?? '';
    final String author = widget.selectedStory['author'] ?? '';

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
              'Author: $author',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              'Title: $title',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  articleText,
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: _toggleReading,
                child: Text(isPlayingState ? 'Stop' : 'Read Aloud'),
              ),
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