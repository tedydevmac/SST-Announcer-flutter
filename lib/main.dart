import 'dart:typed_data';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sst_announcer/announcement.dart';
import 'package:sst_announcer/search.dart';
import 'package:sst_announcer/themes.dart';
import 'package:sst_announcer/categories/categories_list.dart';
import 'package:sst_announcer/categories/user_categories.dart';
import 'package:xml/xml.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
      home: HomePage(title: 'All announcements'),
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
      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Ink(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const Center(
                    child: Text("SST Announcer",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    thickness: 1,
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ExpansionTile(
                    clipBehavior: Clip.none,
                    title: Text(
                      "Categories",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      CategoryListPage(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                var navigator = Navigator.of(context);
                navigator.push(
                  CupertinoPageRoute(
                    builder: (context) {
                      return const AtomFeedSearchPage();
                    },
                  ),
                );
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Ink(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Expanded(child: FeedPage()),
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

  // Instantiate the cache manager
  final CacheManager _cacheManager = CacheManager(Config(
    'atomFeedCache',
    maxNrOfCacheObjects: 20,
    stalePeriod: const Duration(minutes: 30),
  ));

  Future<void> _refreshFeed() async {
    // Check if the feed is in the cache
    final cacheData = await _cacheManager.getSingleFile(
      'http://studentsblog.sst.edu.sg/feeds/posts/default',
    );

    // If the feed is not in the cache, fetch it and add it to the cache
    if (cacheData == null) {
      final response = await http.get(Uri.parse(
        'http://studentsblog.sst.edu.sg/feeds/posts/default',
      ));
      await _cacheManager.putFile(
        'http://studentsblog.sst.edu.sg/feeds/posts/default',
        Uint8List.fromList(response.bodyBytes),
      );
      _parseFeed(response.body);
    } else {
      _parseFeed(await cacheData.readAsString());
    }
  }

  // Parse the feed and update the state
  void _parseFeed(String responseBody) {
    final feedXml = XmlDocument.parse(responseBody);
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

  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshFeed();
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (isTop) {
          print('At the top');
        } else {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: ListView.separated(
          controller: _controller,
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
