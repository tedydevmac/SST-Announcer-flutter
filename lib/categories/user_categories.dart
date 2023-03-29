import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:sst_announcer/announcement.dart';
import 'package:sst_announcer/themes.dart';
import 'package:xml/xml.dart' as xml;

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _numPostsController = TextEditingController();
  int _numPosts = 10;
  List<xml.XmlElement> _posts = [];
  Map<String, List<xml.XmlElement>> _categories = {};

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
            if (index < 3) {
              return ListTile(
                onTap: () {
                  final navigator = Navigator.of(context);
                  navigator.push(
                    CupertinoPageRoute(
                      builder: (context) {
                        return AnnouncementPage(
                          title: title,
                          bodyText: content!,
                          position: index,
                        );
                      },
                    ),
                  );
                },
                title: Text("Pinned post $index"),
                subtitle: Text("Body text $index"),
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
                            position: index,
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
                    onPressed: () {},
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.settings),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Settings'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _numPostsController,
                      decoration: const InputDecoration(
                        labelText: 'Number of Posts',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(
                              () {
                                navigator.pop();
                                _numPosts = int.parse(_numPostsController.text);
                                _refresh();
                              },
                            );
                          },
                          style: filledButtonStyle,
                          child: const Text("Done"),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
