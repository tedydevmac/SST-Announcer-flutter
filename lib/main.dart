import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sst_announcer/announcement.dart';
import 'package:sst_announcer/search.dart';
import 'package:sst_announcer/settings.dart';
import 'package:sst_announcer/themes.dart';
import 'package:xml/xml.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SST Announcer',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: HomePage(title: 'Announcer'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.title});
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            var navigator = Navigator.of(context);
            navigator.push(CupertinoPageRoute(builder: (context) {
              return SettingsScreen();
            }));
          },
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                var navigator = Navigator.of(context);
                navigator.push(
                  CupertinoPageRoute(
                    builder: (context) {
                      return AtomFeedSearchPage();
                    },
                  ),
                );
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Ink(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Expanded(child: AtomFeedPage()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AtomFeedPage extends StatefulWidget {
  @override
  _AtomFeedPageState createState() => _AtomFeedPageState();
}

class _AtomFeedPageState extends State<AtomFeedPage> {
  List<String> _postTitles = [];
  List<String> _postContent = [];

  Future<void> _refreshFeed() async {
    final response = await http
        .get(Uri.parse('http://studentsblog.sst.edu.sg/feeds/posts/default'));
    final feedXml = XmlDocument.parse(response.body);
    final postContent = feedXml.findAllElements("entry").map((content) {
      return content.findElements("content").single.text;
    }).toList();
    final postTitles = feedXml.findAllElements('entry').map((entry) {
      return entry.findElements('title').single.text;
    }).toList();
    setState(() {
      _postTitles = postTitles;
      _postContent = postContent;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: _postTitles.length,
          itemBuilder: (context, index) {
            var bodyText = parseFragment(_postContent[index]).text;
            return Ink(
              child: ListTile(
                onTap: () {
                  var navigator = Navigator.of(context);
                  navigator.push(
                    CupertinoPageRoute(
                      builder: (context) {
                        return AnnouncementPage(
                            title: _postTitles[index], bodyText: bodyText);
                      },
                    ),
                  );
                },
                title: Text(_postTitles[index]),
                subtitle: Text(
                  bodyText!,
                  maxLines: 3,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
