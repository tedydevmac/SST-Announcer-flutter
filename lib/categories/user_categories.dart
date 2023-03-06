import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
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

  Future<void> _saveToCategory(xml.XmlElement post, String category) async {
    // Check if the category already exists in the map
    if (_categories.containsKey(category)) {
      // If it does, add the post to the existing list of posts for the category
      setState(() {
        _categories[category]!.add(post);
      });
    } else {
      // If it doesn't, create a new list for the category and add the post to it
      setState(() {
        _categories[category] = [post];
      });
    }
  }

  Future<void> _refresh() async {
    final response = await http.get(Uri.parse(
        'http://studentsblog.sst.edu.sg/feeds/posts/default?max-results=$_numPosts'));
    final body = response.body;
    final document = xml.parse(body);
    final posts = document.findAllElements('entry').toList();
    setState(() {
      _posts = posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            final post = _posts[index];
            final title = post.findElements('title').first.text;
            final content =
                parseFragment(post.findElements('content').first.text).text;
            return ListTile(
              title: Text(title),
              subtitle: Text(
                content!,
                maxLines: 3,
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Text('Save to category'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Save to category'),
                              content: TextField(
                                controller: _categoryController,
                                decoration: InputDecoration(
                                  labelText: 'Category',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Save'),
                                  onPressed: () {
                                    final category = _categoryController.text;
                                    _saveToCategory(post, category);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ];
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.settings),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Settings'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _numPostsController,
                      decoration: InputDecoration(
                        labelText: 'Number of Posts',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(
                          () {
                            _numPosts = int.parse(_numPostsController.text);
                            _refresh();
                          },
                        );
                        Navigator.of(context).pop();
                      },
                      child: Text("Done"),
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
