import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class RssFeedScreen extends StatefulWidget {
  @override
  _RssFeedScreenState createState() => _RssFeedScreenState();
}

class _RssFeedScreenState extends State<RssFeedScreen> {
  List<xml.XmlElement> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchRssFeed();
  }

  Future<void> _fetchRssFeed() async {
    final response = await http
        .get(Uri.parse('http://studentsblog.sst.edu.sg/feeds/posts/default'));

    final document = xml.parse(response.body);
    final channel = document.findAllElements('channel').first;
    final items = channel.findElements('item').toList();

    setState(() {
      _items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RSS Feed'),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = _items[index];

          final title = item.findElements('title').single.text;
          final description = item.findElements('description').single.text;
          final pubDate = item.findElements('pubDate').single.text;

          return ListTile(
            title: Text(title),
            subtitle: Text(pubDate),
            onTap: () {
              // Do something when the tile is tapped
            },
          );
        },
      ),
    );
  }
}
