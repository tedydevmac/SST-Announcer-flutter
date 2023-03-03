import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sst_announcer/search.dart';
import 'package:sst_announcer/settings.dart';
import 'package:sst_announcer/themes.dart';
import 'package:webfeed/domain/atom_feed.dart';

import 'announcement.dart';

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
                      return const Searchpage();
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
                Expanded(child: AtomFeedList()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AtomFeedList extends StatefulWidget {
  @override
  _AtomFeedListState createState() => _AtomFeedListState();
}

class _AtomFeedListState extends State<AtomFeedList> {
  late Future<AtomFeed> _futureFeed;
  @override
  void initState() {
    super.initState();
    _futureFeed = _fetchFeed();
  }

  Future<AtomFeed> _fetchFeed() async {
    print("starting fetch");
    final response = await http.get(Uri.parse(
        'http://studentsblog.sst.edu.sg/feeds/posts/default/?max-results=100'));
    if (response.statusCode == 200) {
      return AtomFeed.parse(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to fetch feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return FutureBuilder<AtomFeed>(
      future: _futureFeed,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final feed = snapshot.data!;
          return ListView.separated(
            shrinkWrap: true,
            clipBehavior: Clip.hardEdge,
            itemCount: feed.items!.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = feed.items![index];
              var bodyText = parseFragment(item.content ?? "").text;
              print(bodyText);
              return ListTile(
                title: Text(item.title ?? ''),
                subtitle: Text(
                  bodyText ?? "",
                  maxLines: 3,
                ),
                onTap: () {
                  var navigator = Navigator.of(context);
                  navigator.push(CupertinoPageRoute(builder: (context) {
                    return AnnouncementPage(
                        title: item.title, bodyText: bodyText);
                  }));
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
