import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class BlogFeedPage extends StatefulWidget {
  const BlogFeedPage({Key? key}) : super(key: key);

  @override
  _BlogFeedPageState createState() => _BlogFeedPageState();
}

class _BlogFeedPageState extends State<BlogFeedPage> {
  List<xml.XmlElement>? _posts;
  List<String>? _categories;
  String? _selectedCategory;
  String? _searchTerm;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final response = await http
        .get(Uri.parse('http://studentsblog.sst.edu.sg/feeds/posts/default'));
    final document = xml.XmlDocument.parse(response.body);
    final entries = document.findAllElements('entry').toList();
    final categories = entries
        .expand((entry) => entry.findElements('category'))
        .map((category) => category.getAttribute('term') ?? '')
        .toSet()
        .toList();
    setState(() {
      _posts = entries;
      _categories = categories;
      _selectedCategory = null;
      _searchTerm = null;
    });
  }

  List<xml.XmlElement>? _filterPosts() {
    var filteredPosts = _posts;
    if (_selectedCategory != null) {
      filteredPosts = filteredPosts
          ?.where((post) => post.findElements('category').any(
              (category) => category.getAttribute('term') == _selectedCategory))
          .toList();
    }
    if (_searchTerm != null && _searchTerm!.isNotEmpty) {
      filteredPosts = filteredPosts
          ?.where((post) =>
              post.findElements('title').any((title) => title.text
                  .toLowerCase()
                  .contains(_searchTerm!.toLowerCase())) ||
              post.findElements('content').any((content) => content.text
                  .toLowerCase()
                  .contains(_searchTerm!.toLowerCase())))
          .toList();
    }
    return filteredPosts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Feed'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search for posts...',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _searchTerm = value),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (_) => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 8),
                ...?_categories?.map((category) => ChoiceChip(
                      label: Text(category),
                      selected: category == _selectedCategory,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = category),
                    )),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _filterPosts()?.length,
              itemBuilder: (context, index) {
                final post = _filterPosts()![index];
                final title = post.findElements('title').first.text;
                final content = post.findElements('content').first.text;
                final author = post
                    .findElements('author')
                    .first
                    .findElements('name')
                    .first
                    .text;
                final published = post.findElements('published').first.text;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By $author on $published',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
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
