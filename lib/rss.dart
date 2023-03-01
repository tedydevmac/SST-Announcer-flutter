import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:http/http.dart' as http;
import 'package:sst_announcer/announcement.dart';
import 'package:sst_announcer/settings.dart';
import 'package:sst_announcer/webview.dart';
import 'package:webfeed/webfeed.dart';
import 'package:html/parser.dart';

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
    setState(() {});
    print("starting fetch");
    final response = await http.get(Uri.parse(
        'http://studentsblog.sst.edu.sg/feeds/posts/default/?max-results=${SettingsScreen().numberOfPostsToFetch})'));
    if (response.statusCode == 200) {
      return AtomFeed.parse(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to fetch feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(SettingsScreen().numberOfPostsToFetch);
    print(
        "http://studentsblog.sst.edu.sg/feeds/posts/default/?max-results=${SettingsScreen().numberOfPostsToFetch})");
    setState(() {});
    return FutureBuilder<AtomFeed>(
      future: _futureFeed,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final feed = snapshot.data!;
          return ListView.separated(
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
                  maxLines: 2,
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
