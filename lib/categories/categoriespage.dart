import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
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

Map<String, List<xml.XmlElement>> customCatPosts = {
  for (var item in customCats)
    item: [
      xml.XmlElement(
        xml.XmlName('post'),
        [],
        [
          xml.XmlElement(
            xml.XmlName('title'),
            [],
            [
              xml.XmlText('Sample Post Title'),
            ],
          ),
          xml.XmlElement(
            xml.XmlName('content'),
            [],
            [
              xml.XmlText('Sample Post Content'),
            ],
          )
        ],
      ),
    ]
};

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
                              customCatPosts[widget.customCategoryName]!
                                  .add(post);
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

class _CategoryPageState extends State<CategoryPage> {
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
    postStreamController.stream.listen(postStreamControllerListener);
    super.initState();
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
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: ListView.separated(
                  separatorBuilder: (separatorContext, index) => const Divider(
                    color: Colors.grey,
                    thickness: 0.4,
                    height: 1,
                  ),
                  shrinkWrap: true,
                  itemCount: customCatPosts[widget.category]!.length,
                  itemBuilder: (context, index) {
                    final customCatPost =
                        customCatPosts[widget.category]![index];
                    final title =
                        customCatPost.findElements('title').first.text;
                    final content = parseFragment(
                            customCatPost.findElements('content').first.text)
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
                                isCustom:
                                    widget.isCustom == true ? true : false,
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
      ),
    );
  }
}
