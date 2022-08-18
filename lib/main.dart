import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],
        textTheme: const TextTheme(
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Montserrat'),
        ),
      ),
      initialRoute: '/',
      routes: {
        _RandomWordsState.routeName: (context) => const RandomWords(),
        _EditPageState.routeName: (context) => const EditPage()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class EditPage extends StatefulWidget {
  const EditPage({Key? key}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class NewWordPair {
  String firstWord;
  String secondWord;

  getFirstWord() {
    return firstWord;
  }

  getSecondWord() {
    return secondWord;
  }

  mountPair() {
    return firstWord + secondWord;
  }

  NewWordPair(this.firstWord, this.secondWord);
}

class Repository {
  List wordsList = [];

  getAllList() {
    return wordsList;
  }

  getWordIndex(string) {
    return wordsList.indexOf(string);
  }

  insertWord(String element) {
    wordsList.add(element);
  }
}

class _EditPageState extends State<EditPage> {
  @override
  static const routeName = '/edit';

  Widget build(BuildContext context) {
    final wordArguments =
        (ModalRoute.of(context)?.settings.arguments ?? <int, String>{}) as Map;
    final edittingController =
        TextEditingController(text: wordArguments['currentWord'].toString());

    return Scaffold(
        appBar: AppBar(
          title: const Text('Startup Name Generator'),
        ),
        body: Column(children: [
          TextField(controller: edittingController),
          TextButton(
            child: const Text('Salvar Palavra'),
            onPressed: () {
              setState(() {
                wordArguments['wordsList'][wordArguments['wordsList']
                        .indexOf(wordArguments['currentWord'])] =
                    edittingController.text;

                Navigator.popAndPushNamed(context, '/');
              });
            },
          ),
        ]));
  }
}

class _RandomWordsState extends State<RandomWords> {
  final _saved = [];
  final repository = Repository();
  static const routeName = '/';
  bool _openned = true;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
            (pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: _pushSaved,
            tooltip: 'Saved Suggestions',
          ),
          IconButton(
            icon: const Icon(Icons.crop_square),
            onPressed: () {
              setState(() {
                _openned = !_openned;
              });
            },
          ),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    if (_openned) {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) {
            return const Divider();
          }

          final int index = i ~/ 2;

          if (index >= repository.getAllList().length) {
            repository
                .insertWord(NewWordPair(nouns[i], nouns[i + 1]).mountPair());
          }

          return _buildRow(repository.wordsList[index]);
        },
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 4),
        itemBuilder: (context, i) {
          if (i >= repository.getAllList().length) {
            repository
                .insertWord(NewWordPair(nouns[i], nouns[i + 1]).mountPair());
          }

          return Card(child: _buildRow(repository.wordsList[i]));
        },
      );
    }
  }

  Widget _buildRow(String pair) {
    final alreadySaved = _saved.contains(pair);

    return ListTile(
        title: Text(
          pair,
          style: _biggerFont,
        ),
        onTap: () {
          setState(() {
            Navigator.pushNamed(context, '/edit', arguments: {
              'wordsList': repository.getAllList(),
              'currentWord': pair
            });
          });
        },
        trailing: Container(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: alreadySaved
                      ? const Icon(Icons.favorite)
                      : const Icon(Icons.favorite_border),
                  color: alreadySaved ? Colors.red : null,
                  onPressed: () {
                    setState(() {
                      alreadySaved ? _saved.remove(pair) : _saved.add(pair);
                    });
                  },
                ),
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        repository.getAllList().remove(pair);
                        _saved.remove(pair);
                      });
                    })
              ],
            )));
  }
}
