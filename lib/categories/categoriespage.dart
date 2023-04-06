
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sst_announcer/announcement.dart';
import 'package:sst_announcer/main.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class AddPostBotttomSheet extends StatefulWidget {
  final String customCategoryName;
  const AddPostBotttomSheet({super.key, required this.customCategoryName});

  @override
  State<AddPostBotttomSheet> createState() => _AddPostBotttomSheetState();
}

Map<String, List<xml.XmlElement>> customCatPosts = {};

Future<SharedPreferences> get _prefs async {
  return await SharedPreferences.getInstance();
}

Future<void> saveXmlDataList(List<String> xmlDataList) async {
  final SharedPreferences prefs = await _prefs;
  final xmlStrings = xmlDataList.map((xmlData) {
    final document = xml.XmlDocument.parse(xmlData);
    return document.toXmlString();
  }).toList();
  final xmlDataString = xmlStrings.join('\n');
  await prefs.setString('xml_data_list', xmlDataString);
}

Future<List<String>> getXmlDataList() async {
  final SharedPreferences prefs = await _prefs;
  final xmlDataString = prefs.getString('xml_data_list');
  if (xmlDataString == null) {
    return [];
  }
  final xmlStrings = xmlDataString.split('\n');
  final xmlDataList = xmlStrings.map((xmlString) {
    final document = xml.XmlDocument.parse(xmlString);
    return document.toXmlString();
  }).toList();
  return xmlDataList;
}

class _AddPostBotttomSheetState extends State<AddPostBotttomSheet> {
  bool _isLoading = true;
  bool isLoading = false;
  List<xml.XmlElement> _posts = [];
  Future<void> _fetchPosts() async {
    final response = await http.get(
      Uri.parse('http://studentsblog.sst.edu.sg/feeds/posts/default?'),
    );
    final body = response.body;
    final document = xml.XmlDocument.parse(body);
    final posts = document.findAllElements('entry').toList();
    setState(() {
      _posts = posts;
      _isLoading = !_isLoading;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final _controller = ScrollController();
    final navigator = Navigator.of(context);
    return Container(
      height: screenHeight * 0.75,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
      child: _isLoading == true
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: screenHeight * 0.726,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.separated(
                    separatorBuilder: (separatorContext, index) =>
                        const Divider(
                      color: Colors.grey,
                      thickness: 0.4,
                      height: 1,
                    ),
                    controller: _controller,
                    itemCount: _posts.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      final title = post.findElements('title').first.text;
                      final content =
                          parseFragment(post.findElements('content').first.text)
                              .text;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(6, 15, 6, 10),
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(
                            content!,
                            maxLines: 3,
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                              });
                              customCatPosts[widget.customCategoryName]
                                  ?.add(post);
                              postStreamController.add(PostStream.refreshPosts);
                              navigator.pop();
                            },
                            iconSize: 21.5,
                            icon: isLoading == true
                                ? const CircularProgressIndicator()
                                : const Icon(
                                    Icons.add,
                                    color: Color.fromARGB(255, 99, 99, 99),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

enum PostStream { refreshPosts }

class CategoryPage extends StatefulWidget {
  final String category;
  final bool isCustom;

  CategoryPage({required this.category, required this.isCustom});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

Future<AtomFeed> fetchAtomFeed() async {
  final response = await http
      .get(Uri.parse('http://studentsblog.sst.edu.sg/feeds/posts/default'));
  return AtomFeed.parse(response.body);
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<AtomFeed> _futureAtomFeed;
  void postStreamControllerListener(PostStream value) {
    switch (value) {
      case PostStream.refreshPosts:
        setState(() {});
        break;
      default:
    }
  }

  @override
  void initState() {
    for (String str in customCats) {
      customCatPosts[str] = [];
    }
    postStreamController.stream.listen(postStreamControllerListener);
    super.initState();
    _futureAtomFeed = fetchAtomFeed();
  }

  void showAddPostBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (bottomSheetContext) => AddPostBotttomSheet(
              customCategoryName: widget.category,
            ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      floatingActionButton: widget.isCustom == true
          ? FloatingActionButton.extended(
              onPressed: showAddPostBottomSheet,
              label: const Text("Add posts"),
              icon: const Icon(Icons.post_add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: widget.isCustom == true
          ? SafeArea(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: ListView.separated(
                        separatorBuilder: (separatorContext, index) =>
                            const Divider(
                          color: Colors.grey,
                          thickness: 0.4,
                          height: 1,
                        ),
                        shrinkWrap: true,
                        itemCount: customCatPosts[widget.category]?.length ?? 0,
                        itemBuilder: (context, index) {
                          final customCatPost =
                              customCatPosts[widget.category]![index];
                          final title =
                              customCatPost.findElements('title').first.text;
                          final content = parseFragment(customCatPost
                                  .findElements('content')
                                  .first
                                  .text)
                              .text;
                          return ListTile(
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
                            subtitle: Text(
                              content!,
                              maxLines: 2,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: FutureBuilder<AtomFeed>(
                      future: _futureAtomFeed,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final items = snapshot.data!.items!
                              .where((item) => item.categories!.any(
                                  (category) =>
                                      category.term == widget.category))
                              .toList();
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                            child: ListView.separated(
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return ListTile(
                                  onTap: () {
                                    var navigator = Navigator.of(context);
                                    navigator.push(
                                      CupertinoPageRoute(
                                        builder: (context) {
                                          return AnnouncementPage(
                                            title: item.title!,
                                            bodyText:
                                                parseFragment(item.content)
                                                    .text!,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  title: Text(item.title ?? ''),
                                  subtitle: Text(
                                    parseFragment(item.content).text!,
                                    maxLines: 2,
                                  ),
                                );
                              },
                              separatorBuilder: (separatorContext, index) =>
                                  const Divider(
                                color: Colors.grey,
                                thickness: 0.4,
                                height: 1,
                              ),
                              shrinkWrap: true,
                              itemCount: items.length,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        } else {}
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
