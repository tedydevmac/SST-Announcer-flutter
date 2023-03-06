import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:sst_announcer/announcement.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;

Future<AtomFeed> fetchAtomFeed() async {
  final response = await http
      .get(Uri.parse('http://studentsblog.sst.edu.sg/feeds/posts/default'));
  return AtomFeed.parse(response.body);
}

class CategoryPage extends StatefulWidget {
  final String category;

  CategoryPage({required this.category});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<AtomFeed> _futureAtomFeed;

  @override
  void initState() {
    super.initState();
    _futureAtomFeed = fetchAtomFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.category),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: FutureBuilder<AtomFeed>(
                future: _futureAtomFeed,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final items = snapshot.data!.items!
                        .where((item) => item.categories!.any(
                            (category) => category.term == widget.category))
                        .toList();
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          onTap: () {
                            var navigator = Navigator.of(context);
                            navigator.push(
                              CupertinoPageRoute(
                                builder: (context) {
                                  return AnnouncementPage(
                                    title: item.title,
                                    bodyText: parseFragment(item.content).text!,
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
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            )
          ],
        ));
  }
}
