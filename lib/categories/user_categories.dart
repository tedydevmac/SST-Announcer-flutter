import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sst_announcer/announcement.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<String>? pinnedTitles = [];
  List<String>? pinnedContent = [];

  getSavedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    pinnedTitles = prefs.getStringList("titles") ?? ["", "", ""];
    pinnedContent = prefs.getStringList("content") ?? ["", "", ""];
  }

  /*getContentValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String

    pinnedContent = prefs.getStringList("content") ?? ["", "", ""];
    print(pinnedContent);
  }*/

  int _numPosts = 10;
  List<xml.XmlElement> _posts = [];

  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final url =
        'http://studentsblog.sst.edu.sg/feeds/posts/default?max-results=$_numPosts';
    final file = await DefaultCacheManager().getSingleFile(url);

    if (await file.exists()) {
      final document = xml.XmlDocument.parse(await file.readAsString());
      final posts = document.findAllElements('entry').toList();
      setState(() {
        _posts = posts;
      });
    } else {
      final response = await http.get(Uri.parse(url));
      final body = response.body;
      final document = xml.XmlDocument.parse(body);
      final posts = document.findAllElements('entry').toList();
      setState(() {
        _posts = posts;
      });
      await DefaultCacheManager()
          .putFile(url, Uint8List.fromList(utf8.encode(body)));
    }
  }

  Future<void> _refresh() async {
    final response = await http.get(Uri.parse(
        'http://studentsblog.sst.edu.sg/feeds/posts/default?max-results=$_numPosts'));
    final body = response.body;
    final document = xml.XmlDocument.parse(body);
    final posts = document.findAllElements('entry').toList();
    setState(() {
      _posts = posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    getSavedValues();

    final navigator = Navigator.of(context);
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (isTop) {
          debugPrint('At the top');
        } else {
          setState(() {
            _numPosts += 10;
            _refresh();
          });
        }
      }
    });
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.separated(
          separatorBuilder: (separatorContext, index) => const Divider(
            color: Colors.grey,
            thickness: 0.4,
            height: 1,
          ),
          controller: _controller,
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            final post = _posts[index];
            final title = post.findElements('title').first.text;
            final content = post.findElements('content').first.text;
            if (index < pinnedTitles!.length) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: ListTile(
                  onTap: () {
                    final navigator = Navigator.of(context);
                    navigator.push(
                      CupertinoPageRoute(
                        builder: (context) {
                          return AnnouncementPage(
                            title: pinnedTitles![index],
                            bodyText: pinnedContent![index],
                          );
                        },
                      ),
                    );
                  },
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pinned",
                        style: TextStyle(fontSize: 10),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(pinnedTitles![index]),
                    ],
                  ),
                  subtitle: Text(
                    parseFragment(pinnedContent![index]).text!,
                    maxLines: 3,
                  ),
                  trailing: IconButton(
                    onPressed: () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await getSavedValues();
                      pinnedTitles?.removeAt(index);
                      pinnedContent?.removeAt(index);
                      await prefs.setStringList('titles', pinnedTitles!);
                      await prefs.setStringList('content', pinnedContent!);

                      _refresh();
                    },
                    icon: const Icon(Icons.push_pin),
                    color: Colors.red,
                    iconSize: 21.5,
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: ListTile(
                  onTap: () {
                    var navigator = Navigator.of(context);
                    navigator.push(
                      CupertinoPageRoute(
                        builder: (context) {
                          return AnnouncementPage(
                            title: title,
                            bodyText: content,
                          );
                        },
                      ),
                    );
                  },
                  title: Text(title),
                  subtitle: Text(parseFragment(content).text!, maxLines: 3),
                  trailing: IconButton(
                    onPressed: () async {
                      // saving pinned title values
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      await getSavedValues();

                      pinnedTitles!.insert(0, title);
                      if (pinnedTitles!.length > 3) {
                        pinnedTitles!.removeLast();
                      }

                      // saving pinned content values
                      pinnedContent!.insert(0, content);
                      if (pinnedContent!.length > 3) {
                        pinnedContent!.removeLast();
                      }

                      await prefs.setStringList('titles', pinnedTitles!);
                      await prefs.setStringList('content', pinnedContent!);
                      _refresh();
                    },
                    iconSize: 21.5,
                    icon: const Icon(
                      Icons.push_pin,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
