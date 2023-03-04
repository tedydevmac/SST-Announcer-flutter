import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:sst_announcer/announcement.dart';
import 'package:webfeed/webfeed.dart';

class AtomFeedSearchPage extends StatefulWidget {
  const AtomFeedSearchPage({Key? key}) : super(key: key);

  @override
  _AtomFeedSearchPageState createState() => _AtomFeedSearchPageState();
}

class _AtomFeedSearchPageState extends State<AtomFeedSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late List<AtomItem> _feedItems;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _feedItems = [];
    _isLoading = false;
  }

  Future<void> _searchFeed() async {
    setState(() {
      _isLoading = true;
      _feedItems = [];
    });

    final response = await http
        .get(Uri.parse("http://studentsblog.sst.edu.sg/feeds/posts/default"));
    if (response.statusCode == 200) {
      final feed = AtomFeed.parse(response.body);
      final searchQuery = _searchController.text.trim().toLowerCase();
      final matchingItems = feed.items!
          .where((item) =>
              item.title?.toLowerCase().contains(searchQuery) ?? false)
          .toList();

      setState(() {
        _feedItems = matchingItems;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search for posts'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for announcements',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        _searchFeed();
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _feedItems.isEmpty
                        ? Center(child: Text('No items found'))
                        : ListView.builder(
                            itemCount: _feedItems.length,
                            itemBuilder: (context, index) {
                              final item = _feedItems[index];
                              return ListTile(
                                title: Text(item.title ?? ''),
                                subtitle: Text(
                                  "${parseFragment(item.content).text}",
                                  maxLines: 2,
                                ),
                                onTap: () {
                                  var navigator = Navigator.of(context);
                                  navigator.push(
                                    CupertinoPageRoute(
                                      builder: (context) {
                                        return AnnouncementPage(
                                            title: item.title,
                                            bodyText:
                                                "${parseFragment(item.content).text}");
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
