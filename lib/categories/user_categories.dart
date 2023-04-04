import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sst_announcer/announcement.dart';
import 'package:xml/xml.dart' as xml;

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<String> pinnedTitles = [];
  List<String> pinnedContent = [];

  getTitleValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    pinnedTitles = prefs.getStringList("titles") ?? ["", "", ""];
    print(pinnedTitles);
  }

  getContentValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String

    pinnedContent = prefs.getStringList("content") ?? ["", "", ""];
    print(pinnedContent);
  }

  int _numPosts = 10;
  List<xml.XmlElement> _posts = [];

  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final response = await http.get(Uri.parse(
        'http://studentsblog.sst.edu.sg/feeds/posts/default?max-results=$_numPosts'));
    final body = response.body;
    final document = xml.XmlDocument.parse(body);
    final posts = document.findAllElements('entry').toList();
    setState(() {
      _posts = posts;
    });
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
    getTitleValues();
    getContentValues();
    print(pinnedTitles);
    print(pinnedContent);
    final navigator = Navigator.of(context);
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (isTop) {
          debugPrint('At the top');
        } else {
          setState(() {
            _numPosts += 10;
            debugPrint("reached bottom, adding more posts");
            _refresh();
            debugPrint("added posts successfully");
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
            final content =
                parseFragment(post.findElements('content').first.text).text;
            if (index < pinnedTitles.length) {
              return Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: ListTile(
                  onTap: () {
                    final navigator = Navigator.of(context);
                    navigator.push(
                      CupertinoPageRoute(
                        builder: (context) {
                          return AnnouncementPage(
                            title: pinnedTitles[index],
                            bodyText: pinnedContent[index],
                            isCustom: false,
                          );
                        },
                      ),
                    );
                  },
                  title: Text(pinnedTitles[index]),
                  subtitle: Text(
                    pinnedContent[index],
                    maxLines: 3,
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
                            isCustom: false,
                          );
                        },
                      ),
                    );
                  },
                  title: Text(title),
                  subtitle: Text(
                    content!,
                    maxLines: 3,
                  ),
                  trailing: IconButton(
                    onPressed: () async {
                      // saving pinned title values
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      getTitleValues();
                      pinnedTitles.insert(0, title);
                      if (pinnedTitles.length > 3) {
                        pinnedTitles.removeLast();
                      }

                      // saving pinned content values
                      getContentValues();
                      pinnedContent.insert(0, content);
                      if (pinnedContent.length > 3) {
                        pinnedContent.removeLast();
                      }
                      print("getting content: $content");
                      await prefs.setStringList('titles', pinnedTitles);
                      print("successfully saved titles");
                      print(
                          "fetching titles: ${prefs.getStringList('titles')}");
                      await prefs.setStringList('content', pinnedContent);
                      print("successfully saved content");
                      print(
                          "fetching content: ${prefs.getStringList('content')}");

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
