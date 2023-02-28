import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    final response = await http.get(Uri.parse(
        'http://studentsblog.sst.edu.sg/feeds/posts/default/?max-results=50'));
    print(AtomFeed.parse(utf8.decode(response.bodyBytes)));
    if (response.statusCode == 200) {
      return AtomFeed.parse(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to fetch feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AtomFeed>(
      future: _futureFeed,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final feed = snapshot.data!;
          return ListView.separated(
            itemCount: feed.items!.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              final item = feed.items![index];
              var bodyText = parseFragment(item.content ?? "").text;
              return ListTile(
                title: Text(item.title ?? ''),
                subtitle: Text(bodyText ?? ''),
                onTap: () {},
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
