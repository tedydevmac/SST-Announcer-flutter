import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class RssItem {
  final String title;
  final String description;
  final String pubDate;
  final String link;

  RssItem({
    required this.title,
    required this.description,
    required this.pubDate,
    required this.link,
  });
}

class RssFeedPage extends StatefulWidget {
  @override
  _RssFeedPageState createState() => _RssFeedPageState();
}

class _RssFeedPageState extends State<RssFeedPage> {
  List<RssItem> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchRssFeed();
  }

  Future<void> _fetchRssFeed() async {
    final response = await http
        .get(Uri.parse('http://studentsblog.sst.edu.sg/feeds/posts/default'));
    final document = xml.XmlDocument.parse(response.body);
    final items = document.findAllElements('item');
    setState(() {
      _items = items.map((item) {
        return RssItem(
          title: item.findElements('title').single.text,
          description: item.findElements('description').single.text,
          pubDate: item.findElements('pubDate').single.text,
          link: item.findElements('link').single.text,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RSS Feed'),
      ),
      body: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          final item = _items[index];
          return ListTile(
            title: Text(item.title),
            subtitle: Text(item.description),
            trailing: Text(item.pubDate),
            onTap: () {
              // Handle item tap here
            },
          );
        },
      ),
    );
  }
}
